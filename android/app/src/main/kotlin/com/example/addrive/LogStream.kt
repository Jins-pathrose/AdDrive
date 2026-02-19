package com.techfifo.addrive

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

object LogStream {

    private val mainHandler = Handler(Looper.getMainLooper())
    var eventSink: EventChannel.EventSink? = null

    fun send(message: String) {
        mainHandler.post {
            eventSink?.success(message)
        }
    }
}
