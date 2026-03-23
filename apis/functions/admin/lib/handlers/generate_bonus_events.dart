import 'dart:convert';
import 'dart:io';

import 'package:infrastructure/infrastructure.dart';

import 'bonus_events/database.dart';
import 'bonus_events/openai.dart';
import 'bonus_events/prompt.dart';

Future<dynamic> handleGenerateBonusEvents(final dynamic context, AppWriteClient appwrite, String? userId) async {
  if (userId == null) {
    return context.res.json({'ok': false, 'error': 'Unauthenticated'}, 401);
  }

  try {
    final Map<String, dynamic> body = jsonDecode(context.req.body) as Map<String, dynamic>;

    final int count = body['count'] as int? ?? 0;
    final String model = body['model'] as String? ?? '';
    final String? guidance = body['guidance'] as String?;

    if (count < 1 || count > 20) {
      return context.res.json({'ok': false, 'error': 'Count must be between 1 and 20'}, 400);
    }
    if (!allowedModels.contains(model)) {
      return context.res.json({'ok': false, 'error': 'Invalid model. Allowed: ${allowedModels.join(', ')}'}, 400);
    }

    final String apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      return context.res.json({'ok': false, 'error': 'OPENAI_API_KEY not configured'}, 500);
    }

    final List<Map<String, dynamic>> existingEvents = await fetchExistingBonusEvents(appwrite);
    final String userPrompt = buildUserPrompt(count, existingEvents, guidance);
    final List<Map<String, dynamic>> generated = await callOpenAI(apiKey, model, userPrompt);
    final List<Map<String, dynamic>> created = await writeGeneratedBonusEvents(appwrite, generated, userId);

    context.log('Generated ${created.length} bonus events');
    return context.res.json({'ok': true, 'bonusEvents': created, 'count': created.length});
  } on FormatException catch (e) {
    context.error('Invalid JSON body: $e');
    return context.res.json({'ok': false, 'error': 'Invalid request body'}, 400);
  } catch (e) {
    context.error('Error generating bonus events: $e');
    return context.res.json({'ok': false, 'error': '$e'}, 500);
  }
}
