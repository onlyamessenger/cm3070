import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:core/core.dart';

import 'package:fortify/controllers/player_controller.dart';
import 'package:fortify/controllers/readiness_controller.dart';
import 'package:fortify/state/challenge_play_state.dart';

class ChallengePlayController {
  final DataSource<Challenge> _challengeDataSource;
  final DataSource<ChallengeQuestion> _questionDataSource;
  final DataSource<PlayerChallengeProgress> _progressDataSource;
  final Functions _functions;
  final ChallengePlayState _state;
  final PlayerController _playerController;
  final ReadinessController _readinessController;

  ChallengePlayController({
    required DataSource<Challenge> challengeDataSource,
    required DataSource<ChallengeQuestion> questionDataSource,
    required DataSource<PlayerChallengeProgress> progressDataSource,
    required Functions functions,
    required ChallengePlayState state,
    required PlayerController playerController,
    required ReadinessController readinessController,
  }) : _challengeDataSource = challengeDataSource,
       _questionDataSource = questionDataSource,
       _progressDataSource = progressDataSource,
       _functions = functions,
       _state = state,
       _playerController = playerController,
       _readinessController = readinessController;

  Future<void> loadChallengeList(String userId) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Challenge> allChallenges = await _challengeDataSource.readItems();
      final List<Challenge> published = allChallenges.where((Challenge c) => c.isPublished).toList();

      final List<PlayerChallengeProgress> progressList = await _progressDataSource.readItemsWhere('userId', userId);
      final Map<String, PlayerChallengeProgress> progressMap = <String, PlayerChallengeProgress>{};
      for (final PlayerChallengeProgress p in progressList) {
        progressMap[p.challengeId] = p;
      }

      _state.setChallengeList(published, progressMap);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<PlayerChallengeProgress> startChallenge(String challengeId, String userId) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      if (_state.challenges.isEmpty) {
        await loadChallengeList(userId);
      }

      final Challenge challenge = _state.challenges.firstWhere((Challenge c) => c.id == challengeId);

      final PlayerChallengeProgress? existing = _state.getProgress(challengeId);
      if (existing != null) {
        final List<ChallengeQuestion> questions = await _fetchQuestions(challengeId);
        _state.setActiveChallenge(challenge, questions, existing);
        return existing;
      }

      final String id = await _progressDataSource.generateId();
      final DateTime now = DateTime.now();
      final PlayerChallengeProgress progress = PlayerChallengeProgress(
        id: id,
        created: now,
        updated: now,
        createdBy: userId,
        updatedBy: userId,
        userId: userId,
        challengeId: challengeId,
      );

      final PlayerChallengeProgress created = await _progressDataSource.createItem(progress);
      final List<ChallengeQuestion> questions = await _fetchQuestions(challengeId);
      _state.setActiveChallenge(challenge, questions, created);
      return created;
    } on Exception catch (e) {
      _state.setError(e.toString());
      rethrow;
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> submitAnswer(int answerIndex) async {
    final PlayerChallengeProgress? progress = _state.activeProgress;
    final ChallengeQuestion? question = _state.currentQuestion;
    if (progress == null || question == null) return;

    _state.setFeedbackState(selectedAnswer: answerIndex, showingFeedback: true);

    await Future<void>.delayed(const Duration(milliseconds: 200));

    final bool isCorrect = answerIndex == question.correctIndex;
    final List<int> updatedAnswers = <int>[...progress.answers, answerIndex];
    final int updatedCorrectCount = progress.correctCount + (isCorrect ? 1 : 0);
    final int updatedIndex = progress.currentQuestionIndex + 1;

    final PlayerChallengeProgress updated = progress.copyWith(
      answers: updatedAnswers,
      correctCount: updatedCorrectCount,
      currentQuestionIndex: updatedIndex,
    );

    final PlayerChallengeProgress saved = await _progressDataSource.updateItem(updated);
    _state.updateActiveProgress(saved);
  }

  Future<void> completeChallenge() async {
    final PlayerChallengeProgress? progress = _state.activeProgress;
    if (progress == null) return;

    _state.setLoading(true);
    try {
      final result = await _functions.createExecution(
        functionId: 'player',
        path: '/complete-challenge',
        body: jsonEncode(<String, dynamic>{'progressId': progress.id}),
        method: ExecutionMethod.pOST,
      );

      final Map<String, dynamic> response = jsonDecode(result.responseBody) as Map<String, dynamic>;
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to complete challenge');
      }

      final PlayerChallengeProgress completedProgress = progress.copyWith(
        isCompleted: true,
        xpEarned: response['xpAwarded'] as int,
        completedAt: DateTime.now(),
      );
      _state.markChallengeCompleted(completedProgress);

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

  Future<List<ChallengeQuestion>> _fetchQuestions(String challengeId) async {
    final List<ChallengeQuestion> questions = await _questionDataSource.readItemsWhere('challengeId', challengeId);
    questions.sort((ChallengeQuestion a, ChallengeQuestion b) => a.sortOrder.compareTo(b.sortOrder));
    return questions;
  }
}
