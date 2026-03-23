import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/quest_play_controller.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/quest_play_state.dart';
import 'package:fortify/widgets/player/quest_card.dart';

class QuestListPage extends StatefulWidget {
  const QuestListPage({super.key});

  @override
  State<QuestListPage> createState() => _QuestListPageState();
}

class _QuestListPageState extends State<QuestListPage> {
  @override
  void initState() {
    super.initState();
    final String? userId = Inject.get<AuthState>().user?.id;
    if (userId != null) {
      Inject.get<QuestPlayController>().loadQuestList(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestPlayState>(
      builder: (BuildContext context, QuestPlayState state, Widget? _) {
        if (state.isLoading && state.quests.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (state.error != null && state.quests.isEmpty) {
          return Center(
            child: Text(state.error!, style: const TextStyle(color: AdminColors.error, fontSize: 14)),
          );
        }

        if (state.quests.isEmpty) {
          return const Center(
            child: Text(
              'No quests available yet.',
              style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            const Text(
              'Quests',
              style: TextStyle(color: AdminColors.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...state.quests.map((Quest quest) {
              final bool isLocked = state.isQuestLocked(quest);
              final PlayerQuestProgress? progress = state.getProgress(quest.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuestCard(
                  quest: quest,
                  progress: progress,
                  isLocked: isLocked,
                  onTap: isLocked
                      ? null
                      : progress?.isCompleted == true
                      ? null
                      : () => _startQuest(quest.id),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _startQuest(String questId) async {
    final String? userId = Inject.get<AuthState>().user?.id;
    if (userId == null) return;

    await Inject.get<QuestPlayController>().startQuest(questId, userId);
    if (mounted) {
      context.go('/quests/$questId');
    }
  }
}
