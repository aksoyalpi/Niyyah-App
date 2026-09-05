enum DisplayMode { quranOnly, hadithOnly, mixed }

enum ContentStyle { arabicOnly, englishOnly, arabicWithTranslation }

extension DisplayModeLabel on DisplayMode {
  String get label => switch (this) {
        DisplayMode.quranOnly => 'Quran only',
        DisplayMode.hadithOnly => 'Hadith only',
        DisplayMode.mixed => 'Mixed',
      };
}

extension ContentStyleLabel on ContentStyle {
  String get label => switch (this) {
        ContentStyle.arabicOnly => 'Arabic only',
        ContentStyle.englishOnly => 'English only',
        ContentStyle.arabicWithTranslation => 'Arabic + English',
      };
}

final class DisplaySettings {
  final DisplayMode mode;
  final ContentStyle style;
  final int sessionMinutes;

  const DisplaySettings({
    this.mode = DisplayMode.mixed,
    this.style = ContentStyle.arabicWithTranslation,
    this.sessionMinutes = 15,
  });

  DisplaySettings copyWith({
    DisplayMode? mode,
    ContentStyle? style,
    int? sessionMinutes,
  }) {
    return DisplaySettings(
      mode: mode ?? this.mode,
      style: style ?? this.style,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
    );
  }
}
