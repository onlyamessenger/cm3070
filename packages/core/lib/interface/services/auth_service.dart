abstract class AuthService {
  Future<String> createAccount({required String email, required String password, required String name});
  Future<void> deleteAccount({required String userId});
}
