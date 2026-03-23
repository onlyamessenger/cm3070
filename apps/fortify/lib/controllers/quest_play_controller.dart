import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:core/core.dart';

import 'package:fortify/controllers/player_controller.dart';
import 'package:fortify/controllers/readiness_controller.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/state/quest_play_state.dart';

class QuestPlayController {
  final DataSource<Quest> _questDataSource;
  final DataSource<QuestNode> _questNodeDataSource;
  final DataSource<PlayerQuestProgress> _progressDataSource;
  final Functions _functions;
  final QuestPlayState _state;
  final PlayerController _playerController;
  final ReadinessController _readinessController;

  QuestPlayController({
    required DataSource<Quest> questDataSource,
    required DataSource<QuestNode> questNodeDataSource,
    required DataSource<PlayerQuestProgress> progressDataSource,
    required Functions functions,
    required QuestPlayState state,
    required PlayerController playerController,
    required ReadinessController readinessController,
  }) : _questDataSource = questDataSource,
       _questNodeDataSource = questNodeDataSource,
       _progressDataSource = progressDataSource,
       _functions = functions,
       _state = state,
       _playerController = playerController,
       _readinessController = readinessController;

  Future<void> loadQuestList(String userId) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Quest> allQuests = await _questDataSource.readItems();
      final List<Quest> published = allQuests.where((Quest q) => q.isPublished).toList();

      final List<PlayerQuestProgress> progressList = await _progressDataSource.readItemsWhere('userId', userId);
      final Map<String, PlayerQuestProgress> progressMap = <String, PlayerQuestProgress>{};
      for (final PlayerQuestProgress p in progressList) {
        progressMap[p.questId] = p;
      }

      _state.setQuestList(published, progressMap);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> startQuest(String questId, String userId) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      if (_state.quests.isEmpty) {
        await loadQuestList(userId);
      }

      final Quest quest = _state.quests.firstWhere((Quest q) => q.id == questId);
      final List<QuestNode> nodes = await _questNodeDataSource.readItemsWhere('questId', questId);

      final PlayerQuestProgress? existing = _state.getProgress(questId);
      if (existing != null) {
        _state.setActiveQuest(quest, nodes, existing);
        return;
      }

      final String id = await _progressDataSource.generateId();
      final DateTime now = DateTime.now();
      final PlayerQuestProgress progress = PlayerQuestProgress(
        id: id,
        created: now,
        updated: now,
        createdBy: userId,
        updatedBy: userId,
        userId: userId,
        questId: questId,
        currentNodeId: quest.startNodeId,
        xpEarned: _getNodeXp(nodes, quest.startNodeId),
      );

      final PlayerQuestProgress created = await _progressDataSource.createItem(progress);
      _state.setActiveQuest(quest, nodes, created);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> makeChoice(QuestChoice choice) async {
    final PlayerQuestProgress? progress = _state.activeProgress;
    if (progress == null) return;

    final int nextNodeXp = _getNodeXp(_state.nodes, choice.nextNodeId);

    final PlayerQuestProgress updated = progress.copyWith(
      visitedNodeIds: <String>[...progress.visitedNodeIds, progress.currentNodeId],
      currentNodeId: choice.nextNodeId,
      xpEarned: progress.xpEarned + choice.xpReward + nextNodeXp,
    );

    final PlayerQuestProgress saved = await _progressDataSource.updateItem(updated);
    _state.updateActiveProgress(saved);
  }

  Future<void> completeQuest() async {
    final PlayerQuestProgress? progress = _state.activeProgress;
    if (progress == null) return;

    _state.setLoading(true);
    try {
      final result = await _functions.createExecution(
        functionId: 'player',
        path: '/complete-quest',
        body: jsonEncode(<String, dynamic>{'progressId': progress.id}),
        method: ExecutionMethod.pOST,
      );

      final Map<String, dynamic> response = jsonDecode(result.responseBody) as Map<String, dynamic>;
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to complete quest');
      }

      final PlayerQuestProgress completedProgress = progress.copyWith(
        isCompleted: true,
        xpEarned: response['xpAwarded'] as int,
        completedAt: DateTime.now(),
      );
      _state.markQuestCompleted(completedProgress);

      _state.setCompletionResult(
        CompletionResult(
          xpAwarded: response['xpAwarded'] as int,
          multiplier: (response['multiplier'] as num).toDouble(),
          unlockedSection: response['unlockedSection'] as String?,
        ),
      );

      await _playerController.loadProfile(progress.userId);

      final String? unlockedSection = response['unlockedSection'] as String?;
      if (unlockedSection != null) {
        await _readinessController.refreshAfterUnlock(progress.userId);
        await _readinessController.loadKitItems(progress.userId);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  int _getNodeXp(List<QuestNode> nodes, String nodeId) {
    for (final QuestNode node in nodes) {
      if (node.id == nodeId) return node.xpReward;
    }
    return 0;
  }
}
