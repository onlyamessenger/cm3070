import 'package:test/test.dart';
import 'package:admin/handlers/levels/prompt.dart' as levels;
import 'package:admin/handlers/challenges/prompt.dart' as challenges;
import 'package:admin/handlers/quests/prompt.dart' as quests;
import 'package:admin/handlers/kit_items/prompt.dart' as kit_items;
import 'package:admin/handlers/bonus_events/prompt.dart' as bonus_events;

void main() {
  // ---------------------------------------------------------------------------
  // Levels
  // ---------------------------------------------------------------------------
  group('levels.buildUserPrompt', () {
    test('systemPrompt is non-empty', () {
      expect(levels.systemPrompt.isNotEmpty, isTrue);
    });

    test('contains count in output', () {
      final String result = levels.buildUserPrompt(5, [], null);
      expect(result, contains('Generate 5 new levels'));
    });

    test('empty list emits start-from-level-1 message', () {
      final String result = levels.buildUserPrompt(3, [], null);
      expect(result, contains('No existing levels. Start from level 1'));
    });

    test('existing levels are listed with number, title, icon, and xpThreshold', () {
      final List<Map<String, dynamic>> existingLevels = <Map<String, dynamic>>[
        <String, dynamic>{'level': 1, 'title': 'Potential Casualty', 'icon': '🌱', 'xpThreshold': 0},
        <String, dynamic>{'level': 2, 'title': 'Storm Chaser', 'icon': '⛈️', 'xpThreshold': 100},
      ];
      final String result = levels.buildUserPrompt(2, existingLevels, null);
      expect(result, contains('Level 1'));
      expect(result, contains('Potential Casualty'));
      expect(result, contains('🌱'));
      expect(result, contains('0 XP'));
    });

    test('guidance is included when non-empty', () {
      final String result = levels.buildUserPrompt(1, [], 'Focus on natural disasters');
      expect(result, contains('Additional guidance: Focus on natural disasters'));
    });

    test('guidance is omitted when null or whitespace', () {
      final String nullGuidance = levels.buildUserPrompt(1, [], null);
      final String whitespaceGuidance = levels.buildUserPrompt(1, [], '   ');
      expect(nullGuidance, isNot(contains('Additional guidance')));
      expect(whitespaceGuidance, isNot(contains('Additional guidance')));
    });
  });

  // ---------------------------------------------------------------------------
  // Kit Items
  // ---------------------------------------------------------------------------
  group('kit_items.buildUserPrompt', () {
    test('contains count in output', () {
      final String result = kit_items.buildUserPrompt(4, [], null);
      expect(result, contains('Generate 4 new emergency kit items'));
    });

    test('empty list emits start-from-sortOrder-1 message', () {
      final String result = kit_items.buildUserPrompt(2, [], null);
      expect(result, contains('No existing kit items. Start from sortOrder 1'));
    });

    test('existing items are listed with itemName and sortOrder', () {
      final List<Map<String, dynamic>> existingItems = <Map<String, dynamic>>[
        <String, dynamic>{'itemName': 'First Aid Kit', 'sortOrder': 1},
        <String, dynamic>{'itemName': 'Flashlight', 'sortOrder': 2},
      ];
      final String result = kit_items.buildUserPrompt(3, existingItems, null);
      expect(result, contains('First Aid Kit'));
      expect(result, contains('sort order: 1'));
      expect(result, contains('Flashlight'));
    });

    test('guidance is included when non-empty', () {
      final String result = kit_items.buildUserPrompt(1, [], 'Include water purification');
      expect(result, contains('Additional guidance: Include water purification'));
    });

    test('guidance is omitted when null or whitespace', () {
      final String nullGuidance = kit_items.buildUserPrompt(1, [], null);
      final String whitespaceGuidance = kit_items.buildUserPrompt(1, [], '  ');
      expect(nullGuidance, isNot(contains('Additional guidance')));
      expect(whitespaceGuidance, isNot(contains('Additional guidance')));
    });
  });

  // ---------------------------------------------------------------------------
  // Bonus Events
  // ---------------------------------------------------------------------------
  group('bonus_events.buildUserPrompt', () {
    test('contains count and today\'s date', () {
      final String today = DateTime.now().toIso8601String().substring(0, 10);
      final String result = bonus_events.buildUserPrompt(3, [], null);
      expect(result, contains('Generate 3 new bonus events'));
      expect(result, contains(today));
    });

    test('empty list emits no-existing-events message', () {
      final String result = bonus_events.buildUserPrompt(2, [], null);
      expect(result, contains('No existing bonus events'));
    });

    test('existing events are listed with title, multiplier, dates, and description', () {
      final List<Map<String, dynamic>> existingEvents = <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Storm Season Sprint',
          'multiplier': 2.0,
          'startsAt': '2026-06-01T00:00:00.000',
          'endsAt': '2026-06-14T23:59:59.000',
          'description': 'Hurricane season is approaching!',
        },
      ];
      final String result = bonus_events.buildUserPrompt(2, existingEvents, null);
      expect(result, contains('Storm Season Sprint'));
      expect(result, contains('2.0x'));
      expect(result, contains('2026-06-01T00:00:00.000'));
      expect(result, contains('2026-06-14T23:59:59.000'));
      expect(result, contains('Hurricane season is approaching!'));
    });

    test('guidance is included when non-empty', () {
      final String result = bonus_events.buildUserPrompt(1, [], 'Focus on fire season');
      expect(result, contains('Additional guidance: Focus on fire season'));
    });

    test('guidance is omitted when null or whitespace', () {
      final String nullGuidance = bonus_events.buildUserPrompt(1, [], null);
      final String whitespaceGuidance = bonus_events.buildUserPrompt(1, [], '\t ');
      expect(nullGuidance, isNot(contains('Additional guidance')));
      expect(whitespaceGuidance, isNot(contains('Additional guidance')));
    });
  });

  // ---------------------------------------------------------------------------
  // Challenges
  // ---------------------------------------------------------------------------
  group('challenges.buildUserPrompt', () {
    final List<Map<String, dynamic>> sampleLevels = <Map<String, dynamic>>[
      <String, dynamic>{'level': 1, 'title': 'Potential Casualty', 'xpThreshold': 0},
      <String, dynamic>{'level': 2, 'title': 'Storm Chaser', 'xpThreshold': 100},
    ];

    test('standalone (no quests) uses null-questId language', () {
      final String result = challenges.buildUserPrompt(
        count: 3,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        quests: null,
        guidance: null,
      );
      expect(result, contains('standalone challenges (questId should be null)'));
    });

    test('with quests: uses PER QUEST language and lists quest details', () {
      final List<Map<String, dynamic>> questList = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'q1',
          'title': 'Flood in Durban',
          'disasterType': 'flood',
          'difficulty': 'beginner',
          'description': 'A flash flood catches you off guard.',
        },
      ];
      final String result = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        quests: questList,
        guidance: null,
      );
      expect(result, contains('Generate 2 challenges PER QUEST'));
      expect(result, contains('Flood in Durban'));
      expect(result, contains('q1'));
    });

    test('questionsPerChallenge value appears in output', () {
      final String result = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 7,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: null,
      );
      expect(result, contains('exactly 7 questions'));
    });

    test('fewer than 4 challenge types emits restriction', () {
      final String result = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'timed'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: null,
      );
      expect(result, contains('Only generate these challenge types'));
      expect(result, contains('quiz, timed'));
    });

    test('all 4 challenge types does NOT emit restriction', () {
      final String result = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: null,
      );
      expect(result, isNot(contains('Only generate')));
    });

    test('specific difficulty emits constraint; "any" emits mix message', () {
      final String specific = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'beginner',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: null,
      );
      expect(specific, contains('All challenges must be difficulty: beginner'));

      final String any = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: null,
      );
      expect(any, contains('mix of difficulties'));
    });

    test('specific disasterType emits constraint; "any" with no quests emits variety message', () {
      final String specific = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'flood',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: null,
      );
      expect(specific, contains('All challenges must be disasterType: flood'));

      final String any = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        quests: null,
        guidance: null,
      );
      expect(any, contains('variety of disaster types'));
    });

    test('existing challenges and levels are listed', () {
      final List<Map<String, dynamic>> existing = <Map<String, dynamic>>[
        <String, dynamic>{'title': 'Flood Safety Basics', 'type': 'quiz', 'difficulty': 'beginner', 'disasterType': 'flood'},
      ];
      final String result = challenges.buildUserPrompt(
        count: 2,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: existing,
        levels: sampleLevels,
        guidance: null,
      );
      expect(result, contains('Flood Safety Basics'));
      expect(result, contains('Level 1'));
      expect(result, contains('Potential Casualty'));
    });

    test('guidance is included when non-empty and omitted when null', () {
      final String withGuidance = challenges.buildUserPrompt(
        count: 1,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: 'Emphasise water safety',
      );
      expect(withGuidance, contains('Additional guidance: Emphasise water safety'));

      final String noGuidance = challenges.buildUserPrompt(
        count: 1,
        questionsPerChallenge: 5,
        challengeTypes: <String>['quiz', 'decision', 'timed', 'checklist'],
        difficulty: 'any',
        disasterType: 'any',
        existingChallenges: <Map<String, dynamic>>[],
        levels: sampleLevels,
        guidance: null,
      );
      expect(noGuidance, isNot(contains('Additional guidance')));
    });
  });

  // ---------------------------------------------------------------------------
  // Quests
  // ---------------------------------------------------------------------------
  group('quests.buildUserPrompt', () {
    final List<Map<String, dynamic>> sampleLevels = <Map<String, dynamic>>[
      <String, dynamic>{'level': 1, 'title': 'Potential Casualty', 'xpThreshold': 0},
      <String, dynamic>{'level': 2, 'title': 'Storm Chaser', 'xpThreshold': 100},
    ];

    test('contains count and tree constraints', () {
      final String result = quests.buildUserPrompt(
        count: 3,
        maxDepth: 4,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(result, contains('Generate 3 quests'));
      expect(result, contains('max depth 4 levels, max 2 choices'));
    });

    test('specific totalDays emits span constraint; "any" emits appropriate-days message', () {
      final String specific = quests.buildUserPrompt(
        count: 1,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: '7',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(specific, contains('should span 7 days'));

      final String any = quests.buildUserPrompt(
        count: 1,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(any, contains('appropriate number of days'));
    });

    test('specific difficulty emits constraint; "any" emits progressive distribution', () {
      final String specific = quests.buildUserPrompt(
        count: 2,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'advanced',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(specific, contains('All quests must be difficulty'));

      final String any = quests.buildUserPrompt(
        count: 2,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(any, contains('Distribute difficulties progressively'));
    });

    test('specific disasterType emits constraint; "any" emits variety message', () {
      final String specific = quests.buildUserPrompt(
        count: 1,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'bushfire',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(specific, contains('All quests must be disasterType: bushfire'));

      final String any = quests.buildUserPrompt(
        count: 1,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(any, contains('variety of disaster types'));
    });

    test('no unlocked sections lists all 5 as available', () {
      final String result = quests.buildUserPrompt(
        count: 1,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(result, contains('evacuationRoutes'));
      expect(result, contains('emergencyContacts'));
      expect(result, contains('emergencyKit'));
      expect(result, contains('floodRisk'));
      expect(result, contains('shelterLocations'));
    });

    test('already-unlocked sections are listed and remaining computed', () {
      final List<String> unlocked = <String>['evacuationRoutes', 'emergencyKit'];
      final String result = quests.buildUserPrompt(
        count: 2,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: unlocked,
        guidance: null,
      );
      expect(result, contains('Already-unlocked readiness sections'));
      expect(result, contains('evacuationRoutes'));
      expect(result, contains('emergencyKit'));
      expect(result, contains('Remaining sections available to unlock'));
      expect(result, contains('emergencyContacts'));
      expect(result, contains('floodRisk'));
      expect(result, contains('shelterLocations'));
    });

    test('existing quests and levels are listed', () {
      final List<Map<String, dynamic>> existingQuests = <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Flood in Durban',
          'difficulty': 'beginner',
          'disasterType': 'flood',
          'region': 'KwaZulu-Natal',
        },
      ];
      final String result = quests.buildUserPrompt(
        count: 2,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: existingQuests,
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(result, contains('Flood in Durban'));
      expect(result, contains('KwaZulu-Natal'));
      expect(result, contains('Level 1'));
      expect(result, contains('Storm Chaser'));
    });

    test('guidance is included when non-empty and omitted when null', () {
      final String withGuidance = quests.buildUserPrompt(
        count: 1,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: 'Prioritise coastal scenarios',
      );
      expect(withGuidance, contains('Additional guidance: Prioritise coastal scenarios'));

      final String noGuidance = quests.buildUserPrompt(
        count: 1,
        maxDepth: 3,
        maxBranches: 2,
        difficulty: 'any',
        disasterType: 'any',
        totalDays: 'any',
        existingQuests: <Map<String, dynamic>>[],
        levels: sampleLevels,
        alreadyUnlockedSections: <String>[],
        guidance: null,
      );
      expect(noGuidance, isNot(contains('Additional guidance')));
    });
  });
}
