import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:infrastructure/infrastructure.dart';

Future<List<Map<String, dynamic>>> fetchExistingLevels(AppWriteClient appwrite) async {
  final DocumentList result = await appwrite.databases.listDocuments(
    databaseId: appwrite.databaseId,
    collectionId: 'levels',
    queries: <String>[Query.limit(5000)],
  );

  return result.documents.map((Document doc) {
    return <String, dynamic>{
      'level': doc.data['level'],
      'title': doc.data['title'],
      'description': doc.data['description'] ?? '',
      'icon': doc.data['icon'],
      'xpThreshold': doc.data['xpThreshold'],
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> writeGeneratedLevels(
  AppWriteClient appwrite,
  List<Map<String, dynamic>> levels,
  String userId,
) async {
  final List<Future<Map<String, dynamic>>> futures = levels.map((Map<String, dynamic> level) async {
    final Document doc = await appwrite.databases.createDocument(
      databaseId: appwrite.databaseId,
      collectionId: 'levels',
      documentId: ID.unique(),
      data: <String, dynamic>{
        'level': level['level'],
        'title': level['title'],
        'description': level['description'] ?? '',
        'icon': level['icon'],
        'xpThreshold': level['xpThreshold'],
        'source': 'llm',
        'isPublished': false,
        'createdBy': userId,
        'updatedBy': userId,
        'isDeleted': false,
      },
    );

    return <String, dynamic>{
      'id': doc.$id,
      'level': doc.data['level'],
      'title': doc.data['title'],
      'description': doc.data['description'] ?? '',
      'icon': doc.data['icon'],
      'xpThreshold': doc.data['xpThreshold'],
    };
  }).toList();

  return Future.wait(futures);
}
