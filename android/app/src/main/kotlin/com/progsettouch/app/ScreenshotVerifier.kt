package com.progsettouch.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.WindowManager
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.math.abs

/**
 * ScreenshotVerifier — visual verification of executed actions.
 *
 * Features:
 * - Downscaled pixel diff (64x64 default)
 * - Region-based diff
 * - Histogram diff
 * - FPS limiting (2-5 fps)
 * - CPU throttling
 * - FLAG_SECURE handling
 */
class ScreenshotVerifier(
    private val context: Context,
) {
    private val logger = LogManager.getInstance(context)
    private val mainHandler = Handler(Looper.getMainLooper())

    // Configuration
    private val defaultConfig = VerifierConfig()

    // MediaProjection
    private var mediaProjection: MediaProjection? = null
    private var mediaProjectionCallback: MediaProjection.Callback? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null

    // FPS limiting
    private var lastCaptureTimeMs = 0L
    private val minCaptureIntervalMs = 200L // 5 fps max

    // CPU throttling
    private val captureLock = Any()
    @Volatile private var lastCaptureFlagSecure = false

    /**
     * Initialize with MediaProjection (must be obtained from user consent).
     */
    fun initialize(newProjection: MediaProjection) {
        synchronized(captureLock) {
            unregisterMediaProjectionCallback()
            virtualDisplay?.release()
            imageReader?.close()
            virtualDisplay = null
            imageReader = null
            mediaProjection?.stop()
            mediaProjection = newProjection
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val cb =
                    object : MediaProjection.Callback() {
                        override fun onStop() {
                            logger.w("ScreenshotVerifier", "MediaProjection onStop")
                            mainHandler.post {
                                MediaProjectionForegroundService.stop(context.applicationContext)
                                synchronized(captureLock) {
                                    unregisterMediaProjectionCallback()
                                    virtualDisplay?.release()
                                    imageReader?.close()
                                    virtualDisplay = null
                                    imageReader = null
                                    mediaProjection = null
                                }
                            }
                        }
                    }
                mediaProjectionCallback = cb
                newProjection.registerCallback(cb, mainHandler)
            }
        }
        logger.i("ScreenshotVerifier", "Initialized with MediaProjection")
    }

    private fun unregisterMediaProjectionCallback() {
        val proj = mediaProjection
        val cb = mediaProjectionCallback
        if (proj != null && cb != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            try {
                proj.unregisterCallback(cb)
            } catch (_: Exception) {
            }
        }
        mediaProjectionCallback = null
    }

    /**
     * Check if MediaProjection is available.
     */
    fun hasMediaProjection(): Boolean = mediaProjection != null

    /**
     * Release resources.
     */
    fun release() {
        synchronized(captureLock) {
            unregisterMediaProjectionCallback()
            virtualDisplay?.release()
            imageReader?.close()
            mediaProjection?.stop()

            virtualDisplay = null
            imageReader = null
            mediaProjection = null
        }
        MediaProjectionForegroundService.stop(context.applicationContext)
        logger.i("ScreenshotVerifier", "Released resources")
    }

    /**
     * Capture screenshot and return bitmap.
     * Returns null if FLAG_SECURE or other error.
     */
    fun captureScreenshot(): Bitmap? {
        // FPS limiting
        val now = SystemClock.elapsedRealtime()
        val timeSinceLastCapture = now - lastCaptureTimeMs
        if (timeSinceLastCapture < minCaptureIntervalMs) {
            Thread.sleep(minCaptureIntervalMs - timeSinceLastCapture)
        }

        synchronized(captureLock) {
            lastCaptureFlagSecure = false
            val projection = mediaProjection ?: run {
                logger.w("ScreenshotVerifier", "MediaProjection not available")
                return null
            }

            return try {
                val (width, height) = getDisplayDimensions()
                val scaledWidth = width / 4
                val scaledHeight = height / 4

                // Create ImageReader
                val reader = ImageReader.newInstance(
                    scaledWidth,
                    scaledHeight,
                    PixelFormat.RGBA_8888,
                    2
                )
                imageReader = reader

                // Create VirtualDisplay
                val display = projection.createVirtualDisplay(
                    "ScreenshotVerifier",
                    scaledWidth,
                    scaledHeight,
                    context.resources.configuration.densityDpi,
                    DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                    reader.surface,
                    null,
                    null
                )
                virtualDisplay = display

                // Wait for image with timeout
                val latch = CountDownLatch(1)
                var bitmap: Bitmap? = null
                var flagSecureDetected = false

                reader.setOnImageAvailableListener({ reader ->
                    try {
                        val image = reader.acquireLatestImage()
                        if (image != null) {
                            try {
                                bitmap = imageToBitmap(image)
                                if (bitmap == null) {
                                    flagSecureDetected = true
                                }
                            } finally {
                                image.close()
                            }
                        }
                    } catch (e: Exception) {
                        logger.e("ScreenshotVerifier", "Error processing image", e)
                    } finally {
                        latch.countDown()
                    }
                }, mainHandler)

                // Wait for capture
                val captured = latch.await(2, TimeUnit.SECONDS)

                // Cleanup
                display.release()
                reader.close()
                virtualDisplay = null
                imageReader = null

                lastCaptureTimeMs = SystemClock.elapsedRealtime()

                if (!captured) {
                    logger.w("ScreenshotVerifier", "Screenshot capture timeout")
                    return null
                }

                if (flagSecureDetected) {
                    lastCaptureFlagSecure = true
                    logger.w("ScreenshotVerifier", "FLAG_SECURE detected, considering as success")
                    return null // Will be treated as success by caller
                }

                bitmap
            } catch (e: Exception) {
                logger.e("ScreenshotVerifier", "Screenshot capture failed", e)
                null
            }
        }
    }

    fun wasLastCaptureFlagSecure(): Boolean = lastCaptureFlagSecure

    /**
     * Compare two screenshots and return similarity score (0.0 - 1.0).
     * 1.0 = identical, 0.0 = completely different
     */
    fun compareScreenshots(
        before: Bitmap,
        after: Bitmap,
        method: ComparisonMethod = ComparisonMethod.PHASH, // Change default to PHASH
        config: VerifierConfig = defaultConfig,
    ): Float {
        return when (method) {
            ComparisonMethod.DOWNSCALED_PIXEL_DIFF -> downscaledPixelDiff(before, after, config.downscaleSize)
            ComparisonMethod.REGION_BASED -> regionBasedDiff(before, after, config.regionSize)
            ComparisonMethod.HISTOGRAM -> histogramDiff(before, after)
            ComparisonMethod.PHASH -> {
                // For PHASH, we use a combination of structural diff and histogram to be both precise and robust
                val structural = phashDiff(before, after)
                val color = histogramDiff(before, after)
                (structural * 0.7f) + (color * 0.3f)
            }
        }
    }

    /**
     * Verify action by comparing screenshots before and after.
     * Returns true if change detected (> threshold).
     */
    fun verifyAction(
        before: Bitmap,
        after: Bitmap,
        config: VerifierConfig = defaultConfig,
    ): Boolean {
        val similarity = compareScreenshots(before, after, config.method, config)
        val changePercent = (1.0f - similarity) * 100

        logger.d("ScreenshotVerifier", "Verification: similarity=$similarity, change=$changePercent%")

        return changePercent >= config.thresholdPercent
    }

    /**
     * Downscaled pixel diff (default method).
     * Downscale both images to small size, compare pixel by pixel.
     */
    private fun downscaledPixelDiff(
        before: Bitmap,
        after: Bitmap,
        targetSize: Int = 64,
    ): Float {
        try {
            // Downscale both images
            val downscaledBefore = Bitmap.createScaledBitmap(before, targetSize, targetSize, true)
            val downscaledAfter = Bitmap.createScaledBitmap(after, targetSize, targetSize, true)

            var totalDiff = 0L
            val pixels = targetSize * targetSize

            for (y in 0 until targetSize) {
                for (x in 0 until targetSize) {
                    val pixelBefore = downscaledBefore.getPixel(x, y)
                    val pixelAfter = downscaledAfter.getPixel(x, y)

                    val rDiff = abs(((pixelBefore shr 16) and 0xFF) - ((pixelAfter shr 16) and 0xFF))
                    val gDiff = abs(((pixelBefore shr 8) and 0xFF) - ((pixelAfter shr 8) and 0xFF))
                    val bDiff = abs((pixelBefore and 0xFF) - (pixelAfter and 0xFF))

                    totalDiff += rDiff + gDiff + bDiff
                }
            }

            downscaledBefore.recycle()
            downscaledAfter.recycle()

            // Max possible diff per pixel is 255 * 3 = 765
            val maxDiff = pixels * 765
            val normalizedDiff = totalDiff.toFloat() / maxDiff

            // Return similarity (1.0 = identical)
            return 1.0f - normalizedDiff.coerceIn(0f, 1f)
        } catch (e: Exception) {
            logger.e("ScreenshotVerifier", "Downscaled pixel diff failed", e)
            return 0.0f
        }
    }

    /**
     * Region-based diff.
     * Compare only region around the action point.
     */
    private fun regionBasedDiff(
        before: Bitmap,
        after: Bitmap,
        regionSize: Int = 100,
    ): Float {
        // For now, fall back to downscaled diff
        // Full implementation would need action coordinates
        return downscaledPixelDiff(before, after, 64)
    }

    /**
     * Histogram-based diff.
     * Compare color histograms of images.
     */
    private fun histogramDiff(before: Bitmap, after: Bitmap): Float {
        try {
            // We'll calculate histograms for R, G, B channels separately for better color sensitivity
            val bHist = calculateRGBHistogram(before)
            val aHist = calculateRGBHistogram(after)

            var totalCorrelation = 0.0
            
            // Channels: Red, Green, Blue
            for (c in 0..2) {
                var correlation = 0.0
                var bSum = 0.0
                var aSum = 0.0
                
                val offset = c * 256
                for (i in 0..255) {
                    val bv = bHist[offset + i]
                    val av = aHist[offset + i]
                    correlation += bv * av
                    bSum += bv * bv
                    aSum += av * av
                }
                
                val denominator = kotlin.math.sqrt(bSum) * kotlin.math.sqrt(aSum)
                if (denominator > 0) {
                    totalCorrelation += correlation / denominator
                }
            }

            return (totalCorrelation / 3.0).toFloat().coerceIn(0f, 1f)
        } catch (e: Exception) {
            logger.e("ScreenshotVerifier", "Histogram diff failed", e)
            return 0.0f
        }
    }

    private fun calculateRGBHistogram(bitmap: Bitmap): DoubleArray {
        val histogram = DoubleArray(256 * 3) { 0.0 } // R, G, B
        val width = bitmap.width
        val height = bitmap.height

        for (y in 0 until height step 4) {
            for (x in 0 until width step 4) {
                val pixel = bitmap.getPixel(x, y)
                val r = (pixel shr 16) and 0xFF
                val g = (pixel shr 8) and 0xFF
                val b = pixel and 0xFF
                
                histogram[r]++
                histogram[256 + g]++
                histogram[512 + b]++
            }
        }

        // Normalize each channel
        for (c in 0..2) {
            val offset = c * 256
            var sum = 0.0
            for (i in 0..255) sum += histogram[offset + i]
            if (sum > 0) {
                for (i in 0..255) histogram[offset + i] /= sum
            }
        }

        return histogram
    }

    private fun phashDiff(before: Bitmap, after: Bitmap): Float {
        // Simplified pHash - downscale and compare
        return downscaledPixelDiff(before, after, 32)
    }

    private fun imageToBitmap(image: Image): Bitmap? {
        return try {
            val planes = image.planes
            val buffer = planes[0].buffer
            val pixelStride = planes[0].pixelStride
            val rowStride = planes[0].rowStride
            val rowPadding = rowStride - pixelStride * image.width

            // Check for FLAG_SECURE (black image)
            if (isBlackImage(buffer, image.width, image.height, rowStride)) {
                logger.w("ScreenshotVerifier", "Black image detected (FLAG_SECURE?)")
                return null
            }

            val bitmap = Bitmap.createBitmap(
                image.width + rowPadding / pixelStride,
                image.height,
                Bitmap.Config.ARGB_8888
            )
            bitmap.copyPixelsFromBuffer(buffer.rewind() as ByteBuffer)

            // Crop to actual size if needed
            if (rowPadding > 0) {
                val cropped = Bitmap.createBitmap(bitmap, 0, 0, image.width, image.height)
                bitmap.recycle()
                return cropped
            }

            bitmap
        } catch (e: Exception) {
            logger.e("ScreenshotVerifier", "Image to bitmap conversion failed", e)
            null
        }
    }

    private fun isBlackImage(
        buffer: ByteBuffer,
        width: Int,
        height: Int,
        rowStride: Int,
    ): Boolean {
        // Sample pixels to check if image is black (FLAG_SECURE)
        val sampleStep = 10
        var sampledPixels = 0
        var blackPixels = 0

        for (y in 0 until height step sampleStep) {
            for (x in 0 until width step sampleStep) {
                val position = y * rowStride + x * 4
                if (position < buffer.capacity() - 4) {
                    val r = buffer.get(position).toInt() and 0xFF
                    val g = buffer.get(position + 1).toInt() and 0xFF
                    val b = buffer.get(position + 2).toInt() and 0xFF

                    if (r < 10 && g < 10 && b < 10) {
                        blackPixels++
                    }
                    sampledPixels++
                }
            }
        }

        return sampledPixels > 0 && blackPixels.toFloat() / sampledPixels > 0.95f
    }

    private fun getDisplayDimensions(): Pair<Int, Int> {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = windowManager.defaultDisplay
        val metrics = android.util.DisplayMetrics()
        display.getRealMetrics(metrics)
        return Pair(metrics.widthPixels, metrics.heightPixels)
    }
}

/**
 * Comparison methods for screenshot verification.
 */
enum class ComparisonMethod {
    DOWNSCALED_PIXEL_DIFF,  // Default: 64x64 downscale, pixel-by-pixel
    REGION_BASED,           // Compare region around action point
    HISTOGRAM,              // Histogram comparison
    PHASH,                  // Perceptual hash
}

/**
 * Configuration for screenshot verification.
 */
data class VerifierConfig(
    val method: ComparisonMethod = ComparisonMethod.DOWNSCALED_PIXEL_DIFF,
    val downscaleSize: Int = 64,
    val regionSize: Int = 100,
    val thresholdPercent: Float = 20.0f,  // Change > 20% = success
    val fpsLimit: Int = 5,
)

/**
 * Result of screenshot verification.
 */
data class VerificationResult(
    val success: Boolean,
    val similarity: Float,      // 0.0 - 1.0
    val changePercent: Float,   // 0.0 - 100.0
    val isFlagSecure: Boolean = false,
    val error: String? = null,
)
