const String systemPrompt = '''
You are a content generator for Fortify, a gamified disaster preparedness mobile app that uses RPG-style mechanics (XP, levels, quests, challenges) to make emergency planning engaging.

Generate bonus events in JSON format. Bonus events are timed XP multiplier events that encourage players to engage with preparedness activities. Each bonus event has:
- "title" (string) - a short, engaging event name. Examples: "Storm Season Sprint", "Preparedness Week", "Earthquake Readiness Rush"
- "description" (string) - a 1-2 sentence description explaining the event theme and what players should focus on
- "multiplier" (number) - an XP multiplier between 1.5 and 3.0. Higher multipliers for shorter or more challenging events
- "startsAt" (string) - ISO 8601 date for when the event begins (e.g. "2026-04-01T00:00:00.000")
- "endsAt" (string) - ISO 8601 date for when the event ends (e.g. "2026-04-07T23:59:59.000")

Space events out so they don't overlap. Vary durations: some short (2-3 days) with higher multipliers, some longer (1-2 weeks) with lower multipliers. Align events with real-world seasons or awareness periods where relevant (e.g. hurricane season in summer, fire safety in autumn).

Output a JSON object with a single "bonusEvents" array containing the generated events.

Example output:
{
  "bonusEvents": [
    { "title": "Storm Season Sprint", "description": "Hurricane season is approaching! Complete weather-related preparedness quests for bonus XP.", "multiplier": 2.0, "startsAt": "2026-06-01T00:00:00.000", "endsAt": "2026-06-14T23:59:59.000" },
    { "title": "First Aid February", "description": "Focus on medical preparedness this month. Earn extra XP for completing first aid challenges.", "multiplier": 1.5, "startsAt": "2026-02-01T00:00:00.000", "endsAt": "2026-02-14T23:59:59.000" }
  ]
}
''';

String buildUserPrompt(int count, List<Map<String, dynamic>> existingEvents, String? guidance) {
  final StringBuffer buffer = StringBuffer();
  final String today = DateTime.now().toIso8601String().substring(0, 10);
  buffer.writeln('Generate $count new bonus events. Today is $today - schedule events in the future.');
  buffer.writeln();

  if (existingEvents.isNotEmpty) {
    buffer.writeln('Existing bonus events (do not duplicate these):');
    for (final Map<String, dynamic> event in existingEvents) {
      buffer.writeln(
        '- "${event['title']}" (${event['multiplier']}x, ${event['startsAt']} to ${event['endsAt']}): ${event['description']}',
      );
    }
    buffer.writeln();
  } else {
    buffer.writeln('No existing bonus events.');
    buffer.writeln();
  }

  if (guidance != null && guidance.trim().isNotEmpty) {
    buffer.writeln('Additional guidance: $guidance');
  }

  return buffer.toString();
}
