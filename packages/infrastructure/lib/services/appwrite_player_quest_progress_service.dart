import 'dart:convert';

import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWritePlayerQuestProgressService implements PlayerQuestProgressService {
  final Databases _databases;
  final String _databaseId;

  AppWritePlayerQuestProgressService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<PlayerQuestProgress> getProgress(String progressId) async {
    final doc = await _databases.getDocument(
      databaseId: _databaseId,
      collectionId: 'player_quest_progress',
      documentId: progressId,
    );

    final dynamic visitedRaw = doc.data['visitedNodeIds'];
    final List<String> visitedNodeIds;
    if (visitedRaw is String && visitedRaw.isNotEmpty) {
      visitedNodeIds = (jsonDecode(visitedRaw) as List<dynamic>).cast<String>();
    } else {
      visitedNodeIds = <String>[];
    }

    return PlayerQuestProgress(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      userId: doc.data['userId'] as String,
      questId: doc.data['questId'] as String,
      currentNodeId: doc.data['currentNodeId'] as String,
      isCompleted: doc.data['isCompleted'] as bool? ?? false,
      visitedNodeIds: visitedNodeIds,
      xpEarned: doc.data['xpEarned'] as int? ?? 0,
      completedAt: doc.data['completedAt'] != null ? DateTime.parse(doc.data['completedAt'] as String) : null,
    );
  }

  @override
  Future<void> markCompleted({required String progressId, required int xpEarned, required DateTime completedAt}) async {
    await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: 'player_quest_progress',
      documentId: progressId,
      data: <String, dynamic>{'isCompleted': true, 'xpEarned': xpEarned, 'completedAt': completedAt.toIso8601String()},
    );
  }
}
