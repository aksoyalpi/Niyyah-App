import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/native_bridge.dart';

final installedAppsProvider = FutureProvider<List<InstalledApp>>(
  (ref) => ref.watch(nativeBridgeProvider).listInstalledApps(),
);

final permissionsProvider = FutureProvider<PermissionStatus>(
  (ref) => ref.watch(nativeBridgeProvider).getPermissions(),
);
