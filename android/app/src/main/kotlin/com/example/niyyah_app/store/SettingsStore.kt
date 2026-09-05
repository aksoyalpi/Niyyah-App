package com.example.niyyah_app.store

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray

class SettingsStore(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    val blocklist: Set<String>
        get() = prefs.getString("flutter.blocklist", null)?.let(::parseBlocklist) ?: emptySet()

    val displayMode: String
        get() = prefs.getString("flutter.display_mode", "mixed") ?: "mixed"

    val contentStyle: String
        get() = prefs.getString("flutter.content_style", "arabicWithTranslation")
            ?: "arabicWithTranslation"

    val sessionMinutes: Int
        get() = (prefs.all["flutter.session_minutes"] as? Number)?.toInt() ?: 15

    private fun parseBlocklist(raw: String): Set<String> = try {
        val array = JSONArray(raw.removePrefix(JSON_LIST_PREFIX))
        buildSet {
            for (i in 0 until array.length()) {
                val pkg = array.optString(i)
                if (pkg.isNotEmpty()) add(pkg)
            }
        }
    } catch (e: Exception) {
        emptySet()
    }

    companion object {
        private const val JSON_LIST_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!"
    }
}
