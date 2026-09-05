import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/blocklist_controller.dart';
import '../application/blocklist_providers.dart';
import '../data/native_bridge.dart';

class BlocklistScreen extends ConsumerStatefulWidget {
  const BlocklistScreen({super.key});

  @override
  ConsumerState<BlocklistScreen> createState() => _BlocklistScreenState();
}

class _BlocklistScreenState extends ConsumerState<BlocklistScreen> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(installedAppsProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Block Apps')),
      body: Column(
        children: [
          permissions.maybeWhen(
            data: (p) => p.isComplete ? const SizedBox.shrink() : _PermissionBanner(p),
            orElse: () => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search apps',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: apps.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('Could not load apps')),
              data: (list) {
                final filtered = list
                    .where((a) => a.name.toLowerCase().contains(_query))
                    .toList();
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(indent: 72),
                  itemBuilder: (context, index) {
                    final app = filtered[index];
                    return _AppTile(app: app);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _AppTile extends ConsumerWidget {
  final InstalledApp app;

  const _AppTile({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(
      blocklistControllerProvider.select((s) => s.contains(app.packageName)),
    );
    return ListTile(
      leading: app.icon != null
          ? CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: MemoryImage(app.icon!),
            )
          : const CircleAvatar(
              backgroundColor: AppColors.accentSoft,
              child: Icon(Icons.apps, color: AppColors.accent),
            ),
      title: Text(app.name),
      subtitle: Text(app.packageName, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: blocked,
        onChanged: (value) => ref
            .read(blocklistControllerProvider.notifier)
            .setBlocked(app.packageName, blocked: value),
      ),
    );
  }
}

final class _PermissionBanner extends ConsumerWidget {
  final PermissionStatus status;

  const _PermissionBanner(this.status);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.read(nativeBridgeProvider);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permissions needed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Niyyah needs three permissions to block apps:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _PermissionRow(
              done: status.accessibility,
              label: 'Accessibility (detect blocked apps)',
              onTap: bridge.openAccessibilitySettings,
            ),
            const SizedBox(height: 8),
            _PermissionRow(
              done: status.overlay,
              label: 'Display over other apps (show the verse)',
              onTap: bridge.openOverlaySettings,
            ),
            const SizedBox(height: 8),
            _PermissionRow(
              done: status.battery,
              label: 'Battery optimization (run unrestricted)',
              onTap: bridge.openBatterySettings,
            ),
          ],
        ),
      ),
    );
  }
}

final class _PermissionRow extends StatelessWidget {
  final bool done;
  final String label;
  final Future<void> Function() onTap;

  const _PermissionRow({
    required this.done,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: done ? AppColors.accent : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        if (!done)
          TextButton(
            onPressed: onTap,
            child: const Text('Enable'),
          ),
      ],
    );
  }
}
