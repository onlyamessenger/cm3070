import 'dart:convert';

import 'package:core/core.dart';
import 'package:infrastructure/infrastructure.dart';

Future<dynamic> handleDailyCheckIn(final dynamic context, AppWriteClient appwrite) async {
  final LoggerService logger = AppWriteLoggerService(context: context);

  try {
    final String? userId = AppWriteClient.getUserId(context);
    if (userId == null || userId.isEmpty) {
      return context.res.json({'ok': false, 'error': 'Authentication required'}, 401);
    }

    final dynamic rawBody = context.req.body;
    logger.info('Body type: ${rawBody.runtimeType}, body: $rawBody');
    final Map<String, dynamic> body;
    if (rawBody is Map) {
      body = Map<String, dynamic>.from(rawBody);
    } else if (rawBody is String && rawBody.isNotEmpty) {
      body = jsonDecode(rawBody) as Map<String, dynamic>;
    } else {
      body = <String, dynamic>{};
    }
    final bool useShield = body['useShield'] as bool? ?? false;

    final AppWritePlayerService playerService = AppWritePlayerService(
      databases: appwrite.databases,
      databaseId: appwrite.databaseId,
    );

    final AwardXp awardXp = AwardXp(
      playerService: playerService,
      bonusEventService: AppWriteBonusEventService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      activityLogService: AppWriteActivityLogService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      logger: logger,
    );

    final DailyCheckIn useCase = DailyCheckIn(playerService: playerService, awardXp: awardXp, logger: logger);

    final DailyCheckInResult result = await useCase.execute(
      DailyCheckInInput(userId: userId, useShield: useShield, now: DateTime.now()),
    );

    if (result.alreadyCheckedIn) {
      return context.res.json({'ok': false, 'alreadyCheckedIn': true});
    }

    if (!result.ok && result.shieldAvailable) {
      return context.res.json({
        'ok': false,
        'shieldAvailable': true,
        'streakReset': false,
        'currentStreak': result.currentStreak,
        'message': 'You missed a day. Use your shield to keep your streak?',
      });
    }

    return context.res.json({
      'ok': true,
      'xpAwarded': result.xpAwarded,
      'multiplier': result.multiplier,
      'currentStreak': result.currentStreak,
      'longestStreak': result.longestStreak,
      'shieldAvailable': result.shieldAvailable,
      'alreadyCheckedIn': false,
      'streakReset': result.streakReset,
    });
  } on FormatException catch (e) {
    logger.error('Invalid JSON body: $e');
    return context.res.json({'ok': false, 'error': 'Invalid request body'}, 400);
  } catch (e) {
    logger.error('Daily check-in error: $e');
    return context.res.json({'ok': false, 'error': '$e'}, 500);
  }
}
