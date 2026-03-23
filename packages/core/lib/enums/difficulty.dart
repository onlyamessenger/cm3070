enum Difficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (Difficulty e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid Difficulty: $value'),
    );
  }
}
