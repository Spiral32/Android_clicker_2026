package com.progsettouch.app

import android.content.Context
import android.net.Uri
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.net.Inet4Address
import java.net.NetworkInterface
import java.net.ServerSocket
import java.net.Socket
import java.security.MessageDigest
import java.util.Base64
import java.util.Collections
import java.util.Locale
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean

class WebSocketServerManager private constructor(
    private val context: Context,
) {
    private val appContext = context.applicationContext
    private val logger = LogManager.getInstance(appContext)
    private val prefs = appContext.getSharedPreferences(flutterPrefsName, Context.MODE_PRIVATE)
    private val scenarioActionStore = ScenarioActionStore(appContext)
    private val running = AtomicBoolean(false)
    private val scenarioBatchRunning = AtomicBoolean(false)
    private val stopBatchRequested = AtomicBoolean(false)
    private val lock = Any()

    @Volatile
    private var serverSocket: ServerSocket? = null

    @Volatile
    private var acceptThread: Thread? = null

    @Volatile
    private var currentClientSocket: Socket? = null

    @Volatile
    private var currentClientAddress: String? = null

    @Volatile
    private var lastCommandAtMs: Long = 0L

    @Volatile
    private var lastError: String? = null

    @Volatile
    private var localAddressesCache: List<String> = emptyList()

    @Volatile
    private var localAddressesResolved = false

    @Volatile
    private var localAddressRefreshInProgress = false

    init {
        ensureTokenExists()
        refreshLocalAddressesAsync()
    }

    fun startIfEnabled() {
        if (isEnabled()) {
            startServer()
        }
    }

    fun getStatusMap(): Map<String, Any?> {
        val localAddresses = getLocalIpv4AddressesCached()
        val urls = buildUrls(localAddresses)
        return mapOf(
            "enabled" to isEnabled(),
            "running" to running.get(),
            "port" to getPort(),
            "token" to getToken(),
            "clientConnected" to (currentClientSocket?.isClosed == false),
            "clientAddress" to currentClientAddress,
            "lastCommandAtMs" to lastCommandAtMs,
            "transport" to "ws",
            "authMode" to "bearer_token_preferred",
            "path" to wsPath,
            "localAddresses" to localAddresses,
            "urls" to urls,
            "lastError" to lastError,
        )
    }

    fun setEnabled(enabled: Boolean): Boolean {
        prefs.edit().putBoolean(webSocketEnabledKey, enabled).apply()
        return if (enabled) {
            startServer()
        } else {
            stopServer()
            true
        }
    }

    fun setPort(port: Int): Boolean {
        if (port !in 1024..65535) {
            return false
        }

        val shouldRestart = running.get()
        prefs.edit().putInt(webSocketPortKey, port).apply()
        if (shouldRestart) {
            stopServer()
            if (isEnabled()) {
                return startServer()
            }
        }
        return true
    }

    fun regenerateToken(): String {
        val token = generateToken()
        prefs.edit().putString(webSocketTokenKey, token).apply()
        if (running.get()) {
            logger.i("WebSocketServer", "Token rotated while server is running")
        }
        return token
    }

    fun startServer(): Boolean {
        synchronized(lock) {
            if (running.get()) {
                return true
            }

            return try {
                val socket = ServerSocket(getPort()).apply {
                    reuseAddress = true
                }
                serverSocket = socket
                running.set(true)
                lastError = null
                acceptThread = Thread(::acceptLoop, "WebSocketAcceptThread").apply {
                    isDaemon = true
                    start()
                }
                refreshLocalAddressesAsync()
                logger.i("WebSocketServer", "Server started on port ${getPort()}")
                true
            } catch (error: Exception) {
                lastError = error.message ?: error.javaClass.simpleName
                logger.e("WebSocketServer", "Failed to start server", error)
                running.set(false)
                serverSocket = null
                false
            }
        }
    }

    fun stopServer() {
        synchronized(lock) {
            running.set(false)
            try {
                currentClientSocket?.close()
            } catch (_: Exception) {
            }
            currentClientSocket = null
            currentClientAddress = null

            try {
                serverSocket?.close()
            } catch (_: Exception) {
            }
            serverSocket = null
            acceptThread = null
            logger.i("WebSocketServer", "Server stopped")
        }
    }

    private fun acceptLoop() {
        while (running.get()) {
            val client = try {
                serverSocket?.accept()
            } catch (_: Exception) {
                if (!running.get()) {
                    return
                }
                lastError = "accept_failed"
                continue
            } ?: continue

            val hasClient = synchronized(lock) {
                currentClientSocket?.isClosed == false
            }
            if (hasClient) {
                rejectHttp(client, "409 Conflict", "Only one active client is supported.")
                continue
            }

            Thread(
                { handleClient(client) },
                "WebSocketClientThread",
            ).apply {
                isDaemon = true
                start()
            }
        }
    }

    private fun handleClient(socket: Socket) {
        synchronized(lock) {
            currentClientSocket = socket
            currentClientAddress = socket.inetAddress?.hostAddress
        }

        logger.i("WebSocketServer", "Incoming client ${currentClientAddress ?: "unknown"}")

        try {
            if (!performHandshake(socket)) {
                return
            }

            sendJson(
                socket,
                successResponse(
                    id = null,
                    result = JSONObject().apply {
                        put("message", "connected")
                        put("server", toJsonValue(getStatusMap()))
                    },
                ),
            )

            val input = socket.getInputStream()
            while (running.get() && !socket.isClosed) {
                val frame = readFrame(input) ?: break
                when (frame.opcode) {
                    0x1 -> handleTextFrame(socket, String(frame.payload, Charsets.UTF_8))
                    0x8 -> {
                        sendFrame(socket, 0x8, ByteArray(0))
                        break
                    }
                    0x9 -> sendFrame(socket, 0xA, frame.payload)
                }
            }
        } catch (error: Exception) {
            lastError = error.message ?: error.javaClass.simpleName
            logger.e("WebSocketServer", "Client handling failed", error)
        } finally {
            try {
                socket.close()
            } catch (_: Exception) {
            }
            synchronized(lock) {
                if (currentClientSocket == socket) {
                    currentClientSocket = null
                    currentClientAddress = null
                }
            }
            logger.i("WebSocketServer", "Client disconnected")
        }
    }

    private fun performHandshake(socket: Socket): Boolean {
        val request = readHttpRequest(socket.getInputStream()) ?: run {
            rejectHttp(socket, "400 Bad Request", "Invalid handshake request.")
            return false
        }

        val lines = request.split("\r\n")
        val requestLine = lines.firstOrNull().orEmpty()
        val requestParts = requestLine.split(' ')
        if (requestParts.size < 2) {
            rejectHttp(socket, "400 Bad Request", "Malformed request line.")
            return false
        }
        if (!requestParts[0].equals("GET", ignoreCase = true)) {
            rejectHttp(socket, "405 Method Not Allowed", "WebSocket handshake requires GET.")
            return false
        }

        val target = requestParts[1]
        val headers = mutableMapOf<String, String>()
        for (line in lines.drop(1)) {
            if (line.isBlank()) {
                break
            }
            val separator = line.indexOf(':')
            if (separator > 0) {
                headers[line.substring(0, separator).trim().lowercase(Locale.US)] =
                    line.substring(separator + 1).trim()
            }
        }

        val uri = Uri.parse("ws://localhost$target")
        if (uri.path != wsPath) {
            rejectHttp(socket, "404 Not Found", "Unsupported WebSocket path.")
            return false
        }

        val upgradeHeader = headers["upgrade"]?.lowercase(Locale.US)
        if (upgradeHeader != "websocket") {
            rejectHttp(socket, "400 Bad Request", "Missing Upgrade: websocket header.")
            return false
        }

        val connectionHeader = headers["connection"]?.lowercase(Locale.US).orEmpty()
        if (!connectionHeader.contains("upgrade")) {
            rejectHttp(socket, "400 Bad Request", "Missing Connection: Upgrade header.")
            return false
        }

        val protocolVersion = headers["sec-websocket-version"]?.trim()
        if (protocolVersion != "13") {
            rejectHttp(socket, "426 Upgrade Required", "Only Sec-WebSocket-Version: 13 is supported.")
            return false
        }

        val bearerToken = extractBearerToken(headers["authorization"])
        val queryToken = uri.getQueryParameter("token")
        val token = bearerToken ?: queryToken
        if (token.isNullOrBlank() || !isTokenValid(token)) {
            rejectHttp(socket, "401 Unauthorized", "Invalid token.")
            return false
        }

        val webSocketKey = headers["sec-websocket-key"]
        if (webSocketKey.isNullOrBlank()) {
            rejectHttp(socket, "400 Bad Request", "Missing Sec-WebSocket-Key.")
            return false
        }

        val acceptKey = buildAcceptKey(webSocketKey)
        val response = buildString {
            append("HTTP/1.1 101 Switching Protocols\r\n")
            append("Upgrade: websocket\r\n")
            append("Connection: Upgrade\r\n")
            append("Sec-WebSocket-Accept: ")
            append(acceptKey)
            append("\r\n\r\n")
        }
        socket.getOutputStream().write(response.toByteArray(Charsets.UTF_8))
        socket.getOutputStream().flush()
        logger.i("WebSocketServer", "Handshake completed for ${currentClientAddress ?: "unknown"}")
        return true
    }

    private fun handleTextFrame(socket: Socket, text: String) {
        val response = try {
            val request = JSONObject(text)
            val id = request.opt("id")
            val command = request.optString("command").lowercase(Locale.US)
            val args = request.optJSONObject("args")
            lastCommandAtMs = System.currentTimeMillis()

            when (command) {
                "ping" -> successResponse(
                    id = id,
                    result = JSONObject().apply {
                        put("message", "pong")
                        put("serverTimeMs", System.currentTimeMillis())
                    },
                )
                "status" -> successResponse(
                    id = id,
                    result = JSONObject().apply {
                        put("server", toJsonValue(getStatusMap()))
                        put("app", buildAppSnapshot())
                    },
                )
                "get_log" -> successResponse(
                    id = id,
                    result = JSONObject().apply {
                        val maxChars = args?.optInt("maxChars", 20000) ?: 20000
                        put("logs", logger.getLogsForDisplay(maxChars.coerceIn(1000, 50000)))
                        put("source", logger.getLogSourceForDisplay())
                    },
                )
                "start" -> startExecutionResponse(id, args)
                "start_single" -> startSingleScenarioResponse(id, args)
                "start_batch" -> startBatchResponse(id, args)
                "get_scenarios" -> getScenariosResponse(id)
                "stop" -> stopExecutionResponse(id)
                "upload_script" -> errorResponse(
                    id = id,
                    code = "not_implemented",
                    message = "upload_script is not implemented in Stage 9 foundation.",
                )
                else -> errorResponse(
                    id = id,
                    code = "unknown_command",
                    message = "Unsupported command: $command",
                )
            }
        } catch (error: Exception) {
            errorResponse(
                id = null,
                code = "invalid_json",
                message = error.message ?: "Failed to parse request.",
            )
        }

        sendJson(socket, response)
    }

    private fun startExecutionResponse(id: Any?, args: JSONObject?): JSONObject {
        val service = ProgSetAccessibilityService.instance
            ?: return errorResponse(
                id = id,
                code = "service_unavailable",
                message = "Accessibility service is not connected.",
            )

        val currentState = service.getCurrentState()["state"]?.toString()
        if (currentState == "EXECUTING") {
            return errorResponse(
                id = id,
                code = "execution_busy",
                message = "Execution is already in progress. Parallel execution is not allowed.",
                details = JSONObject().apply {
                    put("state", currentState)
                },
            )
        }

        val delayMs = if (args?.has("delayMs") == true) args.optInt("delayMs") else null
        val summary = service.startExecution(delayMs)
        return if (!summary.isExecuting) {
            errorResponse(
                id = id,
                code = "execution_start_failed",
                message = summary.error ?: "Execution did not start.",
                details = JSONObject(summary.toMap()),
            )
        } else {
            successResponse(id = id, result = JSONObject(summary.toMap()))
        }
    }

    private fun startSingleScenarioResponse(id: Any?, args: JSONObject?): JSONObject {
        val service = ProgSetAccessibilityService.instance
            ?: return errorResponse(
                id = id,
                code = "service_unavailable",
                message = "Accessibility service is not connected.",
            )

        if (isExecutionBusy(service)) {
            return busyExecutionResponse(id, service.getCurrentState()["state"]?.toString())
        }

        val scenarioId = args?.optString("scenarioId")?.trim().orEmpty()
        if (scenarioId.isBlank()) {
            return errorResponse(
                id = id,
                code = "invalid_argument",
                message = "scenarioId is required for start_single.",
            )
        }

        val delayMs = args?.optIntOrNull("delayMs")
        val summary = service.startScenarioExecution(scenarioId, delayMs)
        return if (!summary.isExecuting) {
            errorResponse(
                id = id,
                code = "execution_start_failed",
                message = summary.error ?: "Scenario execution did not start.",
                details = JSONObject(summary.toMap()).apply {
                    put("scenarioId", scenarioId)
                },
            )
        } else {
            successResponse(
                id = id,
                result = JSONObject(summary.toMap()).apply {
                    put("mode", "single")
                    put("scenarioId", scenarioId)
                },
            )
        }
    }

    private fun startBatchResponse(id: Any?, args: JSONObject?): JSONObject {
        val service = ProgSetAccessibilityService.instance
            ?: return errorResponse(
                id = id,
                code = "service_unavailable",
                message = "Accessibility service is not connected.",
            )

        if (isExecutionBusy(service)) {
            return busyExecutionResponse(id, service.getCurrentState()["state"]?.toString())
        }

        val scenarioIds = parseScenarioIdsForBatch(args)
        if (scenarioIds.isEmpty()) {
            return errorResponse(
                id = id,
                code = "invalid_argument",
                message = "scenarioIds must contain at least one id for start_batch.",
            )
        }

        if (!scenarioBatchRunning.compareAndSet(false, true)) {
            return errorResponse(
                id = id,
                code = "execution_busy",
                message = "A batch execution is already in progress.",
            )
        }

        stopBatchRequested.set(false)
        val delayMs = args?.optIntOrNull("delayMs")
        Thread(
            {
                try {
                    runBatchExecution(service, scenarioIds, delayMs)
                } finally {
                    scenarioBatchRunning.set(false)
                    stopBatchRequested.set(false)
                }
            },
            "WebSocketScenarioBatchThread",
        ).apply {
            isDaemon = true
            start()
        }

        return successResponse(
            id = id,
            result = JSONObject().apply {
                put("mode", "batch")
                put("accepted", true)
                put("total", scenarioIds.size)
                put("scenarioIds", JSONArray(scenarioIds))
            },
        )
    }

    private fun runBatchExecution(
        service: ProgSetAccessibilityService,
        scenarioIds: List<String>,
        delayMs: Int?,
    ) {
        logger.i("WebSocketServer", "Batch execution started for ${scenarioIds.size} scenarios")
        val results = JSONArray()
        scenarioIds.forEach { scenarioId ->
            if (stopBatchRequested.get()) {
                logger.i("WebSocketServer", "Batch execution stop requested before scenarioId=$scenarioId")
                return@forEach
            }

            val summary = service.startScenarioExecution(scenarioId, delayMs)
            if (!summary.isExecuting) {
                logger.i(
                    "WebSocketServer",
                    "Batch scenario skipped scenarioId=$scenarioId reason=${summary.error ?: "start_failed"}",
                )
                results.put(
                    JSONObject().apply {
                        put("scenarioId", scenarioId)
                        put("ok", false)
                        put("error", summary.error ?: "execution_start_failed")
                    },
                )
                return@forEach
            }

            waitUntilExecutionStops(service)
            val finalSummary = service.executionSummary()
            val hasError = !finalSummary.error.isNullOrBlank() || finalSummary.failedActions > 0
            results.put(
                JSONObject().apply {
                    put("scenarioId", scenarioId)
                    put("ok", !hasError)
                    put("summary", JSONObject(finalSummary.toMap()))
                },
            )
        }

        logger.i("WebSocketServer", "Batch execution completed results=$results")
    }

    private fun getScenariosResponse(id: Any?): JSONObject {
        val scenarios = loadStoredScenarios()
        return successResponse(
            id = id,
            result = JSONObject().apply {
                put("total", scenarios.length())
                put("scenarios", scenarios)
            },
        )
    }

    private fun stopExecutionResponse(id: Any?): JSONObject {
        val service = ProgSetAccessibilityService.instance
            ?: return errorResponse(
                id = id,
                code = "service_unavailable",
                message = "Accessibility service is not connected.",
            )
        stopBatchRequested.set(true)
        return successResponse(id = id, result = JSONObject(service.stopExecution().toMap()))
    }

    private fun busyExecutionResponse(id: Any?, state: String?): JSONObject {
        return errorResponse(
            id = id,
            code = "execution_busy",
            message = "Execution is already in progress. Parallel execution is not allowed.",
            details = JSONObject().apply {
                put("state", state ?: "unknown")
                put("batchRunning", scenarioBatchRunning.get())
            },
        )
    }

    private fun isExecutionBusy(service: ProgSetAccessibilityService): Boolean {
        val currentState = service.getCurrentState()["state"]?.toString()
        return currentState == "EXECUTING" || scenarioBatchRunning.get()
    }

    private fun waitUntilExecutionStops(service: ProgSetAccessibilityService) {
        while (running.get() && !stopBatchRequested.get()) {
            val status = service.executionSummary()
            if (!status.isExecuting) {
                return
            }
            Thread.sleep(300)
        }
    }

    private fun parseScenarioIdsForBatch(args: JSONObject?): List<String> {
        val source = args?.optJSONArray("scenarioIds") ?: return emptyList()
        val ids = mutableListOf<String>()
        for (index in 0 until source.length()) {
            val value = source.optString(index).trim()
            if (value.isNotBlank()) {
                ids += value
            }
        }
        return ids
    }

    private fun loadStoredScenarios(): JSONArray {
        val rawList = prefs.getString(flutterScenarioItemsKey, null)
        val entries = decodeFlutterStringList(rawList)
        val items = mutableListOf<JSONObject>()
        entries.forEach { encoded ->
            try {
                val item = JSONObject(encoded)
                val scenarioId = item.optString("id").trim()
                if (scenarioId.isBlank()) {
                    return@forEach
                }
                val actionCount = scenarioActionStore.getScenarioActions(scenarioId).size
                item.put("hasActions", actionCount > 0)
                item.put("actionCount", actionCount)
                items += item
            } catch (_: Exception) {
                // ignore malformed entries
            }
        }
        if (items.isEmpty()) {
            scenarioActionStore.getStoredScenarioIds().forEach { scenarioId ->
                val actionCount = scenarioActionStore.getScenarioActions(scenarioId).size
                items += JSONObject().apply {
                    put("id", scenarioId)
                    put("name", scenarioId)
                    put("orderIndex", Int.MAX_VALUE)
                    put("stepCount", actionCount)
                    put("quickLaunchEnabled", false)
                    put("isEnabled", true)
                    put("hasActions", actionCount > 0)
                    put("actionCount", actionCount)
                    put("source", "native_fallback")
                }
            }
        }

        items.sortBy { it.optInt("orderIndex", Int.MAX_VALUE) }
        return JSONArray(items)
    }

    private fun decodeFlutterStringList(raw: String?): List<String> {
        if (raw.isNullOrBlank()) {
            return emptyList()
        }
        val payload = if (raw.startsWith(flutterStringListPrefix)) {
            raw.removePrefix(flutterStringListPrefix)
        } else {
            raw
        }
        return try {
            val parsed = JSONArray(payload)
            buildList {
                for (index in 0 until parsed.length()) {
                    val value = parsed.optString(index)
                    if (value.isNotBlank()) {
                        add(value)
                    }
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun buildAppSnapshot(): JSONObject {
        val service = ProgSetAccessibilityService.instance
        return JSONObject().apply {
            put("serviceConnected", service != null)
            put("timestampMs", System.currentTimeMillis())
            if (service != null) {
                put("appState", JSONObject(service.getCurrentState()))
                put("execution", JSONObject(service.executionSummary().toMap()))
                put("recorder", JSONObject(service.recorderSummary().toMap()))
                put("overlayVisible", service.isOverlayVisible())
                put("mediaProjectionReady", service.hasMediaProjection())
            }
        }
    }

    private fun successResponse(id: Any?, result: JSONObject): JSONObject {
        return JSONObject().apply {
            if (id != null && id != JSONObject.NULL) {
                put("id", id)
            }
            put("ok", true)
            put("result", result)
        }
    }

    private fun errorResponse(
        id: Any?,
        code: String,
        message: String,
        details: JSONObject? = null,
    ): JSONObject {
        return JSONObject().apply {
            if (id != null && id != JSONObject.NULL) {
                put("id", id)
            }
            put("ok", false)
            put(
                "error",
                JSONObject().apply {
                    put("code", code)
                    put("message", message)
                    if (details != null) {
                        put("details", details)
                    }
                },
            )
        }
    }

    private fun sendJson(socket: Socket, payload: JSONObject) {
        sendFrame(socket, 0x1, payload.toString().toByteArray(Charsets.UTF_8))
    }

    private fun sendFrame(socket: Socket, opcode: Int, payload: ByteArray) {
        val output = socket.getOutputStream()
        output.write(0x80 or (opcode and 0x0F))
        when {
            payload.size <= 125 -> output.write(payload.size)
            payload.size <= 65535 -> {
                output.write(126)
                output.write((payload.size shr 8) and 0xFF)
                output.write(payload.size and 0xFF)
            }
            else -> {
                output.write(127)
                var length = payload.size.toLong()
                val bytes = ByteArray(8)
                for (index in 7 downTo 0) {
                    bytes[index] = (length and 0xFF).toByte()
                    length = length shr 8
                }
                output.write(bytes)
            }
        }
        output.write(payload)
        output.flush()
    }

    private fun readFrame(input: InputStream): WebSocketFrame? {
        val first = input.read()
        if (first == -1) {
            return null
        }
        val second = input.read()
        if (second == -1) {
            return null
        }

        val opcode = first and 0x0F
        val masked = (second and 0x80) != 0
        var length = (second and 0x7F).toLong()

        if (length == 126L) {
            length = ((input.read() and 0xFF) shl 8 or (input.read() and 0xFF)).toLong()
        } else if (length == 127L) {
            length = 0L
            repeat(8) {
                length = (length shl 8) or (input.read().toLong() and 0xFF)
            }
        }
        if (length > maxIncomingFrameBytes) {
            throw IllegalArgumentException("Frame is too large: $length")
        }

        // Client-to-server frames must be masked by RFC6455.
        if (!masked) {
            throw IllegalArgumentException("Client frame must be masked")
        }

        val mask = if (masked) readExactly(input, 4) else null
        val payload = readExactly(input, length.toInt())
        if (mask != null) {
            for (index in payload.indices) {
                payload[index] = (payload[index].toInt() xor mask[index % 4].toInt()).toByte()
            }
        }

        return WebSocketFrame(opcode = opcode, payload = payload)
    }

    private fun readExactly(input: InputStream, length: Int): ByteArray {
        val buffer = ByteArray(length)
        var offset = 0
        while (offset < length) {
            val read = input.read(buffer, offset, length - offset)
            if (read == -1) {
                throw IllegalStateException("Unexpected end of stream")
            }
            offset += read
        }
        return buffer
    }

    private fun readHttpRequest(input: InputStream): String? {
        val buffer = ByteArrayOutputStream()
        var state = 0
        while (buffer.size() < 8192) {
            val next = input.read()
            if (next == -1) {
                return null
            }
            buffer.write(next)
            state = when {
                state == 0 && next == '\r'.code -> 1
                state == 1 && next == '\n'.code -> 2
                state == 2 && next == '\r'.code -> 3
                state == 3 && next == '\n'.code -> 4
                next == '\r'.code -> 1
                else -> 0
            }
            if (state == 4) {
                return buffer.toString(Charsets.UTF_8.name())
            }
        }
        return null
    }

    private fun rejectHttp(socket: Socket, status: String, message: String) {
        try {
            val body = message.toByteArray(Charsets.UTF_8)
            val response = buildString {
                append("HTTP/1.1 ")
                append(status)
                append("\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: ")
                append(body.size)
                append("\r\nConnection: close\r\n\r\n")
                append(message)
            }
            socket.getOutputStream().write(response.toByteArray(Charsets.UTF_8))
            socket.getOutputStream().flush()
        } catch (_: Exception) {
        } finally {
            try {
                socket.close()
            } catch (_: Exception) {
            }
        }
    }

    private fun buildAcceptKey(webSocketKey: String): String {
        val digest = MessageDigest.getInstance("SHA-1")
        val raw = digest.digest((webSocketKey + webSocketGuid).toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(raw)
    }

    private fun ensureTokenExists(): String {
        val existing = prefs.getString(webSocketTokenKey, null)
        if (!existing.isNullOrBlank()) {
            return existing
        }
        val generated = generateToken()
        prefs.edit().putString(webSocketTokenKey, generated).apply()
        return generated
    }

    private fun generateToken(): String = UUID.randomUUID().toString().replace("-", "")

    private fun isEnabled(): Boolean = prefs.getBoolean(webSocketEnabledKey, false)

    private fun getPort(): Int = prefs.getInt(webSocketPortKey, defaultPort)

    private fun getToken(): String = ensureTokenExists()

    private fun isTokenValid(candidate: String): Boolean {
        val expected = getToken().toByteArray(Charsets.UTF_8)
        val actual = candidate.toByteArray(Charsets.UTF_8)
        return MessageDigest.isEqual(expected, actual)
    }

    private fun buildUrls(localAddresses: List<String>): List<String> {
        val port = getPort()
        return localAddresses.map { address ->
            "ws://$address:$port$wsPath"
        }
    }

    private fun extractBearerToken(authorizationHeader: String?): String? {
        if (authorizationHeader.isNullOrBlank()) {
            return null
        }
        val prefix = "Bearer "
        if (!authorizationHeader.startsWith(prefix, ignoreCase = true)) {
            return null
        }
        val token = authorizationHeader.substring(prefix.length).trim()
        return token.ifBlank { null }
    }

    private fun getLocalIpv4AddressesCached(): List<String> {
        if (!localAddressesResolved) {
            refreshLocalAddressesAsync()
        }
        return localAddressesCache
    }

    private fun refreshLocalAddressesAsync() {
        val shouldStart = synchronized(lock) {
            if (localAddressRefreshInProgress) {
                false
            } else {
                localAddressRefreshInProgress = true
                true
            }
        }
        if (!shouldStart) {
            return
        }

        Thread(
            {
                val resolved = resolveLocalIpv4Addresses()
                synchronized(lock) {
                    localAddressesCache = resolved
                    localAddressesResolved = true
                    localAddressRefreshInProgress = false
                }
            },
            "WebSocketAddressResolver",
        ).apply {
            isDaemon = true
            start()
        }
    }

    private fun resolveLocalIpv4Addresses(): List<String> {
        return try {
            Collections.list(NetworkInterface.getNetworkInterfaces())
                .filter { network -> network.isUp && !network.isLoopback && !network.isVirtual }
                .flatMap { network ->
                    Collections.list(network.inetAddresses)
                        .filterIsInstance<Inet4Address>()
                        .filterNot { it.isLoopbackAddress }
                        .map { it.hostAddress.orEmpty() }
                }
                .filter { it.isNotBlank() }
                .distinct()
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun toJsonValue(value: Any?): Any {
        return when (value) {
            null -> JSONObject.NULL
            is Map<*, *> -> JSONObject().apply {
                value.forEach { (key, nestedValue) ->
                    if (key != null) {
                        put(key.toString(), toJsonValue(nestedValue))
                    }
                }
            }
            is List<*> -> JSONArray().apply {
                value.forEach { put(toJsonValue(it)) }
            }
            else -> value
        }
    }

    companion object {
        private const val flutterPrefsName = "FlutterSharedPreferences"
        private const val webSocketEnabledKey = "flutter.websocket_enabled"
        private const val webSocketPortKey = "flutter.websocket_port"
        private const val webSocketTokenKey = "flutter.websocket_token"
        private const val flutterScenarioItemsKey = "flutter.scenario_items_v1"
        private const val flutterStringListPrefix = "This is the prefix for a list."
        private const val defaultPort = 8787
        private const val wsPath = "/ws"
        private const val webSocketGuid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
        private const val maxIncomingFrameBytes = 512 * 1024

        @Volatile
        private var instance: WebSocketServerManager? = null

        fun getInstance(context: Context): WebSocketServerManager {
            return instance ?: synchronized(this) {
                instance ?: WebSocketServerManager(context.applicationContext).also { instance = it }
            }
        }
    }
}

private data class WebSocketFrame(
    val opcode: Int,
    val payload: ByteArray,
)

private fun JSONObject.optIntOrNull(key: String): Int? {
    return if (has(key)) {
        try {
            optInt(key)
        } catch (_: Exception) {
            null
        }
    } else {
        null
    }
}
