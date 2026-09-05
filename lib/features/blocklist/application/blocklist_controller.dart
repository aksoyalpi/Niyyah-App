import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../settings/application/settings_controller.dart';

final class BlocklistController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(SettingsKeys.blocklist) ?? const [];
    state = list.toSet();
  }

  Future<void> setBlocked(String packageName, {required bool blocked}) async {
    final current = {...state};
    if (blocked) {
      current.add(packageName);
    } else {
      current.remove(packageName);
    }
    state = current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(SettingsKeys.blocklist, current.toList());
  }

  bool isBlocked(String packageName) => state.contains(packageName);
}

final blocklistControllerProvider =
    NotifierProvider<BlocklistController, Set<String>>(
  BlocklistController.new,
);
