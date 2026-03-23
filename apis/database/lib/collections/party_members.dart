import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

Future<void> createPartyMembersCollection(Databases databases, String databaseId) async {
  const String collectionId = 'party_members';

  await databases.createCollection(databaseId: databaseId, collectionId: collectionId, name: 'Party Members');

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

  // Party Member attributes
  await databases.createStringAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'partyId',
    size: 36,
    xrequired: true,
  );
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
    key: 'role',
    elements: ['leader', 'member'],
    xrequired: true,
  );
  await databases.createIntegerAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'weeklyXpContribution',
    xrequired: true,
  );
  await databases.createDatetimeAttribute(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'joinedAt',
    xrequired: true,
  );

  // Wait for attributes to be processed
  await Future.delayed(const Duration(seconds: 2));

  // Indexes
  await databases.createIndex(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'partyId_idx',
    type: IndexType.key,
    attributes: ['partyId'],
  );
  await databases.createIndex(
    databaseId: databaseId,
    collectionId: collectionId,
    key: 'userId_idx',
    type: IndexType.key,
    attributes: ['userId'],
  );
}
