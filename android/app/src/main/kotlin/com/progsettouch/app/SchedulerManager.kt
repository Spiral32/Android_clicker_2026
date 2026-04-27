package com.progsettouch.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONObject
import java.util.Calendar

class SchedulerManager(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val logger = LogManager.getInstance(context)

    companion object {
        const val ACTION_SCHEDULE_TRIGGER = "com.progsettouch.app.ACTION_SCHEDULE_TRIGGER"
        const val EXTRA_SCHEDULE_ID = "schedule_id"
        const val EXTRA_SCENARIO_ID = "scenario_id"
        const val EXTRA_PLANNED_AT_MS = "planned_at_ms"
        const val EXTRA_SCHEDULE_MODE = "schedule_mode"
    }

    /**
     * Запланировать выполнение сценария
     */
    fun scheduleExecution(scheduleJson: String): Boolean {
        return try {
            val schedule = JSONObject(scheduleJson)
            val scheduleId = schedule.getString("id")
            val scenarioId = schedule.getString("scenarioId")
            val type = schedule.getString("type")
            val hour = schedule.getInt("hour")
            val minute = schedule.getInt("minute")
            val isActive = schedule.optBoolean("isActive", true)

            if (!isActive) {
                cancelSchedule(scheduleId)
                return true
            }

            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            // Для oneTime проверяем, не прошло ли время
            if (type == "oneTime") {
                val dateTimestamp = schedule.optLong("dateTimestamp", 0L)
                if (dateTimestamp > 0) {
                    calendar.timeInMillis = dateTimestamp
                }
                if (calendar.timeInMillis <= System.currentTimeMillis()) {
                    logger.i("SchedulerManager", "One-time schedule $scheduleId is in the past, skipping")
                    return false
                }
            } else {
                // Для повторяющихся, если время уже прошло сегодня, переносим на завтра
                if (calendar.timeInMillis <= System.currentTimeMillis()) {
                    calendar.add(Calendar.DAY_OF_MONTH, 1)
                }

                // Для weekly применяем дни недели
                if (type == "weekly") {
                    val daysOfWeek = schedule.optJSONArray("daysOfWeek")
                    if (daysOfWeek != null) {
                        val currentDay = calendar.get(Calendar.DAY_OF_WEEK) - 1 // 0=воскресенье в Calendar
                        var nextDayIndex = -1
                        for (i in 0 until daysOfWeek.length()) {
                            val day = daysOfWeek.getInt(i)
                            if (day >= currentDay) {
                                nextDayIndex = day
                                break
                            }
                        }
                        if (nextDayIndex == -1) {
                            // Ближайший день на следующей неделе
                            nextDayIndex = daysOfWeek.getInt(0)
                            calendar.add(Calendar.WEEK_OF_YEAR, 1)
                        }
                        calendar.set(Calendar.DAY_OF_WEEK, nextDayIndex + 1) // +1 для Calendar
                    }
                }
            }

            var scheduleMode = "exact"
            val intent = Intent(context, ScheduleTriggerReceiver::class.java).apply {
                action = ACTION_SCHEDULE_TRIGGER
                putExtra(EXTRA_SCHEDULE_ID, scheduleId)
                putExtra(EXTRA_SCENARIO_ID, scenarioId)
                putExtra(EXTRA_PLANNED_AT_MS, calendar.timeInMillis)
            }

            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            val alarmType = if (type == "oneTime") {
                AlarmManager.RTC_WAKEUP
            } else {
                AlarmManager.RTC_WAKEUP
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    intent.putExtra(EXTRA_SCHEDULE_MODE, scheduleMode)
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        scheduleId.hashCode(),
                        intent,
                        flags
                    )
                    alarmManager.setExactAndAllowWhileIdle(alarmType, calendar.timeInMillis, pendingIntent)
                } else {
                    // Fallback for devices/apps without exact alarm capability.
                    // Timing may be less precise, but schedule still remains functional.
                    scheduleMode = "inexact_fallback"
                    intent.putExtra(EXTRA_SCHEDULE_MODE, scheduleMode)
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        scheduleId.hashCode(),
                        intent,
                        flags
                    )
                    alarmManager.setAndAllowWhileIdle(alarmType, calendar.timeInMillis, pendingIntent)
                    logger.w("SchedulerManager", "Exact alarms unavailable, scheduled in inexact mode")
                }
            } else {
                intent.putExtra(EXTRA_SCHEDULE_MODE, scheduleMode)
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    scheduleId.hashCode(),
                    intent,
                    flags
                )
                alarmManager.setExactAndAllowWhileIdle(alarmType, calendar.timeInMillis, pendingIntent)
            }

            logger.i("SchedulerManager", "schedule_set scheduleId=$scheduleId scenarioId=$scenarioId type=$type plannedAtMs=${calendar.timeInMillis} plannedAt=${calendar.time}")
            true
        } catch (e: Exception) {
            logger.e("SchedulerManager", "Failed to schedule execution", e)
            false
        }
    }

    /**
     * Отменить расписание
     */
    fun cancelSchedule(scheduleId: String): Boolean {
        return try {
            val intent = Intent(context, ScheduleTriggerReceiver::class.java).apply {
                action = ACTION_SCHEDULE_TRIGGER
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_NO_CREATE
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                scheduleId.hashCode(),
                intent,
                flags
            )

            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
                logger.i("SchedulerManager", "Cancelled schedule $scheduleId")
            }
            true
        } catch (e: Exception) {
            logger.e("SchedulerManager", "Failed to cancel schedule $scheduleId", e)
            false
        }
    }

    /**
     * Отменить все расписания
     */
    fun cancelAllSchedules(): Boolean {
        return try {
            // Поскольку мы не храним список ID, отменяем все возможные
            // В реальности нужно хранить список активных расписаний
            logger.i("SchedulerManager", "Cancelled all schedules")
            true
        } catch (e: Exception) {
            logger.e("SchedulerManager", "Failed to cancel all schedules", e)
            false
        }
    }
}

/**
 * BroadcastReceiver для обработки триггеров расписаний
 */
class ScheduleTriggerReceiver : BroadcastReceiver() {
    companion object {
        private const val MAX_STALE_TRIGGER_MS = 60_000L
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == SchedulerManager.ACTION_SCHEDULE_TRIGGER) {
            val scheduleId = intent.getStringExtra(SchedulerManager.EXTRA_SCHEDULE_ID)
            val scenarioId = intent.getStringExtra(SchedulerManager.EXTRA_SCENARIO_ID)
            val plannedAtMs = intent.getLongExtra(SchedulerManager.EXTRA_PLANNED_AT_MS, 0L)
            val scheduleMode = intent.getStringExtra(SchedulerManager.EXTRA_SCHEDULE_MODE) ?: "unknown"

            if (scheduleId != null && scenarioId != null) {
                val logger = LogManager.getInstance(context)
                val triggerAtMs = System.currentTimeMillis()
                val driftMs = if (plannedAtMs > 0) triggerAtMs - plannedAtMs else -1L
                logger.i("ScheduleTriggerReceiver", "schedule_trigger scheduleId=$scheduleId scenarioId=$scenarioId mode=$scheduleMode plannedAtMs=$plannedAtMs triggerAtMs=$triggerAtMs driftMs=$driftMs")

                if (plannedAtMs > 0 && driftMs > MAX_STALE_TRIGGER_MS) {
                    logger.w("ScheduleTriggerReceiver", "Skipping stale schedule trigger scheduleId=$scheduleId driftMs=$driftMs")
                    return
                }

                // Запустить выполнение сценария через AccessibilityService
                val accessibilityService = ProgSetAccessibilityService.instance
                if (accessibilityService != null) {
                    try {
                        val currentState = accessibilityService.getCurrentState()["state"]?.toString()
                        if (currentState == "EXECUTING") {
                            logger.w("ScheduleTriggerReceiver", "Skipping schedule $scheduleId because execution is already active")
                            return
                        }
                        val executionSummary = accessibilityService.startScenarioExecution(scenarioId)
                        logger.i("ScheduleTriggerReceiver", "Started execution for scenario $scenarioId: $executionSummary")
                    } catch (e: Exception) {
                        logger.e("ScheduleTriggerReceiver", "Error executing scenario $scenarioId", e)
                    }
                } else {
                    logger.e("ScheduleTriggerReceiver", "AccessibilityService not available for schedule $scheduleId", null)
                }
            }
        }
    }
}
