package com.progsettouch.app

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView

class PointCaptureManager(
    private val context: Context,
) {
    private val windowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val logger = LogManager.getInstance(context)

    private var captureView: View? = null
    private var onCaptureComplete: ((CaptureResult) -> Unit)? = null

    val isCapturing: Boolean
        get() = captureView != null

    fun startCapture(onComplete: (CaptureResult) -> Unit) {
        logger.d("PointCaptureManager", "startCapture() called, current isCapturing=$isCapturing")

        // Важно: сначала сохраняем старый callback, устанавливаем новый,
        // и только потом закрываем старый view (если есть)
        // Это нужно для Swipe где вызывается второй startCapture для end point
        val hadExistingView = captureView != null

        // Устанавливаем новый callback ПЕРЕД закрытием старого view
        onCaptureComplete = onComplete

        if (hadExistingView) {
            logger.d("PointCaptureManager", "Capture already active, removing old view")
            // Важно: сначала отключаем touch listener, чтобы старый view
            // не мог вызвать callback после установки нового
            captureView?.setOnTouchListener(null)
            // Просто удаляем view, НЕ вызываем dismiss() который сбросит onCaptureComplete
            try {
                windowManager.removeView(captureView)
                logger.d("PointCaptureManager", "Old capture view removed")
            } catch (e: Throwable) {
                logger.e("PointCaptureManager", "Error removing old view", e)
            }
            captureView = null
        }

        val layoutParams =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
            }

        val view = buildCaptureView()

        try {
            windowManager.addView(view, layoutParams)
            captureView = view
            logger.i("PointCaptureManager", "Capture view added successfully")
        } catch (e: Throwable) {
            logger.e("PointCaptureManager", "Failed to add capture view", e)
            onCaptureComplete = null
        }
    }

    fun dismiss() {
        val view = captureView ?: return

        try {
            windowManager.removeView(view)
            logger.d("PointCaptureManager", "Capture view dismissed")
        } catch (e: Throwable) {
            logger.e("PointCaptureManager", "Error dismissing capture view", e)
        } finally {
            captureView = null
            onCaptureComplete = null
        }
    }

    private fun buildCaptureView(): View {
        val container =
            FrameLayout(context).apply {
                setBackgroundColor(0x44000000)
                isClickable = true
                isFocusable = false
            }

        val hintText =
            TextView(context).apply {
                text = context.getString(R.string.point_capture_hint)
                setTextColor(Color.WHITE)
                textSize = 18f
                setShadowLayer(4f, 0f, 0f, Color.BLACK)
                gravity = Gravity.CENTER
            }

        val hintParams =
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
            ).apply {
                gravity = Gravity.CENTER
            }

        container.addView(hintText, hintParams)

        container.setOnTouchListener { view, event ->
            logger.d("PointCaptureManager", "onTouch: action=${event.actionMasked}, x=${event.rawX}, y=${event.rawY}")
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    logger.i("PointCaptureManager", "ACTION_DOWN received at (${event.rawX}, ${event.rawY})")
                    val result =
                        CaptureResult(
                            x = event.rawX,
                            y = event.rawY,
                            cancelled = false,
                        )
                    // Важно: сначала сохраняем и очищаем callback, потом вызываем!
                    // Иначе если callback вызовет startCapture() для второй точки (свайп),
                    // то последующий dismiss() сбросит новый onCaptureComplete
                    val callback = onCaptureComplete
                    onCaptureComplete = null  // Очищаем ДО вызова callback
                    callback?.invoke(result)
                    logger.i("PointCaptureManager", "Capture complete callback invoked with (${result.x}, ${result.y})")
                    // Удаляем view без сброса onCaptureComplete (уже null)
                    captureView?.let { view ->
                        try {
                            windowManager.removeView(view)
                            logger.d("PointCaptureManager", "Capture view removed after callback")
                        } catch (e: Throwable) {
                            logger.e("PointCaptureManager", "Error removing capture view", e)
                        }
                    }
                    captureView = null
                    true
                }

                MotionEvent.ACTION_CANCEL -> {
                    logger.w("PointCaptureManager", "ACTION_CANCEL received")
                    val result =
                        CaptureResult(
                            x = 0f,
                            y = 0f,
                            cancelled = true,
                        )
                    // Очищаем callback ДО вызова, затем удаляем view
                    val callback = onCaptureComplete
                    onCaptureComplete = null
                    callback?.invoke(result)
                    captureView?.let { view ->
                        try {
                            windowManager.removeView(view)
                        } catch (_: Throwable) {
                        }
                    }
                    captureView = null
                    true
                }

                else -> false
            }
        }

        return container
    }

    data class CaptureResult(
        val x: Float,
        val y: Float,
        val cancelled: Boolean,
    )
}
