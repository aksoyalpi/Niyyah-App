package com.example.niyyah_app.store

import android.content.Context
import android.content.SharedPreferences
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

class StatsStore(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("niyyah_stats", Context.MODE_PRIVATE)

    fun record(seconds: Int, items: Int) {
        val day = dayKey(0)
        prefs.edit()
            .putInt("s_$day", prefs.getInt("s_$day", 0) + seconds)
            .putInt("i_$day", prefs.getInt("i_$day", 0) + items)
            .apply()
    }

    fun dayStats(offsetDays: Int): Triple<String, Int, Int> {
        val key = dayKey(offsetDays)
        return Triple(key, prefs.getInt("s_$key", 0), prefs.getInt("i_$key", 0))
    }

    private fun dayKey(offsetDays: Int): String =
        LocalDate.now().minusDays(offsetDays.toLong()).format(FORMATTER)

    companion object {
        private val FORMATTER: DateTimeFormatter =
            DateTimeFormatter.ofPattern("yyyy-MM-dd", Locale.ROOT)
    }
}
