import 'dart:convert';

import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWritePlayerChallengeProgressService implements PlayerChallengeProgressService {
  final Databases _databases;
  final String _databaseId;

  AppWritePlayerChallengeProgressService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<PlayerChallengeProgress> getProgress(String progressId) async {
    final doc = await _databases.getDocument(
      databaseId: _databaseId,
      collectionId: 'player_challenge_progress',
      documentId: progressId,
    );

    final dynamic answersRaw = doc.data['answers'];
    final List<int> answers;
    if (answersRaw is String && answersRaw.isNotEmpty) {
      answers = (jsonDecode(answersRaw) as List<dynamic>).cast<int>();
    } else {
      answers = <int>[];
    }

    return PlayerChallengeProgress(
      id: doc.$id,
      created: DateTime.parse(doc.$createdAt),
      updated: DateTime.parse(doc.$updatedAt),
      createdBy: doc.data['createdBy'] as String,
      updatedBy: doc.data['updatedBy'] as String,
      userId: doc.data['userId'] as String,
      challengeId: doc.data['challengeId'] as String,
      isCompleted: doc.data['isCompleted'] as bool? ?? false,
      currentQuestionIndex: doc.data['currentQuestionIndex'] as int? ?? 0,
      answers: answers,
      correctCount: doc.data['correctCount'] as int? ?? 0,
      xpEarned: doc.data['xpEarned'] as int? ?? 0,
      completedAt: doc.data['completedAt'] != null ? DateTime.parse(doc.data['completedAt'] as String) : null,
    );
  }

  @override
  Future<void> markCompleted({required String progressId, required int xpEarned, required DateTime completedAt}) async {
    await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: 'player_challenge_progress',
      documentId: progressId,
      data: <String, dynamic>{'isCompleted': true, 'xpEarned': xpEarned, 'completedAt': completedAt.toIso8601String()},
    );
  }
}
