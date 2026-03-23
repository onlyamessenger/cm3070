import 'dart:collection';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Pure data container for BonusEvent CRUD state.
class AdminBonusEventState extends ChangeNotifier implements CrudState<BonusEvent> {
  List<BonusEvent> _items = <BonusEvent>[];
  @override
  UnmodifiableListView<BonusEvent> get items => UnmodifiableListView<BonusEvent>(_items);

  BonusEvent? _item;
  @override
  BonusEvent? get item => _item;

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
  void setItems(List<BonusEvent> items) {
    _items = items;
    notifyListeners();
  }

  @override
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  @override
  void setItem(BonusEvent item) {
    _item = item;
    notifyListeners();
  }

  @override
  void clearItem() {
    _item = null;
    notifyListeners();
  }

  @override
  void addItem(BonusEvent item) {
    _items = <BonusEvent>[..._items, item];
    notifyListeners();
  }

  @override
  void editItem(BonusEvent item) {
    _items = _items.map((BonusEvent b) => b.id == item.id ? item : b).toList();
    notifyListeners();
  }

  @override
  void upsertItem(BonusEvent item) {
    final int index = _items.indexWhere((BonusEvent b) => b.id == item.id);
    if (index >= 0) {
      editItem(item);
    } else {
      addItem(item);
    }
  }

  @override
  void deleteItem(BonusEvent item) {
    _items = _items.where((BonusEvent b) => b.id != item.id).toList();
    notifyListeners();
  }

  @override
  BonusEvent? getItemById(String id) {
    try {
      return _items.firstWhere((BonusEvent b) => b.id == id);
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
  List<BonusEvent> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final String query = _searchQuery.toLowerCase();
    return _items.where((BonusEvent b) => b.title.toLowerCase().contains(query)).toList();
  }
}
