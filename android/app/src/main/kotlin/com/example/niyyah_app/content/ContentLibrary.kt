package com.example.niyyah_app.content

import android.content.Context
import org.json.JSONArray
import kotlin.random.Random

class ContentLibrary(private val context: Context) {

    data class Pick(val arabic: String, val translationEn: String, val source: String)

    private val cache = mutableMapOf<String, JSONArray>()

    @Synchronized
    fun pick(displayMode: String, contentStyle: String): Pick {
        val quran = load("quran.json")
        val hadith = load("hadith.json")
        val pool = when (displayMode) {
            "quranOnly" -> quran
            "hadithOnly" -> hadith
            else ->
                if (Random.nextBoolean()) quran.ifEmpty(hadith) else hadith.ifEmpty(quran)
        }
        if (pool.length() == 0) return Pick("", "", "")
        val entry = pool.getJSONObject(Random.nextInt(pool.length()))
        val arabic = entry.optString("arabic")
        val translation = entry.optString("translationEn")
        val source = entry.optString("source")
        return when (contentStyle) {
            "arabicOnly" -> Pick(arabic, "", source)
            "englishOnly" -> Pick("", translation, source)
            else -> Pick(arabic, translation, source)
        }
    }

    private fun JSONArray.ifEmpty(fallback: JSONArray): JSONArray =
        if (length() == 0) fallback else this

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
