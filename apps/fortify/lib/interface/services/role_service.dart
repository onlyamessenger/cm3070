import 'package:fortify/models/role_member.dart';

/// Abstract role management service.
/// Maps to AppWrite Teams API internally, but consumers
/// only see domain terminology (Role, RoleMember).
abstract class RoleService {
  Future<List<RoleMember>> getMembers();
  Future<void> inviteMember({required String email});
  Future<void> removeMember({required String memberId});
  Future<bool> isAdmin({required String userId});
}
