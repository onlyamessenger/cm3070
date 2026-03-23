import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class GenerateChallengesModal extends StatefulWidget {
  final List<Quest> availableQuests;
  final Future<void> Function({
    required int count,
    required int questionsPerChallenge,
    required String model,
    required List<String> challengeTypes,
    required String difficulty,
    required String disasterType,
    List<String>? questIds,
    String? guidance,
  })
  onGenerate;

  const GenerateChallengesModal({super.key, required this.availableQuests, required this.onGenerate});

  static Future<bool?> show(
    BuildContext context, {
    required List<Quest> availableQuests,
    required Future<void> Function({
      required int count,
      required int questionsPerChallenge,
      required String model,
      required List<String> challengeTypes,
      required String difficulty,
      required String disasterType,
      List<String>? questIds,
      String? guidance,
    })
    onGenerate,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          GenerateChallengesModal(availableQuests: availableQuests, onGenerate: onGenerate),
    );
  }

  @override
  State<GenerateChallengesModal> createState() => _GenerateChallengesModalState();
}

class _GenerateChallengesModalState extends State<GenerateChallengesModal> {
  final TextEditingController _countController = TextEditingController(text: '3');
  final TextEditingController _questionsPerChallengeController = TextEditingController(text: '3');
  final TextEditingController _guidanceController = TextEditingController();
  String _selectedModel = 'gpt-4o';
  String _selectedDifficulty = 'any';
  String _selectedDisasterType = 'any';
  final Set<String> _selectedQuestIds = <String>{};
  final Set<String> _selectedChallengeTypes = <String>{'quiz', 'checklist', 'timed', 'decision'};
  bool _isLoading = false;
  String? _error;

  static const List<String> _models = <String>['gpt-4o', 'gpt-4o-mini'];

  static const Map<String, String> _difficultyOptions = <String, String>{
    'any': 'LLM chooses',
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
  };

  static const Map<String, String> _disasterTypeOptions = <String, String>{
    'any': 'LLM chooses',
    'flood': 'Flood',
    'bushfire': 'Bushfire',
    'earthquake': 'Earthquake',
    'cyclone': 'Cyclone',
    'storm': 'Storm',
  };

  static const Map<String, String> _challengeTypeLabels = <String, String>{
    'quiz': 'Quiz',
    'checklist': 'Checklist',
    'timed': 'Timed',
    'decision': 'Decision',
  };

  @override
  void dispose() {
    _countController.dispose();
    _questionsPerChallengeController.dispose();
    _guidanceController.dispose();
    super.dispose();
  }

  bool get _hasQuestsSelected => _selectedQuestIds.isNotEmpty;

  int get _maxCount => _hasQuestsSelected ? 10 : 20;

  String get _countLabel => _hasQuestsSelected ? 'Challenges per quest' : 'Number of challenges';

  String get _countHelper => _hasQuestsSelected ? 'Between 1 and 10' : 'Between 1 and 20';

  Future<void> _handleGenerate() async {
    final int? count = int.tryParse(_countController.text.trim());
    if (count == null || count < 1 || count > _maxCount) {
      setState(() => _error = 'Count must be between 1 and $_maxCount');
      return;
    }

    final int? questionsPerChallenge = int.tryParse(_questionsPerChallengeController.text.trim());
    if (questionsPerChallenge == null || questionsPerChallenge < 3 || questionsPerChallenge > 10) {
      setState(() => _error = 'Questions per challenge must be between 3 and 10');
      return;
    }

    if (_selectedChallengeTypes.isEmpty) {
      setState(() => _error = 'Select at least one challenge type');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onGenerate(
        count: count,
        questionsPerChallenge: questionsPerChallenge,
        model: _selectedModel,
        challengeTypes: _selectedChallengeTypes.toList(),
        difficulty: _selectedDifficulty,
        disasterType: _selectedDisasterType,
        questIds: _hasQuestsSelected ? _selectedQuestIds.toList() : null,
        guidance: _guidanceController.text.trim().isEmpty ? null : _guidanceController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: AdminColors.surfaceContainer.withValues(alpha: 0.95),
        title: Row(
          children: <Widget>[
            Icon(Icons.auto_awesome, color: AdminColors.primary, size: 24),
            const SizedBox(width: 8),
            const Text('Generate Challenges', style: TextStyle(color: AdminColors.onSurface)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Quest multi-select
                if (widget.availableQuests.isNotEmpty) ...<Widget>[
                  const Text(
                    'Link to quests (optional)',
                    style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.availableQuests.map((Quest quest) {
                      final bool isSelected = _selectedQuestIds.contains(quest.id);
                      return FilterChip(
                        label: Text('${quest.title} (${quest.disasterType.displayName})'),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedQuestIds.add(quest.id);
                            } else {
                              _selectedQuestIds.remove(quest.id);
                            }
                          });
                        },
                        selectedColor: AdminColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AdminColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AdminColors.primary : AdminColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Count
                TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AdminColors.onSurface),
                  decoration: InputDecoration(labelText: _countLabel, helperText: _countHelper),
                ),
                const SizedBox(height: 16),

                // Questions per challenge
                TextField(
                  controller: _questionsPerChallengeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AdminColors.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Questions per challenge',
                    helperText: 'Between 3 and 10',
                  ),
                ),
                const SizedBox(height: 16),

                // Challenge types
                const Text('Challenge types', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _challengeTypeLabels.entries.map((MapEntry<String, String> entry) {
                    final bool isSelected = _selectedChallengeTypes.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedChallengeTypes.add(entry.key);
                          } else {
                            _selectedChallengeTypes.remove(entry.key);
                          }
                        });
                      },
                      selectedColor: AdminColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AdminColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AdminColors.primary : AdminColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Difficulty
                DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  items: _difficultyOptions.entries.map((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) setState(() => _selectedDifficulty = value);
                  },
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  dropdownColor: AdminColors.surfaceContainerHigh,
                  style: const TextStyle(color: AdminColors.onSurface),
                ),
                const SizedBox(height: 16),

                // Disaster type
                DropdownButtonFormField<String>(
                  value: _selectedDisasterType,
                  items: _disasterTypeOptions.entries.map((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) setState(() => _selectedDisasterType = value);
                  },
                  decoration: const InputDecoration(labelText: 'Disaster type'),
                  dropdownColor: AdminColors.surfaceContainerHigh,
                  style: const TextStyle(color: AdminColors.onSurface),
                ),
                const SizedBox(height: 16),

                // Model
                DropdownButtonFormField<String>(
                  value: _selectedModel,
                  items: _models.map((String model) {
                    return DropdownMenuItem<String>(value: model, child: Text(model));
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) setState(() => _selectedModel = value);
                  },
                  decoration: const InputDecoration(labelText: 'Model'),
                  dropdownColor: AdminColors.surfaceContainerHigh,
                  style: const TextStyle(color: AdminColors.onSurface),
                ),
                const SizedBox(height: 16),

                // Guidance
                TextField(
                  controller: _guidanceController,
                  maxLines: 3,
                  style: const TextStyle(color: AdminColors.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Guidance (optional)',
                    hintText: 'e.g., Focus on evacuation procedures',
                    alignLabelWithHint: true,
                  ),
                ),

                // Error display
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.error_outline, color: AdminColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!, style: const TextStyle(color: AdminColors.error, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleGenerate,
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_isLoading ? 'Generating...' : 'Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: AdminColors.background,
            ),
          ),
        ],
      ),
    );
  }
}
