package com.example.niyyah_app

import com.example.niyyah_app.bridge.BridgeChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "niyyah/bridge",
        ).setMethodCallHandler(BridgeChannel(this))
    }
}
