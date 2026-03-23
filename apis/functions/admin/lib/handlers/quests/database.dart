import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:infrastructure/infrastructure.dart';

Future<List<Map<String, dynamic>>> fetchExistingQuests(AppWriteClient appwrite) async {
  final DocumentList result = await appwrite.databases.listDocuments(
    databaseId: appwrite.databaseId,
    collectionId: 'quests',
    queries: <String>[Query.limit(5000)],
  );

  return result.documents.map((Document doc) {
    return <String, dynamic>{
      'title': doc.data['title'],
      'description': doc.data['description'],
      'difficulty': doc.data['difficulty'],
      'disasterType': doc.data['disasterType'],
      'region': doc.data['region'],
      'totalDays': doc.data['totalDays'],
    };
  }).toList();
}

Future<List<String>> fetchAlreadyUnlockedSections(AppWriteClient appwrite) async {
  final DocumentList result = await appwrite.databases.listDocuments(
    databaseId: appwrite.databaseId,
    collectionId: 'quest_nodes',
    queries: <String>[Query.isNotNull('unlocksSectionType'), Query.limit(5000)],
  );

  final Set<String> sections = <String>{};
  for (final Document doc in result.documents) {
    final String? section = doc.data['unlocksSectionType'] as String?;
    if (section != null && section.isNotEmpty) {
      sections.add(section);
    }
  }
  return sections.toList();
}

Future<List<Map<String, dynamic>>> writeGeneratedQuests(
  AppWriteClient appwrite,
  List<Map<String, dynamic>> quests,
  String userId,
) async {
  final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];

  for (final Map<String, dynamic> quest in quests) {
    try {
      // Step 1: Create quest with empty startNodeId placeholder
      final Document questDoc = await appwrite.databases.createDocument(
        databaseId: appwrite.databaseId,
        collectionId: 'quests',
        documentId: ID.unique(),
        data: <String, dynamic>{
          'title': quest['title'],
          'description': quest['description'],
          'totalDays': quest['totalDays'],
          'startNodeId': '',
          'difficulty': quest['difficulty'],
          'disasterType': quest['disasterType'],
          'region': quest['region'],
          'source': 'llm',
          'isPublished': false,
          'createdBy': userId,
          'updatedBy': userId,
          'isDeleted': false,
        },
      );

      final List<dynamic> nodes = quest['nodes'] as List<dynamic>? ?? <dynamic>[];
      final String tempStartNodeId = quest['startNodeId'] as String;

      // Step 2: Pre-generate real AppWrite IDs for all nodes
      final Map<String, String> tempToReal = <String, String>{};
      for (final dynamic n in nodes) {
        final String tempId = (n as Map<String, dynamic>)['id'] as String;
        tempToReal[tempId] = ID.unique();
      }

      // Step 3: Resolve startNodeId
      final String realStartNodeId = tempToReal[tempStartNodeId] ?? '';

      // Step 4: Write all nodes in parallel with resolved IDs
      final List<Future<void>> nodeFutures = nodes.map((dynamic n) async {
        final Map<String, dynamic> node = n as Map<String, dynamic>;
        final String tempId = node['id'] as String;
        final String realId = tempToReal[tempId]!;

        // Resolve choices' nextNodeIds
        final List<dynamic> rawChoices = node['choices'] as List<dynamic>? ?? <dynamic>[];
        final List<Map<String, dynamic>> resolvedChoices = rawChoices.map((dynamic c) {
          final Map<String, dynamic> choice = c as Map<String, dynamic>;
          final String tempNextId = choice['nextNodeId'] as String;
          return <String, dynamic>{
            'label': choice['label'],
            'nextNodeId': tempToReal[tempNextId] ?? tempNextId,
            'xpReward': choice['xpReward'],
          };
        }).toList();

        await appwrite.databases.createDocument(
          databaseId: appwrite.databaseId,
          collectionId: 'quest_nodes',
          documentId: realId,
          data: <String, dynamic>{
            'questId': questDoc.$id,
            'day': node['day'],
            'text': node['text'],
            'isOutcome': node['isOutcome'],
            'xpReward': node['xpReward'],
            'summary': node['summary'],
            'choices': jsonEncode(resolvedChoices),
            'unlocksSectionType': node['unlocksSectionType'],
            'createdBy': userId,
            'updatedBy': userId,
            'isDeleted': false,
          },
        );
      }).toList();

      await Future.wait(nodeFutures);

      // Step 5: Patch the quest with the real startNodeId
      await appwrite.databases.updateDocument(
        databaseId: appwrite.databaseId,
        collectionId: 'quests',
        documentId: questDoc.$id,
        data: <String, dynamic>{'startNodeId': realStartNodeId},
      );

      results.add(<String, dynamic>{
        'id': questDoc.$id,
        'title': questDoc.data['title'],
        'difficulty': questDoc.data['difficulty'],
        'disasterType': questDoc.data['disasterType'],
        'region': questDoc.data['region'],
        'totalDays': questDoc.data['totalDays'],
        'nodeCount': nodes.length,
      });
    } catch (e) {
      print('Error writing quest: $e');
    }
  }

  return results;
}
