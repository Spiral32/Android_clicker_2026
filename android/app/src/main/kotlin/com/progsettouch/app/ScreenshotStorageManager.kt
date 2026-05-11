package com.progsettouch.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

/**
 * ScreenshotStorageManager handles saving, loading, and deleting target screenshots
 * associated with scenario actions.
 */
class ScreenshotStorageManager(private val context: Context) {
    private val logger = LogManager.getInstance(context)
    private val screenshotsDir: File = File(context.filesDir, "action_screenshots")

    init {
        if (!screenshotsDir.exists()) {
            screenshotsDir.mkdirs()
        }
    }

    /**
     * Compresses and saves a Bitmap to the internal storage.
     * Returns the generated file name (not the full path).
     */
    fun saveScreenshot(bitmap: Bitmap): String? {
        try {
            if (!screenshotsDir.exists()) {
                screenshotsDir.mkdirs()
            }
            
            // Generate unique filename
            val fileName = "screenshot_${UUID.randomUUID()}.webp"
            val file = File(screenshotsDir, fileName)

            // We scale down the image to save space and processing time.
            // Full screen resolution is not needed for histogram/phash comparisons.
            val targetWidth = 720
            val scaledBitmap = if (bitmap.width > targetWidth) {
                val ratio = targetWidth.toFloat() / bitmap.width
                val targetHeight = (bitmap.height * ratio).toInt()
                Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, true)
            } else {
                bitmap
            }

            FileOutputStream(file).use { out ->
                // WebP is more efficient. If API < 30, WEBP is deprecated, but we use WEBP_LOSSY.
                // For simplicity across versions, we can use JPEG with 80% quality.
                scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 80, out)
            }

            if (scaledBitmap != bitmap) {
                scaledBitmap.recycle()
            }

            logger.d("ScreenshotStorage", "Saved screenshot to $fileName")
            return fileName
        } catch (e: Exception) {
            logger.e("ScreenshotStorage", "Failed to save screenshot", e)
            return null
        }
    }

    /**
     * Loads a screenshot from internal storage by file name.
     */
    fun loadScreenshot(fileName: String): Bitmap? {
        if (fileName.isEmpty()) return null
        
        try {
            val file = File(screenshotsDir, fileName)
            if (!file.exists()) {
                logger.w("ScreenshotStorage", "Screenshot file not found: $fileName")
                return null
            }
            return BitmapFactory.decodeFile(file.absolutePath)
        } catch (e: Exception) {
            logger.e("ScreenshotStorage", "Failed to load screenshot $fileName", e)
            return null
        }
    }

    /**
     * Deletes a screenshot by file name.
     */
    fun deleteScreenshot(fileName: String) {
        if (fileName.isEmpty()) return
        
        try {
            val file = File(screenshotsDir, fileName)
            if (file.exists()) {
                file.delete()
                logger.d("ScreenshotStorage", "Deleted screenshot $fileName")
            }
        } catch (e: Exception) {
            logger.e("ScreenshotStorage", "Failed to delete screenshot $fileName", e)
        }
    }

    /**
     * Deletes a list of screenshots.
     */
    fun deleteScreenshots(fileNames: List<String>) {
        for (fileName in fileNames) {
            deleteScreenshot(fileName)
        }
    }

    /**
     * Converts an image file to Base64 string for export.
     */
    fun getBase64(fileName: String): String? {
        if (fileName.isEmpty()) return null
        
        try {
            val file = File(screenshotsDir, fileName)
            if (!file.exists()) return null
            
            val bytes = file.readBytes()
            return Base64.encodeToString(bytes, Base64.NO_WRAP)
        } catch (e: Exception) {
            logger.e("ScreenshotStorage", "Failed to encode screenshot $fileName", e)
            return null
        }
    }

    /**
     * Decodes a Base64 string and saves it to a file, returning the generated file name.
     */
    fun saveBase64(base64Str: String): String? {
        if (base64Str.isEmpty()) return null
        
        try {
            if (!screenshotsDir.exists()) {
                screenshotsDir.mkdirs()
            }
            
            val bytes = Base64.decode(base64Str, Base64.DEFAULT)
            val fileName = "screenshot_${UUID.randomUUID()}.jpg"
            val file = File(screenshotsDir, fileName)
            
            FileOutputStream(file).use { out ->
                out.write(bytes)
            }
            
            return fileName
        } catch (e: Exception) {
            logger.e("ScreenshotStorage", "Failed to save decoded base64 screenshot", e)
            return null
        }
    }
}
