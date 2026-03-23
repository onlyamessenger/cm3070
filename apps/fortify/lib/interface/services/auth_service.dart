import 'package:fortify/models/app_user.dart';

/// Abstract authentication service.
abstract class AuthService {
  Future<AppUser?> getCurrentSession();
  Future<AppUser> loginWithGoogle();
  Future<AppUser> loginWithApple();
  Future<AppUser> loginWithEmail({required String email, required String password});
  Future<void> resetPassword({required String email});
  Future<void> logout();
}
