import 'package:core/core.dart';
import 'package:test/test.dart';

// ── Mocks ──

class MockPlayerService implements PlayerService {
  Player? playerToReturn;
  String? updatedPlayerId;
  int? updatedCurrentStreak;
  int? updatedLongestStreak;
  DateTime? updatedLastActiveDate;
  bool? updatedShieldAvailable;
  DateTime? updatedShieldUsedAt;
  bool? updatedClearShield;

  @override
  Future<Player> getPlayer(String userId) async => playerToReturn!;

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
    updatedPlayerId = playerId;
    updatedCurrentStreak = currentStreak;
    updatedLongestStreak = longestStreak;
    updatedLastActiveDate = lastActiveDate;
    updatedShieldAvailable = streakShieldAvailable;
    updatedShieldUsedAt = streakShieldUsedAt;
    updatedClearShield = clearStreakShieldUsedAt;
  }

  @override
  Future<Player> createPlayer({required String userId, required String displayName}) async =>
      throw UnimplementedError();

  @override
  Future<void> updateXp({required String userId, required int xpToAdd}) async {}
}

class MockAwardXp extends AwardXp {
  AwardXpInput? capturedInput;

  MockAwardXp()
    : super(
        playerService: _NoOpPlayerService(),
        bonusEventService: _NoOpBonusEventService(),
        activityLogService: _NoOpActivityLogService(),
        logger: MockLoggerService(),
      );

  @override
  Future<AwardXpResult> execute(AwardXpInput input) async {
    capturedInput = input;
    return const AwardXpResult(xpAwarded: 10, multiplier: 1.0);
  }
}

class _NoOpPlayerService implements PlayerService {
  @override
  Future<Player> createPlayer({required String userId, required String displayName}) async =>
      throw UnimplementedError();
  @override
  Future<Player> getPlayer(String userId) async => throw UnimplementedError();
  @override
  Future<void> updateXp({required String userId, required int xpToAdd}) async {}
  @override
  Future<void> updateCheckInState({
    required String playerId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
    required bool streakShieldAvailable,
    DateTime? streakShieldUsedAt,
    required bool clearStreakShieldUsedAt,
  }) async {}
}

class _NoOpBonusEventService implements BonusEventService {
  @override
  Future<List<BonusEvent>> getActiveEvents(DateTime now) async => <BonusEvent>[];
}

class _NoOpActivityLogService implements ActivityLogService {
  @override
  Future<void> logActivity({
    required String userId,
    required String action,
    required int xp,
    required double multiplier,
    required ActivitySourceType sourceType,
  }) async {}
}

class MockLoggerService implements LoggerService {
  @override
  void info(String message) {}
  @override
  void error(String message) {}
}

// ── Helpers ──

Player _makePlayer({
  DateTime? lastActiveDate,
  int currentStreak = 5,
  int longestStreak = 10,
  bool streakShieldAvailable = true,
  DateTime? streakShieldUsedAt,
}) {
  return Player(
    id: 'player-1',
    created: DateTime(2026, 1, 1),
    updated: DateTime(2026, 1, 1),
    createdBy: 'user-1',
    updatedBy: 'user-1',
    userId: 'user-1',
    displayName: 'Hero',
    lastActiveDate: lastActiveDate ?? DateTime(2026, 3, 22),
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    streakShieldAvailable: streakShieldAvailable,
    streakShieldUsedAt: streakShieldUsedAt,
  );
}

DailyCheckIn _makeUseCase({required MockPlayerService playerService, MockAwardXp? awardXp}) {
  return DailyCheckIn(playerService: playerService, awardXp: awardXp ?? MockAwardXp(), logger: MockLoggerService());
}

// ── Tests ──

void main() {
  group('DailyCheckIn', () {
    late MockPlayerService playerService;
    late MockAwardXp awardXp;

    setUp(() {
      playerService = MockPlayerService();
      awardXp = MockAwardXp();
    });

    test('already checked in today returns alreadyCheckedIn', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      playerService.playerToReturn = _makePlayer(lastActiveDate: today, currentStreak: 3);

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.alreadyCheckedIn, isTrue);
      expect(result.ok, isFalse);
      expect(awardXp.capturedInput, isNull);
    });

    test('new player (currentStreak == 0, same day) gets first check-in', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      playerService.playerToReturn = _makePlayer(lastActiveDate: today, currentStreak: 0);

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.ok, isTrue);
      expect(result.currentStreak, 1);
      expect(awardXp.capturedInput, isNotNull);
    });

    test('consecutive day increments streak', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      final DateTime yesterday = DateTime.utc(2026, 3, 22);
      playerService.playerToReturn = _makePlayer(lastActiveDate: yesterday, currentStreak: 5);

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.ok, isTrue);
      expect(result.currentStreak, 6);
      expect(result.streakReset, isFalse);
      expect(playerService.updatedCurrentStreak, 6);
    });

    test('consecutive day updates longestStreak when exceeded', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      final DateTime yesterday = DateTime.utc(2026, 3, 22);
      playerService.playerToReturn = _makePlayer(lastActiveDate: yesterday, currentStreak: 10, longestStreak: 10);

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.longestStreak, 11);
      expect(playerService.updatedLongestStreak, 11);
    });

    test('missed day with shield available and useShield=false returns shield prompt', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      final DateTime twoDaysAgo = DateTime.utc(2026, 3, 21);
      playerService.playerToReturn = _makePlayer(lastActiveDate: twoDaysAgo, streakShieldAvailable: true);

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.ok, isFalse);
      expect(result.shieldAvailable, isTrue);
      expect(awardXp.capturedInput, isNull);
    });

    test('missed day with shield available and useShield=true consumes shield', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      final DateTime twoDaysAgo = DateTime.utc(2026, 3, 21);
      playerService.playerToReturn = _makePlayer(lastActiveDate: twoDaysAgo, streakShieldAvailable: true);

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: true, now: today),
      );

      expect(result.ok, isTrue);
      expect(result.currentStreak, 6);
      expect(result.streakReset, isFalse);
      expect(playerService.updatedShieldAvailable, isFalse);
      expect(awardXp.capturedInput, isNotNull);
    });

    test('missed day without shield resets streak to 1', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      final DateTime twoDaysAgo = DateTime.utc(2026, 3, 21);
      playerService.playerToReturn = _makePlayer(
        lastActiveDate: twoDaysAgo,
        streakShieldAvailable: false,
        currentStreak: 5,
      );

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.ok, isTrue);
      expect(result.currentStreak, 1);
      expect(result.streakReset, isTrue);
      expect(awardXp.capturedInput, isNotNull);
    });

    test('shield resets at start of new calendar month', () async {
      final DateTime today = DateTime.utc(2026, 3, 1);
      final DateTime lastMonth = DateTime.utc(2026, 2, 28);
      playerService.playerToReturn = _makePlayer(
        lastActiveDate: lastMonth,
        streakShieldAvailable: false,
        streakShieldUsedAt: DateTime.utc(2026, 2, 15),
      );

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.shieldAvailable, isTrue);
    });

    test('shield does NOT reset within same calendar month', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      final DateTime yesterday = DateTime.utc(2026, 3, 22);
      playerService.playerToReturn = _makePlayer(
        lastActiveDate: yesterday,
        streakShieldAvailable: false,
        streakShieldUsedAt: DateTime.utc(2026, 3, 10),
      );

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.ok, isTrue);
      expect(result.shieldAvailable, isFalse);
    });

    test('shield resets on consecutive day at start of new month', () async {
      final DateTime today = DateTime.utc(2026, 3, 1);
      final DateTime yesterday = DateTime.utc(2026, 2, 28);
      playerService.playerToReturn = _makePlayer(
        lastActiveDate: yesterday,
        currentStreak: 5,
        streakShieldAvailable: false,
        streakShieldUsedAt: DateTime.utc(2026, 2, 15),
      );

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      final DailyCheckInResult result = await useCase.execute(
        DailyCheckInInput(userId: 'user-1', useShield: false, now: today),
      );

      expect(result.ok, isTrue);
      expect(result.currentStreak, 6);
      expect(result.shieldAvailable, isTrue);
    });

    test('awards 10 base XP with sourceType checkIn', () async {
      final DateTime today = DateTime.utc(2026, 3, 23);
      final DateTime yesterday = DateTime.utc(2026, 3, 22);
      playerService.playerToReturn = _makePlayer(lastActiveDate: yesterday);

      final DailyCheckIn useCase = _makeUseCase(playerService: playerService, awardXp: awardXp);
      await useCase.execute(DailyCheckInInput(userId: 'user-1', useShield: false, now: today));

      expect(awardXp.capturedInput!.baseXp, 10);
      expect(awardXp.capturedInput!.action, 'Daily Check-in');
      expect(awardXp.capturedInput!.sourceType, ActivitySourceType.checkIn);
    });
  });
}
