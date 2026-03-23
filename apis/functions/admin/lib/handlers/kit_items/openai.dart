import 'dart:convert';

import 'package:http/http.dart' as http;

import 'prompt.dart';

const List<String> allowedModels = <String>['gpt-4o-mini', 'gpt-4o'];

const Map<String, dynamic> _responseFormat = <String, dynamic>{
  'type': 'json_schema',
  'json_schema': <String, dynamic>{
    'name': 'generated_kit_items',
    'strict': true,
    'schema': <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'kitItems': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{
            'type': 'object',
            'properties': <String, dynamic>{
              'itemName': <String, dynamic>{'type': 'string'},
              'description': <String, dynamic>{'type': 'string'},
              'sortOrder': <String, dynamic>{'type': 'integer'},
            },
            'required': <String>['itemName', 'description', 'sortOrder'],
            'additionalProperties': false,
          },
        },
      },
      'required': <String>['kitItems'],
      'additionalProperties': false,
    },
  },
};

Future<List<Map<String, dynamic>>> callOpenAI(String apiKey, String model, String userPrompt) async {
  final http.Response response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: <String, String>{'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
    body: jsonEncode(<String, dynamic>{
      'model': model,
      'response_format': _responseFormat,
      'messages': <Map<String, String>>[
        <String, String>{'role': 'system', 'content': systemPrompt},
        <String, String>{'role': 'user', 'content': userPrompt},
      ],
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('OpenAI API error (${response.statusCode}): ${response.body}');
  }

  final Map<String, dynamic> result = jsonDecode(response.body) as Map<String, dynamic>;
  final List<dynamic> choices = result['choices'] as List<dynamic>;
  if (choices.isEmpty) {
    throw Exception('OpenAI returned no choices');
  }

  final String content = (choices[0] as Map<String, dynamic>)['message']['content'] as String;
  final Map<String, dynamic> parsed = jsonDecode(content) as Map<String, dynamic>;
  final List<dynamic> kitItems = parsed['kitItems'] as List<dynamic>? ?? <dynamic>[];

  return kitItems.cast<Map<String, dynamic>>();
}
