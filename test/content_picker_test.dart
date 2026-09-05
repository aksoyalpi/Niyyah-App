import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:niyyah_app/features/content/application/content_picker.dart';
import 'package:niyyah_app/features/content/domain/content_item.dart';
import 'package:niyyah_app/features/settings/domain/display_settings.dart';

void main() {
  ContentItem item(String id, ContentType type) => ContentItem(
        id: id,
        type: type,
        arabic: 'النص',
        translationEn: 'text',
        source: 'test',
      );

  final quran = List.generate(20, (i) => item('q$i', ContentType.quran));
  final hadith = List.generate(20, (i) => item('h$i', ContentType.hadith));
  final picker = ContentPicker(Random(42));

  test('quranOnly picks only quran', () {
    for (var i = 0; i < 50; i++) {
      final picked = picker.pick(
        quran: quran,
        hadith: hadith,
        mode: DisplayMode.quranOnly,
      );
      expect(picked!.type, ContentType.quran);
    }
  });

  test('hadithOnly picks only hadith', () {
    for (var i = 0; i < 50; i++) {
      final picked = picker.pick(
        quran: quran,
        hadith: hadith,
        mode: DisplayMode.hadithOnly,
      );
      expect(picked!.type, ContentType.hadith);
    }
  });

  test('mixed eventually picks both types', () {
    final types = <ContentType>{};
    for (var i = 0; i < 200; i++) {
      final picked = picker.pick(
        quran: quran,
        hadith: hadith,
        mode: DisplayMode.mixed,
      );
      types.add(picked!.type);
    }
    expect(types, containsAll([ContentType.quran, ContentType.hadith]));
  });

  test('empty pool returns null', () {
    final picked = picker.pick(
      quran: const [],
      hadith: const [],
      mode: DisplayMode.mixed,
    );
    expect(picked, isNull);
  });
}
