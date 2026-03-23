import 'package:core/enums/enums.dart';
import 'package:core/models/models.dart';
import 'package:test/test.dart';

DateTime _dt(int day) => DateTime(2026, 1, day);

// ---------------------------------------------------------------------------
// Shared base fixture helpers
// ---------------------------------------------------------------------------

ModelBase _baseModel() =>
    ModelBase(id: 'id-1', created: _dt(1), updated: _dt(2), createdBy: 'user-a', updatedBy: 'user-b');

ContentBase _contentBase() => ContentBase(
  id: 'id-1',
  created: _dt(1),
  updated: _dt(2),
  createdBy: 'user-a',
  updatedBy: 'user-b',
  source: ContentSource.human,
);

void main() {
  // -------------------------------------------------------------------------
  // ModelBase
  // -------------------------------------------------------------------------
  group('ModelBase', () {
    test('constructor sets all fields', () {
      final ModelBase m = _baseModel();

      expect(m.id, 'id-1');
      expect(m.created, _dt(1));
      expect(m.updated, _dt(2));
      expect(m.createdBy, 'user-a');
      expect(m.updatedBy, 'user-b');
    });

    test('isDeleted defaults to false', () {
      final ModelBase m = _baseModel();

      expect(m.isDeleted, isFalse);
    });

    test('copyWith overrides each field', () {
      final ModelBase m = _baseModel().copyWith(
        id: 'id-2',
        created: _dt(3),
        updated: _dt(4),
        createdBy: 'user-c',
        updatedBy: 'user-d',
        isDeleted: true,
      );

      expect(m.id, 'id-2');
      expect(m.created, _dt(3));
      expect(m.updated, _dt(4));
      expect(m.createdBy, 'user-c');
      expect(m.updatedBy, 'user-d');
      expect(m.isDeleted, isTrue);
    });

    test('copyWith with no args preserves all values', () {
      final ModelBase original = _baseModel();
      final ModelBase copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.created, original.created);
      expect(copy.updated, original.updated);
      expect(copy.createdBy, original.createdBy);
      expect(copy.updatedBy, original.updatedBy);
      expect(copy.isDeleted, original.isDeleted);
    });
  });

  // -------------------------------------------------------------------------
  // ContentBase
  // -------------------------------------------------------------------------
  group('ContentBase', () {
    test('constructor sets source and isPublished defaults to false', () {
      final ContentBase c = _contentBase();

      expect(c.source, ContentSource.human);
      expect(c.isPublished, isFalse);
    });

    test('copyWith overrides source and isPublished', () {
      final ContentBase c = _contentBase().copyWith(source: ContentSource.llm, isPublished: true);

      expect(c.source, ContentSource.llm);
      expect(c.isPublished, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Player
  // -------------------------------------------------------------------------
  group('Player', () {
    Player _player() => Player(
      id: 'p-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      userId: 'u-1',
      displayName: 'Hero',
      lastActiveDate: _dt(5),
    );

    test('defaults are correct', () {
      final Player p = _player();

      expect(p.xp, 0);
      expect(p.currentStreak, 0);
      expect(p.longestStreak, 0);
      expect(p.streakShieldAvailable, isTrue);
      expect(p.streakShieldUsedAt, isNull);
    });

    test('copyWith overrides player-specific fields', () {
      final Player p = _player().copyWith(
        userId: 'u-2',
        displayName: 'Veteran',
        xp: 500,
        currentStreak: 7,
        longestStreak: 14,
        streakShieldAvailable: false,
        streakShieldUsedAt: _dt(3),
        lastActiveDate: _dt(10),
      );

      expect(p.userId, 'u-2');
      expect(p.displayName, 'Veteran');
      expect(p.xp, 500);
      expect(p.currentStreak, 7);
      expect(p.longestStreak, 14);
      expect(p.streakShieldAvailable, isFalse);
      expect(p.streakShieldUsedAt, _dt(3));
      expect(p.lastActiveDate, _dt(10));
    });

    test('Player.copyWith can clear streakShieldUsedAt', () {
      final Player player = Player(
        id: 'p1',
        created: DateTime(2026, 1, 1),
        updated: DateTime(2026, 1, 1),
        createdBy: 'u1',
        updatedBy: 'u1',
        userId: 'u1',
        displayName: 'Test',
        lastActiveDate: DateTime(2026, 1, 1),
        streakShieldUsedAt: DateTime(2026, 1, 15),
      );

      final Player cleared = player.copyWith(clearStreakShieldUsedAt: true);

      expect(cleared.streakShieldUsedAt, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Level
  // -------------------------------------------------------------------------
  group('Level', () {
    Level _level() => Level(
      id: 'lv-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      source: ContentSource.human,
      level: 1,
      title: 'Survivor',
      icon: 'shield',
      xpThreshold: 100,
    );

    test('description defaults to empty string', () {
      final Level l = _level();

      expect(l.description, '');
      expect(l.isPublished, isFalse);
    });

    test('copyWith overrides level-specific fields', () {
      final Level l = _level().copyWith(
        level: 2,
        title: 'Defender',
        description: 'A brave soul',
        icon: 'sword',
        xpThreshold: 300,
      );

      expect(l.level, 2);
      expect(l.title, 'Defender');
      expect(l.description, 'A brave soul');
      expect(l.icon, 'sword');
      expect(l.xpThreshold, 300);
    });
  });

  // -------------------------------------------------------------------------
  // Quest
  // -------------------------------------------------------------------------
  group('Quest', () {
    Quest _quest() => Quest(
      id: 'q-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      source: ContentSource.llm,
      title: 'Flood Prep',
      description: 'Get ready for floods.',
      totalDays: 7,
      startNodeId: 'node-1',
      difficulty: Difficulty.beginner,
      disasterType: DisasterType.flood,
    );

    test('region defaults to null', () {
      final Quest q = _quest();

      expect(q.region, isNull);
    });

    test('copyWith overrides quest-specific fields', () {
      final Quest q = _quest().copyWith(
        title: 'Cyclone Ready',
        description: 'Prepare for cyclones.',
        totalDays: 14,
        startNodeId: 'node-2',
        difficulty: Difficulty.advanced,
        disasterType: DisasterType.cyclone,
        region: 'Queensland',
      );

      expect(q.title, 'Cyclone Ready');
      expect(q.description, 'Prepare for cyclones.');
      expect(q.totalDays, 14);
      expect(q.startNodeId, 'node-2');
      expect(q.difficulty, Difficulty.advanced);
      expect(q.disasterType, DisasterType.cyclone);
      expect(q.region, 'Queensland');
    });
  });

  // -------------------------------------------------------------------------
  // Challenge
  // -------------------------------------------------------------------------
  group('Challenge', () {
    Challenge _challenge() => Challenge(
      id: 'ch-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      source: ContentSource.human,
      type: ChallengeType.quiz,
      title: 'Flood Quiz',
      description: 'Test your flood knowledge.',
      xpReward: 50,
      difficulty: Difficulty.beginner,
      disasterType: DisasterType.flood,
    );

    test('nullable fields default to null', () {
      final Challenge c = _challenge();

      expect(c.questId, isNull);
      expect(c.unlocksSectionType, isNull);
    });

    test('copyWith overrides challenge-specific fields', () {
      final Challenge c = _challenge().copyWith(
        type: ChallengeType.checklist,
        title: 'Kit Check',
        description: 'Check your kit.',
        xpReward: 100,
        difficulty: Difficulty.intermediate,
        disasterType: DisasterType.bushfire,
        questId: 'q-1',
        unlocksSectionType: 'emergencyKit',
      );

      expect(c.type, ChallengeType.checklist);
      expect(c.title, 'Kit Check');
      expect(c.description, 'Check your kit.');
      expect(c.xpReward, 100);
      expect(c.difficulty, Difficulty.intermediate);
      expect(c.disasterType, DisasterType.bushfire);
      expect(c.questId, 'q-1');
      expect(c.unlocksSectionType, 'emergencyKit');
    });
  });

  // -------------------------------------------------------------------------
  // ChallengeQuestion
  // -------------------------------------------------------------------------
  group('ChallengeQuestion', () {
    ChallengeQuestion _question() => ChallengeQuestion(
      id: 'cq-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      challengeId: 'ch-1',
      sortOrder: 0,
      questionText: 'What is a go-bag?',
      options: const <String>['A bag', 'A car', 'A boat'],
      correctIndex: 0,
    );

    test('constructor sets all fields', () {
      final ChallengeQuestion q = _question();

      expect(q.challengeId, 'ch-1');
      expect(q.sortOrder, 0);
      expect(q.questionText, 'What is a go-bag?');
      expect(q.options, <String>['A bag', 'A car', 'A boat']);
      expect(q.correctIndex, 0);
    });

    test('copyWith overrides fields', () {
      final ChallengeQuestion q = _question().copyWith(
        challengeId: 'ch-2',
        sortOrder: 1,
        questionText: 'How many days of supplies?',
        options: const <String>['3', '7', '14'],
        correctIndex: 1,
      );

      expect(q.challengeId, 'ch-2');
      expect(q.sortOrder, 1);
      expect(q.questionText, 'How many days of supplies?');
      expect(q.options, <String>['3', '7', '14']);
      expect(q.correctIndex, 1);
    });
  });

  // -------------------------------------------------------------------------
  // QuestNode
  // -------------------------------------------------------------------------
  group('QuestNode', () {
    QuestNode _node() => QuestNode(
      id: 'n-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      questId: 'q-1',
      day: 1,
      text: 'Day one text.',
      summary: 'Day one summary.',
      unlocksSectionType: 'emergencyKit',
    );

    test('defaults are correct', () {
      final QuestNode n = QuestNode(
        id: 'n-2',
        created: _dt(1),
        updated: _dt(1),
        createdBy: 'sys',
        updatedBy: 'sys',
        questId: 'q-1',
        day: 2,
        text: 'Day two.',
      );

      expect(n.isOutcome, isFalse);
      expect(n.xpReward, 0);
      expect(n.summary, isNull);
      expect(n.choices, isEmpty);
      expect(n.unlocksSectionType, isNull);
    });

    test('copyWith overrides fields', () {
      final QuestChoice choice = const QuestChoice(label: 'Go', nextNodeId: 'n-3');
      final QuestNode n = _node().copyWith(
        day: 2,
        text: 'Updated text.',
        isOutcome: true,
        xpReward: 25,
        choices: <QuestChoice>[choice],
      );

      expect(n.day, 2);
      expect(n.text, 'Updated text.');
      expect(n.isOutcome, isTrue);
      expect(n.xpReward, 25);
      expect(n.choices, <QuestChoice>[choice]);
    });

    test('clearSummary flag nullifies summary', () {
      final QuestNode n = _node().copyWith(clearSummary: true);

      expect(n.summary, isNull);
    });

    test('clearUnlocksSectionType flag nullifies unlocksSectionType', () {
      final QuestNode n = _node().copyWith(clearUnlocksSectionType: true);

      expect(n.unlocksSectionType, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // QuestChoice
  // -------------------------------------------------------------------------
  group('QuestChoice', () {
    test('constructor sets fields and xpReward defaults to 0', () {
      const QuestChoice c = QuestChoice(label: 'Evacuate', nextNodeId: 'n-2');

      expect(c.label, 'Evacuate');
      expect(c.nextNodeId, 'n-2');
      expect(c.xpReward, 0);
    });

    test('copyWith overrides fields', () {
      const QuestChoice original = QuestChoice(label: 'Stay', nextNodeId: 'n-3', xpReward: 10);
      final QuestChoice copy = original.copyWith(label: 'Run', xpReward: 20);

      expect(copy.label, 'Run');
      expect(copy.nextNodeId, 'n-3');
      expect(copy.xpReward, 20);
    });

    test('fromMap / toMap round-trip', () {
      const QuestChoice original = QuestChoice(label: 'Shelter', nextNodeId: 'n-4', xpReward: 5);
      final Map<String, dynamic> map = original.toMap();
      final QuestChoice restored = QuestChoice.fromMap(map);

      expect(restored.label, original.label);
      expect(restored.nextNodeId, original.nextNodeId);
      expect(restored.xpReward, original.xpReward);
    });
  });

  // -------------------------------------------------------------------------
  // KitItem
  // -------------------------------------------------------------------------
  group('KitItem', () {
    KitItem _kitItem() => KitItem(
      id: 'ki-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      source: ContentSource.human,
      itemName: 'Torch',
      sortOrder: 0,
    );

    test('defaults are correct', () {
      final KitItem k = _kitItem();

      expect(k.userId, isNull);
      expect(k.description, '');
      expect(k.isChecked, isFalse);
      expect(k.checkedAt, isNull);
    });

    test('copyWith overrides fields', () {
      final KitItem k = _kitItem().copyWith(
        userId: 'u-1',
        itemName: 'First Aid Kit',
        description: 'Full kit',
        sortOrder: 1,
        isChecked: true,
        checkedAt: _dt(5),
      );

      expect(k.userId, 'u-1');
      expect(k.itemName, 'First Aid Kit');
      expect(k.description, 'Full kit');
      expect(k.sortOrder, 1);
      expect(k.isChecked, isTrue);
      expect(k.checkedAt, _dt(5));
    });
  });

  // -------------------------------------------------------------------------
  // BonusEvent
  // -------------------------------------------------------------------------
  group('BonusEvent', () {
    BonusEvent _event() => BonusEvent(
      id: 'be-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      title: 'Double XP Weekend',
      description: 'Earn double XP.',
      multiplier: 2.0,
      startsAt: _dt(5),
      endsAt: _dt(7),
    );

    test('isActive defaults to false', () {
      final BonusEvent e = _event();

      expect(e.isActive, isFalse);
    });

    test('copyWith overrides fields', () {
      final BonusEvent e = _event().copyWith(
        title: 'Triple XP',
        multiplier: 3.0,
        startsAt: _dt(10),
        endsAt: _dt(12),
        isActive: true,
      );

      expect(e.title, 'Triple XP');
      expect(e.multiplier, 3.0);
      expect(e.startsAt, _dt(10));
      expect(e.endsAt, _dt(12));
      expect(e.isActive, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // PlayerQuestProgress
  // -------------------------------------------------------------------------
  group('PlayerQuestProgress', () {
    PlayerQuestProgress _progress() => PlayerQuestProgress(
      id: 'pqp-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      userId: 'u-1',
      questId: 'q-1',
      currentNodeId: 'n-1',
    );

    test('defaults are correct', () {
      final PlayerQuestProgress p = _progress();

      expect(p.isCompleted, isFalse);
      expect(p.visitedNodeIds, isEmpty);
      expect(p.xpEarned, 0);
      expect(p.completedAt, isNull);
    });

    test('copyWith overrides fields', () {
      final PlayerQuestProgress p = _progress().copyWith(
        currentNodeId: 'n-5',
        isCompleted: true,
        visitedNodeIds: const <String>['n-1', 'n-2'],
        xpEarned: 75,
        completedAt: _dt(15),
      );

      expect(p.currentNodeId, 'n-5');
      expect(p.isCompleted, isTrue);
      expect(p.visitedNodeIds, <String>['n-1', 'n-2']);
      expect(p.xpEarned, 75);
      expect(p.completedAt, _dt(15));
    });
  });

  // -------------------------------------------------------------------------
  // PlayerChallengeProgress
  // -------------------------------------------------------------------------
  group('PlayerChallengeProgress', () {
    PlayerChallengeProgress _progress() => PlayerChallengeProgress(
      id: 'pcp-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      userId: 'u-1',
      challengeId: 'ch-1',
    );

    test('defaults are correct', () {
      final PlayerChallengeProgress p = _progress();

      expect(p.isCompleted, isFalse);
      expect(p.currentQuestionIndex, 0);
      expect(p.answers, isEmpty);
      expect(p.correctCount, 0);
      expect(p.xpEarned, 0);
      expect(p.completedAt, isNull);
    });

    test('copyWith overrides fields', () {
      final PlayerChallengeProgress p = _progress().copyWith(
        isCompleted: true,
        currentQuestionIndex: 3,
        answers: const <int>[0, 1, 2],
        correctCount: 2,
        xpEarned: 50,
        completedAt: _dt(20),
      );

      expect(p.isCompleted, isTrue);
      expect(p.currentQuestionIndex, 3);
      expect(p.answers, <int>[0, 1, 2]);
      expect(p.correctCount, 2);
      expect(p.xpEarned, 50);
      expect(p.completedAt, _dt(20));
    });
  });

  // -------------------------------------------------------------------------
  // ReadinessSection
  // -------------------------------------------------------------------------
  group('ReadinessSection', () {
    ReadinessSection _section() => ReadinessSection(
      id: 'rs-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      userId: 'u-1',
      sectionType: ReadinessSectionType.emergencyKit,
    );

    test('defaults are correct', () {
      final ReadinessSection s = _section();

      expect(s.isUnlocked, isFalse);
      expect(s.unlockedAt, isNull);
      expect(s.unlockedByType, isNull);
      expect(s.unlockedById, isNull);
    });

    test('copyWith overrides fields', () {
      final ReadinessSection s = _section().copyWith(
        sectionType: ReadinessSectionType.evacuationRoutes,
        isUnlocked: true,
        unlockedAt: _dt(8),
        unlockedByType: 'challenge',
        unlockedById: 'ch-1',
      );

      expect(s.sectionType, ReadinessSectionType.evacuationRoutes);
      expect(s.isUnlocked, isTrue);
      expect(s.unlockedAt, _dt(8));
      expect(s.unlockedByType, 'challenge');
      expect(s.unlockedById, 'ch-1');
    });
  });

  // -------------------------------------------------------------------------
  // ActivityLogEntry
  // -------------------------------------------------------------------------
  group('ActivityLogEntry', () {
    ActivityLogEntry _entry() => ActivityLogEntry(
      id: 'al-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      userId: 'u-1',
      action: 'completed_challenge',
      xpAmount: 50,
    );

    test('nullable fields default to null', () {
      final ActivityLogEntry e = _entry();

      expect(e.sourceType, isNull);
      expect(e.sourceId, isNull);
      expect(e.multiplierApplied, isNull);
    });

    test('copyWith overrides fields', () {
      final ActivityLogEntry e = _entry().copyWith(
        action: 'completed_quest',
        xpAmount: 100,
        sourceType: ActivitySourceType.quest,
        sourceId: 'q-1',
        multiplierApplied: 2.0,
      );

      expect(e.action, 'completed_quest');
      expect(e.xpAmount, 100);
      expect(e.sourceType, ActivitySourceType.quest);
      expect(e.sourceId, 'q-1');
      expect(e.multiplierApplied, 2.0);
    });
  });

  // -------------------------------------------------------------------------
  // Party
  // -------------------------------------------------------------------------
  group('Party', () {
    Party _party() => Party(
      id: 'pt-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      name: 'Alpha Squad',
      createdByUserId: 'u-1',
    );

    test('weeklyXp fields default to 0', () {
      final Party p = _party();

      expect(p.weeklyXpTarget, 0);
      expect(p.weeklyXpCurrent, 0);
    });

    test('copyWith overrides fields', () {
      final Party p = _party().copyWith(
        name: 'Bravo Squad',
        createdByUserId: 'u-2',
        weeklyXpTarget: 500,
        weeklyXpCurrent: 120,
      );

      expect(p.name, 'Bravo Squad');
      expect(p.createdByUserId, 'u-2');
      expect(p.weeklyXpTarget, 500);
      expect(p.weeklyXpCurrent, 120);
    });
  });

  // -------------------------------------------------------------------------
  // PartyMember
  // -------------------------------------------------------------------------
  group('PartyMember', () {
    PartyMember _member() => PartyMember(
      id: 'pm-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      partyId: 'pt-1',
      userId: 'u-1',
      role: PartyMemberRole.member,
      joinedAt: _dt(1),
    );

    test('weeklyXpContribution defaults to 0', () {
      final PartyMember m = _member();

      expect(m.weeklyXpContribution, 0);
    });

    test('copyWith overrides fields', () {
      final PartyMember m = _member().copyWith(
        partyId: 'pt-2',
        userId: 'u-3',
        role: PartyMemberRole.leader,
        weeklyXpContribution: 200,
        joinedAt: _dt(5),
      );

      expect(m.partyId, 'pt-2');
      expect(m.userId, 'u-3');
      expect(m.role, PartyMemberRole.leader);
      expect(m.weeklyXpContribution, 200);
      expect(m.joinedAt, _dt(5));
    });
  });

  // -------------------------------------------------------------------------
  // PartyChallenge
  // -------------------------------------------------------------------------
  group('PartyChallenge', () {
    PartyChallenge _partyChallenge() => PartyChallenge(
      id: 'pc-1',
      created: _dt(1),
      updated: _dt(1),
      createdBy: 'sys',
      updatedBy: 'sys',
      source: ContentSource.llm,
      partyId: 'pt-1',
      type: PartyChallengeType.chain,
      title: 'Group Kit Check',
      description: 'Everyone checks their kit.',
    );

    test('defaults are correct', () {
      final PartyChallenge c = _partyChallenge();

      expect(c.isCompleted, isFalse);
      expect(c.isWeatherTriggered, isFalse);
      expect(c.expiresAt, isNull);
      expect(c.taskData, '{}');
      expect(c.memberProgress, '{}');
    });

    test('copyWith overrides fields', () {
      final PartyChallenge c = _partyChallenge().copyWith(
        type: PartyChallengeType.groupXpTarget,
        title: 'XP Race',
        description: 'Hit the target.',
        isCompleted: true,
        isWeatherTriggered: true,
        expiresAt: _dt(28),
        taskData: '{"target":1000}',
        memberProgress: '{"u-1":500}',
      );

      expect(c.type, PartyChallengeType.groupXpTarget);
      expect(c.title, 'XP Race');
      expect(c.description, 'Hit the target.');
      expect(c.isCompleted, isTrue);
      expect(c.isWeatherTriggered, isTrue);
      expect(c.expiresAt, _dt(28));
      expect(c.taskData, '{"target":1000}');
      expect(c.memberProgress, '{"u-1":500}');
    });
  });
}
