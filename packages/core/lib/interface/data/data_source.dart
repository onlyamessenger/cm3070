import 'package:core/models/models.dart';

abstract class DataSource<T extends ModelBase> {
  Future<String> generateId();
  Future<T> createItem(T item);
  Future<List<T>> createItems(List<T> items);
  Future<T> updateItem(T item);
  Future<List<T>> updateItems(List<T> items);
  Future<T> deleteItem(T item);
  Future<T> readItem(String id);
  Future<List<T>> readItems();
  Future<List<T>> readItemsWhere(String field, String value);
}
