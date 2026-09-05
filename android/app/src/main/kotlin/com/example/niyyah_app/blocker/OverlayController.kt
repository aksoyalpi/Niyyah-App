package com.example.niyyah_app.blocker

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.CountDownTimer
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.ScrollView
import android.widget.TextView
import com.example.niyyah_app.R
import com.example.niyyah_app.content.ContentLibrary

class OverlayController(
    private val context: Context,
    private val contentLibrary: ContentLibrary,
    private val onConfirm: (readingSeconds: Int, itemCount: Int) -> Unit,
) {
    private var view: View? = null
    private var countdown: CountDownTimer? = null
    private var shownAtMs = 0L

    private var sequence: List<ContentLibrary.Pick> = emptyList()
    private var index = 0
    private val visited = mutableSetOf<Int>()

    private var scroll: ScrollView? = null
    private var arabic: TextView? = null
    private var translation: TextView? = null
    private var source: TextView? = null

    val isShowing: Boolean
        get() = view != null

    @SuppressLint("InflateParams")
    fun show(displayMode: String, contentStyle: String) {
        if (view != null) return
        val windowManager =
            context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val inflated =
            LayoutInflater.from(context).inflate(R.layout.overlay_reading, null)
        scroll = inflated.findViewById(R.id.overlay_scroll)
        arabic = inflated.findViewById(R.id.overlay_arabic)
        translation = inflated.findViewById(R.id.overlay_translation)
        source = inflated.findViewById(R.id.overlay_source)
        val button = inflated.findViewById<Button>(R.id.overlay_button)
        val prev = inflated.findViewById<Button>(R.id.overlay_prev)
        val next = inflated.findViewById<Button>(R.id.overlay_next)

        val fresh = contentLibrary.sequence(displayMode, contentStyle)
        if (fresh !== sequence) {
            sequence = fresh
            index = 0
            visited.clear()
        }
        visited.add(index)
        bindItem()

        button.setOnClickListener {
            val seconds = ((System.currentTimeMillis() - shownAtMs) / 1000L).toInt()
            val items = visited.size
            dismiss()
            onConfirm(seconds, items)
        }
        prev.setOnClickListener { navigate(-1) }
        next.setOnClickListener { navigate(1) }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        )

        countdown?.cancel()
        button.isEnabled = false
        countdown = object : CountDownTimer(REQUIRED_READ_MS, 1000L) {
            override fun onTick(msLeft: Long) {
                button.text = context.getString(
                    R.string.overlay_read_it_in,
                    ((msLeft + 999L) / 1000L).toInt(),
                )
            }

            override fun onFinish() {
                button.text = context.getString(R.string.overlay_read_it)
                button.isEnabled = true
            }
        }.start()

        try {
            windowManager.addView(inflated, params)
            view = inflated
            shownAtMs = System.currentTimeMillis()
        } catch (e: Exception) {
            countdown?.cancel()
            view = null
        }
    }

    private fun navigate(step: Int) {
        if (sequence.isEmpty()) return
        index = (index + step).mod(sequence.size)
        visited.add(index)
        bindItem()
    }

    private fun bindItem() {
        val pick = sequence.getOrNull(index) ?: ContentLibrary.Pick("", "", "")
        arabic?.text = pick.arabic
        arabic?.visibility = if (pick.arabic.isBlank()) View.GONE else View.VISIBLE
        translation?.text = pick.translationEn
        translation?.visibility =
            if (pick.translationEn.isBlank()) View.GONE else View.VISIBLE
        source?.text = pick.source
        scroll?.scrollTo(0, 0)
    }

    fun dismiss() {
        countdown?.cancel()
        countdown = null
        val current = view ?: return
        view = null
        try {
            (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager)
                .removeView(current)
        } catch (e: Exception) {
        }
    }

    companion object {
        const val REQUIRED_READ_MS = 10_000L
        const val MAX_READ_SECONDS = 300
    }
}
