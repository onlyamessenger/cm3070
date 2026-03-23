import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class ProfileState extends ChangeNotifier {
  List<ActivityLogEntry> _recentActivity = <ActivityLogEntry>[];
  List<ActivityLogEntry> get recentActivity => _recentActivity;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void setRecentActivity(List<ActivityLogEntry> entries) {
    _recentActivity = entries;
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
    _recentActivity = <ActivityLogEntry>[];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
