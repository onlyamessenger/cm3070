import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;

import 'package:fortify/interface/services/auth_service.dart';
import 'package:fortify/models/app_user.dart';

class AppWriteAuthService implements AuthService {
  final Account _account;

  AppWriteAuthService({required Account account}) : _account = account;

  AppUser _mapUser(models.User user) {
    return AppUser(id: user.$id, name: user.name, email: user.email);
  }

  @override
  Future<AppUser?> getCurrentSession() async {
    try {
      final models.User user = await _account.get();
      return _mapUser(user);
    } on AppwriteException {
      return null;
    }
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    await _account.createOAuth2Token(provider: OAuthProvider.google);
    final models.User user = await _account.get();
    return _mapUser(user);
  }

  @override
  Future<AppUser> loginWithApple() async {
    await _account.createOAuth2Token(provider: OAuthProvider.apple);
    final models.User user = await _account.get();
    return _mapUser(user);
  }

  @override
  Future<AppUser> loginWithEmail({required String email, required String password}) async {
    await _account.createEmailPasswordSession(email: email, password: password);
    final models.User user = await _account.get();
    return _mapUser(user);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _account.createRecovery(email: email, url: 'https://fortify.app/reset-password');
  }

  @override
  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }
}
