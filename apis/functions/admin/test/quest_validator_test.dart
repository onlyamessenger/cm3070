import 'package:admin/handlers/quests/validator.dart';
import 'package:test/test.dart';

Map<String, dynamic> validQuest() => <String, dynamic>{
      'title': 'Test Quest',
      'startNodeId': 'node_1',
      'nodes': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'node_1',
          'isOutcome': false,
          'choices': <Map<String, dynamic>>[
            <String, dynamic>{'nextNodeId': 'node_2'},
          ],
        },
        <String, dynamic>{
          'id': 'node_2',
          'isOutcome': true,
          'choices': <Map<String, dynamic>>[],
        },
      ],
    };

void main() {
  group('validateQuestGraph', () {
    test('valid simple quest (linear: start -> outcome) returns true', () {
      expect(validateQuestGraph(validQuest()), isTrue);
    });

    test('valid branching quest (start -> 2 outcomes) returns true', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Branching Quest',
        'startNodeId': 'node_1',
        'nodes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'node_1',
            'isOutcome': false,
            'choices': <Map<String, dynamic>>[
              <String, dynamic>{'nextNodeId': 'node_2'},
              <String, dynamic>{'nextNodeId': 'node_3'},
            ],
          },
          <String, dynamic>{
            'id': 'node_2',
            'isOutcome': true,
            'choices': <Map<String, dynamic>>[],
          },
          <String, dynamic>{
            'id': 'node_3',
            'isOutcome': true,
            'choices': <Map<String, dynamic>>[],
          },
        ],
      };
      expect(validateQuestGraph(quest), isTrue);
    });

    test('empty nodes returns false', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Empty Quest',
        'startNodeId': 'node_1',
        'nodes': <Map<String, dynamic>>[],
      };
      expect(validateQuestGraph(quest), isFalse);
    });

    test('missing startNodeId returns false', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'No Start Quest',
        'startNodeId': '',
        'nodes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'node_1',
            'isOutcome': true,
            'choices': <Map<String, dynamic>>[],
          },
        ],
      };
      expect(validateQuestGraph(quest), isFalse);
    });

    test('startNodeId references non-existent node returns false', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Bad Start Quest',
        'startNodeId': 'node_999',
        'nodes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'node_1',
            'isOutcome': true,
            'choices': <Map<String, dynamic>>[],
          },
        ],
      };
      expect(validateQuestGraph(quest), isFalse);
    });

    test('non-outcome leaf node (no choices, isOutcome: false) returns false', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Leaf Not Outcome',
        'startNodeId': 'node_1',
        'nodes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'node_1',
            'isOutcome': false,
            'choices': <Map<String, dynamic>>[
              <String, dynamic>{'nextNodeId': 'node_2'},
            ],
          },
          <String, dynamic>{
            'id': 'node_2',
            'isOutcome': false,
            'choices': <Map<String, dynamic>>[],
          },
        ],
      };
      expect(validateQuestGraph(quest), isFalse);
    });

    test('choice references non-existent node returns false', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Bad Choice Quest',
        'startNodeId': 'node_1',
        'nodes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'node_1',
            'isOutcome': false,
            'choices': <Map<String, dynamic>>[
              <String, dynamic>{'nextNodeId': 'node_999'},
            ],
          },
        ],
      };
      expect(validateQuestGraph(quest), isFalse);
    });

    test('cycle detected (node_1 -> node_2 -> node_1) returns false', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Cyclic Quest',
        'startNodeId': 'node_1',
        'nodes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'node_1',
            'isOutcome': false,
            'choices': <Map<String, dynamic>>[
              <String, dynamic>{'nextNodeId': 'node_2'},
            ],
          },
          <String, dynamic>{
            'id': 'node_2',
            'isOutcome': false,
            'choices': <Map<String, dynamic>>[
              <String, dynamic>{'nextNodeId': 'node_1'},
            ],
          },
        ],
      };
      expect(validateQuestGraph(quest), isFalse);
    });

    test('unreachable node returns false', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Unreachable Quest',
        'startNodeId': 'node_1',
        'nodes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'node_1',
            'isOutcome': true,
            'choices': <Map<String, dynamic>>[],
          },
          <String, dynamic>{
            'id': 'node_2',
            'isOutcome': true,
            'choices': <Map<String, dynamic>>[],
          },
        ],
      };
      expect(validateQuestGraph(quest), isFalse);
    });

    test('error callback receives descriptive message', () {
      final Map<String, dynamic> quest = <String, dynamic>{
        'title': 'Empty Quest',
        'startNodeId': 'node_1',
        'nodes': <Map<String, dynamic>>[],
      };
      String? capturedError;
      validateQuestGraph(quest, onError: (String msg) => capturedError = msg);
      expect(capturedError, contains('empty nodes or missing startNodeId'));
    });
  });
}
