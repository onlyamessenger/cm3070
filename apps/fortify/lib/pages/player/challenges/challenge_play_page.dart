import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/challenge_play_controller.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/widgets/player/answer_button.dart';
import 'package:fortify/widgets/player/xp_bar.dart';

class ChallengePlayPage extends StatefulWidget {
  final String challengeId;

  const ChallengePlayPage({super.key, required this.challengeId});

  @override
  State<ChallengePlayPage> createState() => _ChallengePlayPageState();
}

class _ChallengePlayPageState extends State<ChallengePlayPage> {
  @override
  void initState() {
    super.initState();
    final ChallengePlayState state = Inject.get<ChallengePlayState>();
    if (state.activeChallenge == null || state.activeChallenge!.id != widget.challengeId) {
      final String? userId = Inject.get<AuthState>().user?.id;
      if (userId != null) {
        Inject.get<ChallengePlayController>().startChallenge(widget.challengeId, userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengePlayState>(
      builder: (BuildContext context, ChallengePlayState state, Widget? _) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        final Challenge? challenge = state.activeChallenge;
        final ChallengeQuestion? question = state.currentQuestion;
        final PlayerChallengeProgress? progress = state.activeProgress;

        if (challenge == null || question == null || progress == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('No active challenge', style: TextStyle(color: AdminColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                TextButton(onPressed: () => context.go('/challenges'), child: const Text('Back')),
              ],
            ),
          );
        }

        final int totalQuestions = state.questions.length;
        final int currentIndex = progress.currentQuestionIndex;
        final double progressValue = totalQuestions > 0 ? currentIndex / totalQuestions : 0;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => context.go('/challenges'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.arrow_back_ios, size: 16, color: AdminColors.primary),
                    SizedBox(width: 4),
                    Text('Challenges', style: TextStyle(color: AdminColors.primary, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(color: AdminColors.onSurface, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    challenge.type.displayName,
                    style: const TextStyle(color: AdminColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${currentIndex + 1} of $totalQuestions',
              style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 8),
            XpBar(progress: progressValue),
            const SizedBox(height: 8),
            Text(
              '~${state.runningXp} XP on completion',
              style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
              child: Text(
                question.questionText,
                style: const TextStyle(color: AdminColors.onSurface, fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            ...List<Widget>.generate(question.options.length, (int i) {
              final AnswerState answerState;
              if (state.showingFeedback && state.selectedAnswer == i) {
                answerState = i == question.correctIndex ? AnswerState.correct : AnswerState.incorrect;
              } else if (state.showingFeedback && i == question.correctIndex) {
                answerState = AnswerState.correct;
              } else {
                answerState = AnswerState.idle;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnswerButton(
                  text: question.options[i],
                  answerState: answerState,
                  disabled: state.showingFeedback,
                  onTap: () => _submitAnswer(context, i, state),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _submitAnswer(BuildContext context, int answerIndex, ChallengePlayState state) async {
    final ChallengePlayController controller = Inject.get<ChallengePlayController>();
    await controller.submitAnswer(answerIndex);
    if (!context.mounted) return;
    if (state.activeProgress != null && state.activeProgress!.currentQuestionIndex >= state.questions.length) {
      await _completeAndNavigate(context);
    }
  }

  Future<void> _completeAndNavigate(BuildContext context) async {
    final ChallengePlayController controller = Inject.get<ChallengePlayController>();
    await controller.completeChallenge();
    if (!context.mounted) return;

    final ChallengePlayState state = Inject.get<ChallengePlayState>();
    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AdminColors.error));
      context.pop();
    } else {
      final CompletionResult? result = state.completionResult;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+${result.xpAwarded} XP earned!'), backgroundColor: AdminColors.success),
        );
      }
      context.go('/challenges');
    }
  }
}
