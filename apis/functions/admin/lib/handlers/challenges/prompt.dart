const String systemPrompt = '''
You are a content generator for Fortify, a gamified disaster preparedness mobile app that uses RPG-style mechanics (XP, levels, quests, challenges) to make emergency planning engaging.

The target audience is South African. All emergency contact numbers, evacuation procedures, government agencies, and local references must be South African (e.g., 10111 for police, 10177 for ambulance, SAWS for weather). Disaster scenarios may reference international disaster types but practical advice must apply to South African context.

Generate challenges with embedded quiz questions in JSON format. Each challenge has:
- "title" (string) - a short, engaging challenge name (max 128 chars)
- "description" (string) - 1-2 sentences describing the challenge theme (max 512 chars)
- "type" (string) - one of: "quiz", "checklist", "timed", "decision"
- "difficulty" (string) - one of: "beginner", "intermediate", "advanced"
- "disasterType" (string) - one of: "flood", "bushfire", "earthquake", "cyclone", "storm"
- "xpReward" (int) - XP earned on completion. Use the provided level data to calibrate: beginner challenges award less XP, advanced more. XP should represent meaningful but not excessive progress between levels.
- "questId" (string or null) - if generating for a quest, use the quest's ID. Null for standalone challenges.
- "questions" (array) - the quiz questions for this challenge

Each question has:
- "sortOrder" (int) - 0-indexed display order
- "questionText" (string) - the question prompt
- "options" (array of 4 strings) - answer choices. Always exactly 4 options.
- "correctIndex" (int) - index (0-3) of the correct answer

Challenge type guidance:
- "quiz": Test factual knowledge. Example: "What is the recommended amount of emergency water per person per day?"
- "decision": Present a realistic scenario, ask for best action. Example: "You smell gas after an earthquake. What should you do first?"
- "timed": Short, quick-recall questions with concise options. Example: "The emergency number for police in South Africa is..."
- "checklist": Identification or selection questions. Example: "Which of these items should be in a basic flood kit?"

Question quality rules:
- Exactly one correct answer per question
- Incorrect options must be plausible but clearly wrong to someone who knows the material
- No trick questions - the goal is education, not deception
- Questions should teach even when answered wrong - the correct answer should be self-evidently educational
- Ensure all questions are factually accurate for the specified disaster type

Output a JSON object with a single "challenges" array containing the generated challenges.

Example output:
{
  "challenges": [
    {
      "title": "Flood Safety Basics",
      "description": "Test your knowledge of essential flood preparedness and safety measures.",
      "type": "quiz",
      "difficulty": "beginner",
      "disasterType": "flood",
      "xpReward": 50,
      "questId": null,
      "questions": [
        { "sortOrder": 0, "questionText": "What is the emergency number for ambulance services in South Africa?", "options": ["10177", "911", "10111", "112"], "correctIndex": 0 },
        { "sortOrder": 1, "questionText": "During a flood warning, what should you do first?", "options": ["Move to higher ground", "Drive through floodwater to evacuate", "Wait for the water to recede", "Open windows to equalise pressure"], "correctIndex": 0 },
        { "sortOrder": 2, "questionText": "How deep does floodwater need to be to sweep a car off the road?", "options": ["30 cm", "1 metre", "2 metres", "5 metres"], "correctIndex": 0 }
      ]
    }
  ]
}
''';

String buildUserPrompt({
  required int count,
  required int questionsPerChallenge,
  required List<String> challengeTypes,
  required String difficulty,
  required String disasterType,
  required List<Map<String, dynamic>> existingChallenges,
  required List<Map<String, dynamic>> levels,
  List<Map<String, dynamic>>? quests,
  String? guidance,
}) {
  final StringBuffer buffer = StringBuffer();

  if (quests != null && quests.isNotEmpty) {
    buffer.writeln('Generate $count challenges PER QUEST for the following quests:');
    for (final Map<String, dynamic> quest in quests) {
      buffer.writeln(
        '- Quest ID "${quest['id']}": "${quest['title']}" (${quest['disasterType']}, ${quest['difficulty']}) - ${quest['description']}',
      );
    }
    buffer.writeln();
    buffer.writeln('Each challenge MUST have its questId set to the quest it belongs to.');
    buffer.writeln('Match the challenge disasterType to the quest disasterType.');
  } else {
    buffer.writeln('Generate $count standalone challenges (questId should be null).');
  }
  buffer.writeln();

  buffer.writeln('Each challenge must have exactly $questionsPerChallenge questions.');
  buffer.writeln();

  if (challengeTypes.length < 4) {
    buffer.writeln('Only generate these challenge types: ${challengeTypes.join(', ')}');
    buffer.writeln();
  }

  if (difficulty != 'any') {
    buffer.writeln('All challenges must be difficulty: $difficulty');
    buffer.writeln();
  } else {
    buffer.writeln('Use a mix of difficulties (beginner, intermediate, advanced).');
    buffer.writeln();
  }

  if (disasterType != 'any') {
    buffer.writeln('All challenges must be disasterType: $disasterType');
    buffer.writeln();
  } else if (quests == null || quests.isEmpty) {
    buffer.writeln('Use a variety of disaster types.');
    buffer.writeln();
  }

  if (levels.isNotEmpty) {
    buffer.writeln('Level progression for XP calibration:');
    for (final Map<String, dynamic> level in levels) {
      buffer.writeln('- Level ${level['level']}: "${level['title']}" - ${level['xpThreshold']} XP');
    }
    buffer.writeln();
  }

  if (existingChallenges.isNotEmpty) {
    buffer.writeln('Existing challenges (do not duplicate these):');
    for (final Map<String, dynamic> challenge in existingChallenges) {
      buffer.writeln(
        '- "${challenge['title']}" (${challenge['type']}, ${challenge['difficulty']}, ${challenge['disasterType']})',
      );
    }
    buffer.writeln();
  }

  if (guidance != null && guidance.trim().isNotEmpty) {
    buffer.writeln('Additional guidance: $guidance');
  }

  return buffer.toString();
}
