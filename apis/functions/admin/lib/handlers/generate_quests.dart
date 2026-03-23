import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:infrastructure/infrastructure.dart';

import 'levels/database.dart';
import 'quests/database.dart';
import 'quests/openai.dart';
import 'quests/prompt.dart';
import 'quests/validator.dart';

Future<dynamic> handleGenerateQuests(final dynamic context, AppWriteClient appwrite, String? userId) async {
  if (userId == null) {
    return context.res.json({'ok': false, 'error': 'Unauthenticated'}, 401);
  }

  try {
    final Map<String, dynamic> body = jsonDecode(context.req.body) as Map<String, dynamic>;

    final int count = body['count'] as int? ?? 0;
    final String model = body['model'] as String? ?? '';
    final String? guidance = body['guidance'] as String?;
    final String difficulty = body['difficulty'] as String? ?? 'any';
    final String disasterType = body['disasterType'] as String? ?? 'any';
    final String totalDaysStr = (body['totalDays'] ?? 'any').toString();
    final int maxDepth = body['maxDepth'] as int? ?? 4;
    final int maxBranches = body['maxBranches'] as int? ?? 2;

    if (count < 1 || count > 5) {
      return context.res.json({'ok': false, 'error': 'Count must be between 1 and 5'}, 400);
    }
    if (maxDepth < 3 || maxDepth > 4) {
      return context.res.json({'ok': false, 'error': 'Max depth must be 3 or 4'}, 400);
    }
    if (maxBranches < 1 || maxBranches > 3) {
      return context.res.json({'ok': false, 'error': 'Max branches must be between 1 and 3'}, 400);
    }
    if (!allowedModels.contains(model)) {
      return context.res.json({'ok': false, 'error': 'Invalid model. Allowed: ${allowedModels.join(', ')}'}, 400);
    }

    // Validate totalDays
    if (totalDaysStr != 'any') {
      final int? totalDaysInt = int.tryParse(totalDaysStr);
      if (totalDaysInt == null || totalDaysInt < 3 || totalDaysInt > 14) {
        return context.res.json({'ok': false, 'error': 'Total days must be between 3 and 14, or "any"'}, 400);
      }
      if (totalDaysInt < maxDepth) {
        return context.res.json({'ok': false, 'error': 'Total days must be >= max depth ($maxDepth)'}, 400);
      }
    }

    // Node budget validation
    final int nodeBudget = count * pow(maxBranches, maxDepth).toInt();
    if (nodeBudget > 200) {
      return context.res.json({
        'ok': false,
        'error': 'Node budget exceeded (estimated $nodeBudget nodes). Reduce count, depth, or branches.',
      }, 400);
    }

    final String apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      return context.res.json({'ok': false, 'error': 'OPENAI_API_KEY not configured'}, 500);
    }

    // Fetch context in parallel
    final List<dynamic> contextResults = await Future.wait(<Future<dynamic>>[
      fetchExistingQuests(appwrite),
      fetchExistingLevels(appwrite),
      fetchAlreadyUnlockedSections(appwrite),
    ]);

    final List<Map<String, dynamic>> existingQuests = contextResults[0] as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> levels = contextResults[1] as List<Map<String, dynamic>>;
    final List<String> alreadyUnlockedSections = contextResults[2] as List<String>;

    final String userPrompt = buildUserPrompt(
      count: count,
      maxDepth: maxDepth,
      maxBranches: maxBranches,
      difficulty: difficulty,
      disasterType: disasterType,
      totalDays: totalDaysStr,
      existingQuests: existingQuests,
      levels: levels,
      alreadyUnlockedSections: alreadyUnlockedSections,
      guidance: guidance,
    );

    context.log(
      'Requesting $count quests (model: $model, maxDepth: $maxDepth, maxBranches: $maxBranches, '
      'nodeBudget: $nodeBudget)',
    );

    final List<Map<String, dynamic>> generated = await callOpenAI(apiKey, model, userPrompt);
    context.log('OpenAI returned ${generated.length} quests');

    for (int i = 0; i < generated.length; i++) {
      final Map<String, dynamic> quest = generated[i];
      final List<dynamic> nodes = quest['nodes'] as List<dynamic>? ?? <dynamic>[];
      context.log('Quest ${i + 1}: "${quest['title']}" - ${nodes.length} nodes');
    }

    // Post-generation validation: filter out invalid quests
    final List<Map<String, dynamic>> validQuests = generated.where((Map<String, dynamic> quest) {
      return validateQuestGraph(quest, onError: context.error, onLog: context.log);
    }).toList();
    context.log('Validation: ${validQuests.length}/${generated.length} quests passed');

    final List<Map<String, dynamic>> created = await writeGeneratedQuests(appwrite, validQuests, userId);

    context.log(
      'Written ${created.length} quests to DB '
      '(${generated.length - validQuests.length} failed validation, '
      '${validQuests.length - created.length} failed writing)',
    );
    return context.res.json({'ok': true, 'quests': created, 'count': created.length});
  } on FormatException catch (e) {
    context.error('Invalid JSON body: $e');
    return context.res.json({'ok': false, 'error': 'Invalid request body'}, 400);
  } catch (e) {
    context.error('Error generating quests: $e');
    return context.res.json({'ok': false, 'error': '$e'}, 500);
  }
}

