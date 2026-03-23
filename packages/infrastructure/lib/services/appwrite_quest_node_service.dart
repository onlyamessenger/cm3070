import 'dart:convert';

import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWriteQuestNodeService implements QuestNodeService {
  final Databases _databases;
  final String _databaseId;

  AppWriteQuestNodeService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<QuestNode> getNode(String nodeId) async {
    final doc = await _databases.getDocument(databaseId: _databaseId, collectionId: 'quest_nodes', documentId: nodeId);
    return _mapNode(doc);
  }

  @override
  Future<List<QuestNode>> getNodesForQuest(String questId) async {
    final result = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: 'quest_nodes',
      queries: <String>[Query.equal('questId', questId), Query.limit(100)],
    );
    return result.documents.map((doc) => _mapNode(doc)).toList();
  }

  QuestNode _mapNode(dynamic doc) {
    final List<QuestChoice> choices = (jsonDecode(doc.data['choices'] as String) as List<dynamic>)
        .map((dynamic item) => QuestChoice.fromMap(item as Map<String, dynamic>))
        .toList();

    return QuestNode(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      isDeleted: doc.data['isDeleted'] as bool? ?? false,
      questId: doc.data['questId'] as String,
      day: doc.data['day'] as int,
      text: doc.data['text'] as String,
      isOutcome: doc.data['isOutcome'] as bool? ?? false,
      xpReward: doc.data['xpReward'] as int? ?? 0,
      summary: doc.data['summary'] as String?,
      choices: choices,
      unlocksSectionType: doc.data['unlocksSectionType'] as String?,
    );
  }
}
