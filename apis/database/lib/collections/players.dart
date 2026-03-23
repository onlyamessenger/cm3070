import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

Future<void> createPlayersCollection(Databases databases, String databaseId) async {
  const String collectionId = 'players';

  await databases.createCollection(databaseId: databaseId, collectionId: collectionId, name: 'Players');

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

  // Player attributes
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
    key: 'displayName',
    size: 128,
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'xp',
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'currentStreak',
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'longestStreak',
    xrequired: true,
  );
  await databases.createBooleanAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'streakShieldAvailable',
    xrequired: false,
    xdefault: true,
  );
  await databases.createDatetimeAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'streakShieldUsedAt',
    xrequired: false,
  );
  await databases.createDatetimeAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'lastActiveDate',
    xrequired: true,
  );

  // Wait for attributes to be processed
  await Future.delayed(const Duration(seconds: 2));

  // Indexes
  await databases.createIndex(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'userId_unique',
    type: IndexType.unique,
    attributes: ['userId'],
  );
}
