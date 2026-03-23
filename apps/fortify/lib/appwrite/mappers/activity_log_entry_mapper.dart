import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class ActivityLogEntryMapper extends Mapper<ActivityLogEntry> {
  @override
  ActivityLogEntry fromMap(Map<String, dynamic> map) {
    return ActivityLogEntry(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      userId: map['userId'] as String,
      action: map['action'] as String,
      xpAmount: map['xpAmount'] as int? ?? 0,
      sourceType: map['sourceType'] != null ? ActivitySourceType.fromString(map['sourceType'] as String) : null,
      sourceId: map['sourceId'] as String?,
      multiplierApplied: map['multiplierApplied'] != null ? (map['multiplierApplied'] as num).toDouble() : null,
    );
  }

  @override
  Map<String, dynamic> toMap(ActivityLogEntry item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'userId': item.userId,
      'action': item.action,
      'xpAmount': item.xpAmount,
      'sourceType': item.sourceType?.name,
      'sourceId': item.sourceId,
      'multiplierApplied': item.multiplierApplied,
    };
  }
}
