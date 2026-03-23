import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:core/core.dart';

import 'package:fortify/state/admin/admin_level_state.dart';

/// Orchestrates Level CRUD side effects.
class AdminLevelController {
  final DataSource<Level> _dataSource;
  final AdminLevelState _state;
  final Functions _functions;

  AdminLevelController({
    required DataSource<Level> dataSource,
    required AdminLevelState state,
    required Functions functions,
  }) : _dataSource = dataSource,
       _state = state,
       _functions = functions;

  Future<void> loadItems() async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Level> results = await _dataSource.readItems();
      _state.setItems(results);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> createItem(Level level) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Level created = await _dataSource.createItem(level);
      _state.addItem(created);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> updateItem(Level level) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Level updated = await _dataSource.updateItem(level);
      _state.editItem(updated);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> removeItem(Level level) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _dataSource.deleteItem(level);
      _state.deleteItem(level);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> generateLevels({required int count, required String model, String? guidance}) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Execution result = await _functions.createExecution(
        functionId: 'admin',
        path: '/generate-levels',
        body: jsonEncode(<String, dynamic>{'count': count, 'model': model, 'guidance': guidance}),
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

  Future<void> publishItem(Level level) async {
    await updateItem(level.copyWith(isPublished: true));
  }

  Future<void> bulkDelete(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Level> items = _state.items.where((Level l) => ids.contains(l.id)).toList();
      for (final Level item in items) {
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
      final List<Level> items = _state.items.where((Level l) => ids.contains(l.id) && !l.isPublished).toList();
      for (final Level item in items) {
        final Level updated = await _dataSource.updateItem(item.copyWith(isPublished: true));
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

  void search(String query) {
    _state.setSearchQuery(query);
  }
}
