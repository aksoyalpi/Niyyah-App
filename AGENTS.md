# Niyyah – Agent Memory

Blocker app for Android/iOS: when the user opens a blocked app (e.g. Instagram),
Niyyah shows a Quran verse or Hadith overlay instead. Minimalist product; focus
is on content, not design.

## Product Decisions (confirmed with user, Sep 2026)

- **Name**: Niyyah (package `niyyah_app`).
- **Platform order**: Android first. iOS later (requires Apple *Family Controls*
  entitlement + Developer Account; architecture stays ready via interfaces, no
  implementation yet).
- **Blocking mechanism (Android)**:
  - `AccessibilityService` detects foreground app via `TYPE_WINDOW_STATE_CHANGED`.
  - Overlay shown via `WindowManager` (`TYPE_APPLICATION_OVERLAY`, permission
    "Display over other apps"). No activity launch (avoids background-activity
    launch restrictions).
- **Overlay flow**:
  1. Blocked app opened, no active session → overlay appears instantly.
  2. Fixed **10 second countdown** before the "I've read it" button becomes
     active (no setting for this).
  3. Confirm → overlay closes → **session** starts: app usable for a globally
     configurable duration (5/10/15/30 min, default 15).
  4. Session expires while user stays in app → overlay again (cycle repeats).
  5. User leaves app before expiry → session discarded; next open = full cycle.
  6. No other bypass. Reboot → no active session.
- **Content**: fully offline, bundled JSON. ~50 short Hadiths (Riyad as-Salihin /
  40 Hadith Nawawi) + ~50 well-known Quran verses. **Arabic + English
  translation** (user chose English, not German, despite speaking German).
  User must review religious texts before release.
- **Reading-time tracking**: automatic — time from overlay shown until
  confirmation tap (includes the 10s minimum), capped at ~5 min. No in-app
  reading mode in MVP.
- **Dashboard**: minimal — minutes today, verses/hadiths shown today,
  7-day bar chart. No streaks, no totals.
- **Settings**: "What to show" (Quran only / Hadith only / Mixed), "Content
  style" (Arabic only / English only / Arabic + English), "Session duration".
- **Storage**: local only, no account, no backend. Shared between Dart and
  native via `FlutterSharedPreferences` file (native reads it directly).
- **UI language**: English. Light theme only, minimalist (white/beige +
  green accent, lots of whitespace). No heavy design work.

## Technical Conventions

- **Flutter 3.47 / Dart 3.13**.
- **State management**: Riverpod (`flutter_riverpod`).
- **Architecture**: feature-first:
  `lib/core/` (theme, router, constants) +
  `lib/features/<feature>/{data,application,presentation}`.
- **Packages**: `flutter_riverpod`, `shared_preferences`, `fl_chart` only.
  Everything else via platform channels or hand-rolled (keep deps minimal).
- **MethodChannel** `niyyah/bridge`: native → listInstalledApps, stats access;
  Dart writes blocklist + settings to SharedPreferences, native reads them.
- **Native (Android)**: overlay UI is native (instant, no Flutter engine cold
  start); Arabic font Amiri bundled for both native (`res/font`) and Flutter
  (`assets/fonts`). Session/countdown logic lives in the service (Handler).
- **Stats store**: native writes daily aggregates (minutes, items) to its own
  SharedPreferences; Flutter reads via bridge.
- **Storage contract (native reads of `FlutterSharedPreferences`)**:
  `flutter.blocklist` is a String — `JSON_LIST_PREFIX
  "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!"` + JSON array (as written by
  shared_preferences_android 2.4.28; never read via getStringSet).
  `flutter.session_minutes` is stored as Long (Dart setInt) — read via
  `prefs.all[key] as? Number`. `display_mode`/`content_style` are plain
  strings.
- **CLI builds**: no system java; use
  `JAVA_HOME=/opt/android-studio/jbr flutter build apk --debug`.
- **Lints**: `flutter_lints` defaults. No comments unless needed.
- **Content JSON schema**: `{id, arabic, translationEn, source}` where source
  is e.g. `"Quran 2:286"` or `"Riyad as-Salihin 42"`. Files:
  `assets/content/quran.json`, `assets/content/hadith.json`.

## Current State / Roadmap

- M1 done: AGENTS.md, deps, theme, 3-tab shell (Dashboard / Block Apps /
  Settings).
- M2 done: content models + JSON library (50 Quran, 51 Hadith, Arabic +
  English, NOT yet reviewed religiously by user), settings screen (display
  mode, content style, session duration), reading card + preview on dashboard.
- M3 done: Android side complete but NOT yet compiled (no Java/SDK on dev
  machine): BlockerService (accessibility, session state machine, Handler),
  OverlayController (WindowManager overlay, 10s CountDownTimer, Amiri font,
  reading-time -> StatsStore capped at 300s), SettingsStore reads
  FlutterSharedPreferences (keys: flutter.blocklist / flutter.display_mode /
  flutter.content_style / flutter.session_minutes), ContentLibrary parses
  flutter_assets JSON, BridgeChannel on niyyah/bridge (listInstalledApps,
  getStats, getPermissions, open*Settings), minSdk bumped to 26, app icon
  (green crescent) in all mipmaps.
- M4 done: dashboard with today minutes/items + 7-day bar chart (fl_chart) +
  preview card.
- M5 done: unit tests (content picker, settings controller, blocklist
  persistence, DayStats parsing), widget smoke test. `flutter analyze` and
  `flutter test` pass.
- M6 done (Sep 5, 2026): compiled + run on device, blocking verified
  end-to-end. Fixed SettingsStore type mismatches that crashed the
  accessibility service on every window event: `flutter.blocklist` is a
  prefixed JSON string, `session_minutes` is stored as Long (see storage
  contract below). Battery-optimization exemption added as third permission
  row (manifest `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, bridge
  `openBatterySettings` with direct dialog -> settings-list fallback). Root
  lifecycle observer in app.dart invalidates stats + permissions providers on
  resume, so dashboard/banner refresh after sessions without app restart.
- M7 done: overlay has Previous/Next (wrap-around) to flip through the
  sequence without confirming. ContentLibrary.sequence() returns a list
  shuffled with a day seed (same order all day, reshuffles daily / when
  settings change); overlay keeps its position across sessions and counts
  each *distinct* text shown (`visited` set) — confirm reports
  (readingSeconds, itemCount) and stats record all viewed items.
- TODO (user/device): review religious texts before release, manual test
  protocol below.

## Verification

- `flutter analyze` must pass.
- `flutter test` must pass.
- Manual: block an app, open it → overlay with countdown → confirm → session →
  re-block after expiry.

## Manual Device Test Protocol

1. Build & install: `flutter run` (needs Android Studio / JDK 17 on host).
2. Open Niyyah → Block Apps tab → grant Accessibility + "Display over other
   apps" + battery exemption via the banner (banner refreshes on app resume).
3. Toggle a switch on e.g. Instagram.
4. Open Instagram → overlay must appear with 10s countdown on the button.
5. Tap "I've read it" after countdown → overlay closes, app usable.
6. Stay in Instagram → after session duration (default 15 min) overlay returns.
7. Leave Instagram before expiry → reopen → overlay immediately (session reset).
8. On the overlay: Previous/Next flip texts (wrap-around, no counter);
   confirming after browsing records minutes + every distinct text shown.
9. Dashboard shows minutes + items from overlay sessions (re-fetches on app
   resume, no restart needed).
