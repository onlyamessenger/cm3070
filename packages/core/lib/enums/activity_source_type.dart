enum ActivitySourceType {
  quest,
  challenge,
  checkIn,
  bonus;

  String get displayName {
    switch (this) {
      case ActivitySourceType.quest:
        return 'Quest';
      case ActivitySourceType.challenge:
        return 'Challenge';
      case ActivitySourceType.checkIn:
        return 'Check-in';
      case ActivitySourceType.bonus:
        return 'Bonus';
    }
  }

  static ActivitySourceType fromString(String value) {
    return ActivitySourceType.values.firstWhere(
      (ActivitySourceType e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid ActivitySourceType: $value'),
    );
  }
}
