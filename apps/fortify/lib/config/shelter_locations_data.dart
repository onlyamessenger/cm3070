// apps/fortify/lib/config/shelter_locations_data.dart
import 'package:fortify/config/evacuation_routes_data.dart';

class ShelterLocationData {
  final String name;
  final String type;
  final String address;
  final String distance;
  final String capacity;
  final String description;
  final List<String> amenities;
  final List<RouteStep> directions;

  const ShelterLocationData({
    required this.name,
    required this.type,
    required this.address,
    required this.distance,
    required this.capacity,
    required this.description,
    required this.amenities,
    required this.directions,
  });
}

const List<ShelterLocationData> shelterLocations = <ShelterLocationData>[
  ShelterLocationData(
    name: 'Krugersdorp Town Hall',
    type: 'Community Hall',
    address: '33 Commissioner Street, Krugersdorp',
    distance: '2.9 km',
    capacity: '~300 people',
    description:
        'The Krugersdorp Town Hall is the primary municipal emergency shelter. The large main '
        'hall and adjacent meeting rooms can accommodate several hundred people. It is centrally '
        'located with good road access and is a designated gathering point for civil protection.',
    amenities: <String>[
      'Fresh water supply',
      'First aid station',
      'Backup generator',
      'Public toilets',
      'Wheelchair accessible',
    ],
    directions: <RouteStep>[
      RouteStep(instruction: 'Head south on Dippenaar Road', distance: '200m'),
      RouteStep(instruction: 'Turn left onto Paardekraal Drive', distance: '700m'),
      RouteStep(instruction: 'Continue straight onto Luipaard Street', distance: '850m'),
      RouteStep(instruction: 'Turn right onto Commissioner Street', distance: '600m'),
      RouteStep(instruction: 'Town Hall is on your left past the library', distance: '550m'),
    ],
  ),
  ShelterLocationData(
    name: 'Paardekraal Primary School',
    type: 'School',
    address: '12 Paardekraal Drive, Krugersdorp',
    distance: '1.4 km',
    capacity: '~150 people',
    description:
        'Paardekraal Primary School opens its hall and classrooms as an emergency shelter during '
        'disaster events. The school is close to residential areas and easy to reach on foot. '
        'The covered assembly area provides immediate protection from weather.',
    amenities: <String>['Fresh water supply', 'Covered assembly area', 'Public toilets', 'Perimeter fencing'],
    directions: <RouteStep>[
      RouteStep(instruction: 'Head south on Dippenaar Road', distance: '200m'),
      RouteStep(instruction: 'Turn left onto Paardekraal Drive', distance: '700m'),
      RouteStep(
        instruction: 'School entrance is on the right',
        distance: '500m',
        note: 'Use the main gate, not the learner entrance',
      ),
    ],
  ),
  ShelterLocationData(
    name: 'NG Kerk Krugersdorp',
    type: 'Church',
    address: '45 Burger Street, Krugersdorp',
    distance: '1.8 km',
    capacity: '~200 people',
    description:
        'The NG Kerk (Dutch Reformed Church) has a large worship hall and community kitchen that '
        'serve as an emergency shelter. The church community maintains emergency supplies and the '
        'building has a backup generator for extended power outages.',
    amenities: <String>[
      'Fresh water supply',
      'Community kitchen',
      'Backup generator',
      'First aid supplies',
      'Blankets and bedding',
    ],
    directions: <RouteStep>[
      RouteStep(instruction: 'Head north on Dippenaar Road', distance: '300m'),
      RouteStep(instruction: 'Turn right onto Burger Street', distance: '450m'),
      RouteStep(instruction: 'Continue past the Magistrate Court', distance: '600m'),
      RouteStep(instruction: 'Church is on the left with the tall spire', distance: '450m'),
    ],
  ),
  ShelterLocationData(
    name: 'Krugersdorp Game Reserve Visitors Centre',
    type: 'Government Facility',
    address: 'Game Reserve Road, Krugersdorp North',
    distance: '4.2 km',
    capacity: '~80 people',
    description:
        'The visitors centre at the Krugersdorp Game Reserve is a reinforced building suitable '
        'for severe weather shelter. While smaller than other options, it is well-built and '
        'maintained by the municipality. Best suited for residents in the northern suburbs.',
    amenities: <String>['Fresh water supply', 'First aid station', 'Reinforced structure'],
    directions: <RouteStep>[
      RouteStep(instruction: 'Head north on Dippenaar Road', distance: '300m'),
      RouteStep(instruction: 'Turn right onto Burger Street', distance: '500m'),
      RouteStep(
        instruction: 'Turn left onto Malcolm Road',
        distance: '1.1 km',
        note: 'Road may be congested during evacuations',
      ),
      RouteStep(instruction: 'Continue onto Game Reserve Road', distance: '1.4 km'),
      RouteStep(instruction: 'Visitors centre is at the main entrance', distance: '900m'),
    ],
  ),
  ShelterLocationData(
    name: 'West Village Community Centre',
    type: 'Community Centre',
    address: '8 Coronation Avenue, Krugersdorp West',
    distance: '3.2 km',
    capacity: '~180 people',
    description:
        'The West Village Community Centre serves the western suburbs as an emergency shelter. '
        'The multi-purpose hall is spacious and well-ventilated, with a large car park for '
        'vehicle evacuees. Located away from industrial areas, it is ideal during chemical spills.',
    amenities: <String>['Fresh water supply', 'Public toilets', 'Large car park', 'Covered outdoor area'],
    directions: <RouteStep>[
      RouteStep(instruction: 'Head west on Dippenaar Road', distance: '400m'),
      RouteStep(instruction: 'Turn right onto Voortrekker Road', distance: '900m'),
      RouteStep(instruction: 'Turn left onto Coronation Avenue', distance: '750m'),
      RouteStep(instruction: 'Community Centre is on the right past the sports fields', distance: '1.15 km'),
    ],
  ),
];
