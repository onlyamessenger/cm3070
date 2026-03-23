import 'dart:collection';

import 'package:core/models/models.dart';

abstract class CrudState<T extends ModelBase> {
  UnmodifiableListView<T> get items;
  T? get item;
  bool get loading;
  void addItem(T item);
  void editItem(T item);
  void upsertItem(T item);
  void deleteItem(T item);
  void setItems(List<T> items);
  void setLoading(bool loading);
  T? getItemById(String id);
  void setItem(T item);
  void clearItem();
}
