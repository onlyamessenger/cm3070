import 'dart:collection';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Pure data container for KitItem CRUD state.
class AdminKitItemState extends ChangeNotifier implements CrudState<KitItem> {
  List<KitItem> _items = <KitItem>[];
  @override
  UnmodifiableListView<KitItem> get items => UnmodifiableListView<KitItem>(_items);

  KitItem? _item;
  @override
  KitItem? get item => _item;

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
  void setItems(List<KitItem> items) {
    _items = items;
    notifyListeners();
  }

  @override
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  @override
  void setItem(KitItem item) {
    _item = item;
    notifyListeners();
  }

  @override
  void clearItem() {
    _item = null;
    notifyListeners();
  }

  @override
  void addItem(KitItem item) {
    _items = <KitItem>[..._items, item];
    notifyListeners();
  }

  @override
  void editItem(KitItem item) {
    _items = _items.map((KitItem k) => k.id == item.id ? item : k).toList();
    notifyListeners();
  }

  @override
  void upsertItem(KitItem item) {
    final int index = _items.indexWhere((KitItem k) => k.id == item.id);
    if (index >= 0) {
      editItem(item);
    } else {
      addItem(item);
    }
  }

  @override
  void deleteItem(KitItem item) {
    _items = _items.where((KitItem k) => k.id != item.id).toList();
    notifyListeners();
  }

  @override
  KitItem? getItemById(String id) {
    try {
      return _items.firstWhere((KitItem k) => k.id == id);
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
  List<KitItem> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final String query = _searchQuery.toLowerCase();
    return _items.where((KitItem k) => k.itemName.toLowerCase().contains(query)).toList();
  }
}
