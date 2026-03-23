import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dotenv/dotenv.dart';

import 'collections/collections.dart';

/// Database setup CLI.
///
/// Creates all AppWrite collections, attributes, indexes, and teams for Fortify.
/// Skips collections and teams that already exist.
///
/// Reads configuration from a .env file in the project directory, with
/// system environment variables taking precedence.
///
/// Required variables:
///   APPWRITE_ENDPOINT        - AppWrite API endpoint
///   APPWRITE_PROJECT_ID      - AppWrite project ID
///   APPWRITE_API_KEY         - Server API key with databases.* and teams.* scopes
///   APPWRITE_DATABASE_ID     - Target database ID
///   APPWRITE_ADMIN_TEAM_ID   - Admin team ID
///   APPWRITE_PLAYER_TEAM_ID  - Player team ID
///
/// Usage:
///   cd apis/database && dart run lib/main.dart
void main(List<String> args) async {
  final DotEnv env = DotEnv(includePlatformEnvironment: true)..load();

  final String? endpoint = env['APPWRITE_ENDPOINT'];
  final String? projectId = env['APPWRITE_PROJECT_ID'];
  final String? apiKey = env['APPWRITE_API_KEY'];
  final String? databaseId = env['APPWRITE_DATABASE_ID'];
  final String? adminTeamId = env['APPWRITE_ADMIN_TEAM_ID'];
  final String? playerTeamId = env['APPWRITE_PLAYER_TEAM_ID'];

  if (endpoint == null ||
      projectId == null ||
      apiKey == null ||
      databaseId == null ||
      adminTeamId == null ||
      playerTeamId == null) {
    stderr.writeln('Missing required environment variables.');
    stderr.writeln(
      'Set: APPWRITE_ENDPOINT, APPWRITE_PROJECT_ID, APPWRITE_API_KEY, APPWRITE_DATABASE_ID, '
      'APPWRITE_ADMIN_TEAM_ID, APPWRITE_PLAYER_TEAM_ID',
    );
    exit(1);
  }

  final Client client = Client().setEndpoint(endpoint).setProject(projectId).setKey(apiKey);

  final Databases databases = Databases(client);
  final Teams teams = Teams(client);

  stdout.writeln('Setting up Fortify database...');
  stdout.writeln('Endpoint: $endpoint');
  stdout.writeln('Database: $databaseId');
  stdout.writeln('Admin Team: $adminTeamId');
  stdout.writeln('Player Team: $playerTeamId');
  stdout.writeln('');

  // ── Teams ──
  await _ensureTeam(teams, teamId: adminTeamId, name: 'Admin');
  await _ensureTeam(teams, teamId: playerTeamId, name: 'Players');

  // ── Permission sets ──
  final List<String> adminOnly = <String>[
    Permission.read(Role.team(adminTeamId)),
    Permission.create(Role.team(adminTeamId)),
    Permission.update(Role.team(adminTeamId)),
    Permission.delete(Role.team(adminTeamId)),
  ];

  // Published content: admin full access + player read
  final List<String> contentPermissions = <String>[
    ...adminOnly,
    Permission.read(Role.team(playerTeamId)),
  ];

  // Player-owned data: admin full access + individual user read
  // Document-level permissions (Role.user) are set when creating each document,
  // but the collection must also allow the user role to read.
  final List<String> playerOwnedPermissions = <String>[
    ...adminOnly,
    Permission.read(Role.users()),
    Permission.create(Role.users()),
    Permission.update(Role.users()),
  ];

  // ── Collections with their permission sets ──
  final Map<String, _CollectionSetup> collections = <String, _CollectionSetup>{
    // Content collections (admin + player read)
    'levels': _CollectionSetup(createLevelsCollection, contentPermissions),
    'quests': _CollectionSetup(createQuestsCollection, contentPermissions),
    'quest_nodes': _CollectionSetup(createQuestNodesCollection, contentPermissions),
    'challenges': _CollectionSetup(createChallengesCollection, contentPermissions),
    'challenge_questions': _CollectionSetup(createChallengeQuestionsCollection, contentPermissions),
    'kit_items': _CollectionSetup(createKitItemsCollection, playerOwnedPermissions),
    'bonus_events': _CollectionSetup(createBonusEventsCollection, contentPermissions),
    // Player-owned collections (admin + user-level access)
    'players': _CollectionSetup(createPlayersCollection, playerOwnedPermissions),
    'player_quest_progress': _CollectionSetup(createPlayerQuestProgressCollection, playerOwnedPermissions),
    'player_challenge_progress': _CollectionSetup(createPlayerChallengeProgressCollection, playerOwnedPermissions),
    'readiness_sections': _CollectionSetup(createReadinessSectionsCollection, playerOwnedPermissions),
    'activity_log': _CollectionSetup(createActivityLogCollection, playerOwnedPermissions),
    // Party collections (admin only for now)
    'parties': _CollectionSetup(createPartiesCollection, adminOnly),
    'party_members': _CollectionSetup(createPartyMembersCollection, adminOnly),
    'party_challenges': _CollectionSetup(createPartyChallengesCollection, adminOnly),
  };

  stdout.writeln('');
  stdout.writeln('Collections to process: ${collections.length}');
  stdout.writeln('');

  int created = 0;
  int skipped = 0;
  int failed = 0;

  for (final MapEntry<String, _CollectionSetup> entry in collections.entries) {
    final String name = entry.key;
    final _CollectionSetup setup = entry.value;

    try {
      final bool exists = await _collectionExists(databases, databaseId, name);
      if (exists) {
        stdout.writeln('  $name - already exists, updating permissions...');
        await _updatePermissions(databases, databaseId, name, setup.permissions);
        skipped++;
        continue;
      }

      stdout.write('  Creating $name... ');
      await setup.creator(databases, databaseId);
      await _updatePermissions(databases, databaseId, name, setup.permissions);
      stdout.writeln('done');
      created++;
    } catch (e) {
      stdout.writeln('FAILED');
      stderr.writeln('    Error: $e');
      failed++;
    }
  }

  stdout.writeln('');
  stdout.writeln('Setup complete: $created created, $skipped already existed, $failed failed.');

  if (failed > 0) {
    exit(1);
  }
}

class _CollectionSetup {
  final Future<void> Function(Databases, String) creator;
  final List<String> permissions;

  const _CollectionSetup(this.creator, this.permissions);
}

/// Checks if a collection exists by attempting to get it.
Future<bool> _collectionExists(Databases databases, String databaseId, String collectionId) async {
  try {
    await databases.getCollection(databaseId: databaseId, collectionId: collectionId);
    return true;
  } on AppwriteException catch (e) {
    if (e.code == 404) return false;
    rethrow;
  }
}

/// Updates permissions on an existing collection.
Future<void> _updatePermissions(
  Databases databases,
  String databaseId,
  String collectionId,
  List<String> permissions,
) async {
  try {
    final collection = await databases.getCollection(databaseId: databaseId, collectionId: collectionId);
    await databases.updateCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: collection.name,
      permissions: permissions,
    );
  } on AppwriteException catch (e) {
    stderr.writeln('    Warning: could not update permissions for $collectionId: ${e.message}');
  }
}

/// Creates a team if it doesn't already exist.
Future<void> _ensureTeam(Teams teams, {required String teamId, required String name}) async {
  try {
    await teams.get(teamId: teamId);
    stdout.writeln('Team "$name" ($teamId) - already exists');
  } on AppwriteException catch (e) {
    if (e.code == 404) {
      stdout.write('Creating team "$name" ($teamId)... ');
      await teams.create(teamId: teamId, name: name);
      stdout.writeln('done');
    } else {
      stderr.writeln('Error checking team "$name": ${e.message}');
      rethrow;
    }
  }
}
