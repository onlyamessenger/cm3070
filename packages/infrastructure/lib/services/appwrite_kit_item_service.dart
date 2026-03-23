import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart' as models;

class AppWriteKitItemService implements KitItemService {
  final Databases _databases;
  final String _databaseId;

  AppWriteKitItemService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<List<KitItem>> getPublishedTemplates() async {
    final models.DocumentList result = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: 'kit_items',
      queries: <String>[Query.equal('isPublished', true), Query.limit(100)],
    );
    return result.documents.map(_fromDocument).where((KitItem item) => item.userId == null).toList();
  }

  @override
  Future<KitItem> createKitItem(KitItem item) async {
    final models.Document doc = await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: 'kit_items',
      documentId: ID.unique(),
      data: <String, dynamic>{
        'userId': item.userId,
        'itemName': item.itemName,
        'description': item.description,
        'sortOrder': item.sortOrder,
        'isChecked': item.isChecked,
        'checkedAt': item.checkedAt?.toIso8601String(),
        'source': item.source.name,
        'isPublished': item.isPublished,
        'createdBy': item.createdBy,
        'updatedBy': item.updatedBy,
        'isDeleted': item.isDeleted,
      },
    );
    return _fromDocument(doc);
  }

  KitItem _fromDocument(models.Document doc) {
    return KitItem(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      isDeleted: doc.data['isDeleted'] as bool? ?? false,
      source: ContentSource.fromString(doc.data['source'] as String),
      isPublished: doc.data['isPublished'] as bool? ?? false,
      userId: doc.data['userId'] as String?,
      itemName: doc.data['itemName'] as String,
      description: doc.data['description'] as String? ?? '',
      sortOrder: doc.data['sortOrder'] as int,
      isChecked: doc.data['isChecked'] as bool? ?? false,
      checkedAt: doc.data['checkedAt'] != null ? DateTime.parse(doc.data['checkedAt'] as String) : null,
    );
  }
}
