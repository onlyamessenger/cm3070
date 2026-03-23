import 'dart:collection';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Pure data container for Level CRUD state.
class AdminLevelState extends ChangeNotifier implements CrudState<Level> {
  List<Level> _items = <Level>[];
  @override
  UnmodifiableListView<Level> get items => UnmodifiableListView<Level>(_items);

  Level? _item;
  @override
  Level? get item => _item;

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
  void setItems(List<Level> items) {
    _items = items;
    notifyListeners();
  }

  @override
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  @override
  void setItem(Level item) {
    _item = item;
    notifyListeners();
  }

  @override
  void clearItem() {
    _item = null;
    notifyListeners();
  }

  @override
  void addItem(Level item) {
    _items = <Level>[..._items, item];
    notifyListeners();
  }

  @override
  void editItem(Level item) {
    _items = _items.map((Level l) => l.id == item.id ? item : l).toList();
    notifyListeners();
  }

  @override
  void upsertItem(Level item) {
    final int index = _items.indexWhere((Level l) => l.id == item.id);
    if (index >= 0) {
      editItem(item);
    } else {
      addItem(item);
    }
  }

  @override
  void deleteItem(Level item) {
    _items = _items.where((Level l) => l.id != item.id).toList();
    notifyListeners();
  }

  @override
  Level? getItemById(String id) {
    try {
      return _items.firstWhere((Level l) => l.id == id);
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
  List<Level> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final String query = _searchQuery.toLowerCase();
    return _items.where((Level l) => l.title.toLowerCase().contains(query)).toList();
  }
}
