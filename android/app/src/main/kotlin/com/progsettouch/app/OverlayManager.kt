package com.progsettouch.app

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import kotlin.math.abs

class OverlayManager(
    private val context: Context,
) {
    private val windowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private var iconView: ImageView? = null
    private var currentState: AppState = AppState.IDLE

    var onStopRequested: (() -> Unit)? = null

    fun show(): Boolean {
        if (overlayView != null) {
            return true
        }

        val params =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = 24
                y = 240
            }

        val view = buildOverlayView(params)

        return try {
            windowManager.addView(view, params)
            overlayView = view
            layoutParams = params
            true
        } catch (_: Throwable) {
            false
        }
    }

    fun hide() {
        val view = overlayView ?: return

        try {
            windowManager.removeView(view)
        } catch (_: Throwable) {
        } finally {
            overlayView = null
            layoutParams = null
        }
    }

    fun isVisible(): Boolean = overlayView != null

    fun updateState(state: AppState) {
        currentState = state
        val icon = iconView ?: return
        val container = overlayView ?: return

        when (state) {
            AppState.EXECUTING -> {
                icon.setImageResource(android.R.drawable.ic_media_pause)
                (container.background as? GradientDrawable)?.setColor(0xFFB42318.toInt()) // Red
            }
            else -> {
                icon.setImageResource(android.R.drawable.ic_media_play)
                (container.background as? GradientDrawable)?.setColor(0xDD176B5B.toInt()) // Teal
            }
        }
    }

    private fun buildOverlayView(params: WindowManager.LayoutParams): View {
        val container =
            FrameLayout(context).apply {
                background =
                    GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(0xDD176B5B.toInt())
                    }
                setPadding(28, 28, 28, 28)
                elevation = 12f
            }

        val icon =
            ImageView(context).apply {
                setImageResource(android.R.drawable.ic_media_play)
                setColorFilter(0xFFFFFFFF.toInt())
            }
        iconView = icon

        container.addView(icon)

        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f

        container.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    val deltaX = (event.rawX - initialTouchX).toInt()
                    val deltaY = (event.rawY - initialTouchY).toInt()
                    params.x = initialX + deltaX
                    params.y = initialY + deltaY
                    updateLayout(container, params)
                    true
                }

                MotionEvent.ACTION_UP -> {
                    val isClick =
                        abs(event.rawX - initialTouchX) < 10f &&
                            abs(event.rawY - initialTouchY) < 10f

                    if (isClick) {
                        if (currentState == AppState.EXECUTING) {
                            onStopRequested?.invoke()
                        } else {
                            openApp()
                        }
                        container.performClick()
                    }
                    true
                }

                else -> false
            }
        }

        return container
    }

    private fun updateLayout(view: View, params: WindowManager.LayoutParams) {
        try {
            windowManager.updateViewLayout(view, params)
        } catch (_: Throwable) {
        }
    }

    private fun openApp() {
        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }

        if (launchIntent != null) {
            context.startActivity(launchIntent)
        }
    }
}
