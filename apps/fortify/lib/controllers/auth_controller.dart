import 'package:fortify/interface/services/auth_service.dart';
import 'package:fortify/interface/services/role_service.dart';
import 'package:fortify/models/app_user.dart';
import 'package:fortify/state/auth_state.dart';

/// Orchestrates authentication side effects.
class AuthController {
  final AuthService _authService;
  final RoleService _roleService;
  final AuthState _state;

  AuthController({required AuthService authService, required RoleService roleService, required AuthState state})
    : _authService = authService,
      _roleService = roleService,
      _state = state;

  Future<void> checkSession() async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final AppUser? user = await _authService.getCurrentSession();
      _state.setUser(user);
      if (user != null) {
        final bool isAdmin = await _roleService.isAdmin(userId: user.id);
        _state.setIsAdmin(isAdmin);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    await _loginWithSessionCheck(() => _authService.loginWithGoogle());
  }

  Future<void> loginWithApple() async {
    await _loginWithSessionCheck(() => _authService.loginWithApple());
  }

  /// Shared login flow: checks for existing session first, then calls the
  /// provided login function if no session exists.
  Future<void> _loginWithSessionCheck(Future<AppUser> Function() loginFn) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      // If a session already exists, restore it instead of creating a duplicate
      final AppUser? existing = await _authService.getCurrentSession();
      final AppUser user = existing ?? await loginFn();
      _state.setUser(user);
      final bool isAdmin = await _roleService.isAdmin(userId: user.id);
      _state.setIsAdmin(isAdmin);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> loginWithEmail({required String email, required String password}) async {
    await _loginWithSessionCheck(() => _authService.loginWithEmail(email: email, password: password));
  }

  Future<void> resetPassword({required String email}) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _authService.resetPassword(email: email);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> logout() async {
    _state.setLoading(true);
    try {
      await _authService.logout();
      _state.clear();
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  void toggleEmailForm() {
    _state.setShowEmailForm(!_state.showEmailForm);
  }
}
