import 'package:core/enums/enums.dart';
import 'package:core/interface/services/services.dart';
import 'package:core/models/models.dart';
import 'package:core/usecases/usecase_future.dart';

class AwardXpInput {
  final String userId;
  final int baseXp;
  final String action;
  final ActivitySourceType sourceType;

  const AwardXpInput({required this.userId, required this.baseXp, required this.action, required this.sourceType});
}

class AwardXpResult {
  final int xpAwarded;
  final double multiplier;

  const AwardXpResult({required this.xpAwarded, required this.multiplier});
}

class AwardXp extends UseCaseFuture<AwardXpInput, AwardXpResult> {
  final PlayerService _playerService;
  final BonusEventService _bonusEventService;
  final ActivityLogService _activityLogService;
  final LoggerService _logger;

  AwardXp({
    required PlayerService playerService,
    required BonusEventService bonusEventService,
    required ActivityLogService activityLogService,
    required LoggerService logger,
  }) : _playerService = playerService,
       _bonusEventService = bonusEventService,
       _activityLogService = activityLogService,
       _logger = logger;

  @override
  Future<AwardXpResult> execute(AwardXpInput input) async {
    _logger.info('Awarding XP to ${input.userId}: base=${input.baseXp}, action=${input.action}');

    final Player player = await _playerService.getPlayer(input.userId);

    final double streakMultiplier = _getStreakMultiplier(player.currentStreak);
    _logger.info('Streak multiplier: ${streakMultiplier}x (streak=${player.currentStreak})');

    final List<BonusEvent> activeEvents = await _bonusEventService.getActiveEvents(DateTime.now());
    double bonusMultiplier = 1.0;
    for (final BonusEvent event in activeEvents) {
      if (event.multiplier > bonusMultiplier) {
        bonusMultiplier = event.multiplier;
      }
    }
    _logger.info('Bonus event multiplier: ${bonusMultiplier}x (${activeEvents.length} active events)');

    final double multiplier = streakMultiplier > bonusMultiplier ? streakMultiplier : bonusMultiplier;
    final int xpAwarded = (input.baseXp * multiplier).round();

    _logger.info('Final XP: $xpAwarded (base=${input.baseXp} * ${multiplier}x)');

    await _playerService.updateXp(userId: input.userId, xpToAdd: xpAwarded);

    await _activityLogService.logActivity(
      userId: input.userId,
      action: input.action,
      xp: xpAwarded,
      multiplier: multiplier,
      sourceType: input.sourceType,
    );

    return AwardXpResult(xpAwarded: xpAwarded, multiplier: multiplier);
  }

  double _getStreakMultiplier(int currentStreak) {
    if (currentStreak >= 30) return 3.0;
    if (currentStreak >= 14) return 2.5;
    if (currentStreak >= 7) return 2.0;
    if (currentStreak >= 3) return 1.5;
    return 1.0;
  }
}
