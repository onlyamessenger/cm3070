import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/readiness_metadata.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/player_controller.dart';
import 'package:fortify/controllers/readiness_controller.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/player_state.dart';
import 'package:fortify/state/readiness_state.dart';
import 'package:fortify/widgets/player/level_badge.dart';
import 'package:fortify/widgets/player/player_card.dart';
import 'package:fortify/widgets/player/progress_ring.dart';
import 'package:fortify/widgets/player/readiness_card.dart';
import 'package:fortify/widgets/player/streak_badge.dart';
import 'package:fortify/widgets/player/xp_bar.dart';

class ReadinessDashboardPage extends StatefulWidget {
  const ReadinessDashboardPage({super.key});

  @override
  State<ReadinessDashboardPage> createState() => _ReadinessDashboardPageState();
}

class _ReadinessDashboardPageState extends State<ReadinessDashboardPage> {
  bool _checkInLoading = false;

  bool _isCheckedInToday(Player player) {
    final DateTime now = DateTime.now();
    final DateTime last = player.lastActiveDate;
    return now.year == last.year && now.month == last.month && now.day == last.day && player.currentStreak > 0;
  }

  Future<void> _handleCheckIn(Player player) async {
    setState(() => _checkInLoading = true);

    final PlayerController controller = Inject.get<PlayerController>();
    final Map<String, dynamic> response = await controller.dailyCheckIn(useShield: false);

    if (!mounted) return;

    if (response['ok'] == true) {
      await controller.loadProfile(player.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+${response['xpAwarded']} XP${response['streakReset'] == true ? ' (streak reset)' : ''}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (response['shieldAvailable'] == true) {
      final bool? useShield = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: const Text('Use Shield?'),
          content: Text('You missed a day! Use your shield to keep your ${response['currentStreak']}-day streak?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Use Shield')),
          ],
        ),
      );

      if (useShield == true && mounted) {
        final Map<String, dynamic> shieldResponse = await controller.dailyCheckIn(useShield: true);
        if (shieldResponse['ok'] == true && mounted) {
          await controller.loadProfile(player.userId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Shield used! +${shieldResponse['xpAwarded']} XP'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    }

    if (mounted) setState(() => _checkInLoading = false);
  }

  @override
  void initState() {
    super.initState();
    final AuthState authState = Inject.get<AuthState>();
    final String? userId = authState.user?.id;
    if (userId != null) {
      Inject.get<PlayerController>().loadProfile(userId);
      Inject.get<ReadinessController>().loadSections(userId);
      Inject.get<ReadinessController>().loadKitItems(userId);
      Inject.get<ReadinessController>().resolveUnlockHints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerState, ReadinessState>(
      builder: (BuildContext context, PlayerState playerState, ReadinessState readinessState, Widget? _) {
        if (playerState.isLoading && playerState.player == null) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (playerState.error != null && playerState.player == null) {
          return Center(
            child: Text(playerState.error!, style: const TextStyle(color: AdminColors.error, fontSize: 14)),
          );
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

        final int unlockedCount = readinessState.unlockedCount;
        final double progress = readinessState.readinessProgress;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            Text(
              'Welcome back, ${player.displayName}',
              style: const TextStyle(color: AdminColors.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (currentLevel != null) ...<Widget>[
              LevelBadge(title: currentLevel.title),
              const SizedBox(height: 20),
              Text(
                'Level ${currentLevel.level}: ${currentLevel.title}',
                style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 8),
              XpBar(progress: playerState.xpProgress, label: xpLabel),
            ],
            const SizedBox(height: 20),
            StreakBadge(
              currentStreak: player.currentStreak,
              shieldAvailable: player.streakShieldAvailable,
              checkedInToday: _isCheckedInToday(player),
              isLoading: _checkInLoading,
              onCheckIn: () => _handleCheckIn(player),
            ),
            const SizedBox(height: 24),
            PlayerCard(
              icon: '\u2694\uFE0F',
              title: 'Quests',
              subtitle: 'Story-driven preparedness',
              onTap: () => context.go('/quests'),
            ),
            const SizedBox(height: 12),
            PlayerCard(
              icon: '\u26A1',
              title: 'Challenges',
              subtitle: 'Test your knowledge',
              onTap: () => context.go('/challenges'),
            ),
            const SizedBox(height: 24),
            Center(
              child: ProgressRing(
                progress: progress,
                label: '${(progress * 100).round()}%',
                sublabel: '$unlockedCount of 5 areas complete',
              ),
            ),
            const SizedBox(height: 24),
            ...readinessState.sections.map((ReadinessSection section) {
              final SectionMeta meta = sectionMetadata[section.sectionType]!;
              final String? hint = readinessState.unlockHints[section.sectionType];

              Widget? child;
              if (section.isUnlocked && section.sectionType == ReadinessSectionType.emergencyKit) {
                final int checked = readinessState.kitItemsChecked;
                final int total = readinessState.kitItemsTotal;
                child = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$checked of $total items ready',
                      style: const TextStyle(color: AdminColors.primary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: readinessState.kitProgress,
                        backgroundColor: AdminColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(AdminColors.success),
                        minHeight: 4,
                      ),
                    ),
                  ],
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReadinessCard(
                  icon: meta.icon,
                  title: meta.title,
                  unlocked: section.isUnlocked,
                  hintText: section.isUnlocked ? null : hint,
                  onTap: section.isUnlocked ? () => _navigateToSection(section.sectionType) : null,
                  child: child,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _navigateToSection(ReadinessSectionType type) {
    if (type == ReadinessSectionType.emergencyKit) {
      context.push('/readiness/emergency-kit');
    } else if (type == ReadinessSectionType.evacuationRoutes) {
      context.push('/readiness/evacuation-routes');
    } else if (type == ReadinessSectionType.shelterLocations) {
      context.push('/readiness/shelter-locations');
    } else if (type == ReadinessSectionType.emergencyContacts) {
      context.push('/readiness/emergency-contacts');
    } else if (type == ReadinessSectionType.floodRisk) {
      context.push('/readiness/flood-risk');
    } else {
      context.push('/readiness/${type.name}');
    }
  }
}
