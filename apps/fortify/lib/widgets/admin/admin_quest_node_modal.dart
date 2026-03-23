import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortify/config/theme/admin_colors.dart';

/// Dialog for adding or editing a single quest node.
///
/// Manages day, narrative text, XP reward, outcome toggle, summary,
/// unlocksSectionType, and a list of choices with target node selection.
class AdminQuestNodeModal extends StatefulWidget {
  final QuestNode? node;
  final String questId;
  final List<QuestNode> allNodes;

  const AdminQuestNodeModal({super.key, this.node, required this.questId, required this.allNodes});

  static Future<QuestNode?> show(
    BuildContext context, {
    QuestNode? node,
    required String questId,
    required List<QuestNode> allNodes,
  }) {
    return showDialog<QuestNode?>(
      context: context,
      builder: (BuildContext context) => AdminQuestNodeModal(node: node, questId: questId, allNodes: allNodes),
    );
  }

  @override
  State<AdminQuestNodeModal> createState() => _AdminQuestNodeModalState();
}

class _AdminQuestNodeModalState extends State<AdminQuestNodeModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _dayController;
  late final TextEditingController _textController;
  late final TextEditingController _xpRewardController;
  late final TextEditingController _summaryController;

  bool _isOutcome = false;
  ReadinessSectionType? _unlocksSectionType;
  late List<_ChoiceRow> _choices;

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController(text: widget.node?.day.toString() ?? '');
    _textController = TextEditingController(text: widget.node?.text ?? '');
    _xpRewardController = TextEditingController(text: widget.node?.xpReward.toString() ?? '0');
    _summaryController = TextEditingController(text: widget.node?.summary ?? '');
    _isOutcome = widget.node?.isOutcome ?? false;
    _unlocksSectionType = widget.node?.unlocksSectionType != null
        ? ReadinessSectionType.fromString(widget.node!.unlocksSectionType!)
        : null;

    if (widget.node != null && widget.node!.choices.isNotEmpty) {
      _choices = widget.node!.choices.map((QuestChoice c) {
        return _ChoiceRow(
          labelController: TextEditingController(text: c.label),
          xpController: TextEditingController(text: c.xpReward.toString()),
          nextNodeId: c.nextNodeId,
        );
      }).toList();
    } else {
      _choices = <_ChoiceRow>[];
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    _textController.dispose();
    _xpRewardController.dispose();
    _summaryController.dispose();
    for (final _ChoiceRow row in _choices) {
      row.labelController.dispose();
      row.xpController.dispose();
    }
    super.dispose();
  }

  void _addChoice() {
    setState(() {
      _choices.add(
        _ChoiceRow(
          labelController: TextEditingController(),
          xpController: TextEditingController(text: '0'),
          nextNodeId: '',
        ),
      );
    });
  }

  void _removeChoice(int index) {
    setState(() {
      _choices[index].labelController.dispose();
      _choices[index].xpController.dispose();
      _choices.removeAt(index);
    });
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final int? day = int.tryParse(_dayController.text.trim());
    final int? xpReward = int.tryParse(_xpRewardController.text.trim());
    if (day == null || xpReward == null) return;

    final List<QuestChoice> choices = _choices.map((_ChoiceRow row) {
      return QuestChoice(
        label: row.labelController.text.trim(),
        nextNodeId: row.nextNodeId,
        xpReward: int.tryParse(row.xpController.text.trim()) ?? 0,
      );
    }).toList();

    final DateTime now = DateTime.now();

    final QuestNode result = QuestNode(
      id: widget.node?.id ?? '',
      created: widget.node?.created ?? now,
      updated: now,
      createdBy: widget.node?.createdBy ?? '',
      updatedBy: '',
      isDeleted: widget.node?.isDeleted ?? false,
      questId: widget.questId,
      day: day,
      text: _textController.text.trim(),
      isOutcome: _isOutcome,
      xpReward: xpReward,
      summary: _isOutcome ? _summaryController.text.trim() : null,
      choices: _isOutcome ? const <QuestChoice>[] : choices,
      unlocksSectionType: _unlocksSectionType?.name,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.node != null;

    return Dialog(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 740),
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
                  isEditing ? 'Edit Node' : 'Add Node',
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
                      // Day number
                      TextFormField(
                        controller: _dayController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AdminColors.onSurface),
                        decoration: const InputDecoration(labelText: 'Day Number'),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) return 'Day is required';
                          final int? parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) return 'Day must be greater than 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Narrative text
                      TextFormField(
                        controller: _textController,
                        maxLines: 3,
                        style: const TextStyle(color: AdminColors.onSurface),
                        decoration: const InputDecoration(labelText: 'Narrative Text'),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) return 'Narrative text is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // XP Reward
                      TextFormField(
                        controller: _xpRewardController,
                        keyboardType: const TextInputType.numberWithOptions(signed: true),
                        style: const TextStyle(color: AdminColors.onSurface),
                        decoration: const InputDecoration(
                          labelText: 'XP Reward',
                          helperText: 'Negative values penalise the player',
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) return 'XP Reward is required';
                          if (int.tryParse(value.trim()) == null) return 'Must be a whole number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Is Outcome toggle
                      SwitchListTile(
                        title: const Text('Is Outcome', style: TextStyle(color: AdminColors.onSurface, fontSize: 14)),
                        subtitle: const Text(
                          'Terminal node - no further choices',
                          style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                        ),
                        value: _isOutcome,
                        activeThumbColor: AdminColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool value) => setState(() => _isOutcome = value),
                      ),

                      // Summary (only when outcome)
                      if (_isOutcome) ...<Widget>[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _summaryController,
                          maxLines: 2,
                          style: const TextStyle(color: AdminColors.onSurface),
                          decoration: const InputDecoration(labelText: 'Summary (ending text)'),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Unlocks Section Type dropdown
                      DropdownButtonFormField<ReadinessSectionType?>(
                        initialValue: _unlocksSectionType,
                        items: <DropdownMenuItem<ReadinessSectionType?>>[
                          const DropdownMenuItem<ReadinessSectionType?>(value: null, child: Text('None')),
                          ...ReadinessSectionType.values.map(
                            (ReadinessSectionType type) =>
                                DropdownMenuItem<ReadinessSectionType?>(value: type, child: Text(type.displayName)),
                          ),
                        ],
                        onChanged: (ReadinessSectionType? value) {
                          setState(() => _unlocksSectionType = value);
                        },
                        decoration: const InputDecoration(labelText: 'Unlocks Section Type (optional)'),
                        dropdownColor: AdminColors.surfaceContainerHigh,
                        style: const TextStyle(color: AdminColors.onSurface),
                      ),

                      // Choices section (hidden for outcome nodes)
                      if (!_isOutcome) ...<Widget>[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Choices',
                              style: TextStyle(color: AdminColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            TextButton.icon(
                              onPressed: _addChoice,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Choice'),
                              style: TextButton.styleFrom(foregroundColor: AdminColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._choices.asMap().entries.map((MapEntry<int, _ChoiceRow> entry) {
                          return _buildChoiceRow(entry.key, entry.value);
                        }),
                      ],
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

  Widget _buildChoiceRow(int index, _ChoiceRow row) {
    // Build dropdown items from all nodes in the tree
    final List<DropdownMenuItem<String>> targetItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: '',
        child: Text('New Node', style: TextStyle(fontSize: 12)),
      ),
      ...widget.allNodes.where((QuestNode n) => n.id != widget.node?.id).map((QuestNode n) {
        final String label = 'Day ${n.day}: ${n.text.length > 20 ? '${n.text.substring(0, 20)}...' : n.text}';
        return DropdownMenuItem<String>(
          value: n.id,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        );
      }),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                // Label field - wrapped in Shortcuts to prevent space key interception
                Expanded(
                  child: Shortcuts(
                    shortcuts: const <ShortcutActivator, Intent>{
                      SingleActivator(LogicalKeyboardKey.space): DoNothingAndStopPropagationTextIntent(),
                    },
                    child: TextFormField(
                      controller: row.labelController,
                      style: const TextStyle(color: AdminColors.onSurface, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Choice label',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) return 'Label required';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // XP field
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: row.xpController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    style: TextStyle(
                      color: (int.tryParse(row.xpController.text.trim()) ?? 0) < 0
                          ? AdminColors.error
                          : AdminColors.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'XP',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 4),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => _removeChoice(index),
                  color: AdminColors.onSurfaceVariant,
                  tooltip: 'Remove choice',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Target node dropdown
            DropdownButtonFormField<String>(
              initialValue: row.nextNodeId,
              items: targetItems,
              onChanged: (String? value) {
                setState(() => row.nextNodeId = value ?? '');
              },
              decoration: const InputDecoration(
                labelText: 'Target node',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              dropdownColor: AdminColors.surfaceContainerHigh,
              style: const TextStyle(color: AdminColors.onSurface, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal helper to hold choice editing state.
class _ChoiceRow {
  final TextEditingController labelController;
  final TextEditingController xpController;
  String nextNodeId;

  _ChoiceRow({required this.labelController, required this.xpController, required this.nextNodeId});
}
