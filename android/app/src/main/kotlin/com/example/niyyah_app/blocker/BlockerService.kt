package com.example.niyyah_app.blocker

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import com.example.niyyah_app.content.ContentLibrary
import com.example.niyyah_app.store.SettingsStore
import com.example.niyyah_app.store.StatsStore

class BlockerService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())

    private lateinit var settings: SettingsStore
    private lateinit var stats: StatsStore
    private lateinit var content: ContentLibrary
    private lateinit var overlay: OverlayController

    private var foregroundPackage: String? = null
    private var sessionPackage: String? = null
    private var launchablePackages: Set<String> = emptySet()

    private val sessionExpiryRunnable = Runnable {
        val pkg = sessionPackage ?: return@Runnable
        sessionPackage = null
        if (foregroundPackage == pkg) {
            showOverlay()
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        settings = SettingsStore(this)
        stats = StatsStore(this)
        content = ContentLibrary(this)
        overlay = OverlayController(this, content, ::onOverlayConfirmed)
        launchablePackages = loadLaunchablePackages()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val pkg = event?.packageName?.toString() ?: return
        if (pkg == packageName) return
        if (!launchablePackages.contains(pkg)) return
        if (pkg == foregroundPackage) return
        foregroundPackage = pkg

        if (pkg in settings.blocklist) {
            if (sessionPackage == pkg) return
            sessionPackage = null
            handler.removeCallbacks(sessionExpiryRunnable)
            showOverlay()
        } else if (sessionPackage != null) {
            sessionPackage = null
            handler.removeCallbacks(sessionExpiryRunnable)
        }
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        overlay.dismiss()
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    private fun showOverlay() {
        if (overlay.isShowing) return
        overlay.show(settings.displayMode, settings.contentStyle)
    }

    private fun onOverlayConfirmed(readingSeconds: Int, itemCount: Int) {
        val capped = readingSeconds.coerceAtMost(OverlayController.MAX_READ_SECONDS)
        if (capped > 0 || itemCount > 0) stats.record(capped, itemCount)
        sessionPackage = foregroundPackage
        handler.postDelayed(sessionExpiryRunnable, settings.sessionMinutes * 60_000L)
    }

    private fun loadLaunchablePackages(): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return packageManager
            .queryIntentActivities(intent, 0)
            .mapNotNull { it.activityInfo?.packageName }
            .toSet()
    }

    companion object {
        val componentName: ComponentName
            get() = ComponentName(
                "com.example.niyyah_app",
                "com.example.niyyah_app.blocker.BlockerService",
            )
    }
}
