import 'package:infrastructure/infrastructure.dart';

import 'handlers/complete_challenge.dart';
import 'handlers/complete_quest.dart';
import 'handlers/daily_check_in.dart';
import 'handlers/register.dart';

Future<dynamic> main(final dynamic context) async {
  final String path = context.req.path as String;
  final String method = context.req.method as String;

  final AppWriteClient appwrite = AppWriteClient.fromEnvironment();
  appwrite.setKeyFromContext(context);

  switch ('$method $path') {
    case 'POST /register':
      return handleRegister(context, appwrite);
    case 'POST /complete-challenge':
      return handleCompleteChallenge(context, appwrite);
    case 'POST /complete-quest':
      return handleCompleteQuest(context, appwrite);
    case 'POST /daily-check-in':
      return handleDailyCheckIn(context, appwrite);
    default:
      return context.res.json({'ok': false, 'error': 'Not found: $method $path'}, 404);
  }
}
