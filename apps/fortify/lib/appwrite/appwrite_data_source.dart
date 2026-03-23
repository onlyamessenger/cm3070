import 'package:appwrite/appwrite.dart';
import 'package:core/core.dart';

import 'package:fortify/appwrite/mappers/mapper.dart';

/// Client-side AppWrite data source using the Flutter/client SDK.
abstract class AppWriteDataSource<T extends ModelBase> implements DataSource<T> {
  final Databases databases;
  final String databaseId;
  final String collectionId;
  final Mapper<T> mapper;

  AppWriteDataSource({
    required this.databases,
    required this.databaseId,
    required this.collectionId,
    required this.mapper,
  });

  @override
  Future<String> generateId() async {
    return ID.unique();
  }

  @override
  Future<T> createItem(T item) async {
    final doc = await databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: item.id.isEmpty ? ID.unique() : item.id,
      data: mapper.toMap(item),
    );
    return mapper.fromMap(doc.data);
  }

  @override
  Future<List<T>> createItems(List<T> items) async {
    final List<T> results = <T>[];
    for (final T item in items) {
      results.add(await createItem(item));
    }
    return results;
  }

  @override
  Future<T> readItem(String id) async {
    final doc = await databases.getDocument(databaseId: databaseId, collectionId: collectionId, documentId: id);
    return mapper.fromMap(doc.data);
  }

  @override
  Future<List<T>> readItems() async {
    final result = await databases.listDocuments(databaseId: databaseId, collectionId: collectionId);
    return result.documents.map((doc) => mapper.fromMap(doc.data)).toList();
  }

  @override
  Future<List<T>> readItemsWhere(String field, String value) async {
    final result = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: <String>[Query.equal(field, value), Query.limit(100)],
    );
    return result.documents.map((doc) => mapper.fromMap(doc.data)).toList();
  }

  @override
  Future<T> updateItem(T item) async {
    final doc = await databases.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: item.id,
      data: mapper.toMap(item),
    );
    return mapper.fromMap(doc.data);
  }

  @override
  Future<List<T>> updateItems(List<T> items) async {
    final List<T> results = <T>[];
    for (final T item in items) {
      results.add(await updateItem(item));
    }
    return results;
  }

  @override
  Future<T> deleteItem(T item) async {
    await databases.deleteDocument(databaseId: databaseId, collectionId: collectionId, documentId: item.id);
    return item;
  }
}
