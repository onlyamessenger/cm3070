import 'dart:convert';
import 'dart:io';

import 'package:infrastructure/infrastructure.dart';

import 'challenges/database.dart';
import 'challenges/openai.dart';
import 'challenges/prompt.dart';
import 'levels/database.dart';

Future<dynamic> handleGenerateChallenges(final dynamic context, AppWriteClient appwrite, String? userId) async {
  if (userId == null) {
    return context.res.json({'ok': false, 'error': 'Unauthenticated'}, 401);
  }

  try {
    final Map<String, dynamic> body = jsonDecode(context.req.body) as Map<String, dynamic>;

    final int count = body['count'] as int? ?? 0;
    final int questionsPerChallenge = body['questionsPerChallenge'] as int? ?? 3;
    final String model = body['model'] as String? ?? '';
    final String? guidance = body['guidance'] as String?;
    final List<String> questIds = (body['questIds'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final List<String> challengeTypes = (body['challengeTypes'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final String difficulty = body['difficulty'] as String? ?? 'any';
    final String disasterType = body['disasterType'] as String? ?? 'any';

    final int maxCount = questIds.isNotEmpty ? 10 : 20;
    if (count < 1 || count > maxCount) {
      return context.res.json({'ok': false, 'error': 'Count must be between 1 and $maxCount'}, 400);
    }
    if (questionsPerChallenge < 3 || questionsPerChallenge > 10) {
      return context.res.json({'ok': false, 'error': 'Questions per challenge must be between 3 and 10'}, 400);
    }
    if (!allowedModels.contains(model)) {
      return context.res.json({'ok': false, 'error': 'Invalid model. Allowed: ${allowedModels.join(', ')}'}, 400);
    }
    if (challengeTypes.isEmpty) {
      return context.res.json({'ok': false, 'error': 'At least one challenge type is required'}, 400);
    }

    final String apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      return context.res.json({'ok': false, 'error': 'OPENAI_API_KEY not configured'}, 500);
    }

    // Fetch context in parallel
    final List<dynamic> contextResults = await Future.wait(<Future<dynamic>>[
      fetchExistingChallenges(appwrite),
      fetchExistingLevels(appwrite),
      fetchQuestsByIds(appwrite, questIds),
    ]);

    final List<Map<String, dynamic>> existingChallenges = contextResults[0] as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> levels = contextResults[1] as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> quests = contextResults[2] as List<Map<String, dynamic>>;

    final String userPrompt = buildUserPrompt(
      count: count,
      questionsPerChallenge: questionsPerChallenge,
      challengeTypes: challengeTypes,
      difficulty: difficulty,
      disasterType: disasterType,
      existingChallenges: existingChallenges,
      levels: levels,
      quests: quests.isNotEmpty ? quests : null,
      guidance: guidance,
    );

    final List<Map<String, dynamic>> generated = await callOpenAI(apiKey, model, userPrompt);

    final Set<String> validQuestIds = questIds.toSet();
    final List<Map<String, dynamic>> created = await writeGeneratedChallenges(
      appwrite,
      generated,
      userId,
      validQuestIds,
    );

    context.log('Generated ${created.length} challenges');
    return context.res.json({'ok': true, 'challenges': created, 'count': created.length});
  } on FormatException catch (e) {
    context.error('Invalid JSON body: $e');
    return context.res.json({'ok': false, 'error': 'Invalid request body'}, 400);
  } catch (e) {
    context.error('Error generating challenges: $e');
    return context.res.json({'ok': false, 'error': '$e'}, 500);
  }
}
