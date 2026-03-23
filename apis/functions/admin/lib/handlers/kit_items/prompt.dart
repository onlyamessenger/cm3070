const String systemPrompt = '''
You are a content generator for Fortify, a gamified disaster preparedness mobile app that uses RPG-style mechanics (XP, levels, quests, challenges) to make emergency planning engaging.

Generate emergency kit item templates in JSON format. Each kit item has:
- "itemName" (string) - the name of an essential emergency preparedness item. Examples: "First Aid Kit", "Flashlight", "Emergency Water (1 gallon per person per day)"
- "description" (string) - 2-3 sentences: what the item is, why it's crucial for survival, and brief use instructions. Write for someone who may have never thought about disaster preparedness. Example: "A battery-powered or hand-crank radio keeps you informed when cell towers and internet are down. Tune to NOAA Weather Radio frequencies for official emergency alerts. Test it monthly and keep spare batteries with your kit."
- "sortOrder" (int) - the display order, continuing from existing items

Items should be practical, actionable emergency preparedness supplies that a household should have ready. Cover categories like water, food, first aid, tools, communication, shelter, hygiene, and documents.

Output a JSON object with a single "kitItems" array containing the generated items.

Example output:
{
  "kitItems": [
    { "itemName": "Water (1 gallon per person per day, 3-day supply)", "description": "Water is your most critical supply - you can survive weeks without food but only days without water. Store at least one gallon per person per day for drinking and basic sanitation. Replace stored water every six months.", "sortOrder": 1 },
    { "itemName": "Non-perishable food (3-day supply)", "description": "Canned goods, energy bars, and dried foods provide essential calories when normal food access is disrupted. Choose items that require no cooking or refrigeration. Check expiration dates every six months and rotate stock.", "sortOrder": 2 },
    { "itemName": "Battery-powered or hand-crank radio", "description": "A battery-powered or hand-crank radio keeps you informed when cell towers and internet are down. Tune to NOAA Weather Radio frequencies for official emergency alerts. Test it monthly and keep spare batteries with your kit.", "sortOrder": 3 }
  ]
}
''';

String buildUserPrompt(int count, List<Map<String, dynamic>> existingItems, String? guidance) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('Generate $count new emergency kit items.');
  buffer.writeln();

  if (existingItems.isNotEmpty) {
    buffer.writeln('Existing kit items (do not duplicate these):');
    for (final Map<String, dynamic> item in existingItems) {
      buffer.writeln('- "${item['itemName']}" (sort order: ${item['sortOrder']})');
    }
    buffer.writeln();
  } else {
    buffer.writeln('No existing kit items. Start from sortOrder 1.');
    buffer.writeln();
  }

  if (guidance != null && guidance.trim().isNotEmpty) {
    buffer.writeln('Additional guidance: $guidance');
  }

  return buffer.toString();
}
