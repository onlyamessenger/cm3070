enum ReadinessSectionType {
  evacuationRoutes,
  emergencyContacts,
  emergencyKit,
  floodRisk,
  shelterLocations;

  String get displayName {
    switch (this) {
      case ReadinessSectionType.evacuationRoutes:
        return 'Evacuation Routes';
      case ReadinessSectionType.emergencyContacts:
        return 'Emergency Contacts';
      case ReadinessSectionType.emergencyKit:
        return 'Emergency Kit';
      case ReadinessSectionType.floodRisk:
        return 'Flood Risk';
      case ReadinessSectionType.shelterLocations:
        return 'Shelter Locations';
    }
  }

  static ReadinessSectionType fromString(String value) {
    return ReadinessSectionType.values.firstWhere(
      (ReadinessSectionType e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid ReadinessSectionType: $value'),
    );
  }
}
