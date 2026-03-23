import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

Future<void> createActivityLogCollection(Databases databases, String databaseId) async {
  const String collectionId = 'activity_log';

  await databases.createCollection(databaseId: databaseId, collectionId: collectionId, name: 'Activity Log');

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

  // Activity Log attributes
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
    key: 'action',
    size: 512,
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'xpAmount',
    xrequired: true,
  );
  await databases.createEnumAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'sourceType',
    elements: ['quest', 'challenge', 'checkIn', 'bonus'],
    xrequired: false,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'sourceId',
    size: 36,
    xrequired: false,
  );
  await databases.createFloatAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'multiplierApplied',
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
}
