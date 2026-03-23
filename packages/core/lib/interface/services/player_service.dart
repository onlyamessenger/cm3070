import 'package:core/models/models.dart';

abstract class PlayerService {
  Future<Player> createPlayer({required String userId, required String displayName});

  Future<Player> getPlayer(String userId);

  Future<void> updateXp({required String userId, required int xpToAdd});

  Future<void> updateCheckInState({
    required String playerId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
    required bool streakShieldAvailable,
    DateTime? streakShieldUsedAt,
    required bool clearStreakShieldUsedAt,
  });
}
