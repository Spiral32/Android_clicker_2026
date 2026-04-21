package com.progsettouch.app

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import java.io.File
import java.io.FileWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class LogManager private constructor(private val context: Context) {
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault())
    private val fileDateFormat = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss", Locale.getDefault())
    private val logBuffer = StringBuilder()
    private var currentLogFile: File? = null
    private var fileWriter: FileWriter? = null
    private var isEnabled = true
    private var logToFile = true
    private val maxBufferSize = 10000

    companion object {
        private const val TAG = "LogManager"
        private const val LOG_DIR = "ProgSetTouchLogs"
        private var instance: LogManager? = null

        fun getInstance(context: Context): LogManager {
            return instance ?: synchronized(this) {
                instance ?: LogManager(context.applicationContext).also { instance = it }
            }
        }
    }

    init {
        initLogFile()
    }

    private fun initLogFile() {
        if (!logToFile) return

        try {
            val logDir = File(context.getExternalFilesDir(null), LOG_DIR)
            if (!logDir.exists()) {
                logDir.mkdirs()
            }

            val fileName = "log_${fileDateFormat.format(Date())}.txt"
            currentLogFile = File(logDir, fileName)
            fileWriter = FileWriter(currentLogFile, true)

            d(TAG, "Log file initialized: ${currentLogFile?.absolutePath}")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize log file", e)
        }
    }

    fun d(tag: String, message: String) {
        log("DEBUG", tag, message)
    }

    fun i(tag: String, message: String) {
        log("INFO", tag, message)
    }

    fun w(tag: String, message: String) {
        log("WARN", tag, message)
    }

    fun e(tag: String, message: String, throwable: Throwable? = null) {
        val fullMessage = if (throwable != null) {
            "$message\n${Log.getStackTraceString(throwable)}"
        } else {
            message
        }
        log("ERROR", tag, fullMessage)
    }

    private fun log(level: String, tag: String, message: String) {
        if (!isEnabled) return

        val timestamp = dateFormat.format(Date())
        val logLine = "[$timestamp] $level/$tag: $message"

        // Log to Android system log
        when (level) {
            "DEBUG" -> Log.d(tag, message)
            "INFO" -> Log.i(tag, message)
            "WARN" -> Log.w(tag, message)
            "ERROR" -> Log.e(tag, message)
        }

        // Buffer for Flutter export
        synchronized(logBuffer) {
            logBuffer.appendLine(logLine)
            if (logBuffer.length > maxBufferSize) {
                logBuffer.delete(0, logBuffer.length - maxBufferSize / 2)
            }
        }

        // Write to file
        if (logToFile) {
            try {
                fileWriter?.apply {
                    write(logLine)
                    write("\n")
                    flush()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to write to log file", e)
            }
        }
    }

    fun setEnabled(enabled: Boolean) {
        isEnabled = enabled
        d(TAG, "Logging ${if (enabled) "enabled" else "disabled"}")
    }

    fun setLogToFile(enabled: Boolean) {
        logToFile = enabled
        if (enabled && fileWriter == null) {
            initLogFile()
        }
        d(TAG, "File logging ${if (enabled) "enabled" else "disabled"}")
    }

    fun getLogBuffer(): String {
        return synchronized(logBuffer) {
            logBuffer.toString()
        }
    }

    fun clearLogBuffer() {
        synchronized(logBuffer) {
            logBuffer.clear()
        }
        d(TAG, "Log buffer cleared")
    }

    fun getLogFiles(): List<File> {
        val logDir = File(context.getExternalFilesDir(null), LOG_DIR)
        return if (logDir.exists()) {
            logDir.listFiles()?.toList() ?: emptyList()
        } else {
            emptyList()
        }
    }

    fun getCurrentLogFilePath(): String? {
        return currentLogFile?.absolutePath
    }

    fun exportLogsToFile(customPath: String? = null): String? {
        return try {
            val timestamp = fileDateFormat.format(Date())
            val fileName = "progset_export_$timestamp.txt"
            val exportContent = buildString {
                append("=== ProgSet Touch Logs Export ===\n")
                append("Export time: ${dateFormat.format(Date())}\n")
                append("Log file path: ${currentLogFile?.absolutePath}\n")
                append("=== Buffer Contents ===\n")
                append(getLogBuffer())
                append("\n=== End of Export ===\n")
            }

            // Android 10+ (API 29+) - используем MediaStore для сохранения в общую папку Downloads
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                return exportUsingMediaStore(fileName, exportContent)
            }

            // Android 9 и ниже - используем публичную папку Downloads напрямую
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) {
                downloadsDir.mkdirs()
            }

            val exportFile = File(downloadsDir, fileName)
            FileWriter(exportFile).use { writer ->
                writer.write(exportContent)
            }
            i(TAG, "Logs exported to: ${exportFile.absolutePath}")
            exportFile.absolutePath

        } catch (e: Exception) {
            e(TAG, "Failed to export logs", e)
            null
        }
    }

    private fun exportUsingMediaStore(fileName: String, content: String): String? {
        return try {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "text/plain")
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }

            val uri = context.contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            if (uri != null) {
                context.contentResolver.openOutputStream(uri)?.use { outputStream ->
                    outputStream.write(content.toByteArray())
                }

                // Получаем реальный путь к файлу
                val projection = arrayOf(MediaStore.Downloads.DATA)
                var filePath: String? = null
                context.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Downloads.DATA)
                        filePath = cursor.getString(columnIndex)
                    }
                }

                val resultPath = filePath ?: "/storage/emulated/0/Download/$fileName"
                i(TAG, "Logs exported to Download via MediaStore: $resultPath")
                resultPath
            } else {
                e(TAG, "Failed to create MediaStore entry")
                null
            }
        } catch (e: Exception) {
            e(TAG, "Failed to export via MediaStore", e)
            null
        }
    }

    fun close() {
        try {
            fileWriter?.close()
            fileWriter = null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to close log file", e)
        }
    }
}
