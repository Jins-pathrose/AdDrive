package com.techfifo.addrive

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "gps_service"
    private val EVENT_CHANNEL = "gps_logs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🔹 MethodChannel (Start / Stop GPS Service)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "startGpsService" -> {
                    val intent = Intent(this, GpsTrackingService::class.java)

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }

                    LogStream.send("✅ GPS Service started")
                    result.success(true)
                }

                "stopGpsService" -> {
                    stopService(Intent(this, GpsTrackingService::class.java))
                    LogStream.send("🛑 GPS Service stopped")
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }

        // 🔹 EventChannel (Send logs to Flutter)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                LogStream.eventSink = events
                LogStream.send("📡 Log stream connected")
            }

            override fun onCancel(arguments: Any?) {
                LogStream.send("❌ Log stream disconnected")
                LogStream.eventSink = null
            }
        })
    }
}
