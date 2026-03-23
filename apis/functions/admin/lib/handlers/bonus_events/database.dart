import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:infrastructure/infrastructure.dart';

Future<List<Map<String, dynamic>>> fetchExistingBonusEvents(AppWriteClient appwrite) async {
  final DocumentList result = await appwrite.databases.listDocuments(
    databaseId: appwrite.databaseId,
    collectionId: 'bonus_events',
    queries: <String>[Query.limit(5000)],
  );

  return result.documents.map((Document doc) {
    return <String, dynamic>{
      'title': doc.data['title'],
      'description': doc.data['description'],
      'multiplier': doc.data['multiplier'],
      'startsAt': doc.data['startsAt'],
      'endsAt': doc.data['endsAt'],
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> writeGeneratedBonusEvents(
  AppWriteClient appwrite,
  List<Map<String, dynamic>> events,
  String userId,
) async {
  final List<Future<Map<String, dynamic>>> futures = events.map((Map<String, dynamic> event) async {
    final Document doc = await appwrite.databases.createDocument(
      databaseId: appwrite.databaseId,
      collectionId: 'bonus_events',
      documentId: ID.unique(),
      data: <String, dynamic>{
        'title': event['title'],
        'description': event['description'],
        'multiplier': event['multiplier'],
        'startsAt': event['startsAt'],
        'endsAt': event['endsAt'],
        'isActive': false,
        'createdBy': userId,
        'updatedBy': userId,
        'isDeleted': false,
      },
    );

    return <String, dynamic>{
      'id': doc.$id,
      'title': doc.data['title'],
      'description': doc.data['description'],
      'multiplier': doc.data['multiplier'],
    };
  }).toList();

  return Future.wait(futures);
}
