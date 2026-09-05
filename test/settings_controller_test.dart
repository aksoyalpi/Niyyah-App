import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niyyah_app/features/settings/application/settings_controller.dart';
import 'package:niyyah_app/features/settings/domain/display_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults are applied', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final settings = await container.read(settingsControllerProvider.future);
    expect(settings.mode, DisplayMode.mixed);
    expect(settings.style, ContentStyle.arabicWithTranslation);
    expect(settings.sessionMinutes, 15);
  });

  test('setMode persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(settingsControllerProvider.notifier)
        .setMode(DisplayMode.hadithOnly);
    final settings = await container.read(settingsControllerProvider.future);
    expect(settings.mode, DisplayMode.hadithOnly);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('display_mode'), 'hadithOnly');
  });

  test('setSessionMinutes persists', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(settingsControllerProvider.notifier)
        .setSessionMinutes(30);
    final settings = await container.read(settingsControllerProvider.future);
    expect(settings.sessionMinutes, 30);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('session_minutes'), 30);
  });
}
