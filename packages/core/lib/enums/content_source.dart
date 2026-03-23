enum ContentSource {
  human,
  llm;

  String get displayName {
    switch (this) {
      case ContentSource.human:
        return 'Human';
      case ContentSource.llm:
        return 'LLM';
    }
  }

  static ContentSource fromString(String value) {
    return ContentSource.values.firstWhere(
      (ContentSource e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid ContentSource: $value'),
    );
  }
}
