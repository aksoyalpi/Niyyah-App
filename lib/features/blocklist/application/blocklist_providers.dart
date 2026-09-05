import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/android_bridge.dart';
import '../data/ios_bridge.dart';
import '../data/native_bridge.dart';

final androidBridgeProvider = Provider<AndroidBridge>((ref) => AndroidBridge());

final iosBridgeProvider = Provider<IosBridge>((ref) => IosBridge());

final nativeBridgeProvider = Provider<NativeBridge>(
  (ref) => Platform.isIOS ? ref.watch(iosBridgeProvider) : ref.watch(androidBridgeProvider),
);

final installedAppsProvider = FutureProvider<List<InstalledApp>>(
  (ref) => ref.watch(androidBridgeProvider).listInstalledApps(),
);

final permissionsProvider = FutureProvider<PermissionStatus>(
  (ref) => ref.watch(androidBridgeProvider).getPermissions(),
);

final iosAuthorizationProvider = FutureProvider<IosAuthorizationStatus>(
  (ref) => ref.watch(iosBridgeProvider).getAuthorization(),
);

final iosSelectionCountProvider = FutureProvider<int>(
  (ref) => ref.watch(iosBridgeProvider).selectedAppCount(),
);
