import 'package:dart_appwrite/dart_appwrite.dart';

Future<void> createQuestsCollection(Databases databases, String databaseId) async {
  const String collectionId = 'quests';

  await databases.createCollection(databaseId: databaseId, collectionId: collectionId, name: 'Quests');

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

  // ContentBase attributes
  await databases.createEnumAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'source',
    elements: ['human', 'llm'],
    xrequired: true,
  );
  await databases.createBooleanAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'isPublished',
    xrequired: false,
    xdefault: false,
  );

  // Quest attributes
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'title',
    size: 128,
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'description',
    size: 512,
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'totalDays',
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'startNodeId',
    size: 36,
    xrequired: true,
  );
  await databases.createEnumAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'difficulty',
    elements: ['beginner', 'intermediate', 'advanced'],
    xrequired: true,
  );
  await databases.createEnumAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'disasterType',
    elements: ['flood', 'bushfire', 'earthquake', 'cyclone', 'storm'],
    xrequired: true,
  );
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'region',
    size: 128,
    xrequired: false,
  );
}
