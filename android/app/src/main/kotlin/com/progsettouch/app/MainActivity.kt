package com.progsettouch.app

import android.app.Activity
import android.app.DownloadManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.Locale

class MainActivity : FlutterFragmentActivity() {

    /** Must match [onActivityResult] handling for screen capture consent. */
    private val mediaProjectionRequestCode = 0x4d50 // "MP"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        android.util.Log.d("MainActivity", "onCreate called")
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        android.util.Log.d("MainActivity", "onNewIntent called")
        setIntent(intent)
        handleIntent(intent)
        scheduleMediaProjectionAutoRequestIfPending("onNewIntent")
    }

    /** Single post for onNewIntent + onResume so we do not queue two triggers in one frame. */
    private fun scheduleMediaProjectionAutoRequestIfPending(source: String) {
        if (!shouldAutoRequestMediaProjection) return
        if (mediaProjectionAutoPostScheduled) return
        mediaProjectionAutoPostScheduled = true
        LogManager.getInstance(this).i(
            "MainActivity",
            "$source: scheduling auto MediaProjection consent (single queued post)",
        )
        window.decorView.post {
            mediaProjectionAutoPostScheduled = false
            triggerMediaProjectionRequest()
        }
    }

    private fun handleIntent(intent: Intent?) {
        val hasExtra = intent?.hasExtra("requestMediaProjection") == true
        val value = intent?.getBooleanExtra("requestMediaProjection", false) == true
        android.util.Log.d("MainActivity", "handleIntent: hasExtra=$hasExtra, value=$value")
        if (value) {
            android.util.Log.d("MainActivity", "handleIntent: scheduling auto-request")
            shouldAutoRequestMediaProjection = true
            intent.removeExtra("requestMediaProjection")
        }
    }
    
    private fun triggerMediaProjectionRequest() {
        val log = LogManager.getInstance(this)
        log.i("MainActivity", "triggerMediaProjectionRequest: entered")
        shouldAutoRequestMediaProjection = false

        val service = ProgSetAccessibilityService.instance
        if (service?.isScreenCaptureProjectionReady() == true) {
            log.i("MainActivity", "triggerMediaProjectionRequest: verifier already ready, skip")
            return
        }

        val cached = peekCachedMediaProjection()
        if (cached != null && service != null) {
            log.i("MainActivity", "triggerMediaProjectionRequest: attaching cached token to service")
            service.setMediaProjection(cached)
            try {
                MediaProjectionForegroundService.start(this)
            } catch (e: Exception) {
                log.e("MainActivity", "MediaProjectionForegroundService.start failed", e)
            }
            return
        }

        if (isMediaProjectionRequestInFlight) {
            log.w("MainActivity", "triggerMediaProjectionRequest: request already in flight")
            return
        }

        val projectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager
        if (projectionManager == null) {
            log.e("MainActivity", "triggerMediaProjectionRequest: MediaProjectionManager null", null)
            return
        }
        if (isFinishing || isDestroyed) {
            log.w("MainActivity", "triggerMediaProjectionRequest: activity finishing/destroyed")
            return
        }

        try {
            isMediaProjectionRequestInFlight = true
            val captureIntent = projectionManager.createScreenCaptureIntent()
            log.i("MainActivity", "triggerMediaProjectionRequest: launching system capture consent (startActivityForResult)")
            startActivityForResult(captureIntent, mediaProjectionRequestCode)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to launch MediaProjection consent", e)
            log.e("MainActivity", "Failed to launch MediaProjection consent", e)
            isMediaProjectionRequestInFlight = false
        }
    }
    private val channelName = "prog_set_touch/platform"
    private val flutterPrefsName = "FlutterSharedPreferences"
    private val autostartPrefsKey = "flutter.autostart_enabled"
    private var methodChannel: MethodChannel? = null
    private var mediaProjectionGranted = false
    private var pendingMediaProjectionResult: MethodChannel.Result? = null
    @Volatile
    private var isMediaProjectionRequestInFlight = false
    @Volatile
    private var shouldAutoRequestMediaProjection = false
    @Volatile
    private var mediaProjectionAutoPostScheduled = false
    private lateinit var schedulerManager: SchedulerManager
    private lateinit var webSocketServerManager: WebSocketServerManager

    companion object {
        @Volatile
        var cachedMediaProjection: MediaProjection? = null
            private set

        @Synchronized
        fun cacheMediaProjection(projection: MediaProjection) {
            cachedMediaProjection?.stop()
            cachedMediaProjection = projection
        }

        @Synchronized
        fun peekCachedMediaProjection(): MediaProjection? = cachedMediaProjection

        @Synchronized
        fun clearCachedMediaProjection(context: Context) {
            MediaProjectionForegroundService.stop(context)
            cachedMediaProjection?.stop()
            cachedMediaProjection = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        schedulerManager = SchedulerManager(this)
        webSocketServerManager = WebSocketServerManager.getInstance(this)
        webSocketServerManager.startIfEnabled()

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        )
        channel.setMethodCallHandler(::handleMethodCall)
        methodChannel = channel

        ProgSetAccessibilityService.instance?.setOnExecutionUpdateListener { summary ->
            runOnUiThread {
                methodChannel?.invokeMethod("onExecutionUpdate", summary.toMap())
            }
        }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformInfo" -> {
                result.success(
                    mapOf(
                        "platform" to "android",
                        "manufacturer" to android.os.Build.MANUFACTURER.orEmpty(),
                        "model" to android.os.Build.MODEL.orEmpty(),
                        "sdkInt" to android.os.Build.VERSION.SDK_INT,
                        "locale" to Locale.getDefault().toLanguageTag(),
                    ),
                )
            }

            "getPermissionStatus" -> result.success(permissionStatusMap())
            "getOverlayStatus" -> {
                result.success(
                    mapOf(
                        "visible" to (ProgSetAccessibilityService.instance?.isOverlayVisible() == true),
                    ),
                )
            }

            "showOverlay" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService == null) {
                    result.error(
                        "accessibility_service_unavailable",
                        "Accessibility service is enabled in settings but not connected.",
                        null,
                    )
                    return
                }

                val isShown = accessibilityService.showOverlay()
                result.success(
                    mapOf(
                        "visible" to isShown,
                    ),
                )
            }

            "hideOverlay" -> {
                ProgSetAccessibilityService.instance?.hideOverlay()
                result.success(
                    mapOf(
                        "visible" to false,
                    ),
                )
            }

            "getRecorderStatus" -> {
                result.success(
                    (ProgSetAccessibilityService.instance?.recorderSummary()
                        ?: RecorderSummary(
                            isRecording = false,
                            totalActions = 0,
                            tapCount = 0,
                            doubleTapCount = 0,
                            longPressCount = 0,
                            swipeCount = 0,
                            maxPointerCount = 0,
                            sessionDurationMs = 0L,
                            actions = emptyList(),
                        )).toMap(),
                )
            }

            "clearRecorder" -> {
                result.success(
                    (ProgSetAccessibilityService.instance?.clearRecorder()
                        ?: RecorderSummary(
                            isRecording = false,
                            totalActions = 0,
                            tapCount = 0,
                            doubleTapCount = 0,
                            longPressCount = 0,
                            swipeCount = 0,
                            maxPointerCount = 0,
                            sessionDurationMs = 0L,
                            actions = emptyList(),
                        )).toMap(),
                )
            }

            "startRecorder" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService == null) {
                    result.error(
                        "accessibility_service_unavailable",
                        "Accessibility service is not connected.",
                        null,
                    )
                    return
                }

                if (!accessibilityService.isOverlayVisible()) {
                    result.error(
                        "overlay_not_active",
                        "Floating overlay must be active before recorder start.",
                        null,
                    )
                    return
                }

                val mode = call.argument<String>("mode") ?: "CONTINUOUS"
                val globalVerificationEnabled = call.argument<Boolean>("globalVerificationEnabled") ?: true
                val recorderSummary = accessibilityService.startRecorder(mode, globalVerificationEnabled)
                result.success(recorderSummary.toMap())
                moveTaskToBack(true)
            }

            "stopRecorder" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                android.util.Log.i("MainActivity", "stopRecorder called, instance=$accessibilityService")
                if (accessibilityService != null) {
                    val summary = accessibilityService.stopRecorder()
                    android.util.Log.i("MainActivity", "stopRecorder result: $summary")
                    result.success(summary.toMap())
                } else {
                    android.util.Log.w("MainActivity", "stopRecorder: accessibility service is null")
                    result.success(
                        RecorderSummary(
                            isRecording = false,
                            totalActions = 0,
                            tapCount = 0,
                            doubleTapCount = 0,
                            longPressCount = 0,
                            swipeCount = 0,
                            maxPointerCount = 0,
                            sessionDurationMs = 0L,
                            actions = emptyList(),
                        ).toMap()
                    )
                }
            }

            "openAccessibilitySettings" -> {
                startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                result.success(null)
            }

            "openOverlaySettings" -> {
                val intent =
                    Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        android.net.Uri.parse("package:$packageName"),
                    )
                startActivity(intent)
                result.success(null)
            }

            "requestMediaProjectionPermission" -> requestMediaProjectionPermission(result)

            "getLogs" -> {
                val logManager = LogManager.getInstance(this)
                result.success(logManager.getLogsForDisplay())
            }

            "getLogsSnapshot" -> {
                val logManager = LogManager.getInstance(this)
                result.success(
                    mapOf(
                        "logs" to logManager.getLogsForDisplay(),
                        "source" to logManager.getLogSourceForDisplay(),
                    ),
                )
            }

            "clearLogs" -> {
                val logManager = LogManager.getInstance(this)
                logManager.clearLogBuffer()
                result.success(null)
            }

            "getLogFilePath" -> {
                val logManager = LogManager.getInstance(this)
                result.success(logManager.getCurrentLogFilePath())
            }

            "exportLogs" -> {
                val customPath = call.argument<String>("path")
                val logManager = LogManager.getInstance(this)
                val exportPath = logManager.exportLogsToFile(customPath)
                result.success(exportPath)
            }

            "exportScenarioActions" -> {
                val scenarioId = call.argument<String>("scenarioId")
                if (scenarioId.isNullOrBlank()) {
                    result.error("invalid_argument", "scenarioId parameter is required", null)
                    return
                }
                val screenshotStorageManager = ScreenshotStorageManager(this)
                val actionStore = ScenarioActionStore(this, screenshotStorageManager)
                result.success(actionStore.exportScenarioActions(scenarioId))
            }

            "importScenarioActions" -> {
                val scenarioId = call.argument<String>("scenarioId")
                if (scenarioId.isNullOrBlank()) {
                    result.error("invalid_argument", "scenarioId parameter is required", null)
                    return
                }
                val rawActions = call.argument<List<*>>("actions")
                if (rawActions == null) {
                    result.error("invalid_argument", "actions parameter is required", null)
                    return
                }
                val normalizedActions =
                    rawActions.mapNotNull { entry ->
                        (entry as? Map<*, *>)?.mapNotNull { (key, value) ->
                            val stringKey = key?.toString() ?: return@mapNotNull null
                            stringKey to value
                        }?.toMap()
                    }
                val screenshotStorageManager = ScreenshotStorageManager(this)
                val actionStore = ScenarioActionStore(this, screenshotStorageManager)
                val success = actionStore.importScenarioActions(scenarioId, normalizedActions)
                result.success(mapOf("success" to success))
            }

            "deleteScenarioActions" -> {
                val scenarioId = call.argument<String>("scenarioId")
                if (scenarioId.isNullOrBlank()) {
                    result.error("invalid_argument", "scenarioId parameter is required", null)
                    return
                }
                val screenshotStorageManager = ScreenshotStorageManager(this)
                val actionStore = ScenarioActionStore(this, screenshotStorageManager)
                result.success(mapOf("success" to actionStore.deleteScenarioActions(scenarioId)))
            }

            "testScenarioStep" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService == null) {
                    result.error("accessibility_service_unavailable", "Service not connected", null)
                    return
                }

                val type = call.argument<String>("type") ?: ""
                val pointerCount = call.argument<Int>("pointerCount") ?: 1
                val startX = call.argument<Double>("startX") ?: 0.0
                val startY = call.argument<Double>("startY") ?: 0.0
                val endX = call.argument<Double>("endX") ?: 0.0
                val endY = call.argument<Double>("endY") ?: 0.0
                val durationMs = call.argument<Number>("durationMs")?.toLong() ?: 100L
                val stepDelayMs = call.argument<Number>("stepDelayMs")?.toLong() ?: 1000L
                val verificationEnabled = call.argument<Boolean>("verificationEnabled") ?: false
                val thresholdPercent = call.argument<Double>("thresholdPercent") ?: 1.0

                val action = RecordedAction(
                    type = type,
                    pointerCount = pointerCount,
                    startX = startX,
                    startY = startY,
                    endX = endX,
                    endY = endY,
                    durationMs = durationMs,
                    stepDelayMs = stepDelayMs,
                    verificationEnabled = verificationEnabled,
                    thresholdPercent = thresholdPercent
                )

                Thread {
                    val success = accessibilityService.testScenarioStep(action)
                    runOnUiThread {
                        result.success(mapOf("success" to success))
                    }
                }.start()
            }

            "openLogLocation" -> {
                openLogLocation()
                result.success(null)
            }

            "setLoggingEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                val logManager = LogManager.getInstance(this)
                logManager.setEnabled(enabled)
                result.success(null)
            }

            "setLogToFileEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                val logManager = LogManager.getInstance(this)
                logManager.setLogToFile(enabled)
                result.success(null)
            }

            "getLoggingEnabled" -> {
                val logManager = LogManager.getInstance(this)
                result.success(logManager.isLoggingEnabled())
            }

            "getLogToFileEnabled" -> {
                val logManager = LogManager.getInstance(this)
                result.success(logManager.isLogToFileEnabled())
            }

            "getAutostartEnabled" -> {
                result.success(isAutostartEnabled())
            }

            "setAutostartEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                setAutostartEnabled(enabled)
                result.success(null)
            }

            "setRestoreAppAfterExecution" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                ProgSetAccessibilityService.instance?.setRestoreAppAfterExecution(enabled)
                result.success(null)
            }

            "getExactAlarmStatus" -> {
                result.success(mapOf("exactAlarmsAllowed" to areExactAlarmsAllowed()))
            }

            "getWebSocketStatus" -> {
                result.success(webSocketServerManager.getStatusMap())
            }

            "setWebSocketEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                webSocketServerManager.setEnabled(enabled)
                result.success(webSocketServerManager.getStatusMap())
            }

            "setWebSocketPort" -> {
                val port = call.argument<Int>("port")
                if (port == null) {
                    result.error("invalid_argument", "port parameter is required", null)
                    return
                }
                if (!webSocketServerManager.setPort(port)) {
                    result.error("invalid_argument", "port must be between 1024 and 65535", null)
                    return
                }
                result.success(webSocketServerManager.getStatusMap())
            }

            "regenerateWebSocketToken" -> {
                val token = webSocketServerManager.regenerateToken()
                result.success(
                    mapOf(
                        "token" to token,
                        "status" to webSocketServerManager.getStatusMap(),
                    ),
                )
            }

            "openExactAlarmSettings" -> {
                openExactAlarmSettings()
                result.success(null)
            }

            "getCurrentState" -> {
                val state = ProgSetAccessibilityService.instance?.getCurrentState()
                    ?: mapOf(
                        "state" to "ERROR",
                        "description" to "Accessibility service not connected",
                        "canRecord" to false,
                        "canExecute" to false,
                        "canPause" to false,
                        "canResume" to false,
                        "canReset" to false,
                    )
                result.success(state)
            }

            "resetState" -> {
                val success = ProgSetAccessibilityService.instance?.resetState() ?: false
                result.success(mapOf("success" to success))
            }

            "startExecution" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService == null) {
                    result.error(
                        "accessibility_service_unavailable",
                        "Accessibility service is not connected.",
                        null,
                    )
                    return
                }

                val delayMs = call.argument<Int>("delayMs")
                val globalVerificationEnabled = call.argument<Boolean>("globalVerificationEnabled") ?: true
                val executionSummary = accessibilityService.startExecution(delayMs, globalVerificationEnabled)
                result.success(executionSummary.toMap())
            }

            "startScenarioExecution" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService == null) {
                    result.error(
                        "accessibility_service_unavailable",
                        "Accessibility service is not connected.",
                        null,
                    )
                    return
                }

                val scenarioId = call.argument<String>("scenarioId")
                if (scenarioId.isNullOrBlank()) {
                    result.error("invalid_argument", "scenarioId parameter is required", null)
                    return
                }

                val delayMs = call.argument<Int>("delayMs")
                val globalVerificationEnabled = call.argument<Boolean>("globalVerificationEnabled") ?: true
                val executionSummary = accessibilityService.startScenarioExecution(scenarioId, delayMs, globalVerificationEnabled)
                result.success(executionSummary.toMap())
            }

            "bindCurrentRecordingToScenario" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService == null) {
                    result.error(
                        "accessibility_service_unavailable",
                        "Accessibility service is not connected.",
                        null,
                    )
                    return
                }

                val scenarioId = call.argument<String>("scenarioId")
                if (scenarioId.isNullOrBlank()) {
                    result.error("invalid_argument", "scenarioId parameter is required", null)
                    return
                }

                val success = accessibilityService.bindCurrentRecordingToScenario(scenarioId)
                result.success(mapOf("success" to success))
            }

            "stopExecution" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                result.success(
                    (accessibilityService?.stopExecution()
                        ?: ExecutionSummary(
                            isExecuting = false,
                            totalActions = 0,
                            completedActions = 0,
                            failedActions = 0,
                        )).toMap(),
                )
            }

            "pauseExecution" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                val paused = accessibilityService?.pauseExecution() ?: false
                result.success(mapOf("paused" to paused))
            }

            "resumeExecution" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                val resumed = accessibilityService?.resumeExecution() ?: false
                result.success(mapOf("resumed" to resumed))
            }

            "getExecutionStatus" -> {
                result.success(
                    (ProgSetAccessibilityService.instance?.executionSummary()
                        ?: ExecutionSummary(
                            isExecuting = false,
                            totalActions = 0,
                            completedActions = 0,
                            failedActions = 0,
                        )).toMap(),
                )
            }

            "takeScreenshot" -> {
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService == null) {
                    result.error(
                        "accessibility_service_unavailable",
                        "Accessibility service is not connected.",
                        null,
                    )
                    return
                }

                if (!accessibilityService.isScreenCaptureProjectionReady()) {
                    result.error(
                        "media_projection_not_available",
                        "MediaProjection permission not granted.",
                        null,
                    )
                    return
                }

                val verificationResult = accessibilityService.takeScreenshotForVerification()
                result.success(
                    mapOf(
                        "success" to verificationResult.success,
                        "similarity" to verificationResult.similarity,
                        "changePercent" to verificationResult.changePercent,
                        "isFlagSecure" to verificationResult.isFlagSecure,
                        "error" to verificationResult.error,
                    ),
                )
            }

            "scheduleExecution" -> {
                val rawSchedule = call.argument<Any>("schedule")
                val scheduleJson = when (rawSchedule) {
                    is String -> rawSchedule
                    is Map<*, *> -> JSONObject(rawSchedule).toString()
                    else -> null
                }
                if (scheduleJson.isNullOrBlank()) {
                    result.error("invalid_argument", "schedule parameter is required", null)
                    return
                }
                val success = schedulerManager.scheduleExecution(scheduleJson)
                result.success(mapOf("success" to success))
            }

            "cancelSchedule" -> {
                val scheduleId = call.argument<String>("scheduleId")
                if (scheduleId == null) {
                    result.error("invalid_argument", "scheduleId parameter is required", null)
                    return
                }
                val success = schedulerManager.cancelSchedule(scheduleId)
                result.success(mapOf("success" to success))
            }

            "cancelAllSchedules" -> {
                val success = schedulerManager.cancelAllSchedules()
                result.success(mapOf("success" to success))
            }

            else -> result.notImplemented()
        }
    }

    private fun openLogLocation() {
        val intent = Intent(DownloadManager.ACTION_VIEW_DOWNLOADS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    private fun requestMediaProjectionPermission(result: MethodChannel.Result) {
        peekCachedMediaProjection()?.let { cachedProjection ->
            mediaProjectionGranted = true
            // Reset auto-request flag as we have permission now
            shouldAutoRequestMediaProjection = false
            ProgSetAccessibilityService.instance?.setMediaProjection(cachedProjection)
            MediaProjectionForegroundService.start(this)
            result.success(permissionStatusMap())
            return
        }

        if (isMediaProjectionRequestInFlight || pendingMediaProjectionResult != null) {
            result.error(
                "media_projection_request_in_progress",
                "MediaProjection permission request already in progress.",
                null,
            )
            return
        }

        if (isFinishing || isDestroyed) {
            result.error(
                "activity_not_available",
                "Activity is not in a valid state to request MediaProjection.",
                null,
            )
            return
        }

        val projectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager

        if (projectionManager == null) {
            result.success(permissionStatusMap())
            return
        }

        isMediaProjectionRequestInFlight = true
        pendingMediaProjectionResult = result
        val captureIntent = projectionManager.createScreenCaptureIntent()
        try {
            startActivityForResult(captureIntent, mediaProjectionRequestCode)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to launch MediaProjection request", e)
            isMediaProjectionRequestInFlight = false
            result.error(
                "media_projection_start_failed",
                e.message,
                null,
            )
            pendingMediaProjectionResult = null
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == mediaProjectionRequestCode) {
            LogManager.getInstance(this).i(
                "MainActivity",
                "onActivityResult: media projection flow resultCode=$resultCode hasData=${data != null}",
            )
            onMediaProjectionCaptureFinished(resultCode, data)
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun onMediaProjectionCaptureFinished(resultCode: Int, data: Intent?) {
        val log = LogManager.getInstance(this)
        if (!isMediaProjectionRequestInFlight) {
            log.w(
                "MainActivity",
                "onMediaProjectionCaptureFinished: inFlight was already false (duplicate or unexpected delivery)",
            )
        }
        log.i(
            "MainActivity",
            "onMediaProjectionCaptureFinished: resultCode=$resultCode, hasData=${data != null}",
        )
        isMediaProjectionRequestInFlight = false
        mediaProjectionGranted = resultCode == Activity.RESULT_OK
        android.util.Log.d("MainActivity", "MediaProjection result: granted=$mediaProjectionGranted, data=${data != null}")

        if (resultCode == Activity.RESULT_OK && data != null) {
            try {
                try {
                    MediaProjectionForegroundService.start(this)
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "MediaProjectionForegroundService.start failed", e)
                    log.e("MainActivity", "MediaProjectionForegroundService.start failed", e)
                }

                val projectionManager =
                    getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager
                val projection = projectionManager?.getMediaProjection(resultCode, data)
                if (projection != null) {
                    android.util.Log.d("MainActivity", "MediaProjection obtained successfully")
                    log.i("MainActivity", "getMediaProjection succeeded, caching and wiring to service")
                    cacheMediaProjection(projection)
                    val service = ProgSetAccessibilityService.instance
                    if (service != null) {
                        service.setMediaProjection(projection)
                        android.util.Log.d("MainActivity", "MediaProjection passed to service")
                        log.i("MainActivity", "MediaProjection passed to ProgSetAccessibilityService")
                        log.i(
                            "MainActivity",
                            "verifierReady=${service.isScreenCaptureProjectionReady()}",
                        )
                    } else {
                        android.util.Log.w("MainActivity", "Service not available, projection cached for later")
                        log.w("MainActivity", "Accessibility service null; projection only in MainActivity cache")
                    }
                    android.util.Log.d("MainActivity", "Cached projection for future use")
                } else {
                    android.util.Log.e("MainActivity", "getMediaProjection returned null")
                    log.e("MainActivity", "getMediaProjection returned null", null)
                }
            } catch (e: Exception) {
                android.util.Log.e("MainActivity", "Failed to get MediaProjection", e)
                log.e("MainActivity", "Failed to get MediaProjection", e)
            }
        } else {
            android.util.Log.w("MainActivity", "MediaProjection permission denied or no data, resultCode=$resultCode")
            log.w("MainActivity", "MediaProjection denied or missing data (resultCode=$resultCode)")
        }

        shouldAutoRequestMediaProjection = false
        val pendingResult = pendingMediaProjectionResult
        pendingMediaProjectionResult = null
        pendingResult?.success(permissionStatusMap())
    }

    override fun onResume() {
        super.onResume()
        android.util.Log.d("MainActivity", "onResume called, shouldAutoRequest=$shouldAutoRequestMediaProjection")

        scheduleMediaProjectionAutoRequestIfPending("onResume")

        // Try to pass cached projection to service when it becomes available
        peekCachedMediaProjection()?.let { projection ->
            val service = ProgSetAccessibilityService.instance
            if (service != null && !service.isScreenCaptureProjectionReady()) {
                service.setMediaProjection(projection)
                mediaProjectionGranted = true
                MediaProjectionForegroundService.start(this)
                android.util.Log.d("MainActivity", "Passed cached projection to service in onResume")
            }
        }
    }
    
    override fun onDestroy() {
        isMediaProjectionRequestInFlight = false
        val pendingResult = pendingMediaProjectionResult
        pendingMediaProjectionResult = null
        pendingResult?.error(
            "activity_destroyed",
            "Activity was destroyed before permission result",
            null,
        )
        super.onDestroy()
    }

    private fun permissionStatusMap(): Map<String, Any> {
        val hasProjection =
            (ProgSetAccessibilityService.instance?.isScreenCaptureProjectionReady() == true) ||
                peekCachedMediaProjection() != null

        return mapOf(
            "accessibilityGranted" to (isAccessibilityServiceEnabled() && ProgSetAccessibilityService.instance != null),
            "overlayGranted" to canDrawOverlays(),
            "mediaProjectionGranted" to (mediaProjectionGranted || hasProjection),
            "hasMediaProjection" to hasProjection,
        )
    }

    private fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponent = ComponentName(this, ProgSetAccessibilityService::class.java)
        val enabledServices =
            Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
            ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)

        while (splitter.hasNext()) {
            val componentName = ComponentName.unflattenFromString(splitter.next())
            if (componentName == expectedComponent) {
                return true
            }
        }

        return false
    }

    private fun isAutostartEnabled(): Boolean {
        val prefs = getSharedPreferences(flutterPrefsName, Context.MODE_PRIVATE)
        return prefs.getBoolean(autostartPrefsKey, true)
    }

    private fun setAutostartEnabled(enabled: Boolean) {
        val prefs = getSharedPreferences(flutterPrefsName, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(autostartPrefsKey, enabled).apply()
    }

    private fun areExactAlarmsAllowed(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as? android.app.AlarmManager
            alarmManager?.canScheduleExactAlarms() == true
        } else {
            true
        }
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = android.net.Uri.parse("package:$packageName")
            }
            startActivity(intent)
        }
    }
}
