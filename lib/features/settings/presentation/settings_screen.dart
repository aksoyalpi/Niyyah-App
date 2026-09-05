import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../application/settings_controller.dart';
import '../domain/display_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Could not load settings')),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader('What to show'),
            Card(
              child: RadioGroup<DisplayMode>(
                groupValue: s.mode,
                onChanged: (m) => ref
                    .read(settingsControllerProvider.notifier)
                    .setMode(m!),
                child: Column(
                  children: [
                    for (final mode in DisplayMode.values)
                      RadioListTile(
                        value: mode,
                        title: Text(mode.label),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeader('Content style'),
            Card(
              child: RadioGroup<ContentStyle>(
                groupValue: s.style,
                onChanged: (v) => ref
                    .read(settingsControllerProvider.notifier)
                    .setStyle(v!),
                child: Column(
                  children: [
                    for (final style in ContentStyle.values)
                      RadioListTile(
                        value: style,
                        title: Text(style.label),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeader('Session duration'),
            Card(
              child: RadioGroup<int>(
                groupValue: s.sessionMinutes,
                onChanged: (v) => ref
                    .read(settingsControllerProvider.notifier)
                    .setSessionMinutes(v!),
                child: Column(
                  children: [
                    for (final minutes in AppConstants.sessionDurationMinutes)
                      RadioListTile(
                        value: minutes,
                        title: Text('$minutes minutes'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
