import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:infrastructure/infrastructure.dart';

Future<dynamic> handleRegister(final dynamic context, AppWriteClient appwrite) async {
  final LoggerService logger = AppWriteLoggerService(context: context);

  try {
    final Map<String, dynamic> body = jsonDecode(context.req.body as String) as Map<String, dynamic>;

    final String name = (body['name'] as String?)?.trim() ?? '';
    final String email = (body['email'] as String?)?.trim() ?? '';
    final String password = body['password'] as String? ?? '';

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return context.res.json({'ok': false, 'error': 'Name, email, and password are required'}, 400);
    }
    if (password.length < 8) {
      return context.res.json({'ok': false, 'error': 'Password must be at least 8 characters'}, 400);
    }
    if (!email.contains('@')) {
      return context.res.json({'ok': false, 'error': 'Invalid email address'}, 400);
    }

    final String playerTeamId = Platform.environment['APPWRITE_PLAYER_TEAM_ID'] ?? '';
    if (playerTeamId.isEmpty) {
      return context.res.json({'ok': false, 'error': 'APPWRITE_PLAYER_TEAM_ID not configured'}, 500);
    }

    logger.info('databaseId=${appwrite.databaseId}, playerTeamId=$playerTeamId');

    final Users users = Users(appwrite.client);
    final Teams teams = Teams(appwrite.client);

    final RegisterPlayer useCase = RegisterPlayer(
      authService: AppWriteAuthService(users: users),
      playerService: AppWritePlayerService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      roleService: AppWriteRoleService(teams: teams),
      sectionService: AppWriteReadinessSectionService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      kitItemService: AppWriteKitItemService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      logger: logger,
      playerTeamId: playerTeamId,
    );

    final Player player = await useCase.execute(RegisterPlayerInput(email: email, password: password, name: name));

    return context.res.json({
      'ok': true,
      'player': <String, dynamic>{'id': player.id, 'userId': player.userId, 'displayName': player.displayName},
    });
  } on FormatException catch (e) {
    logger.error('Invalid JSON body: $e');
    return context.res.json({'ok': false, 'error': 'Invalid request body'}, 400);
  } catch (e) {
    logger.error('Registration error: $e');
    return context.res.json({'ok': false, 'error': '$e'}, 500);
  }
}
