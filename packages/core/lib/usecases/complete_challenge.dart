import 'package:core/enums/enums.dart';
import 'package:core/interface/services/services.dart';
import 'package:core/models/models.dart';
import 'package:core/usecases/award_xp.dart';
import 'package:core/usecases/unlock_readiness_section.dart';
import 'package:core/usecases/usecase_future.dart';

class CompleteChallengeInput {
  final String progressId;

  const CompleteChallengeInput({required this.progressId});
}

class CompleteChallengeResult {
  final int xpAwarded;
  final double multiplier;
  final String? unlockedSection;

  const CompleteChallengeResult({required this.xpAwarded, required this.multiplier, this.unlockedSection});
}

class CompleteChallenge extends UseCaseFuture<CompleteChallengeInput, CompleteChallengeResult> {
  final PlayerChallengeProgressService _progressService;
  final ChallengeService _challengeService;
  final AwardXp _awardXp;
  final ReadinessSectionService _sectionService;
  final LoggerService _logger;

  CompleteChallenge({
    required PlayerChallengeProgressService progressService,
    required ChallengeService challengeService,
    required AwardXp awardXp,
    required ReadinessSectionService sectionService,
    required LoggerService logger,
  }) : _progressService = progressService,
       _challengeService = challengeService,
       _awardXp = awardXp,
       _sectionService = sectionService,
       _logger = logger;

  @override
  Future<CompleteChallengeResult> execute(CompleteChallengeInput input) async {
    _logger.info('Completing challenge progress: ${input.progressId}');

    final PlayerChallengeProgress progress = await _progressService.getProgress(input.progressId);

    if (progress.isCompleted) {
      throw Exception('Challenge already completed: ${input.progressId}');
    }

    final Challenge challenge = await _challengeService.getChallenge(progress.challengeId);
    final int totalQuestions = progress.answers.length;

    if (totalQuestions == 0) {
      throw Exception('No answers recorded for progress: ${input.progressId}');
    }

    final int baseXp = (progress.correctCount / totalQuestions * challenge.xpReward).round();
    _logger.info('Base XP: $baseXp (${progress.correctCount}/$totalQuestions * ${challenge.xpReward})');

    final AwardXpResult xpResult = await _awardXp.execute(
      AwardXpInput(
        userId: progress.userId,
        baseXp: baseXp,
        action: 'Challenge: ${challenge.title}',
        sourceType: ActivitySourceType.challenge,
      ),
    );

    await _progressService.markCompleted(
      progressId: input.progressId,
      xpEarned: xpResult.xpAwarded,
      completedAt: DateTime.now(),
    );

    final String? unlockedSection = challenge.unlocksSectionType;

    if (unlockedSection != null) {
      final UnlockReadinessSection unlock = UnlockReadinessSection(sectionService: _sectionService, logger: _logger);
      await unlock.execute(
        UnlockReadinessSectionInput(
          userId: progress.userId,
          sectionType: unlockedSection,
          unlockedByType: 'challenge',
          unlockedById: progress.challengeId,
        ),
      );
    }

    _logger.info('Challenge completed. XP awarded: ${xpResult.xpAwarded} (${xpResult.multiplier}x)');

    return CompleteChallengeResult(
      xpAwarded: xpResult.xpAwarded,
      multiplier: xpResult.multiplier,
      unlockedSection: unlockedSection,
    );
  }
}
