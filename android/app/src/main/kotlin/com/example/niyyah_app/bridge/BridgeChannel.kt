package com.example.niyyah_app.bridge

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.provider.Settings
import android.view.View
import com.example.niyyah_app.blocker.BlockerService
import com.example.niyyah_app.store.StatsStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class BridgeChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "listInstalledApps" -> result.success(listInstalledApps())
            "getStats" -> result.success(getStats())
            "getPermissions" -> result.success(getPermissions())
            "openAccessibilitySettings" -> {
                open(
                    Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS),
                    result,
                )
            }
            "openOverlaySettings" -> {
                open(
                    Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:${context.packageName}"),
                    ),
                    result,
                )
            }
            else -> result.notImplemented()
        }
    }

    private fun open(intent: Intent, result: MethodChannel.Result) {
        try {
            context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun listInstalledApps(): List<Map<String, Any?>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(intent, 0)
            .filter { it.activityInfo?.packageName != null }
            .groupBy { it.activityInfo.packageName }
            .filterKeys { it != context.packageName }
            .map { (pkg, infos) ->
                val info = infos.first()
                val name = info.loadLabel(pm).toString()
                val icon = info.loadIcon(pm)?.let { encodeIcon(it) }
                mapOf("package" to pkg, "name" to name, "icon" to icon)
            }
            .sortedBy { (it["name"] as? String)?.lowercase() ?: "" }
    }

    private fun encodeIcon(drawable: android.graphics.drawable.Drawable): ByteArray {
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        val out = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        bitmap.recycle()
        return out.toByteArray()
    }

    private fun getStats(): Map<String, Any> {
        val store = StatsStore(context)
        val days = (0..6).map { offset ->
            val (date, seconds, items) = store.dayStats(offset)
            mapOf(
                "date" to date,
                "minutes" to seconds / 60,
                "items" to items,
            )
        }
        return mapOf("days" to days)
    }

    private fun getPermissions(): Map<String, Boolean> = mapOf(
        "accessibility" to isAccessibilityEnabled(),
        "overlay" to Settings.canDrawOverlays(context),
    )

    private fun isAccessibilityEnabled(): Boolean {
        val expected = ComponentName(context, BlockerService::class.java).flattenToString()
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        return enabled.split(':').any { it.equals(expected, ignoreCase = true) }
    }
}
