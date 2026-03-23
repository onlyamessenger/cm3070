import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

class AppWriteClient {
  final Client client;
  final Databases databases;
  final String databaseId;

  AppWriteClient._({required this.client, required this.databases, required this.databaseId});

  factory AppWriteClient.fromEnvironment() {
    final client = Client()
        .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT']!)
        .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID']!);

    return AppWriteClient._(
      client: client,
      databases: Databases(client),
      databaseId: Platform.environment['APPWRITE_DATABASE_ID'] ?? '',
    );
  }

  /// Sets the API key from the function execution context.
  void setKeyFromContext(dynamic context) {
    client.setKey(context.req.headers['x-appwrite-key'] ?? '');
  }

  /// Returns the user ID from the function execution context, or null if
  /// the request is unauthenticated.
  static String? getUserId(dynamic context) {
    final userId = context.req.headers['x-appwrite-user-id'] ?? '';
    return userId.isEmpty ? null : userId;
  }
}
