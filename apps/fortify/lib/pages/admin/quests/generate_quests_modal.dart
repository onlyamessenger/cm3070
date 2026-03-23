import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class GenerateQuestsModal extends StatefulWidget {
  final Future<void> Function({
    required int count,
    required String model,
    required String difficulty,
    required String disasterType,
    required String totalDays,
    required int maxDepth,
    required int maxBranches,
    String? guidance,
  })
  onGenerate;

  const GenerateQuestsModal({super.key, required this.onGenerate});

  static Future<bool?> show(
    BuildContext context, {
    required Future<void> Function({
      required int count,
      required String model,
      required String difficulty,
      required String disasterType,
      required String totalDays,
      required int maxDepth,
      required int maxBranches,
      String? guidance,
    })
    onGenerate,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => GenerateQuestsModal(onGenerate: onGenerate),
    );
  }

  @override
  State<GenerateQuestsModal> createState() => _GenerateQuestsModalState();
}

class _GenerateQuestsModalState extends State<GenerateQuestsModal> {
  final TextEditingController _countController = TextEditingController(text: '3');
  final TextEditingController _guidanceController = TextEditingController();
  String _selectedModel = 'gpt-4o';
  String _selectedDifficulty = 'any';
  String _selectedDisasterType = 'any';
  String _selectedTotalDays = 'any';
  int _selectedMaxDepth = 4;
  int _selectedMaxBranches = 2;
  bool _isLoading = false;
  String? _error;

  static const List<String> _models = <String>['gpt-4o', 'gpt-4o-mini'];

  static const Map<String, String> _difficultyOptions = <String, String>{
    'any': 'LLM chooses (progressive)',
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

  static const Map<String, String> _totalDaysOptions = <String, String>{
    'any': 'LLM chooses',
    '3': '3 days',
    '5': '5 days',
    '7': '7 days',
    '10': '10 days',
    '14': '14 days',
  };

  @override
  void dispose() {
    _countController.dispose();
    _guidanceController.dispose();
    super.dispose();
  }

  int get _nodeBudget {
    final int count = int.tryParse(_countController.text.trim()) ?? 3;
    return count * pow(_selectedMaxBranches, _selectedMaxDepth).toInt();
  }

  bool get _showBudgetWarning => _nodeBudget > 100;

  Future<void> _handleGenerate() async {
    final int? count = int.tryParse(_countController.text.trim());
    if (count == null || count < 1 || count > 5) {
      setState(() => _error = 'Count must be between 1 and 5');
      return;
    }

    if (_nodeBudget > 200) {
      setState(() => _error = 'Node budget too large ($_nodeBudget). Reduce count, depth, or branches.');
      return;
    }

    // Validate totalDays >= maxDepth when both specified
    if (_selectedTotalDays != 'any') {
      final int totalDays = int.parse(_selectedTotalDays);
      if (totalDays < _selectedMaxDepth) {
        setState(() => _error = 'Total days must be >= max depth ($_selectedMaxDepth)');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onGenerate(
        count: count,
        model: _selectedModel,
        difficulty: _selectedDifficulty,
        disasterType: _selectedDisasterType,
        totalDays: _selectedTotalDays,
        maxDepth: _selectedMaxDepth,
        maxBranches: _selectedMaxBranches,
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
            const Text('Generate Quests', style: TextStyle(color: AdminColors.onSurface)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Count
                TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AdminColors.onSurface),
                  decoration: const InputDecoration(labelText: 'Number of quests', helperText: 'Between 1 and 5'),
                  onChanged: (_) => setState(() {}),
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

                // Total days
                DropdownButtonFormField<String>(
                  value: _selectedTotalDays,
                  items: _totalDaysOptions.entries.map((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) setState(() => _selectedTotalDays = value);
                  },
                  decoration: const InputDecoration(labelText: 'Total days'),
                  dropdownColor: AdminColors.surfaceContainerHigh,
                  style: const TextStyle(color: AdminColors.onSurface),
                ),
                const SizedBox(height: 16),

                // Max depth
                DropdownButtonFormField<int>(
                  value: _selectedMaxDepth,
                  items: <int>[3, 4].map((int depth) {
                    return DropdownMenuItem<int>(value: depth, child: Text('$depth levels'));
                  }).toList(),
                  onChanged: (int? value) {
                    if (value != null) setState(() => _selectedMaxDepth = value);
                  },
                  decoration: const InputDecoration(labelText: 'Max depth'),
                  dropdownColor: AdminColors.surfaceContainerHigh,
                  style: const TextStyle(color: AdminColors.onSurface),
                ),
                const SizedBox(height: 16),

                // Max branches
                DropdownButtonFormField<int>(
                  value: _selectedMaxBranches,
                  items: <int>[1, 2, 3].map((int branches) {
                    return DropdownMenuItem<int>(value: branches, child: Text('$branches choices'));
                  }).toList(),
                  onChanged: (int? value) {
                    if (value != null) setState(() => _selectedMaxBranches = value);
                  },
                  decoration: const InputDecoration(labelText: 'Max branches per node'),
                  dropdownColor: AdminColors.surfaceContainerHigh,
                  style: const TextStyle(color: AdminColors.onSurface),
                ),
                const SizedBox(height: 16),

                // Node budget warning
                if (_showBudgetWarning) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.warning_amber_outlined, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This may produce a large response (~$_nodeBudget max nodes). Consider reducing count or branching.',
                            style: const TextStyle(color: Colors.amber, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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
                    hintText: 'e.g., Focus on coastal flooding scenarios',
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
