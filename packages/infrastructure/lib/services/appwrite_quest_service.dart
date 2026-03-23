import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWriteQuestService implements QuestService {
  final Databases _databases;
  final String _databaseId;

  AppWriteQuestService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<Quest> getQuest(String questId) async {
    final doc = await _databases.getDocument(databaseId: _databaseId, collectionId: 'quests', documentId: questId);

    return Quest(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      source: ContentSource.fromString(doc.data['source'] as String),
      isPublished: doc.data['isPublished'] as bool? ?? false,
      title: doc.data['title'] as String,
      description: doc.data['description'] as String,
      totalDays: doc.data['totalDays'] as int,
      startNodeId: doc.data['startNodeId'] as String,
      difficulty: Difficulty.fromString(doc.data['difficulty'] as String),
      disasterType: DisasterType.fromString(doc.data['disasterType'] as String),
      region: doc.data['region'] as String?,
    );
  }
}
