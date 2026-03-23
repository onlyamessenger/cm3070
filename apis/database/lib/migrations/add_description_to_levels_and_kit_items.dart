import 'package:dart_appwrite/dart_appwrite.dart';

/// Adds a `description` string attribute to the `levels` and `kit_items` collections.
///
/// Run from the database project directory:
///   dart run lib/migrations/add_description_to_levels_and_kit_items.dart
Future<void> migrate(Databases databases, String databaseId) async {
  const List<String> collections = <String>['levels', 'kit_items'];

  for (final String collectionId in collections) {
    try {
      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: 'description',
        size: 1024,
        xrequired: false,
        xdefault: '',
      );
      print('  Added description to $collectionId');
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        print('  description already exists on $collectionId, skipping');
      } else {
        rethrow;
      }
    }
  }
}
