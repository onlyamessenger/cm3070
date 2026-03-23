import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

Future<void> createPlayerChallengeProgressCollection(Databases databases, String databaseId) async {
  const String collectionId = 'player_challenge_progress';

  await databases.createCollection(
    databaseId: databaseId,
    collectionId: collectionId,
    name: 'Player Challenge Progress',
  );

  // ModelBase attributes
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'createdBy',
    size: 36,
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'updatedBy',
    size: 36,
    xrequired: true,
  );
  await databases.createBooleanAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'isDeleted',
    xrequired: false,
    xdefault: false,
  );

  // Player Challenge Progress attributes
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'userId',
    size: 36,
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'challengeId',
    size: 36,
    xrequired: true,
  );
  await databases.createBooleanAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'isCompleted',
    xrequired: false,
    xdefault: false,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'currentQuestionIndex',
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'answers',
    size: 10000,
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'correctCount',
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'xpEarned',
    xrequired: true,
  );
  await databases.createDatetimeAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'completedAt',
    xrequired: false,
  );

  // Wait for attributes to be processed
  await Future.delayed(const Duration(seconds: 2));

  // Indexes
  await databases.createIndex(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'userId_idx',
    type: IndexType.key,
    attributes: ['userId'],
  );
  await databases.createIndex(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'user_challenge_idx',
    type: IndexType.key,
    attributes: ['userId', 'challengeId'],
  );
}
