import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/content_item.dart';

final class ContentRepository {
  static const _quranPath = 'assets/content/quran.json';
  static const _hadithPath = 'assets/content/hadith.json';

  Future<List<ContentItem>> loadQuran() => _load(_quranPath, ContentType.quran);

  Future<List<ContentItem>> loadHadith() =>
      _load(_hadithPath, ContentType.hadith);

  Future<List<ContentItem>> _load(String path, ContentType type) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ContentItem.fromJson(e as Map<String, dynamic>, type: type))
        .toList();
  }
}

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(),
);

final quranLibraryProvider = FutureProvider<List<ContentItem>>(
  (ref) => ref.watch(contentRepositoryProvider).loadQuran(),
);

final hadithLibraryProvider = FutureProvider<List<ContentItem>>(
  (ref) => ref.watch(contentRepositoryProvider).loadHadith(),
);
