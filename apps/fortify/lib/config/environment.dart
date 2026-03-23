import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application environment configuration.
///
/// Reads values from the .env file loaded at app startup.
/// Call [Environment.load()] in main() before accessing any values.
class Environment {
  Environment._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get appwriteEndpoint => dotenv.env['APPWRITE_ENDPOINT'] ?? '';
  static String get appwriteProjectId => dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
  static String get appwriteDatabaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '';
  static String get appwriteAdminTeamId => dotenv.env['APPWRITE_ADMIN_TEAM_ID'] ?? '';
  static String get appwritePlayerTeamId => dotenv.env['APPWRITE_PLAYER_TEAM_ID'] ?? '';

  // Collection IDs
  static const String playersCollectionId = 'players';
  static const String levelsCollectionId = 'levels';
  static const String challengesCollectionId = 'challenges';
  static const String questsCollectionId = 'quests';
  static const String kitItemsCollectionId = 'kit_items';
  static const String bonusEventsCollectionId = 'bonus_events';
  static const String challengeQuestionsCollectionId = 'challenge_questions';
  static const String questNodesCollectionId = 'quest_nodes';
  static const String playerChallengeProgressCollectionId = 'player_challenge_progress';
  static const String playerQuestProgressCollectionId = 'player_quest_progress';
  static const String activityLogCollectionId = 'activity_log';
  static const String readinessSectionsCollectionId = 'readiness_sections';
}
