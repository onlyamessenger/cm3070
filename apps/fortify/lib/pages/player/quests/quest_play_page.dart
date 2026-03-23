import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/quest_play_controller.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/quest_play_state.dart';
import 'package:fortify/widgets/player/quest_choice_button.dart';
import 'package:fortify/widgets/player/quest_node_entry.dart';
import 'package:fortify/widgets/player/quest_results.dart';

class QuestPlayPage extends StatefulWidget {
  final String questId;

  const QuestPlayPage({super.key, required this.questId});

  @override
  State<QuestPlayPage> createState() => _QuestPlayPageState();
}

class _QuestPlayPageState extends State<QuestPlayPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final QuestPlayState state = Inject.get<QuestPlayState>();
    if (state.activeQuest == null || state.activeQuest!.id != widget.questId) {
      final String? userId = Inject.get<AuthState>().user?.id;
      if (userId != null) {
        Inject.get<QuestPlayController>().startQuest(widget.questId, userId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestPlayState>(
      builder: (BuildContext context, QuestPlayState state, Widget? _) {
        if (state.isLoading && state.activeQuest == null) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        final Quest? quest = state.activeQuest;
        final QuestNode? currentNode = state.currentNode;
        final PlayerQuestProgress? progress = state.activeProgress;

        if (quest == null || currentNode == null || progress == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('No active quest', style: TextStyle(color: AdminColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                TextButton(onPressed: () => context.go('/quests'), child: const Text('Back')),
              ],
            ),
          );
        }

        // Show results screen if completed
        if (state.completionResult != null) {
          return QuestResults(
            progress: progress,
            quest: quest,
            outcomeNode: currentNode,
            result: state.completionResult!,
            onBack: () {
              state.clear();
              context.go('/quests');
            },
          );
        }

        final List<QuestNode> visited = state.visitedNodes;

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => context.go('/quests'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.arrow_back_ios, size: 16, color: AdminColors.primary),
                    SizedBox(width: 4),
                    Text('Quests', style: TextStyle(color: AdminColors.primary, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    quest.title,
                    style: const TextStyle(color: AdminColors.onSurface, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${state.runningXp} XP',
                  style: const TextStyle(color: AdminColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Visited nodes (journal history)
            ...visited.map((QuestNode node) {
              final String? chosenLabel = state.choiceLabelForNode(node.id);
              return QuestNodeEntry(node: node, chosenLabel: chosenLabel);
            }),

            // Current node
            QuestNodeEntry(node: currentNode),

            // Choices or complete button
            if (state.isOutcome) ...<Widget>[
              const SizedBox(height: 16),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator(color: AdminColors.primary))
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _completeQuest(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Complete Quest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
            ] else ...<Widget>[
              const SizedBox(height: 12),
              ...currentNode.choices.map((QuestChoice choice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QuestChoiceButton(choice: choice, onTap: () => _makeChoice(choice)),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Future<void> _makeChoice(QuestChoice choice) async {
    await Inject.get<QuestPlayController>().makeChoice(choice);
    _scrollToBottom();
  }

  Future<void> _completeQuest(BuildContext context) async {
    await Inject.get<QuestPlayController>().completeQuest();
  }
}
