import 'package:fortify/interface/services/role_service.dart';
import 'package:fortify/models/role_member.dart';
import 'package:fortify/state/admin/admin_role_state.dart';

/// Orchestrates role management side effects.
class AdminRoleController {
  final RoleService _roleService;
  final AdminRoleState _state;

  AdminRoleController({required RoleService roleService, required AdminRoleState state})
    : _roleService = roleService,
      _state = state;

  Future<void> loadMembers() async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<RoleMember> members = await _roleService.getMembers();
      _state.setMembers(members);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> inviteMember({required String email}) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _roleService.inviteMember(email: email);
      await loadMembers();
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> removeMember({required String memberId}) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _roleService.removeMember(memberId: memberId);
      _state.removeMember(memberId);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }
}
