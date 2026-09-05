package com.example.niyyah_app.content

import android.content.Context
import org.json.JSONArray
import java.time.LocalDate
import kotlin.random.Random

class ContentLibrary(private val context: Context) {

    data class Pick(val arabic: String, val translationEn: String, val source: String)

    private val cache = mutableMapOf<String, JSONArray>()
    private val sequences = mutableMapOf<String, List<Pick>>()

    @Synchronized
    fun sequence(displayMode: String, contentStyle: String): List<Pick> {
        val day = LocalDate.now().toEpochDay()
        val key = "$day|$displayMode|$contentStyle"
        sequences[key]?.let { return it }
        sequences.keys.retainAll { it.startsWith("$day|") }
        val pools = when (displayMode) {
            "quranOnly" -> listOf(load("quran.json"))
            "hadithOnly" -> listOf(load("hadith.json"))
            else -> listOf(load("quran.json"), load("hadith.json"))
        }
        val raw = mutableListOf<Triple<String, String, String>>()
        for (pool in pools) {
            for (i in 0 until pool.length()) {
                val entry = pool.getJSONObject(i)
                raw.add(
                    Triple(
                        entry.optString("arabic"),
                        entry.optString("translationEn"),
                        entry.optString("source"),
                    ),
                )
            }
        }
        raw.shuffle(Random(day))
        val list = raw.map { (arabic, translation, source) ->
            when (contentStyle) {
                "arabicOnly" -> Pick(arabic, "", source)
                "englishOnly" -> Pick("", translation, source)
                else -> Pick(arabic, translation, source)
            }
        }
        sequences[key] = list
        return list
    }

    private fun load(name: String): JSONArray {
        cache[name]?.let { return it }
        return try {
            val stream = context.assets.open("flutter_assets/assets/content/$name")
            val text = stream.bufferedReader().use { it.readText() }
            JSONArray(text).also { cache[name] = it }
        } catch (e: Exception) {
            JSONArray()
        }
    }
}
