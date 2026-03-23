import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/auth_controller.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/widgets/admin/admin_sidebar.dart';

/// Responsive layout shell wrapping all admin routes.
///
/// On desktop (>=768px) renders a permanent sidebar alongside the content.
/// On mobile (<768px) uses an AppBar with a hamburger that opens a Drawer.
class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (BuildContext context, AuthState authState, Widget? _) {
        final String currentRoute = GoRouterState.of(context).location;

        final String userName = authState.user?.name ?? authState.user?.email ?? 'Admin';
        final String userRole = authState.isAdmin ? 'Administrator' : 'User';

        final AuthController authController = Inject.get<AuthController>();

        void handleNavigate(String route) => context.go(route);

        void handleLogout() => authController.logout();

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isDesktop = constraints.maxWidth >= 768;

            if (isDesktop) {
              return _DesktopLayout(
                currentRoute: currentRoute,
                onNavigate: handleNavigate,
                userName: userName,
                userRole: userRole,
                onLogout: handleLogout,
                child: child,
              );
            }

            return _MobileLayout(
              currentRoute: currentRoute,
              onNavigate: handleNavigate,
              userName: userName,
              userRole: userRole,
              onLogout: handleLogout,
              child: child,
            );
          },
        );
      },
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final String userName;
  final String userRole;
  final VoidCallback onLogout;
  final Widget child;

  const _DesktopLayout({
    required this.currentRoute,
    required this.onNavigate,
    required this.userName,
    required this.userRole,
    required this.onLogout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.surface,
      body: Row(
        children: <Widget>[
          AdminSidebar(
            currentRoute: currentRoute,
            onNavigate: onNavigate,
            userName: userName,
            userRole: userRole,
            onLogout: onLogout,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final String userName;
  final String userRole;
  final VoidCallback onLogout;
  final Widget child;

  const _MobileLayout({
    required this.currentRoute,
    required this.onNavigate,
    required this.userName,
    required this.userRole,
    required this.onLogout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.surface,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        foregroundColor: AdminColors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AdminColors.onSurface),
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
            );
          },
        ),
        title: const Text(
          'FORTIFY',
          style: TextStyle(color: AdminColors.primary, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2.0),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
            AdminSidebar(
              currentRoute: currentRoute,
              onNavigate: (String route) {
                Navigator.of(context).pop();
                onNavigate(route);
              },
              userName: userName,
              userRole: userRole,
              onLogout: onLogout,
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
