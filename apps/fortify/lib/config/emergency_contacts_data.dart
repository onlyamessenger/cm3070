// apps/fortify/lib/config/emergency_contacts_data.dart

class EmergencyContactData {
  final String name;
  final String category;
  final String phoneNumber;
  final String description;
  final String operatingHours;

  const EmergencyContactData({
    required this.name,
    required this.category,
    required this.phoneNumber,
    required this.description,
    required this.operatingHours,
  });
}

const List<EmergencyContactData> emergencyContacts = <EmergencyContactData>[
  EmergencyContactData(
    name: 'SAPS Krugersdorp',
    category: 'Police',
    phoneNumber: '10111',
    description:
        'South African Police Service. Call for crime in progress, '
        'theft, assault, or any situation requiring police response.',
    operatingHours: '24/7',
  ),
  EmergencyContactData(
    name: 'Krugersdorp Fire Department',
    category: 'Fire/Rescue',
    phoneNumber: '011 953 2000',
    description:
        'Municipal fire and rescue services. Call for fires, vehicle '
        'accidents, structural collapses, or rescue operations.',
    operatingHours: '24/7',
  ),
  EmergencyContactData(
    name: 'Netcare 911',
    category: 'Medical',
    phoneNumber: '082 911',
    description:
        'Private ambulance and emergency medical services. Call for '
        'medical emergencies, injuries, or when someone needs urgent care.',
    operatingHours: '24/7',
  ),
  EmergencyContactData(
    name: 'Krugersdorp Municipality Disaster Management',
    category: 'Municipal',
    phoneNumber: '011 951 2000',
    description:
        'Local government disaster coordination. Call for flood '
        'warnings, evacuation guidance, or municipal emergency support.',
    operatingHours: 'Mon-Fri 7:00-17:00',
  ),
  EmergencyContactData(
    name: 'Eskom Emergency',
    category: 'Utility',
    phoneNumber: '0860 037 566',
    description:
        'National electricity provider emergency line. Call for '
        'downed power lines, electrical fires, or prolonged outages.',
    operatingHours: '24/7',
  ),
  EmergencyContactData(
    name: 'Goldfields Private Security',
    category: 'Private Security',
    phoneNumber: '060 997 4740',
    description:
        'Local private security patrol and armed response. Call for '
        'suspicious activity, alarm activations, or security escort requests.',
    operatingHours: '24/7',
  ),
];
