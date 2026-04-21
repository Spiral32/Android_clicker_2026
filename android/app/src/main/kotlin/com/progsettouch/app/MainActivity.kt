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
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val channelName = "prog_set_touch/platform"
    private var methodChannel: MethodChannel? = null
    private val mediaProjectionRequestCode = 4242
    private var mediaProjectionGranted = false
    private var pendingMediaProjectionResult: MethodChannel.Result? = null
    @Volatile
    private var isMediaProjectionRequestInFlight = false

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
        fun clearCachedMediaProjection() {
            cachedMediaProjection?.stop()
            cachedMediaProjection = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
                val recorderSummary = accessibilityService.startRecorder(mode)
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
                result.success(logManager.getLogBuffer())
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
                val executionSummary = accessibilityService.startExecution(delayMs)
                result.success(executionSummary.toMap())
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

                if (!accessibilityService.hasMediaProjection()) {
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
            ProgSetAccessibilityService.instance?.setMediaProjection(cachedProjection)
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
        startActivityForResult(
            projectionManager.createScreenCaptureIntent(),
            mediaProjectionRequestCode,
        )
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == mediaProjectionRequestCode) {
            isMediaProjectionRequestInFlight = false
            mediaProjectionGranted = resultCode == Activity.RESULT_OK
            android.util.Log.d("MainActivity", "MediaProjection result: granted=$mediaProjectionGranted, data=${data != null}")

            if (resultCode == Activity.RESULT_OK && data != null) {
                try {
                    val projectionManager =
                        getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager
                    val projection = projectionManager?.getMediaProjection(resultCode, data)
                    if (projection != null) {
                        android.util.Log.d("MainActivity", "MediaProjection obtained successfully")
                        cacheMediaProjection(projection)
                        // Try to set it on service if available
                        val service = ProgSetAccessibilityService.instance
                        if (service != null) {
                            service.setMediaProjection(projection)
                            android.util.Log.d("MainActivity", "MediaProjection passed to service")
                        } else {
                            android.util.Log.w("MainActivity", "Service not available, projection cached for later")
                        }
                    } else {
                        android.util.Log.e("MainActivity", "getMediaProjection returned null")
                    }
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Failed to get MediaProjection", e)
                }
            } else {
                android.util.Log.w("MainActivity", "MediaProjection permission denied or no data")
            }

            val pendingResult = pendingMediaProjectionResult
            pendingMediaProjectionResult = null
            pendingResult?.success(permissionStatusMap())
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onResume() {
        super.onResume()
        // Try to pass cached projection to service when it becomes available
        peekCachedMediaProjection()?.let { projection ->
            val service = ProgSetAccessibilityService.instance
            if (service != null && !service.hasMediaProjection()) {
                service.setMediaProjection(projection)
                mediaProjectionGranted = true
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
            (ProgSetAccessibilityService.instance?.hasMediaProjection() == true) ||
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
}
