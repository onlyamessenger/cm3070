import 'package:core/core.dart';
import 'package:test/test.dart';

class MockAuthService implements AuthService {
  bool shouldFail;
  String? deletedUserId;

  MockAuthService({this.shouldFail = false});

  @override
  Future<String> createAccount({required String email, required String password, required String name}) async {
    if (shouldFail) throw Exception('auth failed');
    return 'user-123';
  }

  @override
  Future<void> deleteAccount({required String userId}) async {
    deletedUserId = userId;
  }
}

class MockPlayerService implements PlayerService {
  bool shouldFail;
  String? capturedUserId;
  String? capturedDisplayName;

  MockPlayerService({this.shouldFail = false});

  @override
  Future<Player> createPlayer({required String userId, required String displayName}) async {
    if (shouldFail) throw Exception('player creation failed');
    capturedUserId = userId;
    capturedDisplayName = displayName;
    return Player(
      id: 'player-1',
      created: DateTime(2026, 1, 1),
      updated: DateTime(2026, 1, 1),
      createdBy: userId,
      updatedBy: userId,
      userId: userId,
      displayName: displayName,
      lastActiveDate: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<Player> getPlayer(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateXp({required String userId, required int xpToAdd}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCheckInState({
    required String playerId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
    required bool streakShieldAvailable,
    DateTime? streakShieldUsedAt,
    required bool clearStreakShieldUsedAt,
  }) async {
    throw UnimplementedError();
  }
}

class MockRoleService implements RoleService {
  bool shouldFail;
  String? capturedUserId;
  String? capturedTeamId;

  MockRoleService({this.shouldFail = false});

  @override
  Future<void> addToTeam({required String userId, required String teamId}) async {
    if (shouldFail) throw Exception('role add failed');
    capturedUserId = userId;
    capturedTeamId = teamId;
  }
}

class MockLoggerService implements LoggerService {
  @override
  void info(String message) {}

  @override
  void error(String message) {}
}

class MockReadinessSectionService implements ReadinessSectionService {
  List<ReadinessSection> createdSections = <ReadinessSection>[];

  @override
  Future<ReadinessSection> createSection(ReadinessSection section) async {
    createdSections.add(section);
    return section.copyWith(id: 'section-${createdSections.length}');
  }

  @override
  Future<ReadinessSection> getSection(String sectionId) async => throw UnimplementedError();

  @override
  Future<List<ReadinessSection>> getSectionsForUser(String userId) async => throw UnimplementedError();

  @override
  Future<ReadinessSection> updateSection(ReadinessSection section) async => throw UnimplementedError();
}

class MockKitItemService implements KitItemService {
  List<KitItem> templates = <KitItem>[];
  List<KitItem> createdItems = <KitItem>[];

  @override
  Future<List<KitItem>> getPublishedTemplates() async => templates;

  @override
  Future<KitItem> createKitItem(KitItem item) async {
    createdItems.add(item);
    return item.copyWith(id: 'kit-${createdItems.length}');
  }
}

const String _teamId = 'team-players';

RegisterPlayer _makeUseCase({
  MockAuthService? auth,
  MockPlayerService? player,
  MockRoleService? role,
  MockReadinessSectionService? sectionService,
  MockKitItemService? kitItemService,
}) {
  return RegisterPlayer(
    authService: auth ?? MockAuthService(),
    playerService: player ?? MockPlayerService(),
    roleService: role ?? MockRoleService(),
    sectionService: sectionService ?? MockReadinessSectionService(),
    kitItemService: kitItemService ?? MockKitItemService(),
    logger: MockLoggerService(),
    playerTeamId: _teamId,
  );
}

RegisterPlayerInput _input() => const RegisterPlayerInput(email: 'hero@example.com', password: 's3cret!', name: 'Hero');

void main() {
  group('RegisterPlayer', () {
    test('happy path: creates account, adds to team, creates player', () async {
      final MockAuthService auth = MockAuthService();
      final MockPlayerService playerService = MockPlayerService();
      final MockRoleService role = MockRoleService();

      final RegisterPlayer useCase = _makeUseCase(auth: auth, player: playerService, role: role);

      final Player result = await useCase.execute(_input());

      expect(result.userId, 'user-123');
      expect(result.displayName, 'Hero');
      expect(role.capturedUserId, 'user-123');
      expect(role.capturedTeamId, _teamId);
      expect(playerService.capturedUserId, 'user-123');
    });

    test('rolls back auth when team add fails', () async {
      final MockAuthService auth = MockAuthService();
      final MockRoleService role = MockRoleService(shouldFail: true);

      final RegisterPlayer useCase = _makeUseCase(auth: auth, role: role);

      await expectLater(useCase.execute(_input()), throwsException);

      expect(auth.deletedUserId, 'user-123');
    });

    test('rolls back auth when player creation fails', () async {
      final MockAuthService auth = MockAuthService();
      final MockPlayerService playerService = MockPlayerService(shouldFail: true);

      final RegisterPlayer useCase = _makeUseCase(auth: auth, player: playerService);

      await expectLater(useCase.execute(_input()), throwsException);

      expect(auth.deletedUserId, 'user-123');
    });

    test('does NOT roll back when auth creation itself fails', () async {
      final MockAuthService auth = MockAuthService(shouldFail: true);

      final RegisterPlayer useCase = _makeUseCase(auth: auth);

      await expectLater(useCase.execute(_input()), throwsException);

      expect(auth.deletedUserId, isNull);
    });

    test('seeds readiness sections and clones kit items', () async {
      final MockReadinessSectionService sectionService = MockReadinessSectionService();
      final MockKitItemService kitItemService = MockKitItemService();
      kitItemService.templates = <KitItem>[
        KitItem(
          id: 'tpl-1',
          created: DateTime(2026, 1, 1),
          updated: DateTime(2026, 1, 1),
          createdBy: 'admin',
          updatedBy: 'admin',
          source: ContentSource.human,
          isPublished: true,
          itemName: 'Water',
          description: 'Store water',
          sortOrder: 1,
        ),
      ];

      final RegisterPlayer useCase = _makeUseCase(sectionService: sectionService, kitItemService: kitItemService);

      await useCase.execute(_input());

      expect(sectionService.createdSections.length, 5);
      final List<bool> unlockStates = sectionService.createdSections.map((ReadinessSection s) => s.isUnlocked).toList();
      expect(unlockStates.where((bool u) => u).length, 1);
      expect(
        sectionService.createdSections.firstWhere((ReadinessSection s) => s.isUnlocked).sectionType,
        ReadinessSectionType.floodRisk,
      );

      expect(kitItemService.createdItems.length, 1);
      expect(kitItemService.createdItems.first.userId, 'user-123');
      expect(kitItemService.createdItems.first.itemName, 'Water');
    });
  });
}
