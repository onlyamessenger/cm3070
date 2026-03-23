enum ChallengeType {
  quiz,
  checklist,
  timed,
  decision;

  String get displayName {
    switch (this) {
      case ChallengeType.quiz:
        return 'Quiz';
      case ChallengeType.checklist:
        return 'Checklist';
      case ChallengeType.timed:
        return 'Timed';
      case ChallengeType.decision:
        return 'Decision';
    }
  }

  static ChallengeType fromString(String value) {
    return ChallengeType.values.firstWhere(
      (ChallengeType e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid ChallengeType: $value'),
    );
  }
}
