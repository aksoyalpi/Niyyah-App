import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/application/preview_controller.dart';
import '../../content/presentation/reading_card.dart';
import '../../settings/application/settings_controller.dart';
import '../../stats/data/stats_repository.dart';
import '../../stats/presentation/stats_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(previewProvider);
    final settings = ref.watch(settingsControllerProvider);
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Niyyah')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            stats.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => const Text('Could not load stats'),
              data: (days) => StatsCard(days: days),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Color(0xFF6F6A63),
              ),
            ),
            const SizedBox(height: 8),
            settings.maybeWhen(
              data: (s) => preview.when(
                data: (item) => ReadingCard(item: item, style: s.style),
                loading: () => const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => const Text('Could not load content'),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            Center(
              child: IconButton.filledTonal(
                onPressed: () => ref.read(previewProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                tooltip: 'New verse',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
