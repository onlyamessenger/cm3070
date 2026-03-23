import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart' as models;

class AppWritePlayerService implements PlayerService {
  final Databases _databases;
  final String _databaseId;
  final String _collectionId;

  AppWritePlayerService({required Databases databases, required String databaseId, String collectionId = 'players'})
    : _databases = databases,
      _databaseId = databaseId,
      _collectionId = collectionId;

  @override
  Future<Player> createPlayer({required String userId, required String displayName}) async {
    final DateTime now = DateTime.now();
    final models.Document doc = await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: ID.unique(),
      data: <String, dynamic>{
        'userId': userId,
        'displayName': displayName,
        'xp': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'streakShieldAvailable': true,
        'lastActiveDate': now.toIso8601String(),
        'createdBy': userId,
        'updatedBy': userId,
        'isDeleted': false,
      },
    );

    return Player(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: userId,
      updatedBy: userId,
      userId: userId,
      displayName: displayName,
      lastActiveDate: now,
    );
  }

  @override
  Future<void> updateXp({required String userId, required int xpToAdd}) async {
    final Player player = await getPlayer(userId);
    final int newXp = player.xp + xpToAdd;
    await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: player.id,
      data: <String, dynamic>{'xp': newXp},
    );
  }

  @override
  Future<void> updateCheckInState({
    required String playerId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
    required bool streakShieldAvailable,
    DateTime? streakShieldUsedAt,
    required bool clearStreakShieldUsedAt,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'streakShieldAvailable': streakShieldAvailable,
    };

    if (clearStreakShieldUsedAt) {
      data['streakShieldUsedAt'] = null;
    } else if (streakShieldUsedAt != null) {
      data['streakShieldUsedAt'] = streakShieldUsedAt.toIso8601String();
    }

    await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: playerId,
      data: data,
    );
  }

  @override
  Future<Player> getPlayer(String userId) async {
    final models.DocumentList result = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: <String>[Query.equal('userId', userId), Query.limit(1)],
    );

    if (result.documents.isEmpty) {
      throw Exception('Player not found for userId: $userId');
    }

    final models.Document doc = result.documents.first;
    return Player(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      userId: doc.data['userId'] as String,
      displayName: doc.data['displayName'] as String,
      xp: doc.data['xp'] as int? ?? 0,
      currentStreak: doc.data['currentStreak'] as int? ?? 0,
      longestStreak: doc.data['longestStreak'] as int? ?? 0,
      streakShieldAvailable: doc.data['streakShieldAvailable'] as bool? ?? true,
      streakShieldUsedAt: doc.data['streakShieldUsedAt'] != null
          ? DateTime.parse(doc.data['streakShieldUsedAt'] as String)
          : null,
      lastActiveDate: DateTime.parse(doc.data['lastActiveDate'] as String),
    );
  }
}
