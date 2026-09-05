import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/display_settings.dart';

final class SettingsKeys {
  static const displayMode = 'display_mode';
  static const contentStyle = 'content_style';
  static const sessionMinutes = 'session_minutes';
  static const blocklist = 'blocklist';
}

final class SettingsController extends AsyncNotifier<DisplaySettings> {
  SharedPreferences? _prefs;

  @override
  Future<DisplaySettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;
    final settings = DisplaySettings(
      mode: _readMode(prefs),
      style: _readStyle(prefs),
      sessionMinutes:
          prefs.getInt(SettingsKeys.sessionMinutes) ?? const DisplaySettings().sessionMinutes,
    );
    return settings;
  }

  DisplayMode _readMode(SharedPreferences prefs) {
    final name = prefs.getString(SettingsKeys.displayMode);
    if (name == null) return DisplayMode.mixed;
    return DisplayMode.values.asNameMap()[name] ?? DisplayMode.mixed;
  }

  ContentStyle _readStyle(SharedPreferences prefs) {
    final name = prefs.getString(SettingsKeys.contentStyle);
    if (name == null) return ContentStyle.arabicWithTranslation;
    return ContentStyle.values.asNameMap()[name] ??
        ContentStyle.arabicWithTranslation;
  }

  Future<void> setMode(DisplayMode mode) async {
    final current = await future;
    state = AsyncData(current.copyWith(mode: mode));
    await _prefs?.setString(SettingsKeys.displayMode, mode.name);
  }

  Future<void> setStyle(ContentStyle style) async {
    final current = await future;
    state = AsyncData(current.copyWith(style: style));
    await _prefs?.setString(SettingsKeys.contentStyle, style.name);
  }

  Future<void> setSessionMinutes(int minutes) async {
    final current = await future;
    state = AsyncData(current.copyWith(sessionMinutes: minutes));
    await _prefs?.setInt(SettingsKeys.sessionMinutes, minutes);
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, DisplaySettings>(
  SettingsController.new,
);
