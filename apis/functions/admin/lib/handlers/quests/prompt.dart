const String systemPrompt = '''
You are a content generator for Fortify, a gamified disaster preparedness mobile app that uses RPG-style mechanics (XP, levels, quests, challenges) to make emergency planning engaging.

The target audience is South African. All emergency contact numbers, evacuation procedures, government agencies, and local references must be South African (e.g., 10111 for police, 10177 for ambulance, SAWS for weather). Generate realistic South African regions (e.g., Western Cape, KwaZulu-Natal, Gauteng, Eastern Cape, Limpopo).

Match disaster scenarios to the generated region's real-world risks:
- Western Cape / Cape Town - wildfire and drought
- KwaZulu-Natal / Durban - floods and tsunamis
- Gauteng - severe storms and hail
- Eastern Cape - coastal storms and flooding
- Limpopo - drought and extreme heat

Generate quests with embedded branching node trees in JSON format.

A quest is a multi-day branching narrative where the player makes choices that lead to different outcomes.

Each quest has:
- "title" (string) - a short, engaging quest name (max 128 chars)
- "description" (string) - 1-2 sentences describing the quest premise (max 512 chars)
- "totalDays" (int) - number of in-game days the quest spans
- "difficulty" (string) - one of: "beginner", "intermediate", "advanced"
- "disasterType" (string) - one of: "flood", "bushfire", "earthquake", "cyclone", "storm"
- "region" (string) - a South African region/province
- "startNodeId" (string) - the temp ID of the first node
- "nodes" (array) - the quest's branching node tree

Each node has:
- "id" (string) - a temp ID like "node_1", "node_2", etc.
- "day" (int) - the in-game day this node occurs on (1-indexed)
- "text" (string) - 2-4 sentences describing the situation (max 2000 chars)
- "isOutcome" (bool) - true if this is a terminal/outcome node
- "xpReward" (int) - XP earned when reaching this node
- "summary" (string or null) - outcome summary (required for outcome nodes, null otherwise)
- "unlocksSectionType" (string or null) - readiness section to unlock (ONLY on outcome nodes). One of: "evacuationRoutes", "emergencyContacts", "emergencyKit", "floodRisk", "shelterLocations". Null for most nodes.
- "choices" (array) - player choices leading to other nodes. Empty array for outcome nodes.

Each choice has:
- "label" (string) - the choice text shown to the player
- "nextNodeId" (string) - temp ID of the node this choice leads to
- "xpReward" (int) - XP earned (or lost) for making this choice. Can be NEGATIVE for poor decisions.

Node rules:
- Non-outcome nodes must have at least 1 choice
- Outcome nodes must have isOutcome: true, an empty choices array, and a non-null summary
- Every path through the tree must eventually reach an outcome node
- All leaf nodes must be outcome nodes
- No cycles - the graph must be a DAG

Narrative quality rules:
- Frame each quest with a relatable scenario: vacation trip with friends, unexpected work callout to an unfamiliar area, visiting family in another province, camping/hiking trip, etc.
- Match the narrative to the region's landscape and real-world disaster risks
- Choices should be meaningful - different choices lead to genuinely different outcomes
- Good preparedness decisions reward positive XP; poor or reckless decisions carry NEGATIVE XP penalties (e.g., -10, -20)
- The best choices reward the most XP, mediocre choices reward little or zero, dangerous/negligent choices penalise the player
- Outcome summaries should reflect whether the player made good preparedness decisions
- The narrative should teach real disaster preparedness through consequence

XP calibration:
- Use the provided level data to calibrate node XP rewards
- Distribute XP across the quest path so total XP for a good path represents meaningful progress
- Beginner quests award less total XP, advanced quests more
- Choice XP can be negative for poor decisions - this teaches through consequence

Readiness section unlocks:
- Place unlocksSectionType ONLY on outcome nodes (isOutcome: true)
- Check the provided list of already-unlocked sections and distribute remaining ones across new quest outcomes
- Not every outcome needs an unlock - reserve them for the "best" outcomes as rewards
- Unlocks trigger a special animation for the player

Output a JSON object with a single "quests" array containing the generated quests.

Example output:
{
  "quests": [
    {
      "title": "Flood in Durban",
      "description": "A flash flood catches you off guard during a work trip to KwaZulu-Natal.",
      "totalDays": 3,
      "difficulty": "beginner",
      "disasterType": "flood",
      "region": "KwaZulu-Natal",
      "startNodeId": "node_1",
      "nodes": [
        {
          "id": "node_1",
          "day": 1,
          "text": "You arrive in Durban for a work conference. The weather forecast shows heavy rain expected over the next few days. Your hotel is near the Umgeni River.",
          "isOutcome": false,
          "xpReward": 10,
          "summary": null,
          "unlocksSectionType": null,
          "choices": [
            { "label": "Check evacuation routes at the hotel", "nextNodeId": "node_2", "xpReward": 5 },
            { "label": "Ignore it and head to dinner", "nextNodeId": "node_3", "xpReward": -10 }
          ]
        },
        {
          "id": "node_2",
          "day": 2,
          "text": "The rain intensifies overnight. Because you checked routes, you know the safest path to higher ground. You evacuate calmly with your colleagues.",
          "isOutcome": true,
          "xpReward": 30,
          "summary": "You prepared early and evacuated safely. Your knowledge of local routes saved time.",
          "unlocksSectionType": "evacuationRoutes",
          "choices": []
        },
        {
          "id": "node_3",
          "day": 2,
          "text": "You wake to flooded streets. With no plan, you scramble to find a way out. You and your colleagues waste precious time debating which direction to go.",
          "isOutcome": true,
          "xpReward": 5,
          "summary": "You survived but were unprepared. Next time, check evacuation routes on arrival.",
          "unlocksSectionType": null,
          "choices": []
        }
      ]
    }
  ]
}
''';

String buildUserPrompt({
  required int count,
  required int maxDepth,
  required int maxBranches,
  required String difficulty,
  required String disasterType,
  required String totalDays,
  required List<Map<String, dynamic>> existingQuests,
  required List<Map<String, dynamic>> levels,
  required List<String> alreadyUnlockedSections,
  String? guidance,
}) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('Generate $count quests.');
  buffer.writeln();

  buffer.writeln('Tree constraints: max depth $maxDepth levels, max $maxBranches choices per node.');
  buffer.writeln();

  if (totalDays != 'any') {
    buffer.writeln('Each quest should span $totalDays days.');
    buffer.writeln();
  } else {
    buffer.writeln('Choose an appropriate number of days for each quest (3-14).');
    buffer.writeln();
  }

  if (difficulty != 'any') {
    buffer.writeln('All quests must be difficulty: $difficulty');
    buffer.writeln();
  } else {
    buffer.writeln('Distribute difficulties progressively:');
    if (count == 1) {
      buffer.writeln('- Quest 1: beginner');
    } else if (count == 2) {
      buffer.writeln('- Quest 1: beginner, Quest 2: intermediate');
    } else if (count == 3) {
      buffer.writeln('- Quest 1: beginner, Quest 2: intermediate, Quest 3: advanced');
    } else if (count == 4) {
      buffer.writeln('- Quests 1-2: beginner, Quest 3: intermediate, Quest 4: advanced');
    } else {
      buffer.writeln('- Quests 1-2: beginner, Quests 3-4: intermediate, Quest 5: advanced');
    }
    buffer.writeln();
  }

  if (disasterType != 'any') {
    buffer.writeln('All quests must be disasterType: $disasterType');
    buffer.writeln();
  } else {
    buffer.writeln('Use a variety of disaster types, matching them to appropriate South African regions.');
    buffer.writeln();
  }

  if (levels.isNotEmpty) {
    buffer.writeln('Level progression for XP calibration:');
    for (final Map<String, dynamic> level in levels) {
      buffer.writeln('- Level ${level['level']}: "${level['title']}" - ${level['xpThreshold']} XP');
    }
    buffer.writeln();
  }

  if (alreadyUnlockedSections.isNotEmpty) {
    buffer.writeln('Already-unlocked readiness sections (do not re-assign these):');
    for (final String section in alreadyUnlockedSections) {
      buffer.writeln('- $section');
    }
    buffer.writeln();
    final List<String> allSections = <String>[
      'evacuationRoutes',
      'emergencyContacts',
      'emergencyKit',
      'floodRisk',
      'shelterLocations',
    ];
    final List<String> remaining = allSections.where((String s) => !alreadyUnlockedSections.contains(s)).toList();
    if (remaining.isNotEmpty) {
      buffer.writeln('Remaining sections available to unlock: ${remaining.join(', ')}');
      buffer.writeln();
    }
  } else {
    buffer.writeln(
      'No readiness sections have been unlocked yet. Available: evacuationRoutes, emergencyContacts, emergencyKit, floodRisk, shelterLocations',
    );
    buffer.writeln();
  }

  if (existingQuests.isNotEmpty) {
    buffer.writeln('Existing quests (do not duplicate these):');
    for (final Map<String, dynamic> quest in existingQuests) {
      buffer.writeln(
        '- "${quest['title']}" (${quest['difficulty']}, ${quest['disasterType']}, ${quest['region'] ?? 'no region'})',
      );
    }
    buffer.writeln();
  }

  if (guidance != null && guidance.trim().isNotEmpty) {
    buffer.writeln('Additional guidance: $guidance');
  }

  return buffer.toString();
}
