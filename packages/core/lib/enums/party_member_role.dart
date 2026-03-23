enum PartyMemberRole {
  leader,
  member;

  String get displayName {
    switch (this) {
      case PartyMemberRole.leader:
        return 'Leader';
      case PartyMemberRole.member:
        return 'Member';
    }
  }

  static PartyMemberRole fromString(String value) {
    return PartyMemberRole.values.firstWhere(
      (PartyMemberRole e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid PartyMemberRole: $value'),
    );
  }
}
