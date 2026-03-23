enum PartyChallengeType {
  chain,
  groupXpTarget,
  groupChecklist;

  String get displayName {
    switch (this) {
      case PartyChallengeType.chain:
        return 'Chain';
      case PartyChallengeType.groupXpTarget:
        return 'Group XP Target';
      case PartyChallengeType.groupChecklist:
        return 'Group Checklist';
    }
  }

  static PartyChallengeType fromString(String value) {
    return PartyChallengeType.values.firstWhere(
      (PartyChallengeType e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid PartyChallengeType: $value'),
    );
  }
}
