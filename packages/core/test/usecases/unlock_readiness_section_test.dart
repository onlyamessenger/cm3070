import 'package:core/core.dart';
import 'package:test/test.dart';

class MockReadinessSectionService implements ReadinessSectionService {
  List<ReadinessSection> sections = <ReadinessSection>[];
  ReadinessSection? updatedSection;

  @override
  Future<ReadinessSection> createSection(ReadinessSection section) async => throw UnimplementedError();

  @override
  Future<ReadinessSection> getSection(String sectionId) async {
    return sections.firstWhere((ReadinessSection s) => s.id == sectionId);
  }

  @override
  Future<List<ReadinessSection>> getSectionsForUser(String userId) async {
    return sections.where((ReadinessSection s) => s.userId == userId).toList();
  }

  @override
  Future<ReadinessSection> updateSection(ReadinessSection section) async {
    updatedSection = section;
    return section;
  }
}

class MockLoggerService implements LoggerService {
  @override
  void info(String message) {}

  @override
  void error(String message) {}
}

ReadinessSection _makeSection({
  String id = 'section-1',
  String userId = 'user-1',
  ReadinessSectionType sectionType = ReadinessSectionType.emergencyKit,
  bool isUnlocked = false,
}) {
  return ReadinessSection(
    id: id,
    created: DateTime(2026, 1, 1),
    updated: DateTime(2026, 1, 1),
    createdBy: 'system',
    updatedBy: 'system',
    userId: userId,
    sectionType: sectionType,
    isUnlocked: isUnlocked,
  );
}

void main() {
  group('UnlockReadinessSection', () {
    late MockReadinessSectionService sectionService;
    late UnlockReadinessSection useCase;

    setUp(() {
      sectionService = MockReadinessSectionService();
      useCase = UnlockReadinessSection(sectionService: sectionService, logger: MockLoggerService());
    });

    test('unlocks a locked section', () async {
      sectionService.sections = <ReadinessSection>[_makeSection()];

      final ReadinessSection result = await useCase.execute(
        UnlockReadinessSectionInput(
          userId: 'user-1',
          sectionType: 'emergencyKit',
          unlockedByType: 'challenge',
          unlockedById: 'challenge-1',
        ),
      );

      expect(result.isUnlocked, isTrue);
      expect(result.unlockedByType, 'challenge');
      expect(result.unlockedById, 'challenge-1');
      expect(result.unlockedAt, isNotNull);
      expect(sectionService.updatedSection, isNotNull);
    });

    test('returns existing section if already unlocked (idempotent)', () async {
      sectionService.sections = <ReadinessSection>[_makeSection(isUnlocked: true)];

      final ReadinessSection result = await useCase.execute(
        UnlockReadinessSectionInput(
          userId: 'user-1',
          sectionType: 'emergencyKit',
          unlockedByType: 'challenge',
          unlockedById: 'challenge-1',
        ),
      );

      expect(result.isUnlocked, isTrue);
      expect(sectionService.updatedSection, isNull);
    });

    test('throws when section not found for user', () async {
      sectionService.sections = <ReadinessSection>[];

      await expectLater(
        useCase.execute(
          UnlockReadinessSectionInput(
            userId: 'user-1',
            sectionType: 'emergencyKit',
            unlockedByType: 'challenge',
            unlockedById: 'challenge-1',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
