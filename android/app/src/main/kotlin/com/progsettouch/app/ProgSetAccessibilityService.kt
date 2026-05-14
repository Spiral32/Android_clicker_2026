package com.progsettouch.app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class ProgSetAccessibilityService : AccessibilityService() {
    private lateinit var overlayManager: OverlayManager
    private lateinit var recorderManager: RecorderManager
    private lateinit var executionEngine: ExecutionEngine
    private lateinit var screenshotVerifier: ScreenshotVerifier
    lateinit var stateMachine: StateMachine
        private set
    private lateinit var logger: LogManager
    private lateinit var scenarioActionStore: ScenarioActionStore

    // Listeners for execution updates
    private var onExecutionUpdateListener: ((ExecutionSummary) -> Unit)? = null

    // Store last recorded actions for execution
    private var lastRecordedActions: List<RecordedAction> = emptyList()
    private var mediaProjection: android.media.projection.MediaProjection? = null
    @Volatile private var overlayStopInProgress = false
    private var shouldRestoreApp = true

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        logger = LogManager.getInstance(this)
        logger.d("ProgSetAccessibilityService", "onServiceConnected() called")
        val screenshotStorageManager = ScreenshotStorageManager(this)
        scenarioActionStore = ScenarioActionStore(this, screenshotStorageManager)
        stateMachine = StateMachine(this)
        overlayManager = OverlayManager(this)
        screenshotVerifier = ScreenshotVerifier(this)
        recorderManager = RecorderManager(this, screenshotVerifier, screenshotStorageManager)
        executionEngine = ExecutionEngine(this, this, screenshotVerifier, screenshotStorageManager)
        recorderManager.setOnStopRequested {
            logger.d("ProgSetAccessibilityService", "Recorder stop requested from overlay control")
            overlayStopInProgress = true
            if (stateMachine.getCurrentState() == AppState.RECORDING) {
                stateMachine.transition(AppState.IDLE)
            }
            overlayStopInProgress = false
        }

        overlayManager.onStopRequested = {
            logger.d("ProgSetAccessibilityService", "Execution stop requested from overlay control")
            if (stateMachine.getCurrentState() == AppState.EXECUTING ||
                            stateMachine.getCurrentState() == AppState.PAUSED
            ) {
                stopExecution()
            }
        }

        // Try to get cached MediaProjection if available
        val cached = MainActivity.cachedMediaProjection
        logger.d(
                "ProgSetAccessibilityService",
                "MainActivity.cachedMediaProjection=${cached != null}"
        )
        cached?.let { projection ->
            logger.d(
                    "ProgSetAccessibilityService",
                    "Calling setMediaProjection() with cached projection"
            )
            setMediaProjection(projection)
        }

        // Listen for state changes to auto-stop recorder when leaving RECORDING
        stateMachine.addOnStateChangedListener { from, to ->
            overlayManager.updateState(to)

            if (from == AppState.RECORDING &&
                            to != AppState.RECORDING &&
                            recorderManager.isRecording() &&
                            !overlayStopInProgress
            ) {
                recorderManager.stop()
            }
        }

        // Listen for execution completion
        executionEngine.setOnExecutionComplete { summary ->
            if (stateMachine.getCurrentState() == AppState.EXECUTING) {
                stateMachine.transition(AppState.IDLE)
            }
            onExecutionUpdateListener?.invoke(summary)
            if (shouldRestoreApp) {
                restoreApp()
            }
        }

        executionEngine.setOnActionExecuted { index, action, success ->
            onExecutionUpdateListener?.invoke(executionEngine.buildSummary())
        }
    }

    fun setOnExecutionUpdateListener(listener: ((ExecutionSummary) -> Unit)?) {
        onExecutionUpdateListener = listener
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() = Unit

    private fun minimizeApp() {
        logger.d("ProgSetAccessibilityService", "Minimizing app")
        val homeIntent =
                android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
                    addCategory(android.content.Intent.CATEGORY_HOME)
                    addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        startActivity(homeIntent)
    }

    private fun restoreApp() {
        logger.d("ProgSetAccessibilityService", "Restoring app")
        val launchIntent =
                packageManager.getLaunchIntentForPackage(packageName)?.apply {
                    addFlags(
                            android.content.Intent.FLAG_ACTIVITY_NEW_TASK or
                                    android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP
                    )
                }
        launchIntent?.let { startActivity(it) }
    }

    override fun onDestroy() {
        overlayManager.hide()
        recorderManager.stop()
        screenshotVerifier.release()
        mediaProjection?.stop()
        mediaProjection = null
        // Clear cached projection only if this is the actual app close, not just activity
        // recreation
        if (instance === this) {
            instance = null
            MainActivity.clearCachedMediaProjection(this)
        }
        super.onDestroy()
    }

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        overlayManager.hide()
        recorderManager.stop()
        // Don't stop projection on unbind - it should survive
        if (instance === this) {
            instance = null
        }
        return super.onUnbind(intent)
    }

    /**
     * Set MediaProjection for screenshot verification. Called from MainActivity after user grants
     * permission.
     */
    fun setMediaProjection(projection: android.media.projection.MediaProjection) {
        logger.d("ProgSetAccessibilityService", "setMediaProjection() called")
        try {
            mediaProjection = projection
            logger.d("ProgSetAccessibilityService", "Calling screenshotVerifier.initialize()")
            screenshotVerifier.initialize(projection)
            logger.i(
                    "ProgSetAccessibilityService",
                    "MediaProjection set for screenshot verification"
            )
            logger.d(
                    "ProgSetAccessibilityService",
                    "screenshotVerifier.hasMediaProjection()=${screenshotVerifier.hasMediaProjection()}"
            )
        } catch (e: Exception) {
            logger.e("ProgSetAccessibilityService", "Failed to set MediaProjection", e)
            mediaProjection = null
        }
    }

    fun hasMediaProjection(): Boolean = mediaProjection != null

    /** Use this for capture UX: service field can be set while verifier init failed. */
    fun isScreenCaptureProjectionReady(): Boolean = screenshotVerifier.hasMediaProjection()

    fun openMainActivityForMediaProjection() {
        logger.d("ProgSetAccessibilityService", "openMainActivityForMediaProjection() called")
        try {
            // NEW_TASK is required from a Service context. Do not use NO_HISTORY here: when the
            // system screen-capture consent activity opens, the activity would be finished before
            // onActivityResult runs, so permission is never applied.
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                )
                putExtra("requestMediaProjection", true)
            }
            logger.d("ProgSetAccessibilityService", "Starting MainActivity with intent: $intent")
            startActivity(intent)
            logger.d("ProgSetAccessibilityService", "MainActivity startActivity called successfully")
        } catch (e: Exception) {
            logger.e("ProgSetAccessibilityService", "Failed to start MainActivity", e)
        }
    }

    fun showOverlay(): Boolean = overlayManager.show()

    fun hideOverlay() = overlayManager.hide()

    fun isOverlayVisible(): Boolean = overlayManager.isVisible()

    fun setRestoreAppAfterExecution(enabled: Boolean) {
        shouldRestoreApp = enabled
    }

    fun startRecorder(
            mode: String = "CONTINUOUS",
            globalVerificationEnabled: Boolean = true
    ): RecorderSummary {
        // Validate state before starting
        if (!stateMachine.canStartRecording()) {
            val currentState = stateMachine.getCurrentState()
            return RecorderSummary(
                    isRecording = false,
                    totalActions = 0,
                    tapCount = 0,
                    doubleTapCount = 0,
                    longPressCount = 0,
                    swipeCount = 0,
                    maxPointerCount = 0,
                    sessionDurationMs = 0L,
                    actions = emptyList(),
                    error = "Cannot start recording from state: $currentState",
            )
        }

        val recorderMode =
                when (mode) {
                    "POINT_CAPTURE" -> RecorderMode.POINT_CAPTURE
                    else -> RecorderMode.POINT_CAPTURE
                }

        val result = stateMachine.transition(AppState.RECORDING)
        if (result is StateTransitionResult.Failure) {
            return RecorderSummary(
                    isRecording = false,
                    totalActions = 0,
                    tapCount = 0,
                    doubleTapCount = 0,
                    longPressCount = 0,
                    swipeCount = 0,
                    maxPointerCount = 0,
                    sessionDurationMs = 0L,
                    actions = emptyList(),
                    error = result.reason,
            )
        }

        return recorderManager.start(recorderMode, globalVerificationEnabled)
    }

    fun stopRecorder(): RecorderSummary {
        logger.d("ProgSetAccessibilityService", "stopRecorder() called")
        val summary = recorderManager.stop()
        logger.d(
                "ProgSetAccessibilityService",
                "Recorder stopped, summary: isRecording=${summary.isRecording}, totalActions=${summary.totalActions}, mode=${summary.mode}"
        )

        // Transition back to IDLE if we were recording
        val currentState = stateMachine.getCurrentState()
        logger.i("ProgSetAccessibilityService", "Current state before transition: $currentState")
        if (currentState == AppState.RECORDING) {
            val result = stateMachine.transition(AppState.IDLE)
            logger.i("ProgSetAccessibilityService", "Transition to IDLE result: $result")
            // Verify transition worked
            val newState = stateMachine.getCurrentState()
            logger.i(
                    "ProgSetAccessibilityService",
                    "State after transition: $newState, canExecute=${stateMachine.canStartExecution()}"
            )
        } else {
            logger.w(
                    "ProgSetAccessibilityService",
                    "Not in RECORDING state, cannot transition to IDLE. Current: $currentState"
            )
        }

        return summary
    }

    fun recorderSummary(): RecorderSummary = recorderManager.summary()

    fun clearRecorder(): RecorderSummary = recorderManager.clearRecordedActions()

    fun getCurrentState(): Map<String, Any> = stateMachine.getCurrentState().toMap()

    fun resetState(): Boolean {
        return when (val result = stateMachine.reset()) {
            is StateTransitionResult.Success -> true
            is StateTransitionResult.Failure -> false
        }
    }

    // Execution methods
    fun startExecution(
            delayMs: Int? = null,
            globalVerificationEnabled: Boolean = true
    ): ExecutionSummary {
        // Validate state before starting
        if (!stateMachine.canStartExecution()) {
            val currentState = stateMachine.getCurrentState()
            return ExecutionSummary(
                    isExecuting = false,
                    totalActions = lastRecordedActions.size,
                    completedActions = 0,
                    failedActions = 0,
                    error = "Cannot start execution from state: $currentState",
            )
        }

        // Get actions from last recording
        val actions = recorderManager.summary().actions
        if (actions.isEmpty()) {
            return ExecutionSummary(
                    isExecuting = false,
                    totalActions = 0,
                    completedActions = 0,
                    failedActions = 0,
                    error = "No recorded actions to execute",
            )
        }
        lastRecordedActions = actions

        val result = stateMachine.transition(AppState.EXECUTING)
        if (result is StateTransitionResult.Failure) {
            return ExecutionSummary(
                    isExecuting = false,
                    totalActions = actions.size,
                    completedActions = 0,
                    failedActions = 0,
                    error = result.reason,
            )
        }

        minimizeApp()

        val config =
                if (delayMs != null) {
                    ExecutionConfig(
                            delayBetweenActionsMs = delayMs.toLong().coerceAtLeast(1000L),
                            globalVerificationEnabled = globalVerificationEnabled
                    )
                } else {
                    ExecutionConfig(globalVerificationEnabled = globalVerificationEnabled)
                }

        return executionEngine.start(actions, config)
    }

    fun startScenarioExecution(
            scenarioId: String,
            delayMs: Int? = null,
            globalVerificationEnabled: Boolean = true
    ): ExecutionSummary {
        if (!stateMachine.canStartExecution()) {
            val currentState = stateMachine.getCurrentState()
            return ExecutionSummary(
                    isExecuting = false,
                    totalActions = 0,
                    completedActions = 0,
                    failedActions = 0,
                    error = "Cannot start execution from state: $currentState",
            )
        }

        var actions = scenarioActionStore.getScenarioActions(scenarioId)
        if (actions.isEmpty()) {
            // Backward compatibility: bind current recording to scenario on first run.
            actions = recorderManager.summary().actions
            if (actions.isNotEmpty()) {
                scenarioActionStore.saveScenarioActions(scenarioId, actions)
            }
        }

        if (actions.isEmpty()) {
            return ExecutionSummary(
                    isExecuting = false,
                    totalActions = 0,
                    completedActions = 0,
                    failedActions = 0,
                    error = "No actions stored for scenarioId=$scenarioId",
            )
        }
        lastRecordedActions = actions

        val result = stateMachine.transition(AppState.EXECUTING)
        if (result is StateTransitionResult.Failure) {
            return ExecutionSummary(
                    isExecuting = false,
                    totalActions = actions.size,
                    completedActions = 0,
                    failedActions = 0,
                    error = result.reason,
            )
        }

        minimizeApp()
        val config =
                if (delayMs != null) {
                    ExecutionConfig(
                            delayBetweenActionsMs = delayMs.toLong().coerceAtLeast(1000L),
                            globalVerificationEnabled = globalVerificationEnabled
                    )
                } else {
                    ExecutionConfig(globalVerificationEnabled = globalVerificationEnabled)
                }
        return executionEngine.start(actions, config)
    }

    fun bindCurrentRecordingToScenario(scenarioId: String): Boolean {
        val actions = recorderManager.summary().actions
        if (actions.isEmpty()) {
            return false
        }
        scenarioActionStore.saveScenarioActions(scenarioId, actions)
        return true
    }

    fun stopExecution(): ExecutionSummary {
        val summary = executionEngine.stop()

        // Transition back to IDLE if we were executing
        if (stateMachine.getCurrentState() == AppState.EXECUTING ||
                        stateMachine.getCurrentState() == AppState.PAUSED
        ) {
            stateMachine.transition(AppState.IDLE)
        }

        return summary
    }

    fun pauseExecution(): Boolean {
        if (stateMachine.getCurrentState() != AppState.EXECUTING) {
            return false
        }

        val paused = executionEngine.pause()
        if (paused) {
            stateMachine.transition(AppState.PAUSED)
        }
        return paused
    }

    fun resumeExecution(): Boolean {
        if (stateMachine.getCurrentState() != AppState.PAUSED) {
            return false
        }

        val resumed = executionEngine.resume()
        if (resumed) {
            stateMachine.transition(AppState.EXECUTING)
        }
        return resumed
    }

    fun testScenarioStep(action: RecordedAction): Boolean {
        return executionEngine.testAction(action)
    }

    fun executionSummary(): ExecutionSummary = executionEngine.buildSummary()

    /** Take a screenshot and return verification capabilities. */
    fun takeScreenshotForVerification(): VerificationResult {
        val bitmap = screenshotVerifier.captureScreenshot()
        return if (bitmap != null) {
            // Store bitmap for comparison (in real implementation, compare before/after)
            VerificationResult(
                    success = true,
                    similarity = 1.0f,
                    changePercent = 0f,
                    isFlagSecure = false,
                    error = null,
            )
        } else {
            // FLAG_SECURE or error
            VerificationResult(
                    success = true, // Consider as success per ТЗ
                    similarity = 0.0f,
                    changePercent = 100f,
                    isFlagSecure = true,
                    error = "FLAG_SECURE or capture failed",
            )
        }
    }

    companion object {
        @Volatile
        var instance: ProgSetAccessibilityService? = null
            private set
    }
}
