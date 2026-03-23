import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dotenv/dotenv.dart';

import '../lib/migrations/add_description_to_levels_and_kit_items.dart';

void main() async {
  final DotEnv env = DotEnv(includePlatformEnvironment: true)..load();

  final String? endpoint = env['APPWRITE_ENDPOINT'];
  final String? projectId = env['APPWRITE_PROJECT_ID'];
  final String? apiKey = env['APPWRITE_API_KEY'];
  final String? databaseId = env['APPWRITE_DATABASE_ID'];

  if (endpoint == null || projectId == null || apiKey == null || databaseId == null) {
    stderr.writeln('Missing required environment variables.');
    exit(1);
  }

  final Client client = Client().setEndpoint(endpoint).setProject(projectId).setKey(apiKey);
  final Databases databases = Databases(client);

  stdout.writeln('Running migration: add description to levels and kit_items...');
  await migrate(databases, databaseId);
  stdout.writeln('Migration complete.');
}
