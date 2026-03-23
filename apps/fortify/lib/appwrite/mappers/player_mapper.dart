import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

class PlayerMapper extends Mapper<Player> {
  @override
  Player fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['\$id'] as String,
      created: DateTime.parse(map['\$createdAt'] as String),
      updated: DateTime.parse(map['\$updatedAt'] as String),
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      userId: map['userId'] as String,
      displayName: map['displayName'] as String,
      xp: map['xp'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      streakShieldAvailable: map['streakShieldAvailable'] as bool? ?? true,
      streakShieldUsedAt: map['streakShieldUsedAt'] != null
          ? DateTime.parse(map['streakShieldUsedAt'] as String)
          : null,
      lastActiveDate: DateTime.parse(map['lastActiveDate'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(Player item) {
    return <String, dynamic>{
      'createdBy': item.createdBy,
      'updatedBy': item.updatedBy,
      'isDeleted': item.isDeleted,
      'userId': item.userId,
      'displayName': item.displayName,
      'xp': item.xp,
      'currentStreak': item.currentStreak,
      'longestStreak': item.longestStreak,
      'streakShieldAvailable': item.streakShieldAvailable,
      'streakShieldUsedAt': item.streakShieldUsedAt?.toIso8601String(),
      'lastActiveDate': item.lastActiveDate.toIso8601String(),
    };
  }
}
