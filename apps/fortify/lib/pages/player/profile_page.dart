import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/auth_controller.dart';
import 'package:fortify/controllers/profile_controller.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/state/player_state.dart';
import 'package:fortify/state/profile_state.dart';
import 'package:fortify/state/quest_play_state.dart';
import 'package:fortify/widgets/player/activity_tile.dart';
import 'package:fortify/widgets/player/level_badge.dart';
import 'package:fortify/widgets/player/stat_card.dart';
import 'package:fortify/widgets/player/streak_badge.dart';
import 'package:fortify/widgets/player/xp_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final AuthState authState = Inject.get<AuthState>();
    final String? userId = authState.user?.id;
    if (userId != null) {
      Inject.get<ProfileController>().loadProfile(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<PlayerState, ProfileState, QuestPlayState, ChallengePlayState>(
      builder:
          (
            BuildContext context,
            PlayerState playerState,
            ProfileState profileState,
            QuestPlayState questState,
            ChallengePlayState challengeState,
            Widget? _,
          ) {
            if ((playerState.isLoading && playerState.player == null) || profileState.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
            }

            final Player? player = playerState.player;
            if (player == null) {
              return const Center(
                child: Text('No player data', style: TextStyle(color: AdminColors.onSurfaceVariant)),
              );
            }

            final Level? currentLevel = playerState.currentLevel;
            final Level? nextLevel = playerState.nextLevel;
            final String xpLabel = nextLevel != null
                ? '${player.xp} / ${nextLevel.xpThreshold} XP'
                : '${player.xp} XP (Max Level)';

            final int completedQuests = questState.progressMap.values
                .where((PlayerQuestProgress p) => p.isCompleted)
                .length;
            final int completedChallenges = challengeState.progressMap.values
                .where((PlayerChallengeProgress p) => p.isCompleted)
                .length;
            final int totalXp = player.xp;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: <Widget>[
                // -- Header --
                Text(
                  player.displayName,
                  style: const TextStyle(color: AdminColors.onSurface, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (currentLevel != null) ...<Widget>[
                  Row(
                    children: <Widget>[
                      LevelBadge(title: currentLevel.title),
                      const SizedBox(width: 12),
                      Text(
                        '$totalXp XP total',
                        style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Level ${currentLevel.level}: ${currentLevel.title}',
                    style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  XpBar(progress: playerState.xpProgress, label: xpLabel),
                ],

                // -- Streak --
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StreakBadge(currentStreak: player.currentStreak, shieldAvailable: player.streakShieldAvailable),
                      const SizedBox(height: 8),
                      Text(
                        'Longest streak: ${player.longestStreak} days',
                        style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // -- Stats --
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatCard(label: 'Quests done', value: '$completedQuests', icon: '\u2694\uFE0F'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(label: 'Challenges done', value: '$completedChallenges', icon: '\u26A1'),
                    ),
                  ],
                ),

                // -- Recent Activity --
                const SizedBox(height: 24),
                const Text(
                  'Recent Activity',
                  style: TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (profileState.recentActivity.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No activity yet. Complete a quest or challenge to get started!',
                      style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
                    ),
                  )
                else
                  ...profileState.recentActivity.map((ActivityLogEntry entry) => ActivityTile(entry: entry)),

                // -- Logout --
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Inject.get<AuthController>().logout(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.error,
                      side: const BorderSide(color: AdminColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Log Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            );
          },
    );
  }
}
