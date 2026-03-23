import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart' as models;

class AppWriteAuthService implements AuthService {
  final Users _users;

  AppWriteAuthService({required Users users}) : _users = users;

  @override
  Future<String> createAccount({required String email, required String password, required String name}) async {
    final models.User user = await _users.create(userId: ID.unique(), email: email, password: password, name: name);
    return user.$id;
  }

  @override
  Future<void> deleteAccount({required String userId}) async {
    await _users.delete(userId: userId);
  }
}
