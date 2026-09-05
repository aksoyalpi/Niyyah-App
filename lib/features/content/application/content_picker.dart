import 'dart:math';

import '../../settings/domain/display_settings.dart';
import '../domain/content_item.dart';

final class ContentPicker {
  final Random _random;

  ContentPicker([Random? random]) : _random = random ?? Random();

  ContentItem? pick({
    required List<ContentItem> quran,
    required List<ContentItem> hadith,
    required DisplayMode mode,
  }) {
    final pool = switch (mode) {
      DisplayMode.quranOnly => quran,
      DisplayMode.hadithOnly => hadith,
      DisplayMode.mixed => _random.nextBool() ? quran : hadith,
    };
    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }
}
