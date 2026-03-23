import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

Future<void> createChallengeQuestionsCollection(Databases databases, String databaseId) async {
  const String collectionId = 'challenge_questions';

  await databases.createCollection(databaseId: databaseId, collectionId: collectionId, name: 'Challenge Questions');

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

  // Challenge Question attributes
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'challengeId',
    size: 36,
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'sortOrder',
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'questionText',
    size: 5000,
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'options',
    size: 10000,
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'correctIndex',
    xrequired: true,
  );

  // Wait for attributes to be processed
  await Future.delayed(const Duration(seconds: 2));

  // Indexes
  await databases.createIndex(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'challengeId_idx',
    type: IndexType.key,
    attributes: ['challengeId'],
  );
}
