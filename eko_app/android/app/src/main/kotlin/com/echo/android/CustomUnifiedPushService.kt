package com.echo.android

import android.util.Log
import org.unifiedpush.flutter.connector.Plugin
import org.unifiedpush.flutter.connector.UnifiedPushService

class CustomUnifiedPushService : UnifiedPushService() {

    override fun onCreate() {
        Log.d(
            TAG,
            "onCreate: always start headless engine (default connector skips when Plugin.count > 0)",
        )
        val registry = getEngine(this).plugins
        if (registry.get(Plugin::class.java) == null) {
            registry.add(Plugin())
        }
        super.onCreate()
    }

    companion object {
        private const val TAG = "CustomUnifiedPush"
    }
}
