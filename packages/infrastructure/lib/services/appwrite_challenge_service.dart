import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWriteChallengeService implements ChallengeService {
  final Databases _databases;
  final String _databaseId;

  AppWriteChallengeService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<Challenge> getChallenge(String challengeId) async {
    final doc = await _databases.getDocument(
      databaseId: _databaseId,
      collectionId: 'challenges',
      documentId: challengeId,
    );

    return Challenge(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      source: ContentSource.fromString(doc.data['source'] as String),
      isPublished: doc.data['isPublished'] as bool? ?? false,
      type: ChallengeType.fromString(doc.data['type'] as String),
      title: doc.data['title'] as String,
      description: doc.data['description'] as String? ?? '',
      xpReward: doc.data['xpReward'] as int,
      difficulty: Difficulty.fromString(doc.data['difficulty'] as String),
      disasterType: DisasterType.fromString(doc.data['disasterType'] as String),
      questId: doc.data['questId'] as String?,
      unlocksSectionType: doc.data['unlocksSectionType'] as String?,
    );
  }

  @override
  Future<int> getQuestionCount(String challengeId) async {
    final result = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: 'challenge_questions',
      queries: <String>[Query.equal('challengeId', challengeId), Query.limit(1)],
    );
    return result.total;
  }
}
