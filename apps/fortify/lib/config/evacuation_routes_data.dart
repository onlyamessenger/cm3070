class RouteStep {
  final String instruction;
  final String distance;
  final String? note;

  const RouteStep({required this.instruction, required this.distance, this.note});
}

class EvacuationRouteData {
  final String name;
  final String disasterType;
  final String description;
  final String destination;
  final String totalDistance;
  final String estimatedTime;
  final List<RouteStep> steps;

  const EvacuationRouteData({
    required this.name,
    required this.disasterType,
    required this.description,
    required this.destination,
    required this.totalDistance,
    required this.estimatedTime,
    required this.steps,
  });
}

const String homeAddress = '37 Dippenaar Road, Krugersdorp, South Africa';

const List<EvacuationRouteData> evacuationRoutes = <EvacuationRouteData>[
  EvacuationRouteData(
    name: 'High Ground via Monumentkoppie',
    disasterType: 'Flood',
    description:
        'This route heads north and uphill toward the Monumentkoppie ridge, moving away from '
        'low-lying areas where floodwater collects. The elevated terrain provides natural '
        'protection from rising water levels.',
    destination: 'Monumentkoppie Viewpoint',
    totalDistance: '2.8 km',
    estimatedTime: '~35 min on foot',
    steps: <RouteStep>[
      RouteStep(instruction: 'Head north on Dippenaar Road', distance: '300m'),
      RouteStep(instruction: 'Turn right onto Burger Street', distance: '450m'),
      RouteStep(
        instruction: 'Turn left onto Monumentkoppie Road',
        distance: '600m',
        note: 'Avoid the underpass if water is already rising',
      ),
      RouteStep(instruction: 'Continue uphill past the water tower', distance: '500m'),
      RouteStep(
        instruction: 'Follow the gravel path to the viewpoint',
        distance: '950m',
        note: 'Terrain is uneven - wear sturdy shoes',
      ),
    ],
  ),
  EvacuationRouteData(
    name: 'Urban Corridor to Krugersdorp CBD',
    disasterType: 'Fire',
    description:
        'This route stays within built-up areas with paved roads and minimal vegetation, '
        'avoiding open veld and grasslands where fires spread quickly. The CBD offers '
        'concrete shelter and emergency services access.',
    destination: 'Krugersdorp CBD (Library Square)',
    totalDistance: '3.1 km',
    estimatedTime: '~40 min on foot',
    steps: <RouteStep>[
      RouteStep(instruction: 'Head south on Dippenaar Road', distance: '200m'),
      RouteStep(instruction: 'Turn left onto Paardekraal Drive', distance: '700m'),
      RouteStep(
        instruction: 'Continue straight onto Luipaard Street',
        distance: '850m',
        note: 'Stay on the paved road - do not cut through open fields',
      ),
      RouteStep(instruction: 'Turn right onto Commissioner Street', distance: '600m'),
      RouteStep(instruction: 'Continue to Library Square', distance: '750m'),
    ],
  ),
  EvacuationRouteData(
    name: 'Westward to Coronation Park',
    disasterType: 'Chemical Spill',
    description:
        'This route moves west, away from the mining and industrial belt east of Krugersdorp. '
        'Coronation Park is upwind of the typical prevailing winds and provides open space '
        'away from contamination sources.',
    destination: 'Coronation Park',
    totalDistance: '3.5 km',
    estimatedTime: '~45 min on foot',
    steps: <RouteStep>[
      RouteStep(instruction: 'Head west on Dippenaar Road', distance: '400m'),
      RouteStep(instruction: 'Turn right onto Voortrekker Road', distance: '900m'),
      RouteStep(
        instruction: 'Turn left onto Coronation Avenue',
        distance: '750m',
        note: 'If you smell chemicals, cover nose and mouth with a damp cloth',
      ),
      RouteStep(instruction: 'Continue past the sports grounds', distance: '600m'),
      RouteStep(instruction: 'Enter Coronation Park via the main gate', distance: '850m'),
    ],
  ),
  EvacuationRouteData(
    name: 'Krugersdorp Game Reserve Shelter',
    disasterType: 'Severe Storm',
    description:
        'This route leads to the community shelter at the Krugersdorp Game Reserve entrance. '
        'The reinforced building provides protection from severe storms, hail, and strong '
        'winds. The route avoids tree-lined streets where branches may fall.',
    destination: 'Game Reserve Community Shelter',
    totalDistance: '4.2 km',
    estimatedTime: '~50 min on foot',
    steps: <RouteStep>[
      RouteStep(instruction: 'Head north on Dippenaar Road', distance: '300m'),
      RouteStep(instruction: 'Turn right onto Burger Street', distance: '500m'),
      RouteStep(
        instruction: 'Turn left onto Malcolm Road',
        distance: '1.1 km',
        note: 'Avoid walking under power lines during lightning',
      ),
      RouteStep(instruction: 'Continue onto Game Reserve Road', distance: '1.4 km'),
      RouteStep(instruction: 'Follow signs to the community shelter building', distance: '900m'),
    ],
  ),
  EvacuationRouteData(
    name: 'R28 Highway Access',
    disasterType: 'General Emergency',
    description:
        'This route provides the fastest access to the R28 highway for vehicle-based '
        'evacuation. The highway connects to the N14 and offers multiple directions of '
        'travel away from the affected area.',
    destination: 'R28 Highway On-Ramp',
    totalDistance: '2.4 km',
    estimatedTime: '~30 min on foot',
    steps: <RouteStep>[
      RouteStep(instruction: 'Head south on Dippenaar Road', distance: '200m'),
      RouteStep(instruction: 'Turn right onto Paardekraal Drive', distance: '500m'),
      RouteStep(instruction: 'Turn left onto Randfontein Road', distance: '800m'),
      RouteStep(
        instruction: 'Follow signs to R28 on-ramp',
        distance: '900m',
        note: 'If driving, keep fuel above half tank at all times for emergency readiness',
      ),
    ],
  ),
];
