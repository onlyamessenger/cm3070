import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class ReadinessSectionMapper extends Mapper<ReadinessSection> {
  @override
  ReadinessSection fromMap(Map<String, dynamic> map) {
    return ReadinessSection(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      userId: map['userId'] as String,
      sectionType: ReadinessSectionType.fromString(map['sectionType'] as String),
      isUnlocked: map['isUnlocked'] as bool? ?? false,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt'] as String) : null,
      unlockedByType: map['unlockedByType'] as String?,
      unlockedById: map['unlockedById'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(ReadinessSection item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'userId': item.userId,
      'sectionType': item.sectionType.name,
      'isUnlocked': item.isUnlocked,
      'unlockedAt': item.unlockedAt?.toIso8601String(),
      'unlockedByType': item.unlockedByType,
      'unlockedById': item.unlockedById,
    };
  }
}
