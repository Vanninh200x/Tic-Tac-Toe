package com.example.tic_tac_toe

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tic_tac_toe/preferences")
            .setMethodCallHandler { call, result ->
                val preferences = getSharedPreferences("tic_tac_toe", MODE_PRIVATE)
                when (call.method) {
                    "read" -> {
                        val saved = preferences.getString("data", "{}") ?: "{}"
                        try {
                            val json = JSONObject(saved)
                            val map = mutableMapOf<String, Any?>()
                            json.keys().forEach { key ->
                                val value = json.get(key)
                                map[key] = if (value is org.json.JSONArray) {
                                    (0 until value.length()).map { index ->
                                        val item = value.getJSONObject(index)
                                        item.keys().asSequence().associateWith { item.get(it) }
                                    }
                                } else value
                            }
                            result.success(map)
                        } catch (error: Exception) {
                            result.error("decode", error.message, null)
                        }
                    }
                    "write" -> {
                        val data = call.arguments as? Map<*, *>
                        if (data == null) result.error("arguments", "Expected a map", null)
                        else {
                            preferences.edit().putString("data", JSONObject(data).toString()).apply()
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
