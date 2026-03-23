const String systemPrompt = '''
You are a content generator for Fortify, a gamified disaster preparedness mobile app that uses RPG-style mechanics (XP, levels, quests, challenges) to make emergency planning engaging.

Generate levels in JSON format. Each level has:
- "level" (int) - the level number, continuing from existing levels
- "title" (string) - a thematic RPG-style title progressing from novice to expert preparedness. Examples: "Storm Chaser", "Potential Casualty"
- "description" (string) - 1-2 sentences describing what a player at this level should realistically be capable of in terms of disaster preparedness. Frame it as achieved competency, e.g. "You can assemble a basic 72-hour kit and know your local evacuation routes."
- "icon" (string) - a single emoji representing the level
- "xpThreshold" (int) - XP required to reach this level. Analyze existing level XP thresholds and continue a consistent, balanced progression curve

Output a JSON object with a single "levels" array containing the generated levels.

Example output:
{
  "levels": [
    { "level": 1, "title": "Potential Casualty", "description": "Just getting started. You know disasters exist but haven't taken any concrete steps to prepare.", "icon": "🌱", "xpThreshold": 0 },
    { "level": 2, "title": "Storm Chaser", "description": "You can identify the most likely disasters in your area and have started assembling a basic emergency kit.", "icon": "⛈️", "xpThreshold": 100 },
    { "level": 3, "title": "First Responder", "description": "You have a complete 72-hour kit, know your evacuation routes, and can administer basic first aid.", "icon": "🚑", "xpThreshold": 300 }
  ]
}
''';

String buildUserPrompt(int count, List<Map<String, dynamic>> existingLevels, String? guidance) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('Generate $count new levels.');
  buffer.writeln();

  if (existingLevels.isNotEmpty) {
    buffer.writeln('Existing levels:');
    for (final Map<String, dynamic> level in existingLevels) {
      buffer.writeln('- Level ${level['level']}: "${level['title']}" (${level['icon']}) - ${level['xpThreshold']} XP');
    }
    buffer.writeln();
  } else {
    buffer.writeln('No existing levels. Start from level 1 with xpThreshold of 0.');
    buffer.writeln();
  }

  if (guidance != null && guidance.trim().isNotEmpty) {
    buffer.writeln('Additional guidance: $guidance');
  }

  return buffer.toString();
}
