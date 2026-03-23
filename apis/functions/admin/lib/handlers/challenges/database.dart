import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:infrastructure/infrastructure.dart';

Future<List<Map<String, dynamic>>> fetchExistingChallenges(AppWriteClient appwrite) async {
  final DocumentList result = await appwrite.databases.listDocuments(
    databaseId: appwrite.databaseId,
    collectionId: 'challenges',
    queries: <String>[Query.limit(5000)],
  );

  return result.documents.map((Document doc) {
    return <String, dynamic>{
      'title': doc.data['title'],
      'type': doc.data['type'],
      'difficulty': doc.data['difficulty'],
      'disasterType': doc.data['disasterType'],
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> fetchQuestsByIds(AppWriteClient appwrite, List<String> questIds) async {
  if (questIds.isEmpty) return <Map<String, dynamic>>[];

  final DocumentList result = await appwrite.databases.listDocuments(
    databaseId: appwrite.databaseId,
    collectionId: 'quests',
    queries: <String>[Query.equal('\$id', questIds), Query.limit(questIds.length)],
  );

  return result.documents.map((Document doc) {
    return <String, dynamic>{
      'id': doc.$id,
      'title': doc.data['title'],
      'description': doc.data['description'],
      'disasterType': doc.data['disasterType'],
      'difficulty': doc.data['difficulty'],
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> writeGeneratedChallenges(
  AppWriteClient appwrite,
  List<Map<String, dynamic>> challenges,
  String userId,
  Set<String> validQuestIds,
) async {
  final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];

  final List<Future<void>> futures = challenges.map((Map<String, dynamic> challenge) async {
    try {
      // Validate questId against input
      final String? rawQuestId = challenge['questId'] as String?;
      final String? questId = (rawQuestId != null && validQuestIds.contains(rawQuestId)) ? rawQuestId : null;

      // Create the challenge document
      final Document doc = await appwrite.databases.createDocument(
        databaseId: appwrite.databaseId,
        collectionId: 'challenges',
        documentId: ID.unique(),
        data: <String, dynamic>{
          'title': challenge['title'],
          'description': challenge['description'],
          'type': challenge['type'],
          'difficulty': challenge['difficulty'],
          'disasterType': challenge['disasterType'],
          'xpReward': challenge['xpReward'],
          'questId': questId,
          'unlocksSectionType': null,
          'source': 'llm',
          'isPublished': false,
          'createdBy': userId,
          'updatedBy': userId,
          'isDeleted': false,
        },
      );

      // Create questions in parallel
      final List<dynamic> questions = challenge['questions'] as List<dynamic>? ?? <dynamic>[];
      final List<Future<void>> questionFutures = questions.map((dynamic q) async {
        final Map<String, dynamic> question = q as Map<String, dynamic>;
        final List<String> options = (question['options'] as List<dynamic>).cast<String>();

        await appwrite.databases.createDocument(
          databaseId: appwrite.databaseId,
          collectionId: 'challenge_questions',
          documentId: ID.unique(),
          data: <String, dynamic>{
            'challengeId': doc.$id,
            'sortOrder': question['sortOrder'],
            'questionText': question['questionText'],
            'options': jsonEncode(options),
            'correctIndex': question['correctIndex'],
            'createdBy': userId,
            'updatedBy': userId,
            'isDeleted': false,
          },
        );
      }).toList();

      await Future.wait(questionFutures);

      results.add(<String, dynamic>{
        'id': doc.$id,
        'title': doc.data['title'],
        'type': doc.data['type'],
        'difficulty': doc.data['difficulty'],
        'disasterType': doc.data['disasterType'],
        'xpReward': doc.data['xpReward'],
        'questId': questId,
        'questionCount': questions.length,
      });
    } catch (e) {
      // Log but don't fail the entire batch - partial results are safe
      // since all content requires admin review (isPublished: false)
      print('Error writing challenge: $e');
    }
  }).toList();

  await Future.wait(futures);
  return results;
}
