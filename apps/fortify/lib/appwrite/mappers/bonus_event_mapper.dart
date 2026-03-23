import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class BonusEventMapper extends Mapper<BonusEvent> {
  @override
  BonusEvent fromMap(Map<String, dynamic> map) {
    return BonusEvent(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      title: map['title'] as String,
      description: map['description'] as String,
      multiplier: (map['multiplier'] as num).toDouble(),
      startsAt: DateTime.parse(map['startsAt'] as String),
      endsAt: DateTime.parse(map['endsAt'] as String),
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap(BonusEvent item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'title': item.title,
      'description': item.description,
      'multiplier': item.multiplier,
      'startsAt': item.startsAt.toIso8601String(),
      'endsAt': item.endsAt.toIso8601String(),
      'isActive': item.isActive,
    };
  }
}
