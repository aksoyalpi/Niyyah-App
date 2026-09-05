import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import '../features/blocklist/presentation/blocklist_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

class NiyyahApp extends StatelessWidget {
  const NiyyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niyyah',
      theme: AppTheme.light,
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  var _index = 0;

  static const _screens = [
    DashboardScreen(),
    BlocklistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.block_outlined),
            selectedIcon: Icon(Icons.block),
            label: 'Block Apps',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
