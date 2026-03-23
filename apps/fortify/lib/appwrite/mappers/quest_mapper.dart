import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class QuestMapper extends Mapper<Quest> {
  @override
  Quest fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      source: ContentSource.fromString(map['source'] as String),
      isPublished: map['isPublished'] as bool? ?? false,
      title: map['title'] as String,
      description: map['description'] as String,
      totalDays: map['totalDays'] as int,
      startNodeId: map['startNodeId'] as String,
      difficulty: Difficulty.fromString(map['difficulty'] as String),
      disasterType: DisasterType.fromString(map['disasterType'] as String),
      region: map['region'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(Quest item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'source': item.source.name,
      'isPublished': item.isPublished,
      'title': item.title,
      'description': item.description,
      'totalDays': item.totalDays,
      'startNodeId': item.startNodeId,
      'difficulty': item.difficulty.name,
      'disasterType': item.disasterType.name,
      'region': item.region,
    };
  }
}
