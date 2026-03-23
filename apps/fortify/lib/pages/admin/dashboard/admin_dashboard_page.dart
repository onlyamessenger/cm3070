import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/config/theme/admin_theme.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/admin/admin_level_state.dart';
import 'package:fortify/widgets/admin/admin_button.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const double _wideBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthState, AdminLevelState>(
      builder: (BuildContext context, AuthState authState, AdminLevelState levelState, Widget? child) {
        final String userName = authState.user?.name ?? 'Admin';
        final List<Level> levels = levelState.items.toList();
        final int totalLevels = levels.length;
        final int publishedCount = levels.where((Level l) => l.isPublished).length;
        final int draftCount = totalLevels - publishedCount;

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isWide = screenWidth >= _wideBreakpoint;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AdminPageHeader(title: 'Dashboard', subtitle: 'Welcome back, $userName'),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('OVERVIEW', style: AdminTheme.orbitronStyle(fontSize: 13)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: <Widget>[
                        _StatCard(
                          label: 'Total Levels',
                          value: totalLevels.toString(),
                          icon: Icons.layers_outlined,
                          iconColor: AdminColors.primary,
                          isWide: isWide,
                        ),
                        _StatCard(
                          label: 'Published',
                          value: publishedCount.toString(),
                          icon: Icons.check_circle_outline,
                          iconColor: AdminColors.success,
                          isWide: isWide,
                        ),
                        _StatCard(
                          label: 'Drafts',
                          value: draftCount.toString(),
                          icon: Icons.edit_outlined,
                          iconColor: AdminColors.warning,
                          isWide: isWide,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('QUICK ACTIONS', style: AdminTheme.orbitronStyle(fontSize: 13)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        AdminButton(
                          label: 'Add Level',
                          icon: Icons.add,
                          onPressed: () => context.go('/admin/levels/add'),
                        ),
                        AdminButton(
                          label: 'Manage Roles',
                          icon: Icons.manage_accounts_outlined,
                          isPrimary: false,
                          onPressed: () => context.go('/admin/roles'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('RECENT ACTIVITY', style: AdminTheme.orbitronStyle(fontSize: 13)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                      decoration: BoxDecoration(
                        color: AdminColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminColors.surfaceBorder),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.history_outlined, size: 40, color: AdminColors.onSurfaceVariant),
                          SizedBox(height: 12),
                          Text(
                            'No recent activity',
                            style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isWide;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isWide,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = widget.isWide ? 180 : double.infinity;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _isHovered ? AdminColors.primary : AdminColors.surfaceBorder),
          boxShadow: _isHovered
              ? <BoxShadow>[const BoxShadow(color: AdminColors.primaryGlow, blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AdminColors.primaryTint, borderRadius: BorderRadius.circular(8)),
              child: Icon(widget.icon, color: widget.iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.value, style: AdminTheme.orbitronStyle(fontSize: 22, color: AdminColors.onSurface)),
                const SizedBox(height: 2),
                Text(widget.label, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
