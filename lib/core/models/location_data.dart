/// Location progression system - from bedroom to mega facility
class LocationData {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final double requiredNetWorth;
  final int requiredGPUs;
  final double hashRateBonus;
  final double powerCostMultiplier;
  
  const LocationData({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.requiredNetWorth,
    required this.requiredGPUs,
    this.hashRateBonus = 1.0,
    this.powerCostMultiplier = 1.0,
  });
}

/// Database of all locations
class LocationDatabase {
  static const List<LocationData> locations = [
    LocationData(
      id: 'bedroom',
      name: '🛏️ Bedroom',
      description: 'Your humble beginnings. A single GPU sitting on your desk.',
      imagePath: 'assets/images/location_bedroom.svg',
      requiredNetWorth: 0,
      requiredGPUs: 0,
      hashRateBonus: 1.0,
      powerCostMultiplier: 1.0,
    ),
    LocationData(
      id: 'garage',
      name: '🚗 Garage',
      description: 'Upgraded to the garage with better cooling and more space.',
      imagePath: 'assets/images/location_garage.svg',
      requiredNetWorth: 10000,
      requiredGPUs: 3,
      hashRateBonus: 1.1,
      powerCostMultiplier: 0.95,
    ),
    LocationData(
      id: 'basement',
      name: '🏠 Basement',
      description: 'A dedicated mining room with professional cooling systems.',
      imagePath: 'assets/images/location_basement.svg',
      requiredNetWorth: 50000,
      requiredGPUs: 10,
      hashRateBonus: 1.25,
      powerCostMultiplier: 0.85,
    ),
    LocationData(
      id: 'warehouse',
      name: '🏭 Warehouse',
      description: 'Industrial space with rows of mining rigs.',
      imagePath: 'assets/images/location_warehouse.svg',
      requiredNetWorth: 250000,
      requiredGPUs: 50,
      hashRateBonus: 1.5,
      powerCostMultiplier: 0.7,
    ),
    LocationData(
      id: 'data_center',
      name: '🏢 Data Center',
      description: 'Professional data center with enterprise-grade infrastructure.',
      imagePath: 'assets/images/location_datacenter.svg',
      requiredNetWorth: 1000000,
      requiredGPUs: 200,
      hashRateBonus: 2.0,
      powerCostMultiplier: 0.5,
    ),
    LocationData(
      id: 'mega_facility',
      name: '🏗️ Mega Facility',
      description: 'Massive mining operation with thousands of GPUs. You made it!',
      imagePath: 'assets/images/location_megafacility.svg',
      requiredNetWorth: 10000000,
      requiredGPUs: 1000,
      hashRateBonus: 3.0,
      powerCostMultiplier: 0.3,
    ),
  ];
  
  /// Get current location based on net worth and GPU count
  static LocationData getCurrentLocation(double netWorth, int gpuCount) {
    LocationData currentLocation = locations.first;
    
    for (final location in locations) {
      if (netWorth >= location.requiredNetWorth && gpuCount >= location.requiredGPUs) {
        currentLocation = location;
      } else {
        break;
      }
    }
    
    return currentLocation;
  }
  
  /// Get next location to unlock
  static LocationData? getNextLocation(double netWorth, int gpuCount) {
    final current = getCurrentLocation(netWorth, gpuCount);
    final currentIndex = locations.indexOf(current);
    
    if (currentIndex < locations.length - 1) {
      return locations[currentIndex + 1];
    }
    
    return null;
  }
  
  /// Calculate progress to next location (0.0 to 1.0)
  static double getProgressToNext(double netWorth, int gpuCount) {
    final next = getNextLocation(netWorth, gpuCount);
    if (next == null) return 1.0;
    
    final netWorthProgress = netWorth / next.requiredNetWorth;
    final gpuProgress = gpuCount / next.requiredGPUs;
    
    // Return minimum of both (both requirements must be met)
    return (netWorthProgress < gpuProgress ? netWorthProgress : gpuProgress).clamp(0.0, 1.0);
  }
}
