import 'dart:convert';

import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class PlayerQuestProgressMapper extends Mapper<PlayerQuestProgress> {
  @override
  PlayerQuestProgress fromMap(Map<String, dynamic> map) {
    final dynamic visitedRaw = map['visitedNodeIds'];
    final List<String> visitedNodeIds;
    if (visitedRaw is String && visitedRaw.isNotEmpty) {
      visitedNodeIds = (jsonDecode(visitedRaw) as List<dynamic>).cast<String>();
    } else {
      visitedNodeIds = <String>[];
    }

    return PlayerQuestProgress(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      userId: map['userId'] as String,
      questId: map['questId'] as String,
      currentNodeId: map['currentNodeId'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      visitedNodeIds: visitedNodeIds,
      xpEarned: map['xpEarned'] as int? ?? 0,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toMap(PlayerQuestProgress item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'userId': item.userId,
      'questId': item.questId,
      'currentNodeId': item.currentNodeId,
      'isCompleted': item.isCompleted,
      'visitedNodeIds': jsonEncode(item.visitedNodeIds),
      'xpEarned': item.xpEarned,
      'completedAt': item.completedAt?.toIso8601String(),
    };
  }
}
