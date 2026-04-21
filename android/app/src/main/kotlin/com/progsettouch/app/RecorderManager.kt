package com.progsettouch.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.hypot
import org.json.JSONArray
import org.json.JSONObject

enum class RecorderMode {
    CONTINUOUS,
    POINT_CAPTURE,
}

class RecorderManager(
        private val context: Context,
) {
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    private val actionClassifier = GestureActionClassifier()
    private val recordedActions = mutableListOf<RecordedAction>()
    private val pointCaptureManager = PointCaptureManager(context)
    private val logger = LogManager.getInstance(context)

    private var recorderView: View? = null
    private var recorderControlView: View? = null
    private var sessionStartMs: Long = 0L
    private var currentGesture: ActiveGesture? = null
    private var lastTapSnapshot: TapSnapshot? = null
    private var currentMode: RecorderMode = RecorderMode.CONTINUOUS
    private var isPointCaptureRecording = false
    private var onStopRequested: ((RecorderSummary) -> Unit)? = null
    private var pendingSwipeStart: Pair<Float, Float>? = null
    private val visualFeedbackViews = mutableListOf<View>()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastTapData: TapData? = null
    private val doubleTapWindowMs = 280L
    private val doubleTapDistanceThreshold = 32.0
    private var dispatchedGestureInFlight = 0
    private val dragThresholdPx = 12f

    private val prefs = context.getSharedPreferences("recorder_prefs", Context.MODE_PRIVATE)
    private var previousActionsBackup: List<RecordedAction>? = null

    init {
        loadActions()
    }

    private fun loadActions() {
        val jsonString = prefs.getString("recorded_actions", null) ?: return
        try {
            val array = JSONArray(jsonString)
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                recordedActions.add(
                        RecordedAction(
                                type = obj.getString("type"),
                                pointerCount = obj.getInt("pointerCount"),
                                startX = obj.getDouble("startX"),
                                startY = obj.getDouble("startY"),
                                endX = obj.getDouble("endX"),
                                endY = obj.getDouble("endY"),
                                durationMs = obj.getLong("durationMs")
                        )
                )
            }
            logger.i("RecorderManager", "Loaded ${recordedActions.size} actions from prefs")
        } catch (e: Exception) {
            logger.e("RecorderManager", "Failed to load actions", e)
        }
    }

    private fun saveActions() {
        try {
            val array = JSONArray()
            for (action in recordedActions) {
                val obj =
                        JSONObject().apply {
                            put("type", action.type)
                            put("pointerCount", action.pointerCount)
                            put("startX", action.startX)
                            put("startY", action.startY)
                            put("endX", action.endX)
                            put("endY", action.endY)
                            put("durationMs", action.durationMs)
                        }
                array.put(obj)
            }
            prefs.edit().putString("recorded_actions", array.toString()).apply()
            logger.d("RecorderManager", "Saved ${recordedActions.size} actions to prefs")
        } catch (e: Exception) {
            logger.e("RecorderManager", "Failed to save actions", e)
        }
    }

    fun setOnStopRequested(listener: (RecorderSummary) -> Unit) {
        onStopRequested = listener
    }

    fun start(mode: RecorderMode = RecorderMode.CONTINUOUS): RecorderSummary {
        logger.d("RecorderManager", "start() called with mode=$mode, isRecording=${isRecording()}")

        if (isRecording()) {
            logger.w("RecorderManager", "Already recording, returning current summary")
            return buildSummary()
        }

        currentMode =
                if (mode == RecorderMode.CONTINUOUS) {
                    logger.w(
                            "RecorderManager",
                            "CONTINUOUS mode is remapped to POINT_CAPTURE to keep recording non-blocking.",
                    )
                    RecorderMode.POINT_CAPTURE
                } else {
                    mode
                }
        previousActionsBackup = recordedActions.toList()
        recordedActions.clear()
        currentGesture = null
        lastTapSnapshot = null
        pendingSwipeStart = null
        sessionStartMs = System.currentTimeMillis()
        isPointCaptureRecording = true

        logger.i("RecorderManager", "Starting recording in $currentMode mode")

        return when (currentMode) {
            RecorderMode.CONTINUOUS -> startContinuous()
            RecorderMode.POINT_CAPTURE -> startPointCapture()
        }
    }

    private fun startContinuous(): RecorderSummary {
        val layoutParams =
                WindowManager.LayoutParams(
                                WindowManager.LayoutParams.MATCH_PARENT,
                                WindowManager.LayoutParams.MATCH_PARENT,
                                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                                PixelFormat.TRANSLUCENT,
                        )
                        .apply { gravity = Gravity.TOP or Gravity.START }

        val recordingView =
                FrameLayout(context).apply {
                    setBackgroundColor(Color.TRANSPARENT)
                    isClickable = true
                    isFocusable = false
                    setOnTouchListener(::handleTouchEvent)
                }

        val controlParams =
                WindowManager.LayoutParams(
                                WindowManager.LayoutParams.WRAP_CONTENT,
                                WindowManager.LayoutParams.WRAP_CONTENT,
                                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                                PixelFormat.TRANSLUCENT,
                        )
                        .apply {
                            gravity = Gravity.TOP or Gravity.END
                            x = 24
                            y = 96
                        }

        val controlView = buildContinuousControlView()

        return try {
            windowManager.addView(recordingView, layoutParams)
            windowManager.addView(controlView, controlParams)
            recorderView = recordingView
            recorderControlView = controlView
            buildSummary()
        } catch (_: Throwable) {
            stop()
        }
    }

    private fun startPointCapture(): RecorderSummary {
        logger.d("RecorderManager", "startPointCapture() called")

        val controlParams =
                WindowManager.LayoutParams(
                                WindowManager.LayoutParams.WRAP_CONTENT,
                                WindowManager.LayoutParams.WRAP_CONTENT,
                                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                                PixelFormat.TRANSLUCENT,
                        )
                        .apply {
                            gravity = Gravity.TOP or Gravity.END
                            x = 24
                            y = 96
                        }

        val controlView = buildPointCaptureControlView(controlParams)

        return try {
            windowManager.addView(controlView, controlParams)
            recorderControlView = controlView
            logger.i("RecorderManager", "Point capture control view added successfully")
            buildSummary()
        } catch (e: Throwable) {
            logger.e("RecorderManager", "Failed to add point capture control view", e)
            stop()
        }
    }

    /** Показывает визуальный feedback (цветную точку) на экране в указанных координатах */
    private fun showVisualFeedback(
            x: Float,
            y: Float,
            color: Int = Color.GREEN,
            durationMs: Long = 1000L,
    ) {
        try {
            val dotSize = 40

            val dot =
                    View(context).apply {
                        background =
                                GradientDrawable().apply {
                                    shape = GradientDrawable.OVAL
                                    setColor(color)
                                    setStroke(4, Color.WHITE)
                                }
                    }

            val layoutParams =
                    WindowManager.LayoutParams(
                                    dotSize,
                                    dotSize,
                                    (x - dotSize / 2).toInt(),
                                    (y - dotSize / 2).toInt(),
                                    WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                                            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                                            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                                    PixelFormat.TRANSLUCENT,
                            )
                            .apply { gravity = Gravity.TOP or Gravity.START }

            windowManager.addView(dot, layoutParams)
            visualFeedbackViews.add(dot)

            // Удаляем точку через durationMs
            mainHandler.postDelayed(
                    {
                        try {
                            windowManager.removeView(dot)
                            visualFeedbackViews.remove(dot)
                        } catch (_: Throwable) {}
                    },
                    durationMs
            )
        } catch (e: Throwable) {
            logger.e("RecorderManager", "Failed to show visual feedback", e)
        }
    }

    /** Очищает все визуальные feedback точки */
    private fun clearVisualFeedback() {
        for (view in visualFeedbackViews.toList()) {
            try {
                windowManager.removeView(view)
            } catch (_: Throwable) {}
        }
        visualFeedbackViews.clear()
    }

    fun stop(): RecorderSummary {
        logger.d(
                "RecorderManager",
                "stop() called, recordedActions=${recordedActions.size}, currentMode=$currentMode, isRecording=${isRecording()}"
        )
        val view = recorderView
        val controlView = recorderControlView

        if (view != null) {
            try {
                windowManager.removeView(view)
                logger.d("RecorderManager", "Removed recorder view")
            } catch (e: Throwable) {
                logger.w("RecorderManager", "Error removing recorder view: $e")
            }
        }

        if (controlView != null) {
            try {
                windowManager.removeView(controlView)
                logger.d("RecorderManager", "Removed control view")
            } catch (e: Throwable) {
                logger.w("RecorderManager", "Error removing control view: $e")
            }
        }

        pointCaptureManager.dismiss()
        clearVisualFeedback()

        recorderView = null
        recorderControlView = null
        currentGesture = null
        isPointCaptureRecording = false
        lastTapData = null

        // Restore previous actions if the current session was empty
        if (recordedActions.isEmpty() && previousActionsBackup != null) {
            recordedActions.addAll(previousActionsBackup!!)
            logger.i(
                    "RecorderManager",
                    "Current session is empty, restored ${recordedActions.size} previous actions"
            )
        }
        previousActionsBackup = null

        saveActions()

        logger.d(
                "RecorderManager",
                "After cleanup: recorderView=$recorderView, isPointCaptureRecording=$isPointCaptureRecording, isRecording=${isRecording()}"
        )

        val summary = buildSummary()
        logger.i(
                "RecorderManager",
                "Recording stopped. Summary: isRecording=${summary.isRecording}, totalActions=${summary.totalActions}, mode=${summary.mode}"
        )
        return summary
    }

    fun isRecording(): Boolean =
            when (currentMode) {
                RecorderMode.CONTINUOUS -> recorderView != null
                RecorderMode.POINT_CAPTURE -> isPointCaptureRecording
            }

    fun summary(): RecorderSummary = buildSummary()

    fun clearRecordedActions(): RecorderSummary {
        recordedActions.clear()
        previousActionsBackup = null
        currentGesture = null
        lastTapSnapshot = null
        lastTapData = null
        pendingSwipeStart = null
        saveActions()
        logger.i("RecorderManager", "Recorded actions cleared")
        return buildSummary()
    }

    fun recordManualTap(x: Float, y: Float) {
        logger.d(
                "RecorderManager",
                "recordManualTap called: x=$x, y=$y, isRecording=${isRecording()}"
        )
        if (!isRecording()) {
            logger.w("RecorderManager", "recordManualTap: Not recording, ignoring tap")
            return
        }

        val now = System.currentTimeMillis()
        val lastTap = lastTapData
        val isDoubleTap =
                lastTap != null &&
                        (now - lastTap.timeMs) <= doubleTapWindowMs &&
                        kotlin.math.hypot(x - lastTap.x, y - lastTap.y) <=
                                doubleTapDistanceThreshold

        val actionType =
                if (isDoubleTap) {
                    logger.i("RecorderManager", "Double tap detected at ($x, $y)")
                    lastTapData = null // Сбрасываем для следующего цикла
                    RecordedActionType.doubleTap.value
                } else {
                    lastTapData = TapData(x, y, now)
                    RecordedActionType.tap.value
                }

        val action =
                RecordedAction(
                        type = actionType,
                        pointerCount = 1,
                        startX = x.toDouble(),
                        startY = y.toDouble(),
                        endX = x.toDouble(),
                        endY = y.toDouble(),
                        durationMs = 50L,
                )
        recordedActions += action
        logger.i(
                "RecorderManager",
                "Tap recorded at ($x, $y). Type=$actionType, Total actions: ${recordedActions.size}"
        )
        showVisualFeedback(x, y, if (isDoubleTap) Color.CYAN else Color.GREEN, 800L)
    }

    fun recordManualLongPress(x: Float, y: Float, durationMs: Long = 800L) {
        if (!isRecording()) {
            logger.w("RecorderManager", "recordManualLongPress called but not recording")
            return
        }

        logger.i(
                "RecorderManager",
                "Recording long press at ($x, $y) with duration ${durationMs}ms"
        )

        val action =
                RecordedAction(
                        type = RecordedActionType.longPress.value,
                        pointerCount = 1,
                        startX = x.toDouble(),
                        startY = y.toDouble(),
                        endX = x.toDouble(),
                        endY = y.toDouble(),
                        durationMs = durationMs,
                )
        recordedActions += action
        logger.i("RecorderManager", "Long press recorded. Total actions: ${recordedActions.size}")
        showVisualFeedback(x, y, Color.BLUE, 1200L)
    }

    fun recordManualDoubleTap(x: Float, y: Float) {
        if (!isRecording()) {
            logger.w("RecorderManager", "recordManualDoubleTap called but not recording")
            return
        }

        logger.i("RecorderManager", "Recording double tap at ($x, $y)")

        val action =
                RecordedAction(
                        type = RecordedActionType.doubleTap.value,
                        pointerCount = 1,
                        startX = x.toDouble(),
                        startY = y.toDouble(),
                        endX = x.toDouble(),
                        endY = y.toDouble(),
                        durationMs = 50L,
                )
        recordedActions += action
        logger.i("RecorderManager", "Double tap recorded. Total actions: ${recordedActions.size}")
        showVisualFeedback(x, y, Color.CYAN, 1000L)
    }

    fun startSwipeRecording(x: Float, y: Float) {
        if (!isRecording()) return
        pendingSwipeStart = x to y
    }

    fun completeSwipeRecording(endX: Float, endY: Float) {
        if (!isRecording()) return
        val start = pendingSwipeStart ?: return

        val action =
                RecordedAction(
                        type = RecordedActionType.swipe.value,
                        pointerCount = 1,
                        startX = start.first.toDouble(),
                        startY = start.second.toDouble(),
                        endX = endX.toDouble(),
                        endY = endY.toDouble(),
                        durationMs = 300L,
                )
        recordedActions += action
        pendingSwipeStart = null
    }

    private fun handleTouchEvent(view: View, event: MotionEvent): Boolean {
        if (dispatchedGestureInFlight > 0) {
            logger.d(
                    "RecorderManager",
                    "Ignoring touch event while injected gesture is in flight: action=${event.actionMasked}",
            )
            return true
        }

        val actionName =
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> "DOWN"
                    MotionEvent.ACTION_UP -> "UP"
                    MotionEvent.ACTION_MOVE -> "MOVE"
                    MotionEvent.ACTION_CANCEL -> "CANCEL"
                    MotionEvent.ACTION_POINTER_DOWN -> "POINTER_DOWN"
                    MotionEvent.ACTION_POINTER_UP -> "POINTER_UP"
                    else -> "OTHER"
                }
        logger.d(
                "RecorderManager",
                "Touch event: $actionName at (${event.x.toInt()}, ${event.y.toInt()})"
        )

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                currentGesture = ActiveGesture.from(event)
                logger.d("RecorderManager", "New gesture started at (${event.x}, ${event.y})")
            }
            MotionEvent.ACTION_POINTER_DOWN,
            MotionEvent.ACTION_MOVE,
            MotionEvent.ACTION_POINTER_UP,
            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL -> {
                currentGesture?.update(event)
            }
        }

        if (event.actionMasked == MotionEvent.ACTION_UP ||
                        event.actionMasked == MotionEvent.ACTION_CANCEL
        ) {
            currentGesture?.let { gesture ->
                logger.d(
                        "RecorderManager",
                        "Gesture ended: distance=${gesture.distance()}, duration=${gesture.durationMs()}ms, pointers=${gesture.maxPointerCount}"
                )
                classifyAndStore(gesture)
            }
            currentGesture = null
        }

        return true
    }

    private fun buildContinuousControlView(): View {
        val container =
                LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    background =
                            GradientDrawable().apply {
                                cornerRadius = 36f
                                setColor(0xE0222222.toInt())
                            }
                    setPadding(24, 18, 24, 18)
                    elevation = 12f
                    isClickable = true
                    isFocusable = false
                    setOnClickListener {
                        val summary = stop()
                        openApp()
                        onStopRequested?.invoke(summary)
                    }
                }

        val icon =
                ImageView(context).apply {
                    setImageResource(android.R.drawable.ic_media_pause)
                    setColorFilter(0xFFFFFFFF.toInt())
                }

        val label =
                TextView(context).apply {
                    text = context.getString(R.string.recorder_stop_label)
                    setTextColor(Color.WHITE)
                    textSize = 16f
                    setPadding(16, 0, 0, 0)
                }

        container.addView(icon)
        container.addView(label)
        return container
    }

    private fun buildPointCaptureControlView(
            controlParams: WindowManager.LayoutParams,
    ): View {
        val container =
                LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    background =
                            GradientDrawable().apply {
                                cornerRadius = 24f
                                setColor(0xE0222222.toInt())
                            }
                    setPadding(16, 16, 16, 16)
                    elevation = 12f
                }

        val dragHandle =
                LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.CENTER_VERTICAL
                    setPadding(4, 0, 4, 12)
                }

        val dragIcon =
                ImageView(context).apply {
                    setImageResource(android.R.drawable.ic_menu_more)
                    setColorFilter(0xFFB8C7D9.toInt())
                }

        val actionsLabel =
                TextView(context).apply {
                    text = "Step-by-step capture"
                    setTextColor(Color.WHITE)
                    textSize = 14f
                    setPadding(12, 0, 0, 0)
                }

        dragHandle.addView(dragIcon)
        dragHandle.addView(actionsLabel)
        attachDragHandle(dragHandle, container, controlParams)

        val tapBtn =
                createActionButton(android.R.drawable.ic_input_add, "Choose tap point") {
                    startPointCaptureForTap()
                }

        val swipeBtn =
                createActionButton(
                        android.R.drawable.ic_menu_sort_alphabetically,
                        "Choose swipe start and end"
                ) {
                    logger.d("RecorderManager", "SWIPE BUTTON CLICKED!")
                    startPointCaptureForSwipe()
                }
        logger.d("RecorderManager", "Swipe button created: $swipeBtn")

        val longPressBtn =
                createActionButton(
                        android.R.drawable.ic_lock_idle_lock,
                        "Choose long press point"
                ) { startPointCaptureForLongPress() }

        val doubleTapBtn =
                createActionButton(android.R.drawable.ic_menu_crop, "Choose double tap point") {
                    startPointCaptureForDoubleTap()
                }

        val stopBtn =
                createActionButton(android.R.drawable.ic_media_pause, "Finish recording") {
                    val summary = stop()
                    openApp()
                    onStopRequested?.invoke(summary)
                }

        container.addView(dragHandle)
        container.addView(tapBtn)
        container.addView(swipeBtn)
        container.addView(longPressBtn)
        container.addView(doubleTapBtn)
        container.addView(stopBtn)
        return container
    }

    private fun attachDragHandle(
            handleView: View,
            panelView: View,
            layoutParams: WindowManager.LayoutParams,
    ) {
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var hasMoved = false

        handleView.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams.x
                    initialY = layoutParams.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    hasMoved = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val deltaX = (event.rawX - initialTouchX).toInt()
                    val deltaY = (event.rawY - initialTouchY).toInt()
                    hasMoved =
                            hasMoved ||
                                    kotlin.math.abs(event.rawX - initialTouchX) > dragThresholdPx ||
                                    kotlin.math.abs(event.rawY - initialTouchY) > dragThresholdPx
                    layoutParams.x = initialX - deltaX
                    layoutParams.y = initialY + deltaY
                    updateControlLayout(panelView, layoutParams)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!hasMoved) {
                        handleView.performClick()
                    }
                    true
                }
                MotionEvent.ACTION_CANCEL -> true
                else -> false
            }
        }
    }

    private fun updateControlLayout(
            view: View,
            params: WindowManager.LayoutParams,
    ) {
        try {
            windowManager.updateViewLayout(view, params)
        } catch (e: Throwable) {
            logger.w("RecorderManager", "Failed to update floating recorder panel: $e")
        }
    }

    private fun createActionButton(
            iconRes: Int,
            buttonText: String,
            onClick: () -> Unit
    ): LinearLayout {
        return LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(12, 8, 12, 8)
            isClickable = true
            isFocusable = false
            background =
                    GradientDrawable().apply {
                        cornerRadius = 8f
                        setColor(0x33FFFFFF.toInt())
                    }
            setOnClickListener {
                logger.d("RecorderManager", "Button clicked: $buttonText")
                onClick()
            }

            val icon =
                    ImageView(context).apply {
                        setImageResource(iconRes)
                        setColorFilter(0xFFFFFFFF.toInt())
                        layoutParams = LinearLayout.LayoutParams(48, 48)
                    }

            val label =
                    TextView(context).apply {
                        text = buttonText
                        setTextColor(Color.WHITE)
                        textSize = 14f
                        setPadding(12, 0, 0, 0)
                    }

            addView(icon)
            addView(label)
        }
    }

    private fun startPointCaptureForTap() {
        logger.d("RecorderManager", "startPointCaptureForTap() called")
        pointCaptureManager.startCapture { result ->
            logger.d(
                    "RecorderManager",
                    "Tap capture result: cancelled=${result.cancelled}, x=${result.x}, y=${result.y}"
            )
            if (!result.cancelled) {
                recordManualTap(result.x, result.y)
            } else {
                logger.w("RecorderManager", "Tap capture was cancelled")
            }
        }
    }

    private fun startPointCaptureForLongPress() {
        logger.d("RecorderManager", "startPointCaptureForLongPress() called")
        pointCaptureManager.startCapture { result ->
            logger.d(
                    "RecorderManager",
                    "Long press capture result: cancelled=${result.cancelled}, x=${result.x}, y=${result.y}"
            )
            if (!result.cancelled) {
                recordManualLongPress(result.x, result.y)
            } else {
                logger.w("RecorderManager", "Long press capture was cancelled")
            }
        }
    }

    private fun startPointCaptureForDoubleTap() {
        logger.d("RecorderManager", "startPointCaptureForDoubleTap() called")
        pointCaptureManager.startCapture { result ->
            logger.d(
                    "RecorderManager",
                    "Double tap capture result: cancelled=${result.cancelled}, x=${result.x}, y=${result.y}"
            )
            if (!result.cancelled) {
                recordManualDoubleTap(result.x, result.y)
            } else {
                logger.w("RecorderManager", "Double tap capture was cancelled")
            }
        }
    }

    private fun startPointCaptureForSwipe() {
        logger.d("RecorderManager", "startPointCaptureForSwipe() called - waiting for start point")
        pointCaptureManager.startCapture { result ->
            logger.d(
                    "RecorderManager",
                    "Swipe start capture result: cancelled=${result.cancelled}, x=${result.x}, y=${result.y}"
            )
            if (!result.cancelled) {
                val startX = result.x
                val startY = result.y
                logger.d(
                        "RecorderManager",
                        "Swipe start captured at ($startX, $startY), waiting for end point"
                )

                // Задержка нужна чтобы:
                // 1. WindowManager успел удалить старый view
                // 2. Пользователь видел момент между стартом и концом свайпа
                mainHandler.postDelayed(
                        {
                            pointCaptureManager.startCapture { endResult ->
                                logger.d(
                                        "RecorderManager",
                                        "Swipe end capture result: cancelled=${endResult.cancelled}, x=${endResult.x}, y=${endResult.y}"
                                )
                                if (!endResult.cancelled) {
                                    recordManualSwipe(startX, startY, endResult.x, endResult.y)
                                } else {
                                    logger.w("RecorderManager", "Swipe end capture was cancelled")
                                }
                            }
                        },
                        150
                )
            } else {
                logger.w("RecorderManager", "Swipe start capture was cancelled")
            }
        }
    }

    private fun recordManualSwipe(startX: Float, startY: Float, endX: Float, endY: Float) {
        if (!isRecording()) {
            logger.w("RecorderManager", "recordManualSwipe called but not recording")
            return
        }

        logger.i("RecorderManager", "Recording swipe from ($startX, $startY) to ($endX, $endY)")

        val action =
                RecordedAction(
                        type = RecordedActionType.swipe.value,
                        pointerCount = 1,
                        startX = startX.toDouble(),
                        startY = startY.toDouble(),
                        endX = endX.toDouble(),
                        endY = endY.toDouble(),
                        durationMs = 300L,
                )
        recordedActions += action
        logger.i("RecorderManager", "Swipe recorded. Total actions: ${recordedActions.size}")
        showVisualFeedback(startX, startY, Color.RED, 1000L)
        showVisualFeedback(endX, endY, Color.parseColor("#FF8C00"), 1000L) // Dark Orange
    }

    private fun classifyAndStore(gesture: ActiveGesture) {
        logger.d(
                "RecorderManager",
                "classifyAndStore called with gesture: distance=${gesture.distance()}, duration=${gesture.durationMs()}ms"
        )
        val candidate = actionClassifier.classify(gesture, lastTapSnapshot)
        recordedActions += candidate.action
        lastTapSnapshot = candidate.updatedTapSnapshot
        logger.i(
                "RecorderManager",
                "Action classified: type=${candidate.action.type}, totalActions=${recordedActions.size}"
        )
        dispatchPassThroughGesture(candidate.action)
    }

    private fun dispatchPassThroughGesture(action: RecordedAction) {
        val service = context as? AccessibilityService ?: return
        val path =
                Path().apply {
                    moveTo(action.startX.toFloat(), action.startY.toFloat())
                    if (action.type == RecordedActionType.swipe.value) {
                        lineTo(action.endX.toFloat(), action.endY.toFloat())
                    }
                }

        val durationMs =
                when (action.type) {
                    RecordedActionType.longPress.value -> maxOf(450L, action.durationMs)
                    RecordedActionType.swipe.value -> maxOf(120L, action.durationMs)
                    else -> maxOf(1L, action.durationMs)
                }

        val gesture =
                GestureDescription.Builder()
                        .addStroke(
                                GestureDescription.StrokeDescription(
                                        path,
                                        0L,
                                        durationMs,
                                ),
                        )
                        .build()

        dispatchedGestureInFlight += 1
        service.dispatchGesture(
                gesture,
                object : AccessibilityService.GestureResultCallback() {
                    override fun onCompleted(gestureDescription: GestureDescription?) {
                        dispatchedGestureInFlight = maxOf(0, dispatchedGestureInFlight - 1)
                        logger.d(
                                "RecorderManager",
                                "Pass-through gesture dispatched: type=${action.type}, duration=${durationMs}ms",
                        )
                    }

                    override fun onCancelled(gestureDescription: GestureDescription?) {
                        dispatchedGestureInFlight = maxOf(0, dispatchedGestureInFlight - 1)
                        logger.w(
                                "RecorderManager",
                                "Pass-through gesture cancelled: type=${action.type}",
                        )
                    }
                },
                mainHandler,
        )
    }

    private fun buildSummary(): RecorderSummary {
        val taps = recordedActions.count { it.type == RecordedActionType.tap.value }
        val doubleTaps = recordedActions.count { it.type == RecordedActionType.doubleTap.value }
        val longPresses = recordedActions.count { it.type == RecordedActionType.longPress.value }
        val swipes = recordedActions.count { it.type == RecordedActionType.swipe.value }
        val maxPointers = recordedActions.maxOfOrNull { it.pointerCount } ?: 0

        return RecorderSummary(
                isRecording = isRecording(),
                totalActions = recordedActions.size,
                tapCount = taps,
                doubleTapCount = doubleTaps,
                longPressCount = longPresses,
                swipeCount = swipes,
                maxPointerCount = maxPointers,
                sessionDurationMs =
                        if (sessionStartMs == 0L) 0L
                        else System.currentTimeMillis() - sessionStartMs,
                actions = recordedActions.toList(),
                mode = currentMode.name,
        )
    }

    private fun openApp() {
        val launchIntent =
                context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }

        if (launchIntent != null) {
            context.startActivity(launchIntent)
        }
    }
}

private class GestureActionClassifier {
    private val tapDistanceThreshold = 32.0
    private val swipeDistanceThreshold = 72.0
    private val longPressDurationMs = 450L
    private val doubleTapWindowMs = 280L

    fun classify(
            gesture: ActiveGesture,
            lastTapSnapshot: TapSnapshot?,
    ): ClassificationResult {
        val distance = gesture.distance()
        val durationMs = gesture.durationMs()
        val centroid = gesture.endCentroid()

        val actionType =
                when {
                    distance >= swipeDistanceThreshold -> RecordedActionType.swipe
                    durationMs >= longPressDurationMs -> RecordedActionType.longPress
                    isDoubleTap(gesture, centroid, lastTapSnapshot) -> RecordedActionType.doubleTap
                    else -> RecordedActionType.tap
                }

        val action =
                RecordedAction(
                        type = actionType.value,
                        pointerCount = gesture.maxPointerCount,
                        startX = gesture.startCentroid().first,
                        startY = gesture.startCentroid().second,
                        endX = centroid.first,
                        endY = centroid.second,
                        durationMs = durationMs,
                )

        val updatedTapSnapshot =
                if (actionType == RecordedActionType.tap) {
                    TapSnapshot(
                            eventTimeMs = gesture.endEventTimeMs,
                            x = centroid.first,
                            y = centroid.second,
                    )
                } else {
                    null
                }

        return ClassificationResult(
                action = action,
                updatedTapSnapshot = updatedTapSnapshot,
        )
    }

    private fun isDoubleTap(
            gesture: ActiveGesture,
            centroid: Pair<Double, Double>,
            lastTapSnapshot: TapSnapshot?,
    ): Boolean {
        if (gesture.maxPointerCount != 1 || lastTapSnapshot == null) {
            return false
        }

        if (gesture.durationMs() >= longPressDurationMs) {
            return false
        }

        val timeDelta = gesture.endEventTimeMs - lastTapSnapshot.eventTimeMs
        if (timeDelta > doubleTapWindowMs) {
            return false
        }

        val distance =
                hypot(
                        centroid.first - lastTapSnapshot.x,
                        centroid.second - lastTapSnapshot.y,
                )

        return distance <= tapDistanceThreshold
    }
}

private data class TapData(val x: Float, val y: Float, val timeMs: Long)

private data class ClassificationResult(
        val action: RecordedAction,
        val updatedTapSnapshot: TapSnapshot?,
)

private data class TapSnapshot(
        val eventTimeMs: Long,
        val x: Double,
        val y: Double,
)

private data class ActiveGesture(
        val startEventTimeMs: Long,
        var endEventTimeMs: Long,
        val startPoints: MutableMap<Int, Pair<Double, Double>>,
        val endPoints: MutableMap<Int, Pair<Double, Double>>,
        var maxPointerCount: Int,
) {
    fun update(event: MotionEvent) {
        endEventTimeMs = event.eventTime
        maxPointerCount = maxOf(maxPointerCount, event.pointerCount)

        for (index in 0 until event.pointerCount) {
            val pointerId = event.getPointerId(index)
            val point = event.getX(index).toDouble() to event.getY(index).toDouble()
            startPoints.putIfAbsent(pointerId, point)
            endPoints[pointerId] = point
        }
    }

    fun durationMs(): Long = endEventTimeMs - startEventTimeMs

    fun startCentroid(): Pair<Double, Double> = centroid(startPoints.values.toList())

    fun endCentroid(): Pair<Double, Double> = centroid(endPoints.values.toList())

    fun distance(): Double {
        val start = startCentroid()
        val end = endCentroid()
        return hypot(end.first - start.first, end.second - start.second)
    }

    private fun centroid(points: List<Pair<Double, Double>>): Pair<Double, Double> {
        if (points.isEmpty()) {
            return 0.0 to 0.0
        }

        val averageX = points.sumOf { it.first } / points.size
        val averageY = points.sumOf { it.second } / points.size
        return averageX to averageY
    }

    companion object {
        fun from(event: MotionEvent): ActiveGesture {
            val startPoints = mutableMapOf<Int, Pair<Double, Double>>()
            val endPoints = mutableMapOf<Int, Pair<Double, Double>>()

            for (index in 0 until event.pointerCount) {
                val pointerId = event.getPointerId(index)
                val point = event.getX(index).toDouble() to event.getY(index).toDouble()
                startPoints[pointerId] = point
                endPoints[pointerId] = point
            }

            return ActiveGesture(
                    startEventTimeMs = event.eventTime,
                    endEventTimeMs = event.eventTime,
                    startPoints = startPoints,
                    endPoints = endPoints,
                    maxPointerCount = event.pointerCount,
            )
        }
    }
}

enum class RecordedActionType(val value: String) {
    tap("tap"),
    doubleTap("double_tap"),
    longPress("long_press"),
    swipe("swipe"),
}

data class RecordedAction(
        val type: String,
        val pointerCount: Int,
        val startX: Double,
        val startY: Double,
        val endX: Double,
        val endY: Double,
        val durationMs: Long,
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
                "type" to type,
                "pointerCount" to pointerCount,
                "startX" to startX,
                "startY" to startY,
                "endX" to endX,
                "endY" to endY,
                "durationMs" to durationMs,
        )
    }
}

data class RecorderSummary(
        val isRecording: Boolean,
        val totalActions: Int,
        val tapCount: Int,
        val doubleTapCount: Int,
        val longPressCount: Int,
        val swipeCount: Int,
        val maxPointerCount: Int,
        val sessionDurationMs: Long,
        val actions: List<RecordedAction>,
        val mode: String = RecorderMode.CONTINUOUS.name,
        val error: String? = null,
) {
    fun toMap(): Map<String, Any> {
        val map =
                mutableMapOf(
                        "isRecording" to isRecording,
                        "totalActions" to totalActions,
                        "tapCount" to tapCount,
                        "doubleTapCount" to doubleTapCount,
                        "longPressCount" to longPressCount,
                        "swipeCount" to swipeCount,
                        "maxPointerCount" to maxPointerCount,
                        "sessionDurationMs" to sessionDurationMs,
                        "actions" to actions.map { it.toMap() },
                        "mode" to mode,
                )
        error?.let { map["error"] = it }
        return map
    }
}
