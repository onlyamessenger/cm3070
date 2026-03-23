import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/config/theme/admin_theme.dart';

/// A single navigation item entry for the sidebar.
class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  final bool enabled;

  const _NavItem({required this.label, required this.icon, required this.route, this.enabled = true});
}

/// A group of navigation items with an optional section title.
class _NavGroup {
  final String? title;
  final List<_NavItem> items;

  const _NavGroup({this.title, required this.items});
}

/// Sidebar navigation component for the admin interface.
///
/// Displays grouped navigation items with active state highlighting,
/// user info at the bottom, and a gradient background.
class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final String userName;
  final String userRole;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.userName,
    required this.userRole,
    required this.onLogout,
  });

  static const double _width = 260;

  static const List<_NavGroup> _groups = <_NavGroup>[
    _NavGroup(
      title: null,
      items: <_NavItem>[_NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/admin/dashboard')],
    ),
    _NavGroup(
      title: 'Content',
      items: <_NavItem>[
        _NavItem(label: 'Levels', icon: Icons.bar_chart_outlined, route: '/admin/levels'),
        _NavItem(label: 'Challenges', icon: Icons.flag_outlined, route: '/admin/challenges'),
        _NavItem(label: 'Quests', icon: Icons.map_outlined, route: '/admin/quests'),
        _NavItem(label: 'Bonus Events', icon: Icons.star_outline, route: '/admin/bonus-events'),
        _NavItem(label: 'Kit Items', icon: Icons.inventory_2_outlined, route: '/admin/kit-items'),
      ],
    ),
    _NavGroup(
      title: 'Players',
      items: <_NavItem>[
        _NavItem(label: 'Players', icon: Icons.person_outline, route: '/admin/players', enabled: false),
        _NavItem(label: 'Parties', icon: Icons.group_outlined, route: '/admin/parties', enabled: false),
      ],
    ),
    _NavGroup(
      title: 'Settings',
      items: <_NavItem>[_NavItem(label: 'Roles', icon: Icons.shield_outlined, route: '/admin/roles')],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AdminColors.sidebarGradientStart, AdminColors.sidebarGradientEnd],
          ),
          border: Border(right: BorderSide(color: AdminColors.surfaceBorder)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildLogo(),
            const Divider(height: 1, thickness: 1, color: AdminColors.surfaceBorderSubtle),
            Expanded(
              child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: _buildNavGroups()),
            ),
            const Divider(height: 1, thickness: 1, color: AdminColors.surfaceBorderSubtle),
            _buildUserFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('FORTIFY', style: AdminTheme.orbitronStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'ADMIN CONSOLE',
            style: TextStyle(
              color: AdminColors.onSurfaceVariant,
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavGroups() {
    final List<Widget> widgets = <Widget>[];
    for (final _NavGroup group in _groups) {
      if (group.title != null) {
        widgets.add(_buildGroupTitle(group.title!));
      }
      for (final _NavItem item in group.items) {
        widgets.add(_buildNavItem(item));
      }
      if (group != _groups.last) {
        widgets.add(const SizedBox(height: 4));
      }
    }
    return widgets;
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AdminColors.onSurfaceVariant,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item) {
    final bool isActive = currentRoute == item.route;

    return Opacity(
      opacity: item.enabled ? 1.0 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.enabled ? () => onNavigate(item.route) : null,
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isActive ? AdminColors.primaryOverlay : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isActive
                    ? const Border(left: BorderSide(color: AdminColors.primary, width: 2))
                    : Border.all(color: Colors.transparent),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(isActive ? 10 : 12, 9, 12, 9),
                child: Row(
                  children: <Widget>[
                    Icon(item.icon, size: 20, color: isActive ? AdminColors.primary : AdminColors.onSurface),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isActive ? AdminColors.primary : AdminColors.onSurface,
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserFooter() {
    final String avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: AdminColors.primaryVariant,
                child: Text(
                  avatarLetter,
                  style: const TextStyle(color: AdminColors.onSurface, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userName,
                      style: const TextStyle(color: AdminColors.onSurface, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      userRole,
                      style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, size: 14),
            label: const Text('Logout', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: AdminColors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }
}
