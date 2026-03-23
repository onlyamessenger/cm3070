import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class GenerateBonusEventsModal extends StatefulWidget {
  final Future<void> Function({required int count, required String model, String? guidance}) onGenerate;

  const GenerateBonusEventsModal({super.key, required this.onGenerate});

  static Future<bool?> show(
    BuildContext context, {
    required Future<void> Function({required int count, required String model, String? guidance}) onGenerate,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => GenerateBonusEventsModal(onGenerate: onGenerate),
    );
  }

  @override
  State<GenerateBonusEventsModal> createState() => _GenerateBonusEventsModalState();
}

class _GenerateBonusEventsModalState extends State<GenerateBonusEventsModal> {
  final TextEditingController _countController = TextEditingController(text: '5');
  final TextEditingController _guidanceController = TextEditingController();
  String _selectedModel = 'gpt-4o-mini';
  bool _isLoading = false;
  String? _error;

  static const List<String> _models = <String>['gpt-4o-mini', 'gpt-4o'];

  @override
  void dispose() {
    _countController.dispose();
    _guidanceController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final int? count = int.tryParse(_countController.text.trim());
    if (count == null || count < 1 || count > 20) {
      setState(() => _error = 'Count must be between 1 and 20');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onGenerate(
        count: count,
        model: _selectedModel,
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
            const Text('Generate Bonus Events', style: TextStyle(color: AdminColors.onSurface)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AdminColors.onSurface),
                decoration: const InputDecoration(labelText: 'Number of events', helperText: 'Between 1 and 20'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                items: _models.map((String model) {
                  return DropdownMenuItem<String>(value: model, child: Text(model));
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selectedModel = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Model'),
                dropdownColor: AdminColors.surfaceContainerHigh,
                style: const TextStyle(color: AdminColors.onSurface),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _guidanceController,
                maxLines: 3,
                style: const TextStyle(color: AdminColors.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Guidance (optional)',
                  hintText: 'e.g., Focus on seasonal weather events',
                  alignLabelWithHint: true,
                ),
              ),
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
