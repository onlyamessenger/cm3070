import 'package:flutter/foundation.dart';

import 'package:fortify/models/app_user.dart';

class AuthState extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _showEmailForm = false;
  bool get showEmailForm => _showEmailForm;

  bool get isAuthenticated => _user != null;

  void setUser(AppUser? value) {
    _user = value;
    notifyListeners();
  }

  void setIsAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setShowEmailForm(bool value) {
    _showEmailForm = value;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _isAdmin = false;
    _error = null;
    _showEmailForm = false;
    notifyListeners();
  }
}
