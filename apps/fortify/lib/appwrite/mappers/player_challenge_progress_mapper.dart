import 'dart:convert';

import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class PlayerChallengeProgressMapper extends Mapper<PlayerChallengeProgress> {
  @override
  PlayerChallengeProgress fromMap(Map<String, dynamic> map) {
    final dynamic answersRaw = map['answers'];
    final List<int> answers;
    if (answersRaw is String && answersRaw.isNotEmpty) {
      answers = (jsonDecode(answersRaw) as List<dynamic>).cast<int>();
    } else {
      answers = <int>[];
    }

    return PlayerChallengeProgress(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      userId: map['userId'] as String,
      challengeId: map['challengeId'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      currentQuestionIndex: map['currentQuestionIndex'] as int? ?? 0,
      answers: answers,
      correctCount: map['correctCount'] as int? ?? 0,
      xpEarned: map['xpEarned'] as int? ?? 0,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toMap(PlayerChallengeProgress item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'userId': item.userId,
      'challengeId': item.challengeId,
      'isCompleted': item.isCompleted,
      'currentQuestionIndex': item.currentQuestionIndex,
      'answers': jsonEncode(item.answers),
      'correctCount': item.correctCount,
      'xpEarned': item.xpEarned,
      'completedAt': item.completedAt?.toIso8601String(),
    };
  }
}
