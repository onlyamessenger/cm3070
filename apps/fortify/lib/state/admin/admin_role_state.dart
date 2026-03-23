import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:fortify/models/role_member.dart';

/// Pure data container for role management state.
class AdminRoleState extends ChangeNotifier {
  List<RoleMember> _members = <RoleMember>[];
  UnmodifiableListView<RoleMember> get members => UnmodifiableListView<RoleMember>(_members);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void setMembers(List<RoleMember> value) {
    _members = value;
    notifyListeners();
  }

  void addMember(RoleMember member) {
    _members = <RoleMember>[..._members, member];
    notifyListeners();
  }

  void removeMember(String memberId) {
    _members = _members.where((RoleMember m) => m.id != memberId).toList();
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
