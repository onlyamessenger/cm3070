/// Provider-agnostic user model.
/// Decouples the app from AppWrite's models.User.
class AppUser {
  final String id;
  final String name;
  final String email;

  AppUser({required this.id, required this.name, required this.email});
}
