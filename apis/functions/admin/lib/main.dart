import 'package:infrastructure/infrastructure.dart';

import 'handlers/generate_bonus_events.dart';
import 'handlers/generate_challenges.dart';
import 'handlers/generate_kit_items.dart';
import 'handlers/generate_levels.dart';
import 'handlers/generate_quests.dart';
import 'handlers/ping.dart';

Future<dynamic> main(final dynamic context) async {
  final String path = context.req.path as String;
  final String method = context.req.method as String;

  final AppWriteClient appwrite = AppWriteClient.fromEnvironment();
  appwrite.setKeyFromContext(context);

  final String? userId = AppWriteClient.getUserId(context);

  switch ('$method $path') {
    case 'GET /ping':
      return handlePing(context);
    case 'POST /generate-levels':
      return handleGenerateLevels(context, appwrite, userId);
    case 'POST /generate-kit-items':
      return handleGenerateKitItems(context, appwrite, userId);
    case 'POST /generate-bonus-events':
      return handleGenerateBonusEvents(context, appwrite, userId);
    case 'POST /generate-challenges':
      return handleGenerateChallenges(context, appwrite, userId);
    case 'POST /generate-quests':
      return handleGenerateQuests(context, appwrite, userId);
    default:
      return context.res.json({'ok': false, 'error': 'Not found: $method $path'}, 404);
  }
}
