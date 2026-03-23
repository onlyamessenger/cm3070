import 'dart:collection';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Pure data container for Challenge CRUD state.
class AdminChallengeState extends ChangeNotifier implements CrudState<Challenge> {
  List<Challenge> _items = <Challenge>[];
  @override
  UnmodifiableListView<Challenge> get items => UnmodifiableListView<Challenge>(_items);

  Challenge? _item;
  @override
  Challenge? get item => _item;

  bool _loading = false;
  @override
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Map<String, dynamic> _activeFilters = <String, dynamic>{};
  Map<String, dynamic> get activeFilters => _activeFilters;

  @override
  void setItems(List<Challenge> items) {
    _items = items;
    notifyListeners();
  }

  @override
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  @override
  void setItem(Challenge item) {
    _item = item;
    notifyListeners();
  }

  @override
  void clearItem() {
    _item = null;
    notifyListeners();
  }

  @override
  void addItem(Challenge item) {
    _items = <Challenge>[..._items, item];
    notifyListeners();
  }

  @override
  void editItem(Challenge item) {
    _items = _items.map((Challenge c) => c.id == item.id ? item : c).toList();
    notifyListeners();
  }

  @override
  void upsertItem(Challenge item) {
    final int index = _items.indexWhere((Challenge c) => c.id == item.id);
    if (index >= 0) {
      editItem(item);
    } else {
      addItem(item);
    }
  }

  @override
  void deleteItem(Challenge item) {
    _items = _items.where((Challenge c) => c.id != item.id).toList();
    notifyListeners();
  }

  @override
  Challenge? getItemById(String id) {
    try {
      return _items.firstWhere((Challenge c) => c.id == id);
    } on StateError {
      return null;
    }
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFilters(Map<String, dynamic> value) {
    _activeFilters = value;
    notifyListeners();
  }

  /// Client-side search over loaded items.
  List<Challenge> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final String query = _searchQuery.toLowerCase();
    return _items.where((Challenge c) => c.title.toLowerCase().contains(query)).toList();
  }
}
