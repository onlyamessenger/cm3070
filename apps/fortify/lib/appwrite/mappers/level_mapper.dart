import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class LevelMapper extends Mapper<Level> {
  @override
  Level fromMap(Map<String, dynamic> map) {
    return Level(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      source: ContentSource.fromString(map['source'] as String),
      isPublished: map['isPublished'] as bool? ?? false,
      level: map['level'] as int,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String,
      xpThreshold: map['xpThreshold'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(Level item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'source': item.source.name,
      'isPublished': item.isPublished,
      'level': item.level,
      'title': item.title,
      'description': item.description,
      'icon': item.icon,
      'xpThreshold': item.xpThreshold,
    };
  }
}
