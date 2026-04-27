package com.progsettouch.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONArray
import org.json.JSONObject

/**
 * BroadcastReceiver для обработки BOOT_COMPLETED
 * Восстанавливает активные расписания после перезагрузки устройства
 */
class BootReceiver : BroadcastReceiver() {
    private val flutterPrefsName = "FlutterSharedPreferences"
    private val autostartPrefsKey = "flutter.autostart_enabled"

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val logger = LogManager.getInstance(context)
            val prefs = context.getSharedPreferences(flutterPrefsName, Context.MODE_PRIVATE)
            val autostartEnabled = prefs.getBoolean(autostartPrefsKey, true)
            if (!autostartEnabled) {
                logger.i("BootReceiver", "Device booted, autostart disabled by user setting")
                return
            }

            logger.i("BootReceiver", "Device booted, restoring schedules")

            try {
                // Восстановить расписания из SharedPreferences
                // Flutter SharedPreferences использует префикс "flutter."
                val schedulesJson = readSchedules(prefs)

                if (schedulesJson.isNullOrEmpty()) {
                    logger.i("BootReceiver", "No schedules to restore")
                    return
                }

                val schedulerManager = SchedulerManager(context)

                for (scheduleJson in schedulesJson) {
                    try {
                        val schedule = JSONObject(scheduleJson)
                        val isActive = schedule.optBoolean("isActive", true)
                        if (isActive) {
                            val success = schedulerManager.scheduleExecution(scheduleJson)
                            if (success) {
                                logger.i("BootReceiver", "Restored schedule: ${schedule.optString("id")}")
                            } else {
                                logger.e("BootReceiver", "Failed to restore schedule: ${schedule.optString("id")}", null)
                            }
                        }
                    } catch (e: Exception) {
                        logger.e("BootReceiver", "Error parsing schedule JSON", e)
                    }
                }

                logger.i("BootReceiver", "Schedule restoration completed")
            } catch (e: Exception) {
                logger.e("BootReceiver", "Error during schedule restoration", e)
            }
        }
    }

    private fun readSchedules(prefs: android.content.SharedPreferences): List<String>? {
        val raw = prefs.getString("flutter.scheduler_schedules", null)
        if (!raw.isNullOrBlank()) {
            return try {
                val jsonArray = JSONArray(raw)
                List(jsonArray.length()) { index -> jsonArray.getString(index) }
            } catch (_: Exception) {
                null
            }
        }

        val asSet = prefs.getStringSet("flutter.scheduler_schedules", null)
        return asSet?.toList()
    }
}
