import 'package:core/models/models.dart';

abstract class ReadinessSectionService {
  Future<ReadinessSection> createSection(ReadinessSection section);
  Future<ReadinessSection> getSection(String sectionId);
  Future<List<ReadinessSection>> getSectionsForUser(String userId);
  Future<ReadinessSection> updateSection(ReadinessSection section);
}
