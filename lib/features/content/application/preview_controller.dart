import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/settings_controller.dart';
import '../../settings/domain/display_settings.dart';
import '../data/content_repository.dart';
import '../domain/content_item.dart';
import 'content_picker.dart';

final contentPickerProvider = Provider<ContentPicker>((ref) => ContentPicker());

final class PreviewController extends AsyncNotifier<ContentItem> {
  @override
  Future<ContentItem> build() async {
    final quran = await ref.watch(quranLibraryProvider.future);
    final hadith = await ref.watch(hadithLibraryProvider.future);
    final settings = await ref.watch(settingsControllerProvider.future);
    return _pick(quran: quran, hadith: hadith, mode: settings.mode);
  }

  Future<ContentItem> _pick({
    required List<ContentItem> quran,
    required List<ContentItem> hadith,
    required DisplayMode mode,
  }) async {
    final item = ref.read(contentPickerProvider).pick(
          quran: quran,
          hadith: hadith,
          mode: mode,
        );
    return item ?? _placeholder;
  }

  static const _placeholder = ContentItem(
    id: '',
    type: ContentType.quran,
    arabic: '',
    translationEn: '',
    source: '',
  );

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final quran = await ref.read(quranLibraryProvider.future);
      final hadith = await ref.read(hadithLibraryProvider.future);
      final settings = await ref.read(settingsControllerProvider.future);
      return _pick(quran: quran, hadith: hadith, mode: settings.mode);
    });
  }
}

final previewProvider =
    AsyncNotifierProvider<PreviewController, ContentItem>(
  PreviewController.new,
);
