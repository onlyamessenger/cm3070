import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import 'package:fortify/interface/services/role_service.dart';
import 'package:fortify/models/role_member.dart';

class AppWriteRoleService implements RoleService {
  final Teams _teams;
  final String _adminTeamId;

  AppWriteRoleService({required Teams teams, required String adminTeamId}) : _teams = teams, _adminTeamId = adminTeamId;

  @override
  Future<List<RoleMember>> getMembers() async {
    final models.MembershipList result = await _teams.listMemberships(teamId: _adminTeamId);
    return result.memberships.map((models.Membership m) {
      return RoleMember(
        id: m.$id,
        userId: m.userId,
        userName: m.userName.isNotEmpty ? m.userName : m.userEmail.split('@').first,
        userEmail: m.userEmail,
        role: m.teamName.isNotEmpty ? m.teamName : 'Admin',
        confirmed: m.confirm,
        joinedAt: DateTime.parse(m.$createdAt),
      );
    }).toList();
  }

  @override
  Future<void> inviteMember({required String email}) async {
    await _teams.createMembership(
      teamId: _adminTeamId,
      email: email,
      roles: <String>['admin'],
      url: 'https://fortify.app/invite',
    );
  }

  @override
  Future<void> removeMember({required String memberId}) async {
    await _teams.deleteMembership(teamId: _adminTeamId, membershipId: memberId);
  }

  @override
  Future<bool> isAdmin({required String userId}) async {
    try {
      final models.MembershipList result = await _teams.listMemberships(teamId: _adminTeamId);
      return result.memberships.any((models.Membership m) => m.userId == userId);
    } on AppwriteException {
      return false;
    }
  }
}
