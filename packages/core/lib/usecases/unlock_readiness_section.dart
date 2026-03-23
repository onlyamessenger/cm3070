import 'package:core/enums/enums.dart';
import 'package:core/interface/services/services.dart';
import 'package:core/models/models.dart';
import 'package:core/usecases/usecase_future.dart';

class UnlockReadinessSectionInput {
  final String userId;
  final String sectionType;
  final String unlockedByType;
  final String unlockedById;

  const UnlockReadinessSectionInput({
    required this.userId,
    required this.sectionType,
    required this.unlockedByType,
    required this.unlockedById,
  });
}

class UnlockReadinessSection extends UseCaseFuture<UnlockReadinessSectionInput, ReadinessSection> {
  final ReadinessSectionService _sectionService;
  final LoggerService _logger;

  UnlockReadinessSection({required ReadinessSectionService sectionService, required LoggerService logger})
    : _sectionService = sectionService,
      _logger = logger;

  @override
  Future<ReadinessSection> execute(UnlockReadinessSectionInput input) async {
    _logger.info('Unlocking section ${input.sectionType} for user ${input.userId}');

    final ReadinessSectionType type = ReadinessSectionType.fromString(input.sectionType);
    final List<ReadinessSection> sections = await _sectionService.getSectionsForUser(input.userId);

    final ReadinessSection section;
    try {
      section = sections.firstWhere((ReadinessSection s) => s.sectionType == type);
    } on StateError {
      throw Exception('Readiness section ${input.sectionType} not found for user ${input.userId}');
    }

    if (section.isUnlocked) {
      _logger.info('Section ${input.sectionType} already unlocked, skipping');
      return section;
    }

    final ReadinessSection updated = section.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      unlockedByType: input.unlockedByType,
      unlockedById: input.unlockedById,
    );

    final ReadinessSection saved = await _sectionService.updateSection(updated);
    _logger.info('Section ${input.sectionType} unlocked successfully');
    return saved;
  }
}
