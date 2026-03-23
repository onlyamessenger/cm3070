import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:core/core.dart';

import 'package:fortify/state/admin/admin_kit_item_state.dart';

/// Orchestrates KitItem CRUD side effects.
class AdminKitItemController {
  final DataSource<KitItem> _dataSource;
  final AdminKitItemState _state;
  final Functions _functions;

  AdminKitItemController({
    required DataSource<KitItem> dataSource,
    required AdminKitItemState state,
    required Functions functions,
  }) : _dataSource = dataSource,
       _state = state,
       _functions = functions;

  Future<void> loadItems() async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<KitItem> results = await _dataSource.readItems();
      _state.setItems(results);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> createItem(KitItem kitItem) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final KitItem created = await _dataSource.createItem(kitItem);
      _state.addItem(created);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> updateItem(KitItem kitItem) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final KitItem updated = await _dataSource.updateItem(kitItem);
      _state.editItem(updated);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> removeItem(KitItem kitItem) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _dataSource.deleteItem(kitItem);
      _state.deleteItem(kitItem);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> bulkDelete(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<KitItem> items = _state.items.where((KitItem k) => ids.contains(k.id)).toList();
      for (final KitItem item in items) {
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
      final List<KitItem> items = _state.items.where((KitItem k) => ids.contains(k.id) && !k.isPublished).toList();
      for (final KitItem item in items) {
        final KitItem updated = await _dataSource.updateItem(item.copyWith(isPublished: true));
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

  Future<void> publishItem(KitItem kitItem) async {
    await updateItem(kitItem.copyWith(isPublished: true));
  }

  Future<void> generateKitItems({required int count, required String model, String? guidance}) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Execution result = await _functions.createExecution(
        functionId: 'admin',
        path: '/generate-kit-items',
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
