/// Admin-only model representing a member with an assigned role.
/// Maps from AppWrite Team Membership internally.
class RoleMember {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String role;
  final bool confirmed;
  final DateTime joinedAt;

  RoleMember({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    required this.confirmed,
    required this.joinedAt,
  });
}
