import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niyyah_app/features/blocklist/application/blocklist_controller.dart';
import 'package:niyyah_app/features/blocklist/data/native_bridge.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setBlocked persists to preferences', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(blocklistControllerProvider.notifier)
        .setBlocked('com.instagram.android', blocked: true);
    expect(
      container.read(blocklistControllerProvider),
      contains('com.instagram.android'),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('blocklist'), contains('com.instagram.android'));
  });

  test('unblocking removes from preferences', () async {
    SharedPreferences.setMockInitialValues(
      {'flutter.blocklist': <String>['com.instagram.android']},
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(blocklistControllerProvider.notifier)
        .setBlocked('com.instagram.android', blocked: false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('blocklist'), isNot(contains('com.instagram.android')));
  });

  test('DayStats parses native map', () {
    final stats = DayStats.fromMap({
      'date': '2026-09-04',
      'minutes': 7,
      'items': 3,
    });
    expect(stats.date, '2026-09-04');
    expect(stats.minutes, 7);
    expect(stats.items, 3);
  });

  test('DayStats handles missing values', () {
    final stats = DayStats.fromMap({});
    expect(stats.date, '');
    expect(stats.minutes, 0);
    expect(stats.items, 0);
  });
}
