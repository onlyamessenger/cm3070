import 'package:core/core.dart';

import 'package:fortify/controllers/challenge_play_controller.dart';
import 'package:fortify/controllers/quest_play_controller.dart';
import 'package:fortify/state/profile_state.dart';

class ProfileController {
  final DataSource<ActivityLogEntry> _activityLogDataSource;
  final QuestPlayController _questPlayController;
  final ChallengePlayController _challengePlayController;
  final ProfileState _state;

  ProfileController({
    required DataSource<ActivityLogEntry> activityLogDataSource,
    required QuestPlayController questPlayController,
    required ChallengePlayController challengePlayController,
    required ProfileState state,
  }) : _activityLogDataSource = activityLogDataSource,
       _questPlayController = questPlayController,
       _challengePlayController = challengePlayController,
       _state = state;

  Future<void> loadProfile(String userId) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await Future.wait(<Future<void>>[
        _loadRecentActivity(userId),
        _questPlayController.loadQuestList(userId),
        _challengePlayController.loadChallengeList(userId),
      ]);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> _loadRecentActivity(String userId) async {
    final List<ActivityLogEntry> entries = await _activityLogDataSource.readItemsWhere('userId', userId);
    entries.sort((ActivityLogEntry a, ActivityLogEntry b) => b.created.compareTo(a.created));
    final List<ActivityLogEntry> recent = entries.take(10).toList();
    _state.setRecentActivity(recent);
  }
}
