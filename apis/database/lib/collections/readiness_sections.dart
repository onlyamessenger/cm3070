import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

Future<void> createReadinessSectionsCollection(Databases databases, String databaseId) async {
  const String collectionId = 'readiness_sections';

  await databases.createCollection(databaseId: databaseId, collectionId: collectionId, name: 'Readiness Sections');

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

  // Readiness Section attributes
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'userId',
    size: 36,
    xrequired: true,
  );
  await databases.createEnumAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'sectionType',
    elements: ['evacuationRoutes', 'emergencyContacts', 'emergencyKit', 'floodRisk', 'shelterLocations'],
    xrequired: true,
  );
  await databases.createBooleanAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'isUnlocked',
    xrequired: false,
    xdefault: false,
  );
  await databases.createDatetimeAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'unlockedAt',
    xrequired: false,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'unlockedByType',
    size: 128,
    xrequired: false,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'unlockedById',
    size: 36,
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
    key: 'user_section_idx',
    type: IndexType.unique,
    attributes: ['userId', 'sectionType'],
  );
}
