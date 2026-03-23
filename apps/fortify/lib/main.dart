import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'package:core/core.dart';
import 'package:fortify/config/environment.dart';
import 'package:fortify/config/theme/admin_theme.dart';
import 'package:fortify/controllers/auth_controller.dart';
import 'package:fortify/dependencies/dependencies.dart';
import 'package:fortify/routes.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/admin/admin_bonus_event_state.dart';
import 'package:fortify/state/admin/admin_challenge_state.dart';
import 'package:fortify/state/admin/admin_kit_item_state.dart';
import 'package:fortify/state/admin/admin_level_state.dart';
import 'package:fortify/state/admin/admin_quest_state.dart';
import 'package:fortify/state/admin/admin_role_state.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/state/player_state.dart';
import 'package:fortify/state/profile_state.dart';
import 'package:fortify/state/quest_play_state.dart';
import 'package:fortify/state/readiness_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Environment.load();
  registerDependencies();

  // Restore existing session before building the router
  await Inject.get<AuthController>().checkSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(value: Inject.get<AuthState>()),
        ChangeNotifierProvider<AdminLevelState>.value(value: Inject.get<AdminLevelState>()),
        ChangeNotifierProvider<AdminChallengeState>.value(value: Inject.get<AdminChallengeState>()),
        ChangeNotifierProvider<AdminQuestState>.value(value: Inject.get<AdminQuestState>()),
        ChangeNotifierProvider<AdminKitItemState>.value(value: Inject.get<AdminKitItemState>()),
        ChangeNotifierProvider<AdminBonusEventState>.value(value: Inject.get<AdminBonusEventState>()),
        ChangeNotifierProvider<AdminRoleState>.value(value: Inject.get<AdminRoleState>()),
        ChangeNotifierProvider<PlayerState>.value(value: Inject.get<PlayerState>()),
        ChangeNotifierProvider<ChallengePlayState>.value(value: Inject.get<ChallengePlayState>()),
        ChangeNotifierProvider<QuestPlayState>.value(value: Inject.get<QuestPlayState>()),
        ChangeNotifierProvider<ReadinessState>.value(value: Inject.get<ReadinessState>()),
        ChangeNotifierProvider<ProfileState>.value(value: Inject.get<ProfileState>()),
      ],
      child: const FortifyApp(),
    ),
  );
}

class FortifyApp extends StatelessWidget {
  const FortifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Fortify', theme: AdminTheme.build(), routerConfig: router);
  }
}
