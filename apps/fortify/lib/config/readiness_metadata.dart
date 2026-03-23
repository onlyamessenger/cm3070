import 'package:core/core.dart';

class SectionMeta {
  final String icon;
  final String title;
  final String unlockDescription;

  const SectionMeta({required this.icon, required this.title, required this.unlockDescription});
}

const Map<ReadinessSectionType, SectionMeta> sectionMetadata = <ReadinessSectionType, SectionMeta>{
  ReadinessSectionType.emergencyKit: SectionMeta(
    icon: '🎒',
    title: 'Emergency Kit',
    unlockDescription: 'Your emergency supply checklist is now available. Start gathering your kit!',
  ),
  ReadinessSectionType.evacuationRoutes: SectionMeta(
    icon: '🚪',
    title: 'Evacuation Routes',
    unlockDescription: 'Plan your escape routes and know your exits.',
  ),
  ReadinessSectionType.emergencyContacts: SectionMeta(
    icon: '📞',
    title: 'Emergency Contacts',
    unlockDescription: 'Store important emergency numbers and contacts.',
  ),
  ReadinessSectionType.floodRisk: SectionMeta(
    icon: '⚠️',
    title: 'Flood Risk Info',
    unlockDescription: 'Understand your local flood risk and hazard levels.',
  ),
  ReadinessSectionType.shelterLocations: SectionMeta(
    icon: '🏠',
    title: 'Shelter Locations',
    unlockDescription: 'Find nearby evacuation points and shelters.',
  ),
};
