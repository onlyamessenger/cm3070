import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class CompletionResult {
  final int xpAwarded;
  final double multiplier;
  final String? unlockedSection;

  const CompletionResult({required this.xpAwarded, required this.multiplier, this.unlockedSection});
}

class ChallengePlayState extends ChangeNotifier {
  List<Challenge> _challenges = <Challenge>[];
  List<Challenge> get challenges => _challenges;

  Map<String, PlayerChallengeProgress> _progressMap = <String, PlayerChallengeProgress>{};
  Map<String, PlayerChallengeProgress> get progressMap => _progressMap;

  Challenge? _activeChallenge;
  Challenge? get activeChallenge => _activeChallenge;

  List<ChallengeQuestion> _questions = <ChallengeQuestion>[];
  List<ChallengeQuestion> get questions => _questions;

  PlayerChallengeProgress? _activeProgress;
  PlayerChallengeProgress? get activeProgress => _activeProgress;

  int? _selectedAnswer;
  int? get selectedAnswer => _selectedAnswer;

  bool _showingFeedback = false;
  bool get showingFeedback => _showingFeedback;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  CompletionResult? _completionResult;
  CompletionResult? get completionResult => _completionResult;

  int get runningXp {
    if (_activeChallenge == null || _activeProgress == null || _questions.isEmpty) return 0;
    final int total = _questions.length;
    return (_activeProgress!.correctCount / total * _activeChallenge!.xpReward).round();
  }

  ChallengeQuestion? get currentQuestion {
    if (_activeProgress == null || _questions.isEmpty) return null;
    final int index = _activeProgress!.currentQuestionIndex;
    if (index >= _questions.length) return null;
    return _questions[index];
  }

  bool get isLastQuestion {
    if (_activeProgress == null || _questions.isEmpty) return false;
    return _activeProgress!.currentQuestionIndex >= _questions.length - 1;
  }

  Challenge? get dailyChallenge {
    for (final Challenge c in _challenges) {
      if (c.questId == null && !_isCompleted(c.id)) return c;
    }
    return null;
  }

  List<Challenge> get questChallenges {
    return _challenges.where((Challenge c) => c.questId != null).toList();
  }

  bool _isCompleted(String challengeId) {
    final PlayerChallengeProgress? progress = _progressMap[challengeId];
    return progress != null && progress.isCompleted;
  }

  PlayerChallengeProgress? getProgress(String challengeId) => _progressMap[challengeId];

  void setChallengeList(List<Challenge> challenges, Map<String, PlayerChallengeProgress> progressMap) {
    _challenges = challenges;
    _progressMap = progressMap;
    notifyListeners();
  }

  void setActiveChallenge(Challenge challenge, List<ChallengeQuestion> questions, PlayerChallengeProgress progress) {
    _activeChallenge = challenge;
    _questions = questions;
    _activeProgress = progress;
    _selectedAnswer = null;
    _showingFeedback = false;
    _completionResult = null;
    notifyListeners();
  }

  void setFeedbackState({required int? selectedAnswer, required bool showingFeedback}) {
    _selectedAnswer = selectedAnswer;
    _showingFeedback = showingFeedback;
    notifyListeners();
  }

  void updateActiveProgress(PlayerChallengeProgress progress) {
    _activeProgress = progress;
    _selectedAnswer = null;
    _showingFeedback = false;
    notifyListeners();
  }

  void markChallengeCompleted(PlayerChallengeProgress progress) {
    _progressMap[progress.challengeId] = progress;
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
    _activeChallenge = null;
    _questions = <ChallengeQuestion>[];
    _activeProgress = null;
    _selectedAnswer = null;
    _showingFeedback = false;
    _completionResult = null;
    _error = null;
    notifyListeners();
  }
}
