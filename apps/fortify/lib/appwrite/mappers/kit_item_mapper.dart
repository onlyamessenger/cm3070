import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class KitItemMapper extends Mapper<KitItem> {
  @override
  KitItem fromMap(Map<String, dynamic> map) {
    return KitItem(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      source: ContentSource.fromString(map['source'] as String),
      isPublished: map['isPublished'] as bool? ?? false,
      userId: map['userId'] as String?,
      itemName: map['itemName'] as String,
      description: map['description'] as String? ?? '',
      sortOrder: map['sortOrder'] as int,
      isChecked: map['isChecked'] as bool? ?? false,
      checkedAt: map['checkedAt'] != null ? DateTime.parse(map['checkedAt'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toMap(KitItem item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'source': item.source.name,
      'isPublished': item.isPublished,
      'userId': item.userId,
      'itemName': item.itemName,
      'description': item.description,
      'sortOrder': item.sortOrder,
      'isChecked': item.isChecked,
      'checkedAt': item.checkedAt?.toIso8601String(),
    };
  }
}
