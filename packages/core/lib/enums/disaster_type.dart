enum DisasterType {
  flood,
  bushfire,
  earthquake,
  cyclone,
  storm;

  String get displayName {
    switch (this) {
      case DisasterType.flood:
        return 'Flood';
      case DisasterType.bushfire:
        return 'Bushfire';
      case DisasterType.earthquake:
        return 'Earthquake';
      case DisasterType.cyclone:
        return 'Cyclone';
      case DisasterType.storm:
        return 'Storm';
    }
  }

  static DisasterType fromString(String value) {
    return DisasterType.values.firstWhere(
      (DisasterType e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid DisasterType: $value'),
    );
  }
}
