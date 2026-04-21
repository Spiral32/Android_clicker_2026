package com.progsettouch.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Context
import android.graphics.Color
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * ExecutionEngine — orchestrates playback of recorded gestures.
 *
 * Features:
 * - Sequential execution (v1)
 * - Watchdog timer (protection against hangs)
 * - Visual feedback during execution
 * - State machine integration
 */
class ExecutionEngine(
    private val context: Context,
    private val accessibilityService: AccessibilityService,
) {
    private val windowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val logger = LogManager.getInstance(context)
    private val mainHandler = Handler(Looper.getMainLooper())

    private var executionThread: Thread? = null
    private val isExecuting = AtomicBoolean(false)
    private val isPaused = AtomicBoolean(false)
    private val shouldStop = AtomicBoolean(false)

    private var onExecutionComplete: ((ExecutionSummary) -> Unit)? = null
    private var onActionExecuted: ((Int, RecordedAction, Boolean) -> Unit)? = null

    private val visualFeedbackViews = mutableListOf<View>()

    // Watchdog configuration
    private val actionTimeoutMs = 15000L // 15 seconds max per action
    private val globalTimeoutMs = 600000L // 10 minutes max per scenario
    private var globalWatchdogTask: Runnable? = null

    // Execution configuration
    private val defaultDelayBetweenActionsMs = 1000L
    @Volatile
    private var currentActionIndex = 0
    private var actions: List<RecordedAction> = emptyList()

    /**
     * Set callback for execution completion.
     */
    fun setOnExecutionComplete(listener: (ExecutionSummary) -> Unit) {
        onExecutionComplete = listener
    }

    /**
     * Set callback for individual action execution.
     * Params: index, action, success
     */
    fun setOnActionExecuted(listener: (index: Int, action: RecordedAction, success: Boolean) -> Unit) {
        onActionExecuted = listener
    }

    /**
     * Start executing recorded actions.
     *
     * @param actions List of actions to execute
     * @param config Execution configuration (delays, etc.)
     * @return Execution summary if already executing, or initial summary
     */
    fun start(
        actions: List<RecordedAction>,
        config: ExecutionConfig = ExecutionConfig(),
    ): ExecutionSummary {
        logger.d("ExecutionEngine", "start() called with ${actions.size} actions")

        if (isExecuting.get()) {
            logger.w("ExecutionEngine", "Already executing, returning current summary")
            return buildSummary()
        }

        if (actions.isEmpty()) {
            logger.w("ExecutionEngine", "No actions to execute")
            return ExecutionSummary(
                isExecuting = false,
                totalActions = 0,
                completedActions = 0,
                failedActions = 0,
                error = "No actions to execute",
            )
        }

        this.actions = actions
        this.currentActionIndex = 0
        this.shouldStop.set(false)
        this.isPaused.set(false)
        this.isExecuting.set(true)

        // Start global watchdog
        startGlobalWatchdog()

        // Start execution thread
        executionThread = Thread {
            try {
                executeActions(config)
            } finally {
                cleanupExecution()
            }
        }.apply {
            name = "ExecutionThread"
            isDaemon = true
            start()
        }

        logger.i("ExecutionEngine", "Execution started with ${actions.size} actions")
        return buildSummary()
    }

    /**
     * Stop execution immediately.
     */
    fun stop(): ExecutionSummary {
        logger.d("ExecutionEngine", "stop() called")
        shouldStop.set(true)
        isPaused.set(false)

        executionThread?.interrupt()
        stopGlobalWatchdog()
        clearVisualFeedback()

        val summary = buildSummary()
        isExecuting.set(false)

        logger.i("ExecutionEngine", "Execution stopped manually. Completed: ${summary.completedActions}/${summary.totalActions}")
        return summary
    }

    /**
     * Pause execution (can be resumed).
     */
    fun pause(): Boolean {
        if (!isExecuting.get() || isPaused.get()) {
            return false
        }
        logger.i("ExecutionEngine", "Execution paused at action $currentActionIndex")
        isPaused.set(true)
        return true
    }

    /**
     * Resume paused execution.
     */
    fun resume(): Boolean {
        if (!isExecuting.get() || !isPaused.get()) {
            return false
        }
        logger.i("ExecutionEngine", "Execution resumed from action $currentActionIndex")
        isPaused.set(false)
        synchronized(isPaused) {
            (isPaused as Object).notify()
        }
        return true
    }

    /**
     * Check if currently executing.
     */
    fun isExecuting(): Boolean = isExecuting.get()

    /**
     * Check if paused.
     */
    fun isPaused(): Boolean = isPaused.get()

    /**
     * Get current execution summary.
     */
    fun summary(): ExecutionSummary = buildSummary()

    private fun startGlobalWatchdog() {
        mainHandler.removeCallbacksAndMessages(null)
        val task = Runnable {
            if (isExecuting.get()) {
                logger.e("ExecutionEngine", "Global watchdog triggered! Execution timed out after ${globalTimeoutMs}ms")
                stop()
                onExecutionComplete?.invoke(buildSummary().copy(error = "Global timeout reached"))
            }
        }
        globalWatchdogTask = task
        mainHandler.postDelayed(task, globalTimeoutMs)
        logger.d("ExecutionEngine", "Global watchdog started")
    }

    private fun stopGlobalWatchdog() {
        globalWatchdogTask?.let { mainHandler.removeCallbacks(it) }
        globalWatchdogTask = null
        logger.d("ExecutionEngine", "Global watchdog stopped")
    }

    private fun cleanupExecution() {
        isExecuting.set(false)
        stopGlobalWatchdog()

        // Clear visual feedback on main thread
        mainHandler.post {
            clearVisualFeedback()
        }

        // Notify completion
        val summary = buildSummary()
        mainHandler.post {
            onExecutionComplete?.invoke(summary)
        }

        logger.i("ExecutionEngine", "Execution thread finished. Success: ${summary.completedActions}, Failed: ${summary.failedActions}")
    }

    private fun executeActions(config: ExecutionConfig) {
        var completedCount = 0
        var failedCount = 0

        for (i in actions.indices) {
            if (shouldStop.get() || Thread.interrupted()) {
                logger.d("ExecutionEngine", "Execution loop breaking due to stop/interrupt at index $i")
                break
            }

            // Wait if paused
            while (isPaused.get() && !shouldStop.get()) {
                synchronized(isPaused) {
                    try {
                        (isPaused as Object).wait(200)
                    } catch (_: InterruptedException) {
                        return // Exit thread immediately
                    }
                }
            }

            if (shouldStop.get()) break

            currentActionIndex = i
            val action = actions[i]

            try {
                // Show visual feedback on main thread
                if (config.enableVisualFeedback) {
                    mainHandler.post {
                        showExecutionFeedback(action)
                    }
                }

                // Execute the action with its own protection
                val success = executeAction(action)

                if (success) {
                    completedCount++
                    logger.i("ExecutionEngine", "Action $i (${action.type}) completed")
                } else {
                    failedCount++
                    logger.w("ExecutionEngine", "Action $i (${action.type}) failed")
                }

                // Notify individual action status
                mainHandler.post {
                    onActionExecuted?.invoke(i, action, success)
                }

                // Delay between actions (unless last action)
                if (i < actions.size - 1 && !shouldStop.get()) {
                    val delay = config.delayBetweenActionsMs
                    if (delay > 0) {
                        Thread.sleep(delay)
                    }
                }

            } catch (e: InterruptedException) {
                logger.w("ExecutionEngine", "Execution thread interrupted during action $i")
                break
            } catch (e: Exception) {
                failedCount++
                logger.e("ExecutionEngine", "Unexpected error during action $i", e)
                if (config.stopOnError) break
            }
        }
    }

    private fun executeAction(action: RecordedAction): Boolean {
        return try {
            when (action.type) {
                RecordedActionType.tap.value -> executeTap(action)
                RecordedActionType.doubleTap.value -> executeDoubleTap(action)
                RecordedActionType.longPress.value -> executeLongPress(action)
                RecordedActionType.swipe.value -> executeSwipe(action)
                else -> {
                    logger.w("ExecutionEngine", "Skipping unknown action type: ${action.type}")
                    false
                }
            }
        } catch (e: InterruptedException) {
            throw e
        } catch (e: Exception) {
            logger.e("ExecutionEngine", "Gesture dispatch failed for ${action.type}", e)
            false
        }
    }

    private fun executeTap(action: RecordedAction): Boolean {
        val path = Path().apply {
            moveTo(action.startX.toFloat(), action.startY.toFloat())
        }

        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, action.durationMs.coerceAtLeast(50)))
            .build()

        return dispatchGesture(gesture)
    }

    private fun executeDoubleTap(action: RecordedAction): Boolean {
        // First tap
        val path1 = Path().apply {
            moveTo(action.startX.toFloat(), action.startY.toFloat())
        }
        val gesture1 = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path1, 0, 50))
            .build()

        if (!dispatchGesture(gesture1)) return false

        // Small delay between taps (hardcoded internal double-tap delay)
        Thread.sleep(150)

        // Second tap
        val path2 = Path().apply {
            moveTo(action.startX.toFloat(), action.startY.toFloat())
        }
        val gesture2 = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path2, 0, 50))
            .build()

        return dispatchGesture(gesture2)
    }

    private fun executeLongPress(action: RecordedAction): Boolean {
        val path = Path().apply {
            moveTo(action.startX.toFloat(), action.startY.toFloat())
        }

        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(
                path,
                0,
                action.durationMs.coerceAtLeast(600)
            ))
            .build()

        return dispatchGesture(gesture)
    }

    private fun executeSwipe(action: RecordedAction): Boolean {
        val path = Path().apply {
            moveTo(action.startX.toFloat(), action.startY.toFloat())
            lineTo(action.endX.toFloat(), action.endY.toFloat())
        }

        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(
                path,
                0,
                action.durationMs.coerceAtLeast(200)
            ))
            .build()

        return dispatchGesture(gesture)
    }

    private fun dispatchGesture(gesture: GestureDescription): Boolean {
        if (shouldStop.get()) return false
        
        val latch = CountDownLatch(1)
        val result = AtomicBoolean(false)

        val callback = object : AccessibilityService.GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                result.set(true)
                latch.countDown()
            }

            override fun onCancelled(gestureDescription: GestureDescription?) {
                result.set(false)
                latch.countDown()
            }
        }

        val dispatched = accessibilityService.dispatchGesture(gesture, callback, null)

        if (!dispatched) {
            logger.w("ExecutionEngine", "dispatchGesture rejected by system")
            return false
        }

        // Wait for completion with per-action timeout
        val completed = try {
            latch.await(actionTimeoutMs, TimeUnit.MILLISECONDS)
        } catch (e: InterruptedException) {
            logger.d("ExecutionEngine", "dispatchGesture wait interrupted")
            throw e
        }

        if (!completed) {
            logger.w("ExecutionEngine", "Gesture timed out (no callback from system within ${actionTimeoutMs}ms)")
            return false
        }

        return result.get()
    }

    private fun startWatchdog() {
        // No-op: replaced by global watchdog
    }

    private fun stopWatchdog() {
        // No-op: replaced by global watchdog
    }

    /**
     * Show visual feedback for executed action.
     * Uses different colors than recording feedback.
     */
    private fun showExecutionFeedback(action: RecordedAction) {
        val color = when (action.type) {
            RecordedActionType.tap.value -> Color.parseColor("#4CAF50")      // Green (lighter)
            RecordedActionType.doubleTap.value -> Color.parseColor("#00BCD4") // Cyan
            RecordedActionType.longPress.value -> Color.parseColor("#2196F3") // Blue
            RecordedActionType.swipe.value -> Color.parseColor("#FF9800")    // Orange
            else -> Color.GRAY
        }

        try {
            // For swipe, show both start and end points
            if (action.type == RecordedActionType.swipe.value) {
                showDot(action.startX.toFloat(), action.startY.toFloat(), Color.parseColor("#F44336"), 800L) // Red start
                showDot(action.endX.toFloat(), action.endY.toFloat(), Color.parseColor("#FF9800"), 800L)   // Orange end
            } else {
                showDot(action.startX.toFloat(), action.startY.toFloat(), color, 600L)
            }
        } catch (e: Exception) {
            logger.e("ExecutionEngine", "Failed to show visual feedback", e)
        }
    }

    private fun showDot(x: Float, y: Float, color: Int, durationMs: Long) {
        val dot = View(context).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(color)
                setStroke(4, Color.WHITE)
            }
        }

        val layoutParams = WindowManager.LayoutParams(
            44, 44,
            (x - 22).toInt(),
            (y - 22).toInt(),
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        try {
            windowManager.addView(dot, layoutParams)
            visualFeedbackViews.add(dot)

            mainHandler.postDelayed({
                try {
                    windowManager.removeView(dot)
                    visualFeedbackViews.remove(dot)
                } catch (_: Throwable) {}
            }, durationMs)
        } catch (e: Exception) {
            logger.e("ExecutionEngine", "Failed to add feedback dot", e)
        }
    }

    private fun clearVisualFeedback() {
        for (view in visualFeedbackViews.toList()) {
            try {
                windowManager.removeView(view)
            } catch (_: Throwable) {}
        }
        visualFeedbackViews.clear()
    }

    private fun buildSummary(): ExecutionSummary {
        val total = actions.size
        // During execution, currentActionIndex is the one we are WORKING ON.
        // After execution, it should be total or -1.
        val completed = if (isExecuting.get()) currentActionIndex else total

        return ExecutionSummary(
            isExecuting = isExecuting.get(),
            isPaused = isPaused.get(),
            totalActions = total,
            completedActions = completed.coerceAtLeast(0).coerceAtMost(total),
            failedActions = 0, // In V1 we don't track persistent failure count in summary yet
            currentActionIndex = if (isExecuting.get()) currentActionIndex else -1,
            error = if (shouldStop.get() && isExecuting.get()) "Stopped" else null,
        )
    }
}

/**
 * Configuration for execution.
 */
data class ExecutionConfig(
    val delayBetweenActionsMs: Long = 1000L,
    val retryCount: Int = 0,
    val enableVisualFeedback: Boolean = true,
    val stopOnError: Boolean = false,
)

/**
 * Summary of execution state/results.
 */
data class ExecutionSummary(
    val isExecuting: Boolean,
    val isPaused: Boolean = false,
    val totalActions: Int,
    val completedActions: Int,
    val failedActions: Int,
    val currentActionIndex: Int = -1,
    val error: String? = null,
) {
    fun toMap(): Map<String, Any> {
        val map = mutableMapOf(
            "isExecuting" to isExecuting,
            "isPaused" to isPaused,
            "totalActions" to totalActions,
            "completedActions" to completedActions,
            "failedActions" to failedActions,
            "currentActionIndex" to currentActionIndex,
        )
        error?.let { map["error"] = it }
        return map
    }
}
