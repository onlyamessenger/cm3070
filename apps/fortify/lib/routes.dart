import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/pages/admin/admin_shell.dart';
import 'package:fortify/pages/admin/bonus_events/admin_bonus_event_add_page.dart';
import 'package:fortify/pages/admin/bonus_events/admin_bonus_event_edit_page.dart';
import 'package:fortify/pages/admin/bonus_events/admin_bonus_events_page.dart';
import 'package:fortify/pages/admin/challenges/admin_challenge_add_page.dart';
import 'package:fortify/pages/admin/challenges/admin_challenge_edit_page.dart';
import 'package:fortify/pages/admin/challenges/admin_challenges_page.dart';
import 'package:fortify/pages/admin/dashboard/admin_dashboard_page.dart';
import 'package:fortify/pages/admin/kit_items/admin_kit_item_add_page.dart';
import 'package:fortify/pages/admin/kit_items/admin_kit_item_edit_page.dart';
import 'package:fortify/pages/admin/kit_items/admin_kit_items_page.dart';
import 'package:fortify/pages/admin/levels/admin_level_add_page.dart';
import 'package:fortify/pages/admin/levels/admin_level_edit_page.dart';
import 'package:fortify/pages/admin/levels/admin_levels_page.dart';
import 'package:fortify/pages/admin/quests/admin_quest_add_page.dart';
import 'package:fortify/pages/admin/quests/admin_quest_edit_page.dart';
import 'package:fortify/pages/admin/quests/admin_quests_page.dart';
import 'package:fortify/pages/admin/roles/admin_roles_page.dart';
import 'package:fortify/pages/login/login_page.dart';
import 'package:fortify/pages/login/reset_password_page.dart';
import 'package:fortify/pages/register/register_page.dart';
import 'package:fortify/pages/player/challenges/challenge_list_page.dart';
import 'package:fortify/pages/player/challenges/challenge_play_page.dart';
import 'package:fortify/pages/player/quests/quest_list_page.dart';
import 'package:fortify/pages/player/quests/quest_play_page.dart';
import 'package:fortify/pages/player/player_shell.dart';
import 'package:fortify/pages/player/profile_page.dart';
import 'package:fortify/pages/player/readiness/flood_risk_page.dart';
import 'package:fortify/pages/player/readiness/evacuation_route_detail_page.dart';
import 'package:fortify/pages/player/readiness/evacuation_routes_page.dart';
import 'package:fortify/pages/player/readiness/kit_checklist_page.dart';
import 'package:fortify/pages/player/readiness/readiness_section_page.dart';
import 'package:fortify/pages/player/readiness/shelter_location_detail_page.dart';
import 'package:fortify/pages/player/readiness/emergency_contacts_page.dart';
import 'package:fortify/pages/player/readiness/shelter_locations_page.dart';
import 'package:fortify/pages/player/readiness_dashboard_page.dart';
import 'package:fortify/state/auth_state.dart';

/// Builds a fade transition page to avoid slide-in artifacts.
CustomTransitionPage<void> _fadePage({required Widget child, required GoRouterState state}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: ColoredBox(color: AdminColors.surface, child: child),
    transitionsBuilder:
        (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    final AuthState authState = Inject.get<AuthState>();
    final bool isLoggedIn = authState.isAuthenticated;
    final bool isAdmin = authState.isAdmin;
    final String location = state.location;

    final bool isLoginRoute = location.startsWith('/login');
    final bool isRegisterRoute = location.startsWith('/register');
    final bool isAdminRoute = location.startsWith('/admin');

    if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) return '/login';
    if (isLoggedIn && (isLoginRoute || isRegisterRoute)) return isAdmin ? '/admin/dashboard' : '/';
    if (isAdminRoute && !isAdmin) return '/';

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      pageBuilder: (BuildContext context, GoRouterState state) => _fadePage(state: state, child: const LoginPage()),
      routes: <RouteBase>[
        GoRoute(
          path: 'reset-password',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const ResetPasswordPage()),
        ),
      ],
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (BuildContext context, GoRouterState state) => _fadePage(state: state, child: const RegisterPage()),
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AdminShell(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/admin/dashboard',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const AdminDashboardPage()),
        ),
        GoRoute(
          path: '/admin/levels',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const AdminLevelsPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const AdminLevelAddPage()),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final String levelId = state.pathParameters['id']!;
                return _fadePage(
                  state: state,
                  child: AdminLevelEditPage(levelId: levelId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/challenges',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const AdminChallengesPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const AdminChallengeAddPage()),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final String challengeId = state.pathParameters['id']!;
                return _fadePage(
                  state: state,
                  child: AdminChallengeEditPage(challengeId: challengeId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/quests',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const AdminQuestsPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const AdminQuestAddPage()),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final String questId = state.pathParameters['id']!;
                return _fadePage(
                  state: state,
                  child: AdminQuestEditPage(questId: questId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/bonus-events',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const AdminBonusEventsPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const AdminBonusEventAddPage()),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final String bonusEventId = state.pathParameters['id']!;
                return _fadePage(
                  state: state,
                  child: AdminBonusEventEditPage(bonusEventId: bonusEventId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/kit-items',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const AdminKitItemsPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const AdminKitItemAddPage()),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final String kitItemId = state.pathParameters['id']!;
                return _fadePage(
                  state: state,
                  child: AdminKitItemEditPage(kitItemId: kitItemId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/roles',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _fadePage(state: state, child: const AdminRolesPage()),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
        return PlayerShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const ReadinessDashboardPage()),
              routes: <RouteBase>[
                GoRoute(
                  path: 'readiness/emergency-kit',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      _fadePage(state: state, child: const KitChecklistPage()),
                ),
                GoRoute(
                  path: 'readiness/evacuation-routes',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      _fadePage(state: state, child: const EvacuationRoutesPage()),
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':routeIndex',
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        final int routeIndex = int.tryParse(state.pathParameters['routeIndex'] ?? '') ?? 0;
                        return _fadePage(
                          state: state,
                          child: EvacuationRouteDetailPage(routeIndex: routeIndex),
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'readiness/shelter-locations',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      _fadePage(state: state, child: const ShelterLocationsPage()),
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':shelterIndex',
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        final int shelterIndex = int.tryParse(state.pathParameters['shelterIndex'] ?? '') ?? 0;
                        return _fadePage(
                          state: state,
                          child: ShelterLocationDetailPage(shelterIndex: shelterIndex),
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'readiness/emergency-contacts',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      _fadePage(state: state, child: const EmergencyContactsPage()),
                ),
                GoRoute(
                  path: 'readiness/flood-risk',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      _fadePage(state: state, child: const FloodRiskPage()),
                ),
                GoRoute(
                  path: 'readiness/:sectionType',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final String sectionType = state.pathParameters['sectionType']!;
                    return _fadePage(
                      state: state,
                      child: ReadinessSectionPage(sectionType: sectionType),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/quests',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const QuestListPage()),
              routes: <RouteBase>[
                GoRoute(
                  path: ':id',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final String questId = state.pathParameters['id']!;
                    return _fadePage(
                      state: state,
                      child: QuestPlayPage(questId: questId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/challenges',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _fadePage(state: state, child: const ChallengeListPage()),
              routes: <RouteBase>[
                GoRoute(
                  path: ':id',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final String challengeId = state.pathParameters['id']!;
                    return _fadePage(
                      state: state,
                      child: ChallengePlayPage(challengeId: challengeId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              pageBuilder: (BuildContext context, GoRouterState state) => _fadePage(
                state: state,
                child: const Scaffold(backgroundColor: AdminColors.surface, body: ProfilePage()),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
