import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/widgets/player/unlock_section_modal.dart';
import 'package:go_router/go_router.dart';

class ChallengeResults extends StatefulWidget {
  final PlayerChallengeProgress progress;
  final List<ChallengeQuestion> questions;
  final CompletionResult result;
  final VoidCallback onBack;

  const ChallengeResults({
    super.key,
    required this.progress,
    required this.questions,
    required this.result,
    required this.onBack,
  });

  @override
  State<ChallengeResults> createState() => _ChallengeResultsState();
}

class _ChallengeResultsState extends State<ChallengeResults> {
  @override
  void initState() {
    super.initState();
    if (widget.result.unlockedSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showUnlockModal(context));
    }
  }

  void _showUnlockModal(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return UnlockSectionModal(
          sectionType: widget.result.unlockedSection!,
          onViewDashboard: () {
            Navigator.of(dialogContext).pop();
            context.go('/');
          },
          onKeepPlaying: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: <Widget>[
        const Center(
          child: Text(
            'Challenge Complete!',
            style: TextStyle(color: AdminColors.primary, fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '${widget.progress.correctCount} out of ${widget.questions.length} correct',
            style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '+${widget.result.xpAwarded} XP',
            style: const TextStyle(color: AdminColors.primary, fontSize: 36, fontWeight: FontWeight.w700),
          ),
        ),
        if (widget.result.multiplier > 1.0) ...<Widget>[
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${widget.result.multiplier}x multiplier applied!',
              style: const TextStyle(color: AdminColors.warning, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
        if (widget.result.unlockedSection != null) ...<Widget>[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showUnlockModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryOverlay,
                foregroundColor: AdminColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('View Unlock', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'Answer Review',
          style: TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(widget.questions.length, (int i) {
          final ChallengeQuestion q = widget.questions[i];
          final int userAnswer = i < widget.progress.answers.length ? widget.progress.answers[i] : -1;
          final bool isCorrect = userAnswer == q.correctIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(q.questionText, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? AdminColors.success : AdminColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          userAnswer >= 0 && userAnswer < q.options.length ? q.options[userAnswer] : 'No answer',
                          style: TextStyle(
                            color: isCorrect ? AdminColors.success : AdminColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isCorrect) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'Correct: ${q.options[q.correctIndex]}',
                      style: const TextStyle(color: AdminColors.success, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.onSurface,
              side: const BorderSide(color: AdminColors.surfaceBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Back to Challenges'),
          ),
        ),
      ],
    );
  }
}
