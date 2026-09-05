import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import 'native_bridge.dart';

enum IosAuthorizationStatus {
  notDetermined,
  denied,
  approved;

  static IosAuthorizationStatus fromCode(int code) {
    if (code < 0 || code >= IosAuthorizationStatus.values.length) {
      return IosAuthorizationStatus.notDetermined;
    }
    return IosAuthorizationStatus.values[code];
  }
}

final class IosBridge implements NativeBridge {
  static const _channel = MethodChannel(AppConstants.bridgeChannel);

  @override
  Future<List<DayStats>> getStats() async {
    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>('getStats');
      final days = result?['days'] as List<Object?>?;
      return (days ?? const [])
          .map((d) => DayStats.fromMap(d as Map<Object?, Object?>))
          .toList();
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  Future<IosAuthorizationStatus> getAuthorization() async {
    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>(
        'getAuthorization',
      );
      return IosAuthorizationStatus.fromCode(result?['status'] as int? ?? 0);
    } on PlatformException {
      return IosAuthorizationStatus.notDetermined;
    } on MissingPluginException {
      return IosAuthorizationStatus.notDetermined;
    }
  }

  Future<IosAuthorizationStatus> requestAuthorization() async {
    try {
      await _channel.invokeMethod<void>('requestAuthorization');
    } on PlatformException {
      return getAuthorization();
    } on MissingPluginException {
      return getAuthorization();
    }
    return getAuthorization();
  }

  Future<int> pickAppsToBlock() async {
    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>(
        'pickAppsToBlock',
      );
      return result?['count'] as int? ?? 0;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }

  Future<int> selectedAppCount() async {
    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>(
        'selectedAppCount',
      );
      return result?['count'] as int? ?? 0;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }
}
