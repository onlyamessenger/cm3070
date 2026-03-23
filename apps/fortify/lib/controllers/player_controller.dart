import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:core/core.dart';

import 'package:fortify/state/player_state.dart';

class PlayerController {
  final DataSource<Player> _playerDataSource;
  final DataSource<Level> _levelDataSource;
  final Functions _functions;
  final PlayerState _state;

  PlayerController({
    required DataSource<Player> playerDataSource,
    required DataSource<Level> levelDataSource,
    required Functions functions,
    required PlayerState state,
  }) : _playerDataSource = playerDataSource,
       _levelDataSource = levelDataSource,
       _functions = functions,
       _state = state;

  Future<void> loadProfile(String userId) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Player> players = await _playerDataSource.readItemsWhere('userId', userId);
      if (players.isEmpty) {
        throw Exception('Player not found for userId: $userId');
      }
      final Player player = players.first;

      final List<Level> allLevels = await _levelDataSource.readItems();
      final List<Level> levels = allLevels.where((Level l) => l.isPublished).toList()
        ..sort((Level a, Level b) => a.xpThreshold.compareTo(b.xpThreshold));

      if (levels.isEmpty) {
        throw Exception('No published levels found');
      }

      Level currentLevel = levels.first;
      for (final Level level in levels) {
        if (player.xp >= level.xpThreshold) {
          currentLevel = level;
        } else {
          break;
        }
      }

      final int currentIndex = levels.indexOf(currentLevel);
      final Level? nextLevel = currentIndex < levels.length - 1 ? levels[currentIndex + 1] : null;

      final double xpProgress;
      if (nextLevel != null) {
        final int earned = player.xp - currentLevel.xpThreshold;
        final int needed = nextLevel.xpThreshold - currentLevel.xpThreshold;
        xpProgress = needed > 0 ? (earned / needed).clamp(0.0, 1.0) : 1.0;
      } else {
        xpProgress = 1.0;
      }

      _state.setProfile(
        player: player,
        levels: levels,
        currentLevel: currentLevel,
        nextLevel: nextLevel,
        xpProgress: xpProgress,
      );
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<Map<String, dynamic>> dailyCheckIn({required bool useShield}) async {
    try {
      final models.Execution result = await _functions.createExecution(
        functionId: 'player',
        path: '/daily-check-in',
        body: jsonEncode(<String, dynamic>{'useShield': useShield}),
        method: ExecutionMethod.pOST,
      );

      final Map<String, dynamic> response = jsonDecode(result.responseBody) as Map<String, dynamic>;
      return response;
    } on Exception catch (e) {
      return <String, dynamic>{'ok': false, 'error': e.toString()};
    }
  }
}
