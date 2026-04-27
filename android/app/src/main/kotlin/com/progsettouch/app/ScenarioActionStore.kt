package com.progsettouch.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class ScenarioActionStore(context: Context) {
    private val prefs = context.getSharedPreferences("scenario_actions_store", Context.MODE_PRIVATE)

    fun saveScenarioActions(scenarioId: String, actions: List<RecordedAction>) {
        prefs.edit().putString(scenarioKey(scenarioId), actionsToJson(actions).toString()).apply()
    }

    fun exportScenarioActions(scenarioId: String): List<Map<String, Any>> {
        return getScenarioActions(scenarioId).map { it.toMap() }
    }

    fun importScenarioActions(scenarioId: String, rawActions: List<Map<String, Any?>>): Boolean {
        return try {
            val actions = rawActions.mapNotNull(::mapToRecordedAction)
            saveScenarioActions(scenarioId, actions)
            true
        } catch (_: Exception) {
            false
        }
    }

    fun deleteScenarioActions(scenarioId: String): Boolean {
        return prefs.edit().remove(scenarioKey(scenarioId)).commit()
    }

    fun replaceScenarioActions(scenarioId: String, actions: List<RecordedAction>) {
        saveScenarioActions(scenarioId, actions)
    }

    private fun actionsToJson(actions: List<RecordedAction>): JSONArray {
        val jsonArray = JSONArray()
        actions.forEach { action ->
            jsonArray.put(
                JSONObject().apply {
                    put("type", action.type)
                    put("pointerCount", action.pointerCount)
                    put("startX", action.startX)
                    put("startY", action.startY)
                    put("endX", action.endX)
                    put("endY", action.endY)
                    put("durationMs", action.durationMs)
                },
            )
        }
        return jsonArray
    }

    fun getScenarioActions(scenarioId: String): List<RecordedAction> {
        val raw = prefs.getString(scenarioKey(scenarioId), null) ?: return emptyList()
        return try {
            val parsed = JSONArray(raw)
            buildList {
                for (index in 0 until parsed.length()) {
                    val obj = parsed.getJSONObject(index)
                    add(
                        RecordedAction(
                            type = obj.optString("type"),
                            pointerCount = obj.optInt("pointerCount", 1),
                            startX = obj.optDouble("startX", 0.0),
                            startY = obj.optDouble("startY", 0.0),
                            endX = obj.optDouble("endX", 0.0),
                            endY = obj.optDouble("endY", 0.0),
                            durationMs = obj.optLong("durationMs", 50L),
                        ),
                    )
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun getStoredScenarioIds(): List<String> {
        return prefs.all.keys
            .asSequence()
            .filter { it.startsWith(scenarioKeyPrefix) }
            .map { it.removePrefix(scenarioKeyPrefix) }
            .filter { it.isNotBlank() }
            .sorted()
            .toList()
    }

    private fun mapToRecordedAction(raw: Map<String, Any?>): RecordedAction? {
        val type = raw["type"]?.toString()?.trim().orEmpty()
        if (type.isBlank()) {
            return null
        }

        return RecordedAction(
            type = type,
            pointerCount = raw["pointerCount"].toIntValue(default = 1),
            startX = raw["startX"].toDoubleValue(),
            startY = raw["startY"].toDoubleValue(),
            endX = raw["endX"].toDoubleValue(),
            endY = raw["endY"].toDoubleValue(),
            durationMs = raw["durationMs"].toLongValue(default = 50L),
        )
    }

    private fun scenarioKey(scenarioId: String): String = "$scenarioKeyPrefix$scenarioId"

    companion object {
        private const val scenarioKeyPrefix = "scenario_actions_"
    }
}

private fun Any?.toIntValue(default: Int): Int {
    return when (this) {
        is Int -> this
        is Long -> this.toInt()
        is Double -> this.toInt()
        is Float -> this.toInt()
        is Number -> this.toInt()
        is String -> this.toIntOrNull() ?: default
        else -> default
    }
}

private fun Any?.toLongValue(default: Long): Long {
    return when (this) {
        is Long -> this
        is Int -> this.toLong()
        is Double -> this.toLong()
        is Float -> this.toLong()
        is Number -> this.toLong()
        is String -> this.toLongOrNull() ?: default
        else -> default
    }
}

private fun Any?.toDoubleValue(default: Double = 0.0): Double {
    return when (this) {
        is Double -> this
        is Float -> this.toDouble()
        is Int -> this.toDouble()
        is Long -> this.toDouble()
        is Number -> this.toDouble()
        is String -> this.toDoubleOrNull() ?: default
        else -> default
    }
}
