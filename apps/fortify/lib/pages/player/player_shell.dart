import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class PlayerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PlayerShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.surface,
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AdminColors.surfaceContainerHigh,
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AdminColors.primary);
            }
            return const IconThemeData(color: AdminColors.onSurfaceVariant);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: AdminColors.primary, fontSize: 12, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12);
          }),
        ),
        child: NavigationBar(
          backgroundColor: AdminColors.background,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (int index) {
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Readiness',
            ),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Quests'),
            NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: 'Challenges'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
