import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class PlayerState extends ChangeNotifier {
  Player? _player;
  Player? get player => _player;

  List<Level> _levels = <Level>[];
  List<Level> get levels => _levels;

  Level? _currentLevel;
  Level? get currentLevel => _currentLevel;

  Level? _nextLevel;
  Level? get nextLevel => _nextLevel;

  double _xpProgress = 0.0;
  double get xpProgress => _xpProgress;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int? get xpToNextLevel {
    if (_player == null || _nextLevel == null) return null;
    return _nextLevel!.xpThreshold - _player!.xp;
  }

  void setProfile({
    required Player player,
    required List<Level> levels,
    required Level currentLevel,
    required Level? nextLevel,
    required double xpProgress,
  }) {
    _player = player;
    _levels = levels;
    _currentLevel = currentLevel;
    _nextLevel = nextLevel;
    _xpProgress = xpProgress;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clear() {
    _player = null;
    _levels = <Level>[];
    _currentLevel = null;
    _nextLevel = null;
    _xpProgress = 0.0;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
