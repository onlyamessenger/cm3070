import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/challenge_play_controller.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/widgets/player/challenge_card.dart';

class ChallengeListPage extends StatefulWidget {
  const ChallengeListPage({super.key});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  @override
  void initState() {
    super.initState();
    final String? userId = Inject.get<AuthState>().user?.id;
    if (userId != null) {
      Inject.get<ChallengePlayController>().loadChallengeList(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengePlayState>(
      builder: (BuildContext context, ChallengePlayState state, Widget? _) {
        if (state.isLoading && state.challenges.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (state.error != null && state.challenges.isEmpty) {
          return Center(
            child: Text(state.error!, style: const TextStyle(color: AdminColors.error, fontSize: 14)),
          );
        }

        final Challenge? daily = state.dailyChallenge;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            const Text(
              'Daily Challenge',
              style: TextStyle(color: AdminColors.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (daily != null)
              ChallengeCard(
                challenge: daily,
                progress: state.getProgress(daily.id),
                onTap: state.getProgress(daily.id)?.isCompleted == true ? null : () => _startChallenge(daily.id),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text(
                    'All caught up! Check back tomorrow.',
                    style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14),
                  ),
                ),
              ),
            const SizedBox(height: 28),
            const Text(
              'Quest Challenges',
              style: TextStyle(color: AdminColors.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text(
                  'Complete quests to unlock challenge content',
                  style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startChallenge(String challengeId) async {
    final String? userId = Inject.get<AuthState>().user?.id;
    if (userId == null) return;

    await Inject.get<ChallengePlayController>().startChallenge(challengeId, userId);
    if (mounted) {
      context.go('/challenges/$challengeId');
    }
  }
}
