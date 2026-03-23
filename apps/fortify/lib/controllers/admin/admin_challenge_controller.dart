import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:core/core.dart';

import 'package:fortify/state/admin/admin_challenge_state.dart';

/// Orchestrates Challenge CRUD side effects, including embedded question management.
class AdminChallengeController {
  final DataSource<Challenge> _dataSource;
  final DataSource<ChallengeQuestion> _questionDataSource;
  final AdminChallengeState _state;
  final Functions _functions;

  AdminChallengeController({
    required DataSource<Challenge> dataSource,
    required DataSource<ChallengeQuestion> questionDataSource,
    required AdminChallengeState state,
    required Functions functions,
  }) : _dataSource = dataSource,
       _questionDataSource = questionDataSource,
       _state = state,
       _functions = functions;

  Future<void> loadItems() async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Challenge> results = await _dataSource.readItems();
      _state.setItems(results);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> createItem(Challenge challenge) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Challenge created = await _dataSource.createItem(challenge);
      _state.addItem(created);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> updateItem(Challenge challenge) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Challenge updated = await _dataSource.updateItem(challenge);
      _state.editItem(updated);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> removeItem(Challenge challenge) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _dataSource.deleteItem(challenge);
      _state.deleteItem(challenge);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> publishItem(Challenge challenge) async {
    await updateItem(challenge.copyWith(isPublished: true));
  }

  Future<void> bulkDelete(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Challenge> items = _state.items.where((Challenge c) => ids.contains(c.id)).toList();
      for (final Challenge item in items) {
        await _dataSource.deleteItem(item);
        _state.deleteItem(item);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> bulkPublish(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Challenge> items = _state.items.where((Challenge c) => ids.contains(c.id) && !c.isPublished).toList();
      for (final Challenge item in items) {
        final Challenge updated = await _dataSource.updateItem(item.copyWith(isPublished: true));
        _state.editItem(updated);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _state.setFilters(filters);
    await loadItems();
  }

  Future<void> generateChallenges({
    required int count,
    required int questionsPerChallenge,
    required String model,
    required List<String> challengeTypes,
    required String difficulty,
    required String disasterType,
    List<String>? questIds,
    String? guidance,
  }) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Execution result = await _functions.createExecution(
        functionId: 'admin',
        path: '/generate-challenges',
        body: jsonEncode(<String, dynamic>{
          'count': count,
          'questionsPerChallenge': questionsPerChallenge,
          'model': model,
          'challengeTypes': challengeTypes,
          'difficulty': difficulty,
          'disasterType': disasterType,
          'questIds': questIds,
          'guidance': guidance,
        }),
        method: ExecutionMethod.pOST,
      );

      final Map<String, dynamic> response = jsonDecode(result.responseBody) as Map<String, dynamic>;

      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Generation failed');
      }

      await loadItems();
    } on Exception catch (e) {
      _state.setError(e.toString());
      rethrow;
    } finally {
      _state.setLoading(false);
    }
  }

  void search(String query) {
    _state.setSearchQuery(query);
  }

  // ── Question Management ──

  /// Loads all questions belonging to the given challenge.
  Future<List<ChallengeQuestion>> loadQuestionsForChallenge(String challengeId) async {
    return _questionDataSource.readItemsWhere('challengeId', challengeId);
  }

  /// Saves the challenge and its questions together.
  ///
  /// For the edit page: updates the challenge, then diffs questions against the
  /// original list to determine which to create, update, or delete.
  ///
  /// Operations are sequential - if one fails, the error is reported and the
  /// user can retry. Already-saved operations persist in AppWrite.
  Future<void> saveWithQuestions({
    required Challenge challenge,
    required List<ChallengeQuestion> currentQuestions,
    required List<ChallengeQuestion> originalQuestions,
    required bool isNew,
  }) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      // Step 1: Save the challenge itself
      final Challenge savedChallenge;
      if (isNew) {
        savedChallenge = await _dataSource.createItem(challenge);
        _state.addItem(savedChallenge);
      } else {
        savedChallenge = await _dataSource.updateItem(challenge);
        _state.editItem(savedChallenge);
      }

      // Step 2: Assign challengeId to all questions (needed for add page where ID wasn't known)
      final List<ChallengeQuestion> questionsWithId = currentQuestions
          .map((ChallengeQuestion q) => q.copyWith(challengeId: savedChallenge.id))
          .toList();

      // Step 3: Diff current questions against original to find creates, updates, and deletes
      await _saveQuestionsDiff(questionsWithId, originalQuestions);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  /// Compares the current question list against the original and executes
  /// the necessary create/update/delete operations sequentially.
  Future<void> _saveQuestionsDiff(List<ChallengeQuestion> current, List<ChallengeQuestion> original) async {
    final Set<String> originalIds = original.map((ChallengeQuestion q) => q.id).toSet();
    final Set<String> currentIds = current.map((ChallengeQuestion q) => q.id).toSet();

    // New questions: empty ID means they haven't been persisted yet
    final List<ChallengeQuestion> toCreate = current.where((ChallengeQuestion q) => q.id.isEmpty).toList();

    // Updated questions: exist in both lists (non-empty ID present in original)
    final List<ChallengeQuestion> toUpdate = current
        .where((ChallengeQuestion q) => q.id.isNotEmpty && originalIds.contains(q.id))
        .toList();

    // Deleted questions: in original but not in current (compared by id)
    final List<ChallengeQuestion> toDelete = original
        .where((ChallengeQuestion q) => !currentIds.contains(q.id))
        .toList();

    // Execute creates
    for (final ChallengeQuestion question in toCreate) {
      await _questionDataSource.createItem(question);
    }

    // Execute updates
    for (final ChallengeQuestion question in toUpdate) {
      await _questionDataSource.updateItem(question);
    }

    // Execute deletes
    for (final ChallengeQuestion question in toDelete) {
      await _questionDataSource.deleteItem(question);
    }
  }
}
