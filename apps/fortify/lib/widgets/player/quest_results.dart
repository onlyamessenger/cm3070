import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/widgets/player/unlock_section_modal.dart';
import 'package:go_router/go_router.dart';

class QuestResults extends StatefulWidget {
  final PlayerQuestProgress progress;
  final Quest quest;
  final QuestNode outcomeNode;
  final CompletionResult result;
  final VoidCallback onBack;

  const QuestResults({
    super.key,
    required this.progress,
    required this.quest,
    required this.outcomeNode,
    required this.result,
    required this.onBack,
  });

  @override
  State<QuestResults> createState() => _QuestResultsState();
}

class _QuestResultsState extends State<QuestResults> {
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
            'Quest Complete!',
            style: TextStyle(color: AdminColors.primary, fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            widget.quest.title,
            style: const TextStyle(color: AdminColors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        if (widget.outcomeNode.summary != null) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Text(
              widget.outcomeNode.summary!,
              style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14, height: 1.5),
            ),
          ),
        ],
        const SizedBox(height: 20),
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
            child: const Text('Back to Quests'),
          ),
        ),
      ],
    );
  }
}
