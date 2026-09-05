# Niyyah – Agent Memory

Blocker app for Android/iOS: when the user opens a blocked app (e.g. Instagram),
Niyyah shows a Quran verse or Hadith overlay instead. Minimalist product; focus
is on content, not design.

## Product Decisions (confirmed with user, Sep 2026)

- **Name**: Niyyah (package `niyyah_app`).
- **Platform order**: Android first. iOS implemented (code complete, not yet
  compiled — needs macOS CI; see iOS sections below).
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

## iOS Implementation (written on Linux, compile pending CI)

- **Blocking mechanism (iOS)**: Screen Time APIs — `FamilyControls`
  (authorization + `FamilyActivityPicker` tokens), `ManagedSettings` (shield),
  `DeviceActivity` (session end). No accessibility equivalent exists.
- **Flow**: picker selection → shield applied (blocklist survives reboot).
  Opening a blocked app renders the native shield (Quran/Hadith via
  ShieldConfigurationExtension, which records `shield.shown_at` on each
  render). "I've read it" (ShieldActionExtension) → stats += reading seconds
  (cap 300) + 1 item → shield cleared = session starts → one-shot
  DeviceActivitySchedule `niyyah.session` → `intervalDidEnd`
  (DeviceActivityMonitorExtension) → re-apply shield.
- **iOS deltas vs Android (accepted)**: no installed-app list (opaque tokens,
  count only in UI); shield UI is native Swift, not Flutter; no 10s countdown
  (confirm closes immediately); no prev/next flip; "leave early → discard
  session" not implemented; user can revoke Screen Time permission = bypass;
  reading time measured shield-render → confirm.
- **Structure**: `ios/NiyyahKit/` shared sources compiled into ALL targets
  (NiyyahStore.swift: App Group store/settings sync/stats/shield + session
  helpers; ShieldContent.swift: bundled JSON parse + day-seeded pick;
  Shared.entitlements) + `ios/Runner/` (AppDelegate, BridgeChannel, AppPicker)
  + 3 extension dirs (ShieldConfigExtension, ShieldActionExtension,
  DeviceActivityMonitorExtension) each with Info.plist (point identifiers —
  NOTE the inconsistent suffixes, verified against iOS 26-era sources:
  `com.apple.ManagedSettingsUI.shield-configuration-service`,
  `com.apple.ManagedSettings.shield-action-service`,
  `com.apple.deviceactivity.monitor-extension`).
- **Channel contract** `niyyah/bridge` (iOS side, BridgeChannel.swift):
  `getAuthorization` → `{status: Int}` (0 notDetermined/1 denied/2 approved),
  `requestAuthorization` → re-reads status (`.individual`), `pickAppsToBlock`
  → presents native SwiftUI picker, saves tokens, applies shield →
  `{count: Int}`, `selectedAppCount` → `{count: Int}`, `getStats` →
  `{days: [{date, minutes, items}]}` (last 7 days ascending), `syncSettings`.
  Dart impls: `ios_bridge.dart` (defensive defaults) / `android_bridge.dart`;
  platform split in `blocklist_providers.dart` + `blocklist_screen.dart`
  (iOS = auth card + picker button, Android = list + banner).
- **App Group**: `group.com.axoi.niyyah` (matches bundle id `com.axoi.niyyah`;
  renamed from template `com.example.niyyahApp` before App ID registration).
  Keys: `blocklist.selection` (JSON-encoded FamilyActivitySelection),
  `stats.daily` (JSON map yyyy-MM-dd → {minutes, items}),
  `settings.session_minutes` / `settings.display_mode` /
  `settings.content_style` (copied from `UserDefaults.standard`
  `flutter.*` keys on app launch + foreground/background), `shield.shown_at`,
  `session.ends_at`. Settings values: display_mode `quranOnly|hadithOnly|mixed`,
  content_style `arabicOnly|englishOnly|arabicWithTranslation`.
- **Entitlements** (`NiyyahKit/Shared.entitlements`, all 4 targets):
  `com.apple.developer.family-controls` + app group. Needs paid Apple
  Developer Program (dev entitlement = immediate; distribution = Apple
  approval per bundle ID, incl. each extension).
- **Project generation**: `ios/project.yml` (XcodeGen) — Runner + 3 app-ex
  extension targets; Flutter backend scripts (`xcode_backend.sh build` pre /
  `embed_and_thin` post); local SwiftPM package
  `Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage`;
  deployment target 15.0; extension bundle IDs = app id + extension name.
  The checked-in `Runner.xcodeproj` is the Flutter template and will be
  OVERWRITTEN by `xcodegen generate` on CI (never edit pbxproj by hand).
- **CI**: primary = GitHub Actions `.github/workflows/ios.yml` (repo public):
  `checks` (ubuntu, Flutter 3.47.2, analyze+test) → `build-ios` (macos-15,
  `needs: checks`, `flutter config --enable-swift-package-manager` — REQUIRED,
  SPM is off by default and there is no Podfile; `brew install xcodegen`,
  `xcodegen generate` in ios/, `flutter build ios --release --no-codesign`).
  `codemagic.yaml` kept as fallback (Codemagic account never created). Signing
  setup (App Store Connect API key or p12/profile secrets) comes with Apple
  enrollment.
- **Verification**: `flutter analyze` + `flutter test` on Linux; iOS compile
  only verifiable via GitHub Actions `build-ios`. Device testing requires
  enrollment + real iPhone (Screen Time APIs don't run in the simulator).

## Current State / Roadmap

- M1 done: AGENTS.md, deps, theme, 3-tab shell (Dashboard / Block Apps /
  Settings).- M2 done: content models + JSON library (50 Quran, 51 Hadith, Arabic +
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
- M8 done (Sep 5, 2026): iOS implementation written entirely on Linux — Dart
  platform abstraction, Runner bridge (auth/picker/stats/sync), SwiftUI
  FamilyActivityPicker, 3 Screen Time extensions, XcodeGen project spec,
  Codemagic workflows. NOT yet compiled (needs macOS CI run) and NOT yet
  run on device (needs Apple Developer enrollment + Family Controls dev
  entitlement). Next: push to git + run CI; then enroll and enable Family
  Controls (Development) + App Group on the 4 App IDs; shield extension
  assets (content JSON) are bundled via project.yml from `../assets/`.
- M8.5 done (Sep 5, 2026): pre-compile fix pass after verifying APIs against
  iOS 26-era docs — the Screen Time APIs CHANGED since the code was written:
  `ShieldConfigurationDataSource` now has 4 overloads `configuration(shielding:)
  ` / `configuration(shielding:in:)` (ActivityCategory; no `context:` param,
  no (app, webDomain) combo); `ShieldConfiguration` init is
  `backgroundBlurStyle:backgroundColor:icon:title:subtitle:primaryButtonLabel:
  primaryButtonBackgroundColor:secondaryButtonLabel:` where labels are
  `ShieldConfiguration.Label` with ONLY `init(text:color:)` (no font param —
  Amiri cannot be used in shield labels, system font only; Amiri bundling +
  UIAppFonts removed from shield extension); `ShieldActionDelegate` is now
  single `handle(action: ShieldAction, for: ApplicationToken,
  completionHandler:)` (`buttonPressed` removed, `.primaryButtonPressed`
  case kept). Bundle ID renamed to `com.axoi.niyyah`, app group
  `group.com.axoi.niyyah`. Extension point identifiers fixed to `-service`
  for both shield extensions (old `-extension` values now rejected —
  validation error 90349 per Jun 2026 sources). AppDelegate/SceneDelegate
  verified identical to Flutter 3.47.2 template (FlutterImplicitEngineDelegate
  API correct). GH Actions workflow added; everything pushed (bc213b3), CI
  loop pending user: repo public + `gh auth login`.
- M8.6 done (Sep 5, 2026): **iOS CI GREEN** (`build-ios` passing; first
  compile ever). Fix loop learnings, in order:
  1. Flutter 3.47 enables SwiftPM **by default on stable** — the
     `SwiftPackageManagerIntegrationMigration` is hardcoded to the Flutter
     template's fixed UUIDs (Runner target `97C146ED1CF9000F007C117D`,
     frameworks phase `97C146EB1...`; scheme must reference them) and is
     FATAL on xcodegen projects ("Could not find BuildableReference for
     Runner"). Removed the `flutter config --enable-swift-package-manager`
     step — irrelevant — and disabled per-project in pubspec:
     `flutter: config: enable-swift-package-manager: false` (project config
     beats default; covers CI/local/codemagic). With SPM off, the tool uses
     the CocoaPods path: added `ios/Podfile` (template minus RunnerTests
     block; platform 16.0), tool auto-injects `#include? "Pods/Target
     Support Files/..."` into Flutter/Debug/Release.xcconfig before pod
     install (cocoapods.dart addPodsDependencyToFlutterXcconfig), Runner
     target got target-level configFiles (base config) so the pods xcconfig
     chains; extensions rely on project-level configFiles for
     FLUTTER_BUILD_*.
  2. project.yml: removed `packages:`/ephemeral SwiftPM package dep;
     deployment target bumped 15.0 → **16.0** (requestAuthorization(for:) and
     NavigationStack are 16+; FamilyActivityPicker itself is 15+).
  3. Extension Info.plists got full CFBundle keys (CFBundleIdentifier
     `$(PRODUCT_BUNDLE_IDENTIFIER)`, PackageType XPC!, version from
     FLUTTER_BUILD_NAME/NUMBER) — without them embedded-binary validation
     fails ("bundle identifier is not prefixed with the parent app's").
  4. Compile fixes: `shield.applicationCategories` now takes
     `ShieldSettings.ActivityCategoryPolicy<Application>?` → use
     `.specific(selection.categoryTokens)`; `DeviceActivityCenter
     .startMonitoring(_:during:events:)` — `with:` label removed;
     ShieldActionExtension needed explicit `import Foundation` (Date/
     Calendar/TimeInterval not in scope via DeviceActivity alone).
  5. ShieldConfigExtension compiled clean on first compile attempt.
  Repo is public; gh CLI authenticated (ssh protocol). Unsigned build =
  `flutter build ios --release --no-codesign` succeeds; device install still
  needs enrollment + App IDs (Family Controls dev + App Group) + signing.

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
