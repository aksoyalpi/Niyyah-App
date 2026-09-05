import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class InstalledApp {
  final String packageName;
  final String name;
  final Uint8List? icon;

  const InstalledApp({required this.packageName, required this.name, this.icon});
}

final class DayStats {
  final String date;
  final int minutes;
  final int items;

  const DayStats({required this.date, required this.minutes, required this.items});

  factory DayStats.fromMap(Map<Object?, Object?> map) {
    return DayStats(
      date: map['date'] as String? ?? '',
      minutes: map['minutes'] as int? ?? 0,
      items: map['items'] as int? ?? 0,
    );
  }
}

final class PermissionStatus {
  final bool accessibility;
  final bool overlay;
  final bool battery;

  const PermissionStatus({
    required this.accessibility,
    required this.overlay,
    required this.battery,
  });

  bool get isComplete => accessibility && overlay && battery;
}

final class NativeBridge {
  static const _channel = MethodChannel('niyyah/bridge');

  Future<List<InstalledApp>> listInstalledApps() async {
    final result = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'listInstalledApps',
    );
    return (result ?? const [])
        .map(
          (e) => InstalledApp(
            packageName: e['package'] as String? ?? '',
            name: e['name'] as String? ?? '',
            icon: e['icon'] as Uint8List?,
          ),
        )
        .toList();
  }

  Future<List<DayStats>> getStats() async {
    final result = await _channel.invokeMapMethod<Object?, Object?>('getStats');
    final days = result?['days'] as List<Object?>?;
    return (days ?? const [])
        .map((d) => DayStats.fromMap(d as Map<Object?, Object?>))
        .toList();
  }

  Future<PermissionStatus> getPermissions() async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'getPermissions',
    );
    return PermissionStatus(
      accessibility: result?['accessibility'] as bool? ?? false,
      overlay: result?['overlay'] as bool? ?? false,
      battery: result?['battery'] as bool? ?? false,
    );
  }

  Future<void> openAccessibilitySettings() =>
      _channel.invokeMethod('openAccessibilitySettings');

  Future<void> openOverlaySettings() =>
      _channel.invokeMethod('openOverlaySettings');

  Future<void> openBatterySettings() =>
      _channel.invokeMethod('openBatterySettings');
}

final nativeBridgeProvider = Provider<NativeBridge>((ref) => NativeBridge());
