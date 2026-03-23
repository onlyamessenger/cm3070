import 'package:core/enums/enums.dart';
import 'package:core/interface/services/services.dart';
import 'package:core/models/models.dart';
import 'package:core/usecases/award_xp.dart';
import 'package:core/usecases/unlock_readiness_section.dart';
import 'package:core/usecases/usecase_future.dart';

class CompleteQuestInput {
  final String progressId;

  const CompleteQuestInput({required this.progressId});
}

class CompleteQuestResult {
  final int xpAwarded;
  final double multiplier;
  final String? unlockedSection;

  const CompleteQuestResult({required this.xpAwarded, required this.multiplier, this.unlockedSection});
}

class CompleteQuest extends UseCaseFuture<CompleteQuestInput, CompleteQuestResult> {
  final PlayerQuestProgressService _progressService;
  final QuestService _questService;
  final QuestNodeService _questNodeService;
  final AwardXp _awardXp;
  final ReadinessSectionService _sectionService;
  final LoggerService _logger;

  CompleteQuest({
    required PlayerQuestProgressService progressService,
    required QuestService questService,
    required QuestNodeService questNodeService,
    required AwardXp awardXp,
    required ReadinessSectionService sectionService,
    required LoggerService logger,
  }) : _progressService = progressService,
       _questService = questService,
       _questNodeService = questNodeService,
       _awardXp = awardXp,
       _sectionService = sectionService,
       _logger = logger;

  @override
  Future<CompleteQuestResult> execute(CompleteQuestInput input) async {
    _logger.info('Completing quest progress: ${input.progressId}');

    final PlayerQuestProgress progress = await _progressService.getProgress(input.progressId);

    if (progress.isCompleted) {
      throw Exception('Quest already completed: ${input.progressId}');
    }

    final Quest quest = await _questService.getQuest(progress.questId);
    final List<QuestNode> allNodes = await _questNodeService.getNodesForQuest(progress.questId);
    final Map<String, QuestNode> nodeMap = <String, QuestNode>{for (final QuestNode node in allNodes) node.id: node};

    // Recompute XP by walking the visited path
    int totalXp = 0;
    final List<String> fullPath = <String>[...progress.visitedNodeIds, progress.currentNodeId];
    for (int i = 0; i < fullPath.length; i++) {
      final QuestNode? node = nodeMap[fullPath[i]];
      if (node == null) continue;
      totalXp += node.xpReward;

      // Add choice XP for the transition to the next node
      if (i < fullPath.length - 1) {
        final String nextId = fullPath[i + 1];
        for (final QuestChoice choice in node.choices) {
          if (choice.nextNodeId == nextId) {
            totalXp += choice.xpReward;
            break;
          }
        }
      }
    }

    _logger.info('Recomputed XP: $totalXp for quest "${quest.title}"');

    final AwardXpResult xpResult = await _awardXp.execute(
      AwardXpInput(
        userId: progress.userId,
        baseXp: totalXp,
        action: 'Quest: ${quest.title}',
        sourceType: ActivitySourceType.quest,
      ),
    );

    await _progressService.markCompleted(
      progressId: input.progressId,
      xpEarned: xpResult.xpAwarded,
      completedAt: DateTime.now(),
    );

    // Get unlocksSectionType from the outcome node
    final QuestNode? outcomeNode = nodeMap[progress.currentNodeId];
    final String? unlockedSection = outcomeNode?.unlocksSectionType;

    if (unlockedSection != null) {
      final UnlockReadinessSection unlock = UnlockReadinessSection(sectionService: _sectionService, logger: _logger);
      await unlock.execute(
        UnlockReadinessSectionInput(
          userId: progress.userId,
          sectionType: unlockedSection,
          unlockedByType: 'quest',
          unlockedById: progress.questId,
        ),
      );
    }

    _logger.info('Quest completed. XP awarded: ${xpResult.xpAwarded} (${xpResult.multiplier}x)');

    return CompleteQuestResult(
      xpAwarded: xpResult.xpAwarded,
      multiplier: xpResult.multiplier,
      unlockedSection: unlockedSection,
    );
  }
}
