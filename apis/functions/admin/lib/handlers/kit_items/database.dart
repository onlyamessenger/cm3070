import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:infrastructure/infrastructure.dart';

Future<List<Map<String, dynamic>>> fetchExistingKitItems(AppWriteClient appwrite) async {
  final DocumentList result = await appwrite.databases.listDocuments(
    databaseId: appwrite.databaseId,
    collectionId: 'kit_items',
    queries: <String>[Query.limit(5000), Query.isNull('userId')],
  );

  return result.documents.map((Document doc) {
    return <String, dynamic>{
      'itemName': doc.data['itemName'],
      'description': doc.data['description'] ?? '',
      'sortOrder': doc.data['sortOrder'],
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> writeGeneratedKitItems(
  AppWriteClient appwrite,
  List<Map<String, dynamic>> items,
  String userId,
) async {
  final List<Future<Map<String, dynamic>>> futures = items.map((Map<String, dynamic> item) async {
    final Document doc = await appwrite.databases.createDocument(
      databaseId: appwrite.databaseId,
      collectionId: 'kit_items',
      documentId: ID.unique(),
      data: <String, dynamic>{
        'itemName': item['itemName'],
        'description': item['description'] ?? '',
        'sortOrder': item['sortOrder'],
        'isChecked': false,
        'source': 'llm',
        'isPublished': false,
        'createdBy': userId,
        'updatedBy': userId,
        'isDeleted': false,
      },
    );

    return <String, dynamic>{
      'id': doc.$id,
      'itemName': doc.data['itemName'],
      'description': doc.data['description'] ?? '',
      'sortOrder': doc.data['sortOrder'],
    };
  }).toList();

  return Future.wait(futures);
}
