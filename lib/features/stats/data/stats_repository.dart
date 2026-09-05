import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../blocklist/data/native_bridge.dart';

final class StatsRepository {
  final NativeBridge _bridge;

  const StatsRepository(this._bridge);

  Future<List<DayStats>> loadStats() => _bridge.getStats();
}

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(nativeBridgeProvider)),
);

final statsProvider = FutureProvider<List<DayStats>>(
  (ref) => ref.watch(statsRepositoryProvider).loadStats(),
);
