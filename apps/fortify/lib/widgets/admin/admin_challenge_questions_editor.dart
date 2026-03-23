import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/widgets/admin/admin_challenge_question_modal.dart';
import 'package:fortify/widgets/admin/admin_confirm_dialog.dart';

/// Inline editor for challenge questions, displayed on the challenge edit/add pages.
///
/// Shows a reorderable list of expandable question cards. Each card shows the question
/// text and option count when collapsed, and full options with correct answer highlighted
/// when expanded. Drag-to-reorder updates sortOrder as 0-indexed sequential integers.
class AdminChallengeQuestionsEditor extends StatefulWidget {
  final List<ChallengeQuestion> questions;
  final String challengeId;
  final void Function(List<ChallengeQuestion>) onChanged;

  const AdminChallengeQuestionsEditor({
    super.key,
    required this.questions,
    required this.challengeId,
    required this.onChanged,
  });

  @override
  State<AdminChallengeQuestionsEditor> createState() => _AdminChallengeQuestionsEditorState();
}

class _AdminChallengeQuestionsEditorState extends State<AdminChallengeQuestionsEditor> {
  final Set<int> _expandedIndices = <int>{};

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final List<ChallengeQuestion> reordered = List<ChallengeQuestion>.from(widget.questions);
    final ChallengeQuestion moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    // Reassign sortOrder as 0-indexed sequential integers after every reorder
    final List<ChallengeQuestion> updated = <ChallengeQuestion>[];
    for (int i = 0; i < reordered.length; i++) {
      updated.add(reordered[i].copyWith(sortOrder: i));
    }

    _expandedIndices.clear();
    widget.onChanged(updated);
  }

  Future<void> _addQuestion() async {
    final ChallengeQuestion? result = await AdminChallengeQuestionModal.show(context, challengeId: widget.challengeId);

    if (result != null) {
      final List<ChallengeQuestion> updated = <ChallengeQuestion>[
        ...widget.questions,
        result.copyWith(sortOrder: widget.questions.length),
      ];
      widget.onChanged(updated);
    }
  }

  Future<void> _editQuestion(int index) async {
    final ChallengeQuestion? result = await AdminChallengeQuestionModal.show(
      context,
      question: widget.questions[index],
      challengeId: widget.challengeId,
    );

    if (result != null) {
      final List<ChallengeQuestion> updated = List<ChallengeQuestion>.from(widget.questions);
      updated[index] = result.copyWith(sortOrder: index);
      widget.onChanged(updated);
    }
  }

  Future<void> _deleteQuestion(int index) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete Question',
      message: 'Are you sure you want to delete this question? This will take effect when you save.',
    );

    if (confirmed == true) {
      final List<ChallengeQuestion> updated = List<ChallengeQuestion>.from(widget.questions);
      updated.removeAt(index);
      // Reassign sortOrder after deletion
      for (int i = 0; i < updated.length; i++) {
        updated[i] = updated[i].copyWith(sortOrder: i);
      }
      _expandedIndices.clear();
      widget.onChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(height: 32),
        _buildHeader(),
        const SizedBox(height: 12),
        if (widget.questions.isEmpty) _buildEmptyState() else _buildQuestionList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        const Text(
          'Questions',
          style: TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (widget.questions.isNotEmpty) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(10)),
            child: Text(
              widget.questions.length.toString(),
              style: const TextStyle(color: AdminColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const Spacer(),
        TextButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Question'),
          style: TextButton.styleFrom(foregroundColor: AdminColors.primary),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: AdminColors.surfaceBorderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'No questions yet. Add your first question.',
          style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: widget.questions.length,
      onReorder: _onReorder,
      itemBuilder: (BuildContext context, int index) {
        return _buildQuestionCard(index);
      },
    );
  }

  Widget _buildQuestionCard(int index) {
    final ChallengeQuestion question = widget.questions[index];
    final bool isExpanded = _expandedIndices.contains(index);

    return Card(
      key: ValueKey<String>('${question.id}_$index'),
      color: AdminColors.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Collapsed header - always visible
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedIndices.remove(index);
                } else {
                  _expandedIndices.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: <Widget>[
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: AdminColors.onSurfaceVariant, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AdminColors.primaryOverlay,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: AdminColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.questionText,
                      style: const TextStyle(color: AdminColors.onSurface, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${question.options.length} options',
                    style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AdminColors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Full question text
                  Text(question.questionText, style: const TextStyle(color: AdminColors.onSurface, fontSize: 13)),
                  const SizedBox(height: 12),

                  // Options with correct answer highlighted
                  ...List<Widget>.generate(question.options.length, (int optIndex) {
                    final bool isCorrect = optIndex == question.correctIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.circle_outlined,
                            size: 16,
                            color: isCorrect ? Colors.green : AdminColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              question.options[optIndex],
                              style: TextStyle(
                                color: isCorrect ? Colors.green : AdminColors.onSurface,
                                fontSize: 13,
                                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),

                  // Edit/Delete actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _editQuestion(index),
                        tooltip: 'Edit',
                        color: AdminColors.onSurfaceVariant,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _deleteQuestion(index),
                        tooltip: 'Delete',
                        color: AdminColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
