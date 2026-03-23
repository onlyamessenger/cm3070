import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortify/appwrite/mappers/mappers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> baseMap({String id = 'test-id'}) => <String, dynamic>{
      '\$id': id,
      '\$createdAt': '2026-01-01T00:00:00.000Z',
      '\$updatedAt': '2026-01-02T00:00:00.000Z',
      'createdBy': 'user-1',
      'updatedBy': 'user-1',
      'isDeleted': false,
    };

/// Merges [baseMap] with [extra] fields for fromMap calls.
Map<String, dynamic> withBase(
  Map<String, dynamic> extra, {
  String id = 'test-id',
}) =>
    <String, dynamic>{...baseMap(id: id), ...extra};

/// Re-adds the AppWrite built-in fields stripped by toMap so that a round-trip
/// fromMap call receives a complete map.
Map<String, dynamic> reattachBase(
  Map<String, dynamic> toMapResult, {
  String id = 'test-id',
}) =>
    <String, dynamic>{...baseMap(id: id), ...toMapResult};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // LevelMapper
  // -------------------------------------------------------------------------
  group('LevelMapper', () {
    final LevelMapper mapper = LevelMapper();

    final Map<String, dynamic> levelMap = withBase(<String, dynamic>{
      'source': 'human',
      'isPublished': true,
      'level': 3,
      'title': 'Novice Prepper',
      'description': 'You have begun your journey.',
      'icon': 'shield',
      'xpThreshold': 500,
    });

    test('fromMap produces correct Level fields', () {
      final Level level = mapper.fromMap(levelMap);

      expect(level.id, equals('test-id'));
      expect(level.created, equals(DateTime.parse('2026-01-01T00:00:00.000Z')));
      expect(level.updated, equals(DateTime.parse('2026-01-02T00:00:00.000Z')));
      expect(level.createdBy, equals('user-1'));
      expect(level.updatedBy, equals('user-1'));
      expect(level.isDeleted, isFalse);
      expect(level.source, equals(ContentSource.human));
      expect(level.isPublished, isTrue);
      expect(level.level, equals(3));
      expect(level.title, equals('Novice Prepper'));
      expect(level.description, equals('You have begun your journey.'));
      expect(level.icon, equals('shield'));
      expect(level.xpThreshold, equals(500));
    });

    test('toMap excludes \$id/\$createdAt/\$updatedAt and serialises enums', () {
      final Level level = mapper.fromMap(levelMap);
      final Map<String, dynamic> result = mapper.toMap(level);

      expect(result.containsKey('\$id'), isFalse);
      expect(result.containsKey('\$createdAt'), isFalse);
      expect(result.containsKey('\$updatedAt'), isFalse);
      expect(result['source'], equals('human'));
      expect(result['isPublished'], isTrue);
      expect(result['level'], equals(3));
      expect(result['title'], equals('Novice Prepper'));
      expect(result['xpThreshold'], equals(500));
    });

    test('round-trip fromMap(toMap(level)) preserves all fields', () {
      final Level original = mapper.fromMap(levelMap);
      final Level roundTripped = mapper.fromMap(reattachBase(mapper.toMap(original)));

      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.source, equals(original.source));
      expect(roundTripped.level, equals(original.level));
      expect(roundTripped.title, equals(original.title));
      expect(roundTripped.xpThreshold, equals(original.xpThreshold));
    });
  });

  // -------------------------------------------------------------------------
  // QuestMapper
  // -------------------------------------------------------------------------
  group('QuestMapper', () {
    final QuestMapper mapper = QuestMapper();

    final Map<String, dynamic> questMap = withBase(<String, dynamic>{
      'source': 'llm',
      'isPublished': false,
      'title': 'Flood Ready',
      'description': 'Prepare for flood events.',
      'totalDays': 7,
      'startNodeId': 'node-001',
      'difficulty': 'beginner',
      'disasterType': 'flood',
      'region': 'Queensland',
    });

    test('fromMap produces correct Quest fields', () {
      final Quest quest = mapper.fromMap(questMap);

      expect(quest.id, equals('test-id'));
      expect(quest.source, equals(ContentSource.llm));
      expect(quest.isPublished, isFalse);
      expect(quest.title, equals('Flood Ready'));
      expect(quest.totalDays, equals(7));
      expect(quest.startNodeId, equals('node-001'));
      expect(quest.difficulty, equals(Difficulty.beginner));
      expect(quest.disasterType, equals(DisasterType.flood));
      expect(quest.region, equals('Queensland'));
    });

    test('toMap excludes AppWrite built-ins and serialises enums', () {
      final Quest quest = mapper.fromMap(questMap);
      final Map<String, dynamic> result = mapper.toMap(quest);

      expect(result.containsKey('\$id'), isFalse);
      expect(result['source'], equals('llm'));
      expect(result['difficulty'], equals('beginner'));
      expect(result['disasterType'], equals('flood'));
      expect(result['region'], equals('Queensland'));
    });

    test('toMap with null region produces null region key', () {
      final Map<String, dynamic> noRegionMap = withBase(<String, dynamic>{
        'source': 'human',
        'isPublished': true,
        'title': 'Earthquake Basics',
        'description': 'Prepare for earthquakes.',
        'totalDays': 5,
        'startNodeId': 'node-eq-01',
        'difficulty': 'intermediate',
        'disasterType': 'earthquake',
        'region': null,
      });
      final Quest quest = mapper.fromMap(noRegionMap);
      final Map<String, dynamic> result = mapper.toMap(quest);

      expect(result['region'], isNull);
    });

    test('round-trip fromMap(toMap(quest)) preserves all fields', () {
      final Quest original = mapper.fromMap(questMap);
      final Quest roundTripped = mapper.fromMap(reattachBase(mapper.toMap(original)));

      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.title, equals(original.title));
      expect(roundTripped.difficulty, equals(original.difficulty));
      expect(roundTripped.disasterType, equals(original.disasterType));
      expect(roundTripped.region, equals(original.region));
    });
  });

  // -------------------------------------------------------------------------
  // ChallengeMapper
  // -------------------------------------------------------------------------
  group('ChallengeMapper', () {
    final ChallengeMapper mapper = ChallengeMapper();

    final Map<String, dynamic> challengeMap = withBase(<String, dynamic>{
      'source': 'human',
      'isPublished': true,
      'type': 'quiz',
      'title': 'Flood Awareness Quiz',
      'description': 'Test your flood knowledge.',
      'xpReward': 100,
      'difficulty': 'intermediate',
      'disasterType': 'flood',
      'questId': 'quest-001',
      'unlocksSectionType': 'water',
    });

    test('fromMap produces correct Challenge fields', () {
      final Challenge challenge = mapper.fromMap(challengeMap);

      expect(challenge.id, equals('test-id'));
      expect(challenge.source, equals(ContentSource.human));
      expect(challenge.type, equals(ChallengeType.quiz));
      expect(challenge.title, equals('Flood Awareness Quiz'));
      expect(challenge.xpReward, equals(100));
      expect(challenge.difficulty, equals(Difficulty.intermediate));
      expect(challenge.disasterType, equals(DisasterType.flood));
      expect(challenge.questId, equals('quest-001'));
      expect(challenge.unlocksSectionType, equals('water'));
    });

    test('toMap excludes AppWrite built-ins and serialises enums', () {
      final Challenge challenge = mapper.fromMap(challengeMap);
      final Map<String, dynamic> result = mapper.toMap(challenge);

      expect(result.containsKey('\$id'), isFalse);
      expect(result['type'], equals('quiz'));
      expect(result['difficulty'], equals('intermediate'));
      expect(result['disasterType'], equals('flood'));
    });

    test('toMap with null optional fields keeps null values', () {
      final Map<String, dynamic> minimalMap = withBase(<String, dynamic>{
        'source': 'llm',
        'isPublished': false,
        'type': 'checklist',
        'title': 'Kit Check',
        'description': 'Build your kit.',
        'xpReward': 50,
        'difficulty': 'beginner',
        'disasterType': 'storm',
        'questId': null,
        'unlocksSectionType': null,
      });
      final Challenge challenge = mapper.fromMap(minimalMap);
      final Map<String, dynamic> result = mapper.toMap(challenge);

      expect(result['questId'], isNull);
      expect(result['unlocksSectionType'], isNull);
    });

    test('round-trip fromMap(toMap(challenge)) preserves all fields', () {
      final Challenge original = mapper.fromMap(challengeMap);
      final Challenge roundTripped = mapper.fromMap(reattachBase(mapper.toMap(original)));

      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.type, equals(original.type));
      expect(roundTripped.xpReward, equals(original.xpReward));
      expect(roundTripped.questId, equals(original.questId));
    });
  });

  // -------------------------------------------------------------------------
  // QuestNodeMapper
  // -------------------------------------------------------------------------
  group('QuestNodeMapper', () {
    final QuestNodeMapper mapper = QuestNodeMapper();

    final List<Map<String, dynamic>> rawChoices = <Map<String, dynamic>>[
      <String, dynamic>{'label': 'Head north', 'nextNodeId': 'node-002', 'xpReward': 10},
      <String, dynamic>{'label': 'Stay put', 'nextNodeId': 'node-003', 'xpReward': 0},
    ];

    final Map<String, dynamic> nodeMap = withBase(<String, dynamic>{
      'questId': 'quest-001',
      'day': 1,
      'text': 'A flood warning has been issued.',
      'isOutcome': false,
      'xpReward': 20,
      'summary': 'Day 1 briefing',
      'choices': jsonEncode(rawChoices),
      'unlocksSectionType': null,
    });

    test('fromMap decodes choices JSON and populates QuestNode fields', () {
      final QuestNode node = mapper.fromMap(nodeMap);

      expect(node.id, equals('test-id'));
      expect(node.questId, equals('quest-001'));
      expect(node.day, equals(1));
      expect(node.text, equals('A flood warning has been issued.'));
      expect(node.isOutcome, isFalse);
      expect(node.xpReward, equals(20));
      expect(node.summary, equals('Day 1 briefing'));
      expect(node.choices.length, equals(2));
      expect(node.choices[0].label, equals('Head north'));
      expect(node.choices[0].nextNodeId, equals('node-002'));
      expect(node.choices[0].xpReward, equals(10));
      expect(node.choices[1].label, equals('Stay put'));
    });

    test('toMap encodes choices back to JSON string', () {
      final QuestNode node = mapper.fromMap(nodeMap);
      final Map<String, dynamic> result = mapper.toMap(node);

      expect(result.containsKey('\$id'), isFalse);
      expect(result['choices'], isA<String>());

      final List<dynamic> decoded = jsonDecode(result['choices'] as String) as List<dynamic>;
      expect(decoded.length, equals(2));
      expect((decoded[0] as Map<String, dynamic>)['label'], equals('Head north'));
    });

    test('round-trip fromMap(toMap(node)) preserves all fields', () {
      final QuestNode original = mapper.fromMap(nodeMap);
      final QuestNode roundTripped = mapper.fromMap(reattachBase(mapper.toMap(original)));

      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.questId, equals(original.questId));
      expect(roundTripped.day, equals(original.day));
      expect(roundTripped.choices.length, equals(original.choices.length));
      expect(roundTripped.choices[0].label, equals(original.choices[0].label));
      expect(roundTripped.choices[1].xpReward, equals(original.choices[1].xpReward));
    });
  });

  // -------------------------------------------------------------------------
  // ChallengeQuestionMapper
  // -------------------------------------------------------------------------
  group('ChallengeQuestionMapper', () {
    final ChallengeQuestionMapper mapper = ChallengeQuestionMapper();

    final List<String> rawOptions = <String>['72 hours', '24 hours', '1 week', '48 hours'];

    final Map<String, dynamic> questionMap = withBase(<String, dynamic>{
      'challengeId': 'challenge-001',
      'sortOrder': 1,
      'questionText': 'How many days of supplies should you have?',
      'options': jsonEncode(rawOptions),
      'correctIndex': 2,
    });

    test('fromMap decodes options JSON and populates ChallengeQuestion fields', () {
      final ChallengeQuestion question = mapper.fromMap(questionMap);

      expect(question.id, equals('test-id'));
      expect(question.challengeId, equals('challenge-001'));
      expect(question.sortOrder, equals(1));
      expect(question.questionText, equals('How many days of supplies should you have?'));
      expect(question.options.length, equals(4));
      expect(question.options[0], equals('72 hours'));
      expect(question.correctIndex, equals(2));
    });

    test('toMap encodes options back to JSON string', () {
      final ChallengeQuestion question = mapper.fromMap(questionMap);
      final Map<String, dynamic> result = mapper.toMap(question);

      expect(result.containsKey('\$id'), isFalse);
      expect(result['options'], isA<String>());

      final List<dynamic> decoded = jsonDecode(result['options'] as String) as List<dynamic>;
      expect(decoded.length, equals(4));
      expect(decoded[0], equals('72 hours'));
    });

    test('round-trip fromMap(toMap(question)) preserves all fields', () {
      final ChallengeQuestion original = mapper.fromMap(questionMap);
      final ChallengeQuestion roundTripped = mapper.fromMap(reattachBase(mapper.toMap(original)));

      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.challengeId, equals(original.challengeId));
      expect(roundTripped.sortOrder, equals(original.sortOrder));
      expect(roundTripped.options, equals(original.options));
      expect(roundTripped.correctIndex, equals(original.correctIndex));
    });
  });

  // -------------------------------------------------------------------------
  // KitItemMapper
  // -------------------------------------------------------------------------
  group('KitItemMapper', () {
    final KitItemMapper mapper = KitItemMapper();

    final Map<String, dynamic> kitItemMap = withBase(<String, dynamic>{
      'source': 'human',
      'isPublished': true,
      'userId': 'user-42',
      'itemName': 'Torch',
      'description': 'A battery-powered torch.',
      'sortOrder': 2,
      'isChecked': true,
      'checkedAt': '2026-03-01T12:00:00.000Z',
    });

    test('fromMap produces correct KitItem fields', () {
      final KitItem item = mapper.fromMap(kitItemMap);

      expect(item.id, equals('test-id'));
      expect(item.source, equals(ContentSource.human));
      expect(item.userId, equals('user-42'));
      expect(item.itemName, equals('Torch'));
      expect(item.description, equals('A battery-powered torch.'));
      expect(item.sortOrder, equals(2));
      expect(item.isChecked, isTrue);
      expect(item.checkedAt, equals(DateTime.parse('2026-03-01T12:00:00.000Z')));
    });

    test('toMap serialises checkedAt as ISO-8601 string', () {
      final KitItem item = mapper.fromMap(kitItemMap);
      final Map<String, dynamic> result = mapper.toMap(item);

      expect(result.containsKey('\$id'), isFalse);
      expect(result['checkedAt'], isA<String>());
      expect(DateTime.parse(result['checkedAt'] as String), equals(item.checkedAt));
    });

    test('toMap with null checkedAt produces null', () {
      final Map<String, dynamic> uncheckedMap = withBase(<String, dynamic>{
        'source': 'human',
        'isPublished': true,
        'userId': null,
        'itemName': 'Water',
        'description': '4 litres per person.',
        'sortOrder': 1,
        'isChecked': false,
        'checkedAt': null,
      });
      final KitItem item = mapper.fromMap(uncheckedMap);
      final Map<String, dynamic> result = mapper.toMap(item);

      expect(result['checkedAt'], isNull);
    });

    test('round-trip fromMap(toMap(item)) preserves all fields', () {
      final KitItem original = mapper.fromMap(kitItemMap);
      final KitItem roundTripped = mapper.fromMap(reattachBase(mapper.toMap(original)));

      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.itemName, equals(original.itemName));
      expect(roundTripped.sortOrder, equals(original.sortOrder));
      expect(roundTripped.isChecked, equals(original.isChecked));
      expect(roundTripped.checkedAt, equals(original.checkedAt));
    });
  });

  // -------------------------------------------------------------------------
  // BonusEventMapper
  // -------------------------------------------------------------------------
  group('BonusEventMapper', () {
    final BonusEventMapper mapper = BonusEventMapper();

    final Map<String, dynamic> bonusEventMap = withBase(<String, dynamic>{
      'title': 'Double XP Weekend',
      'description': 'Earn double XP on all challenges.',
      'multiplier': 2.0,
      'startsAt': '2026-04-01T00:00:00.000Z',
      'endsAt': '2026-04-03T00:00:00.000Z',
      'isActive': true,
    });

    test('fromMap produces correct BonusEvent fields', () {
      final BonusEvent event = mapper.fromMap(bonusEventMap);

      expect(event.id, equals('test-id'));
      expect(event.title, equals('Double XP Weekend'));
      expect(event.description, equals('Earn double XP on all challenges.'));
      expect(event.multiplier, closeTo(2.0, 0.0001));
      expect(event.startsAt, equals(DateTime.parse('2026-04-01T00:00:00.000Z')));
      expect(event.endsAt, equals(DateTime.parse('2026-04-03T00:00:00.000Z')));
      expect(event.isActive, isTrue);
    });

    test('fromMap coerces int multiplier to double', () {
      final Map<String, dynamic> intMultiplierMap = withBase(<String, dynamic>{
        'title': 'Triple XP',
        'description': 'Earn triple XP.',
        'multiplier': 3,
        'startsAt': '2026-05-01T00:00:00.000Z',
        'endsAt': '2026-05-02T00:00:00.000Z',
        'isActive': false,
      });
      final BonusEvent event = mapper.fromMap(intMultiplierMap);

      expect(event.multiplier, isA<double>());
      expect(event.multiplier, closeTo(3.0, 0.0001));
    });

    test('toMap serialises dates as ISO-8601 strings', () {
      final BonusEvent event = mapper.fromMap(bonusEventMap);
      final Map<String, dynamic> result = mapper.toMap(event);

      expect(result.containsKey('\$id'), isFalse);
      expect(result['startsAt'], isA<String>());
      expect(result['endsAt'], isA<String>());
      expect(DateTime.parse(result['startsAt'] as String), equals(event.startsAt));
      expect(DateTime.parse(result['endsAt'] as String), equals(event.endsAt));
    });

    test('round-trip fromMap(toMap(event)) preserves all fields', () {
      final BonusEvent original = mapper.fromMap(bonusEventMap);
      final BonusEvent roundTripped = mapper.fromMap(reattachBase(mapper.toMap(original)));

      expect(roundTripped.id, equals(original.id));
      expect(roundTripped.title, equals(original.title));
      expect(roundTripped.multiplier, closeTo(original.multiplier, 0.0001));
      expect(roundTripped.startsAt, equals(original.startsAt));
      expect(roundTripped.endsAt, equals(original.endsAt));
      expect(roundTripped.isActive, equals(original.isActive));
    });
  });
}
