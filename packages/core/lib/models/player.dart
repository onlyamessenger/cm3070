import 'package:core/models/model_base.dart';

class Player extends ModelBase {
  String userId;
  String displayName;
  int xp;
  int currentStreak;
  int longestStreak;
  bool streakShieldAvailable;
  DateTime? streakShieldUsedAt;
  DateTime lastActiveDate;

  Player({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.userId,
    required this.displayName,
    this.xp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakShieldAvailable = true,
    this.streakShieldUsedAt,
    required this.lastActiveDate,
  });

  @override
  Player copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? userId,
    String? displayName,
    int? xp,
    int? currentStreak,
    int? longestStreak,
    bool? streakShieldAvailable,
    DateTime? streakShieldUsedAt,
    bool clearStreakShieldUsedAt = false,
    DateTime? lastActiveDate,
  }) {
    return Player(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      xp: xp ?? this.xp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakShieldAvailable: streakShieldAvailable ?? this.streakShieldAvailable,
      streakShieldUsedAt: clearStreakShieldUsedAt ? null : (streakShieldUsedAt ?? this.streakShieldUsedAt),
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
