import 'package:core/enums/enums.dart';
import 'package:core/interface/services/services.dart';
import 'package:core/models/models.dart';
import 'package:core/usecases/award_xp.dart';
import 'package:core/usecases/usecase_future.dart';

class DailyCheckInInput {
  final String userId;
  final bool useShield;
  final DateTime now;

  const DailyCheckInInput({required this.userId, required this.useShield, required this.now});
}

class DailyCheckInResult {
  final bool ok;
  final bool alreadyCheckedIn;
  final bool streakReset;
  final bool shieldAvailable;
  final int currentStreak;
  final int longestStreak;
  final int xpAwarded;
  final double multiplier;

  const DailyCheckInResult({
    required this.ok,
    this.alreadyCheckedIn = false,
    this.streakReset = false,
    this.shieldAvailable = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.xpAwarded = 0,
    this.multiplier = 1.0,
  });
}

class DailyCheckIn extends UseCaseFuture<DailyCheckInInput, DailyCheckInResult> {
  final PlayerService _playerService;
  final AwardXp _awardXp;
  final LoggerService _logger;

  DailyCheckIn({required PlayerService playerService, required AwardXp awardXp, required LoggerService logger})
    : _playerService = playerService,
      _awardXp = awardXp,
      _logger = logger;

  @override
  Future<DailyCheckInResult> execute(DailyCheckInInput input) async {
    _logger.info('Daily check-in for ${input.userId}');

    Player player = await _playerService.getPlayer(input.userId);

    // Monthly shield reset
    player = _resetShieldIfNewMonth(player, input.now);

    // Compare dates (UTC day-level)
    final DateTime today = DateTime.utc(input.now.year, input.now.month, input.now.day);
    final DateTime lastActive = DateTime.utc(
      player.lastActiveDate.year,
      player.lastActiveDate.month,
      player.lastActiveDate.day,
    );
    final int daysDiff = today.difference(lastActive).inDays;

    // Same day, already checked in
    if (daysDiff == 0 && player.currentStreak > 0) {
      return const DailyCheckInResult(ok: false, alreadyCheckedIn: true);
    }

    int newStreak;
    bool streakReset = false;
    bool shieldConsumed = false;

    if (daysDiff == 0 && player.currentStreak == 0) {
      // New player, first check-in
      newStreak = 1;
    } else if (daysDiff == 1) {
      // Consecutive day
      newStreak = player.currentStreak + 1;
    } else {
      // Missed day(s)
      if (player.streakShieldAvailable && !input.useShield) {
        // Shield available but user hasn't confirmed - return prompt
        return DailyCheckInResult(
          ok: false,
          shieldAvailable: true,
          currentStreak: player.currentStreak,
          longestStreak: player.longestStreak,
        );
      } else if (player.streakShieldAvailable && input.useShield) {
        // Use shield - keep and increment streak
        newStreak = player.currentStreak + 1;
        shieldConsumed = true;
      } else {
        // No shield - reset
        newStreak = 1;
        streakReset = true;
      }
    }

    final int newLongestStreak = newStreak > player.longestStreak ? newStreak : player.longestStreak;

    // Award XP
    final AwardXpResult xpResult = await _awardXp.execute(
      AwardXpInput(userId: input.userId, baseXp: 10, action: 'Daily Check-in', sourceType: ActivitySourceType.checkIn),
    );

    // Update player state
    await _playerService.updateCheckInState(
      playerId: player.id,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActiveDate: input.now,
      streakShieldAvailable: shieldConsumed ? false : player.streakShieldAvailable,
      streakShieldUsedAt: shieldConsumed ? input.now : player.streakShieldUsedAt,
      clearStreakShieldUsedAt: false,
    );

    _logger.info('Check-in complete: streak=$newStreak, xp=${xpResult.xpAwarded}');

    return DailyCheckInResult(
      ok: true,
      streakReset: streakReset,
      shieldAvailable: shieldConsumed ? false : player.streakShieldAvailable,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      xpAwarded: xpResult.xpAwarded,
      multiplier: xpResult.multiplier,
    );
  }

  Player _resetShieldIfNewMonth(Player player, DateTime now) {
    if (player.streakShieldUsedAt == null) return player;

    final DateTime usedAt = player.streakShieldUsedAt!;
    final bool isDifferentMonth = now.year > usedAt.year || (now.year == usedAt.year && now.month > usedAt.month);

    if (isDifferentMonth) {
      _logger.info('Shield reset: used in ${usedAt.month}/${usedAt.year}, now ${now.month}/${now.year}');
      return player.copyWith(streakShieldAvailable: true, clearStreakShieldUsedAt: true);
    }

    return player;
  }
}
