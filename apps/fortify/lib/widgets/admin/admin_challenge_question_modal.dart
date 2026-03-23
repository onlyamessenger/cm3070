import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortify/config/theme/admin_colors.dart';

/// Dialog for adding or editing a single challenge question.
///
/// Manages question text, a reorderable list of options, and correct answer selection.
/// Returns the built [ChallengeQuestion] on save, or null on cancel.
class AdminChallengeQuestionModal extends StatefulWidget {
  final ChallengeQuestion? question;
  final String challengeId;

  const AdminChallengeQuestionModal({super.key, this.question, required this.challengeId});

  /// Shows the modal dialog and returns the built question, or null if cancelled.
  static Future<ChallengeQuestion?> show(
    BuildContext context, {
    ChallengeQuestion? question,
    required String challengeId,
  }) {
    return showDialog<ChallengeQuestion?>(
      context: context,
      builder: (BuildContext context) => AdminChallengeQuestionModal(question: question, challengeId: challengeId),
    );
  }

  @override
  State<AdminChallengeQuestionModal> createState() => _AdminChallengeQuestionModalState();
}

class _AdminChallengeQuestionModalState extends State<AdminChallengeQuestionModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionTextController;
  late List<TextEditingController> _optionControllers;
  int _correctIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController(text: widget.question?.questionText ?? '');
    _correctIndex = widget.question?.correctIndex ?? 0;

    if (widget.question != null && widget.question!.options.isNotEmpty) {
      _optionControllers = widget.question!.options.map((String opt) => TextEditingController(text: opt)).toList();
    } else {
      // Start with 2 empty options by default
      _optionControllers = <TextEditingController>[TextEditingController(), TextEditingController()];
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (final TextEditingController c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      // Adjust correctIndex if the removed option was before or at the correct answer
      if (_correctIndex >= _optionControllers.length) {
        _correctIndex = _optionControllers.length - 1;
      } else if (index < _correctIndex) {
        _correctIndex--;
      } else if (index == _correctIndex) {
        _correctIndex = 0;
      }
    });
  }

  void _onReorderOptions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final TextEditingController moved = _optionControllers.removeAt(oldIndex);
      _optionControllers.insert(newIndex, moved);

      // Update correctIndex to follow the correct option's new position
      if (_correctIndex == oldIndex) {
        _correctIndex = newIndex;
      } else if (oldIndex < _correctIndex && newIndex >= _correctIndex) {
        _correctIndex--;
      } else if (oldIndex > _correctIndex && newIndex <= _correctIndex) {
        _correctIndex++;
      }
    });
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final List<String> options = _optionControllers.map((TextEditingController c) => c.text.trim()).toList();
    final DateTime now = DateTime.now();

    final ChallengeQuestion result = ChallengeQuestion(
      id: widget.question?.id ?? '',
      created: widget.question?.created ?? now,
      updated: now,
      createdBy: widget.question?.createdBy ?? '',
      updatedBy: '',
      isDeleted: widget.question?.isDeleted ?? false,
      challengeId: widget.challengeId,
      sortOrder: widget.question?.sortOrder ?? 0,
      questionText: _questionTextController.text.trim(),
      options: options,
      correctIndex: _correctIndex,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.question != null;

    return Dialog(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  isEditing ? 'Edit Question' : 'Add Question',
                  style: const TextStyle(color: AdminColors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Question text
                      TextFormField(
                        controller: _questionTextController,
                        maxLines: 3,
                        style: const TextStyle(color: AdminColors.onSurface),
                        decoration: const InputDecoration(labelText: 'Question Text'),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) return 'Question text is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Options header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            'Options',
                            style: TextStyle(color: AdminColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          TextButton.icon(
                            onPressed: _addOption,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Option'),
                            style: TextButton.styleFrom(foregroundColor: AdminColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Reorderable options list wrapped in RadioGroup for correct answer selection
                      RadioGroup<int>(
                        groupValue: _correctIndex,
                        onChanged: (int? value) {
                          if (value != null) setState(() => _correctIndex = value);
                        },
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: _optionControllers.length,
                          onReorder: _onReorderOptions,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildOptionRow(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _handleSave, child: const Text('Save')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(int index) {
    return Padding(
      key: ValueKey<int>(index),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle, color: AdminColors.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 8),

          // Radio for correct answer (managed by RadioGroup ancestor)
          Radio<int>(value: index, activeColor: AdminColors.primary),
          const SizedBox(width: 4),

          // Option text field - explicitly maps the space key to DoNothingAndStopPropagation
          // to prevent ReorderableListView from intercepting it as an ActivateIntent.
          Expanded(
            child: Shortcuts(
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.space): DoNothingAndStopPropagationTextIntent(),
              },
              child: TextFormField(
                controller: _optionControllers[index],
                style: const TextStyle(color: AdminColors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Option ${index + 1}',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) return 'Option cannot be empty';
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Delete button (disabled if only 2 options)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _optionControllers.length > 2 ? () => _removeOption(index) : null,
            color: AdminColors.onSurfaceVariant,
            tooltip: 'Remove option',
          ),
        ],
      ),
    );
  }
}
