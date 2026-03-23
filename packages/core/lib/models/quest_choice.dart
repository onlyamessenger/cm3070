class QuestChoice {
  final String label;
  final String nextNodeId;
  final int xpReward;

  const QuestChoice({required this.label, required this.nextNodeId, this.xpReward = 0});

  factory QuestChoice.fromMap(Map<String, dynamic> map) {
    return QuestChoice(
      label: map['label'] as String,
      nextNodeId: map['nextNodeId'] as String,
      xpReward: map['xpReward'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'label': label, 'nextNodeId': nextNodeId, 'xpReward': xpReward};
  }

  QuestChoice copyWith({String? label, String? nextNodeId, int? xpReward}) {
    return QuestChoice(
      label: label ?? this.label,
      nextNodeId: nextNodeId ?? this.nextNodeId,
      xpReward: xpReward ?? this.xpReward,
    );
  }
}
