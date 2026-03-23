import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart' as models;

class AppWriteReadinessSectionService implements ReadinessSectionService {
  final Databases _databases;
  final String _databaseId;

  AppWriteReadinessSectionService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<ReadinessSection> createSection(ReadinessSection section) async {
    final models.Document doc = await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: 'readiness_sections',
      documentId: ID.unique(),
      data: <String, dynamic>{
        'userId': section.userId,
        'sectionType': section.sectionType.name,
        'isUnlocked': section.isUnlocked,
        'unlockedAt': section.unlockedAt?.toIso8601String(),
        'unlockedByType': section.unlockedByType,
        'unlockedById': section.unlockedById,
        'createdBy': section.createdBy,
        'updatedBy': section.updatedBy,
        'isDeleted': section.isDeleted,
      },
    );
    return _fromDocument(doc);
  }

  @override
  Future<ReadinessSection> getSection(String sectionId) async {
    final models.Document doc = await _databases.getDocument(
      databaseId: _databaseId,
      collectionId: 'readiness_sections',
      documentId: sectionId,
    );
    return _fromDocument(doc);
  }

  @override
  Future<List<ReadinessSection>> getSectionsForUser(String userId) async {
    final models.DocumentList result = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: 'readiness_sections',
      queries: <String>[Query.equal('userId', userId), Query.limit(10)],
    );
    return result.documents.map(_fromDocument).toList();
  }

  @override
  Future<ReadinessSection> updateSection(ReadinessSection section) async {
    final models.Document doc = await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: 'readiness_sections',
      documentId: section.id,
      data: <String, dynamic>{
        'isUnlocked': section.isUnlocked,
        'unlockedAt': section.unlockedAt?.toIso8601String(),
        'unlockedByType': section.unlockedByType,
        'unlockedById': section.unlockedById,
        'updatedBy': section.updatedBy,
        'isDeleted': section.isDeleted,
      },
    );
    return _fromDocument(doc);
  }

  ReadinessSection _fromDocument(models.Document doc) {
    return ReadinessSection(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      isDeleted: doc.data['isDeleted'] as bool? ?? false,
      userId: doc.data['userId'] as String,
      sectionType: ReadinessSectionType.fromString(doc.data['sectionType'] as String),
      isUnlocked: doc.data['isUnlocked'] as bool? ?? false,
      unlockedAt: doc.data['unlockedAt'] != null ? DateTime.parse(doc.data['unlockedAt'] as String) : null,
      unlockedByType: doc.data['unlockedByType'] as String?,
      unlockedById: doc.data['unlockedById'] as String?,
    );
  }
}
