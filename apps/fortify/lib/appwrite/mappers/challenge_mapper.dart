import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class ChallengeMapper extends Mapper<Challenge> {
  @override
  Challenge fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      source: ContentSource.fromString(map['source'] as String),
      isPublished: map['isPublished'] as bool? ?? false,
      type: ChallengeType.fromString(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      xpReward: map['xpReward'] as int,
      difficulty: Difficulty.fromString(map['difficulty'] as String),
      disasterType: DisasterType.fromString(map['disasterType'] as String),
      questId: map['questId'] as String?,
      unlocksSectionType: map['unlocksSectionType'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(Challenge item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'source': item.source.name,
      'isPublished': item.isPublished,
      'type': item.type.name,
      'title': item.title,
      'description': item.description,
      'xpReward': item.xpReward,
      'difficulty': item.difficulty.name,
      'disasterType': item.disasterType.name,
      'questId': item.questId,
      'unlocksSectionType': item.unlocksSectionType,
    };
  }
}
