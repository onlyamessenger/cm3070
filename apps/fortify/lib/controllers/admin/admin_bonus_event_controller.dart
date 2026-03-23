import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:core/core.dart';

import 'package:fortify/state/admin/admin_bonus_event_state.dart';

/// Orchestrates BonusEvent CRUD side effects.
class AdminBonusEventController {
  final DataSource<BonusEvent> _dataSource;
  final AdminBonusEventState _state;
  final Functions _functions;

  AdminBonusEventController({
    required DataSource<BonusEvent> dataSource,
    required AdminBonusEventState state,
    required Functions functions,
  }) : _dataSource = dataSource,
       _state = state,
       _functions = functions;

  Future<void> loadItems() async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<BonusEvent> results = await _dataSource.readItems();
      _state.setItems(results);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> createItem(BonusEvent bonusEvent) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final BonusEvent created = await _dataSource.createItem(bonusEvent);
      _state.addItem(created);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> updateItem(BonusEvent bonusEvent) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final BonusEvent updated = await _dataSource.updateItem(bonusEvent);
      _state.editItem(updated);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> removeItem(BonusEvent bonusEvent) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _dataSource.deleteItem(bonusEvent);
      _state.deleteItem(bonusEvent);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> activateEvent(BonusEvent bonusEvent) async {
    await updateItem(bonusEvent.copyWith(isActive: true));
  }

  Future<void> bulkDelete(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<BonusEvent> items = _state.items.where((BonusEvent b) => ids.contains(b.id)).toList();
      for (final BonusEvent item in items) {
        await _dataSource.deleteItem(item);
        _state.deleteItem(item);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> bulkActivate(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<BonusEvent> items = _state.items.where((BonusEvent b) => ids.contains(b.id) && !b.isActive).toList();
      for (final BonusEvent item in items) {
        final BonusEvent updated = await _dataSource.updateItem(item.copyWith(isActive: true));
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

  Future<void> generateBonusEvents({required int count, required String model, String? guidance}) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Execution result = await _functions.createExecution(
        functionId: 'admin',
        path: '/generate-bonus-events',
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

  void search(String query) {
    _state.setSearchQuery(query);
  }
}
