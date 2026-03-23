import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWriteRoleService implements RoleService {
  final Teams _teams;

  AppWriteRoleService({required Teams teams}) : _teams = teams;

  @override
  Future<void> addToTeam({required String userId, required String teamId}) async {
    await _teams.createMembership(teamId: teamId, roles: <String>['player'], userId: userId);
  }
}
