import 'dart:convert';

import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class ChallengeQuestionMapper extends Mapper<ChallengeQuestion> {
  @override
  ChallengeQuestion fromMap(Map<String, dynamic> map) {
    return ChallengeQuestion(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      challengeId: map['challengeId'] as String,
      sortOrder: map['sortOrder'] as int,
      questionText: map['questionText'] as String,
      options: (jsonDecode(map['options'] as String) as List<dynamic>).cast<String>(),
      correctIndex: map['correctIndex'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(ChallengeQuestion item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'challengeId': item.challengeId,
      'sortOrder': item.sortOrder,
      'questionText': item.questionText,
      'options': jsonEncode(item.options),
      'correctIndex': item.correctIndex,
    };
  }
}
