import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:fortify/state/challenge_play_state.dart';

class QuestPlayState extends ChangeNotifier {
  List<Quest> _quests = <Quest>[];
  List<Quest> get quests => _quests;

  Map<String, PlayerQuestProgress> _progressMap = <String, PlayerQuestProgress>{};
  Map<String, PlayerQuestProgress> get progressMap => _progressMap;

  Quest? _activeQuest;
  Quest? get activeQuest => _activeQuest;

  List<QuestNode> _nodes = <QuestNode>[];
  List<QuestNode> get nodes => _nodes;

  PlayerQuestProgress? _activeProgress;
  PlayerQuestProgress? get activeProgress => _activeProgress;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  CompletionResult? _completionResult;
  CompletionResult? get completionResult => _completionResult;

  QuestNode? get currentNode {
    if (_activeProgress == null || _nodes.isEmpty) return null;
    final String nodeId = _activeProgress!.currentNodeId;
    for (final QuestNode node in _nodes) {
      if (node.id == nodeId) return node;
    }
    return null;
  }

  bool get isOutcome => currentNode?.isOutcome ?? false;

  List<QuestNode> get visitedNodes {
    if (_activeProgress == null || _nodes.isEmpty) return <QuestNode>[];
    final Map<String, QuestNode> nodeMap = <String, QuestNode>{for (final QuestNode n in _nodes) n.id: n};
    return _activeProgress!.visitedNodeIds.map((String id) => nodeMap[id]).whereType<QuestNode>().toList();
  }

  int get runningXp => _activeProgress?.xpEarned ?? 0;

  bool isQuestLocked(Quest quest) {
    switch (quest.difficulty) {
      case Difficulty.beginner:
        return false;
      case Difficulty.intermediate:
        return !_hasCompletedDifficulty(Difficulty.beginner);
      case Difficulty.advanced:
        return !_hasCompletedDifficulty(Difficulty.intermediate);
    }
  }

  bool _hasCompletedDifficulty(Difficulty difficulty) {
    for (final Quest quest in _quests) {
      if (quest.difficulty == difficulty) {
        final PlayerQuestProgress? progress = _progressMap[quest.id];
        if (progress != null && progress.isCompleted) return true;
      }
    }
    return false;
  }

  String? choiceLabelForNode(String nodeId) {
    if (_activeProgress == null || _nodes.isEmpty) return null;
    final List<String> visited = _activeProgress!.visitedNodeIds;
    final int index = visited.indexOf(nodeId);
    if (index < 0) return null;

    final String nextId;
    if (index < visited.length - 1) {
      nextId = visited[index + 1];
    } else {
      nextId = _activeProgress!.currentNodeId;
    }

    final Map<String, QuestNode> nodeMap = <String, QuestNode>{for (final QuestNode n in _nodes) n.id: n};
    final QuestNode? node = nodeMap[nodeId];
    if (node == null) return null;

    for (final QuestChoice choice in node.choices) {
      if (choice.nextNodeId == nextId) return choice.label;
    }
    return null;
  }

  PlayerQuestProgress? getProgress(String questId) => _progressMap[questId];

  void setQuestList(List<Quest> quests, Map<String, PlayerQuestProgress> progressMap) {
    _quests = quests;
    _progressMap = progressMap;
    notifyListeners();
  }

  void setActiveQuest(Quest quest, List<QuestNode> nodes, PlayerQuestProgress progress) {
    _activeQuest = quest;
    _nodes = nodes;
    _activeProgress = progress;
    _completionResult = null;
    _error = null;
    notifyListeners();
  }

  void updateActiveProgress(PlayerQuestProgress progress) {
    _activeProgress = progress;
    notifyListeners();
  }

  void markQuestCompleted(PlayerQuestProgress progress) {
    _progressMap[progress.questId] = progress;
    _activeProgress = progress;
    notifyListeners();
  }

  void setCompletionResult(CompletionResult result) {
    _completionResult = result;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clear() {
    _activeQuest = null;
    _nodes = <QuestNode>[];
    _activeProgress = null;
    _completionResult = null;
    _error = null;
    notifyListeners();
  }
}
