import 'dart:convert';

import 'package:core/core.dart';
import 'package:infrastructure/infrastructure.dart';

Future<dynamic> handleCompleteChallenge(final dynamic context, AppWriteClient appwrite) async {
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
      return context.res.json({'ok': false, 'error': 'Empty or invalid request body'}, 400);
    }
    final String progressId = (body['progressId'] as String?)?.trim() ?? '';

    if (progressId.isEmpty) {
      return context.res.json({'ok': false, 'error': 'progressId is required'}, 400);
    }

    final AwardXp awardXp = AwardXp(
      playerService: AppWritePlayerService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      bonusEventService: AppWriteBonusEventService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      activityLogService: AppWriteActivityLogService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      logger: logger,
    );

    final CompleteChallenge useCase = CompleteChallenge(
      progressService: AppWritePlayerChallengeProgressService(
        databases: appwrite.databases,
        databaseId: appwrite.databaseId,
      ),
      challengeService: AppWriteChallengeService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      awardXp: awardXp,
      sectionService: AppWriteReadinessSectionService(databases: appwrite.databases, databaseId: appwrite.databaseId),
      logger: logger,
    );

    final CompleteChallengeResult result = await useCase.execute(CompleteChallengeInput(progressId: progressId));

    return context.res.json({
      'ok': true,
      'xpAwarded': result.xpAwarded,
      'multiplier': result.multiplier,
      'unlockedSection': result.unlockedSection,
    });
  } on FormatException catch (e) {
    logger.error('Invalid JSON body: $e');
    return context.res.json({'ok': false, 'error': 'Invalid request body'}, 400);
  } catch (e) {
    logger.error('Complete challenge error: $e');
    return context.res.json({'ok': false, 'error': '$e'}, 500);
  }
}
