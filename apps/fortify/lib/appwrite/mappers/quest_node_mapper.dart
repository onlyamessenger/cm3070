import 'dart:convert';

import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class QuestNodeMapper extends Mapper<QuestNode> {
  @override
  QuestNode fromMap(Map<String, dynamic> map) {
    final List<QuestChoice> choices = (jsonDecode(map['choices'] as String) as List<dynamic>)
        .map((dynamic item) => QuestChoice.fromMap(item as Map<String, dynamic>))
        .toList();

    return QuestNode(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      questId: map['questId'] as String,
      day: map['day'] as int,
      text: map['text'] as String,
      isOutcome: map['isOutcome'] as bool? ?? false,
      xpReward: map['xpReward'] as int? ?? 0,
      summary: map['summary'] as String?,
      choices: choices,
      unlocksSectionType: map['unlocksSectionType'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(QuestNode item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'questId': item.questId,
      'day': item.day,
      'text': item.text,
      'isOutcome': item.isOutcome,
      'xpReward': item.xpReward,
      'summary': item.summary,
      'choices': jsonEncode(item.choices.map((QuestChoice c) => c.toMap()).toList()),
      'unlocksSectionType': item.unlocksSectionType,
    };
  }
}
