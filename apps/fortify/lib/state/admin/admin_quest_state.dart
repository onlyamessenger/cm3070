import 'dart:collection';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Pure data container for Quest CRUD state.
class AdminQuestState extends ChangeNotifier implements CrudState<Quest> {
  List<Quest> _items = <Quest>[];
  @override
  UnmodifiableListView<Quest> get items => UnmodifiableListView<Quest>(_items);

  Quest? _item;
  @override
  Quest? get item => _item;

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
  void setItems(List<Quest> items) {
    _items = items;
    notifyListeners();
  }

  @override
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  @override
  void setItem(Quest item) {
    _item = item;
    notifyListeners();
  }

  @override
  void clearItem() {
    _item = null;
    notifyListeners();
  }

  @override
  void addItem(Quest item) {
    _items = <Quest>[..._items, item];
    notifyListeners();
  }

  @override
  void editItem(Quest item) {
    _items = _items.map((Quest q) => q.id == item.id ? item : q).toList();
    notifyListeners();
  }

  @override
  void upsertItem(Quest item) {
    final int index = _items.indexWhere((Quest q) => q.id == item.id);
    if (index >= 0) {
      editItem(item);
    } else {
      addItem(item);
    }
  }

  @override
  void deleteItem(Quest item) {
    _items = _items.where((Quest q) => q.id != item.id).toList();
    notifyListeners();
  }

  @override
  Quest? getItemById(String id) {
    try {
      return _items.firstWhere((Quest q) => q.id == id);
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
  List<Quest> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final String query = _searchQuery.toLowerCase();
    return _items.where((Quest q) => q.title.toLowerCase().contains(query)).toList();
  }
}
