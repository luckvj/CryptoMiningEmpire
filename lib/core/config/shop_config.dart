/// Shop Configuration
/// 
/// Contains definitions for all purchaseable items (GPUs, CPUs, Buildings).
class ShopConfig {
  
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================
  
  static const List<String> gpuAlgorithms = [
    'Ethash', 'KawPow', 'Autolykos', 'Equihash', 'ZelHash', 'Octopus', 'SHA-256', 'Scrypt', 'X11'
  ];

  // ===========================================================================
  // GPU DEFINITIONS
  // ===========================================================================

  static final List<Map<String, dynamic>> gpus = [
    {
      'name': 'AMD Radeon HD 5870',
      'cost': 120,
      'hashRate': 18.0,
      'hashRateUnit': 'MH/s', 
      'power': 188,
      'imageUrl': 'assets/images/shop/gpu_hd_5870_real.png',
      'description': 'Vintage mining card (2009)',
      'tier': 'Vintage',
      'releaseYear': 2009,
      'manufacturer': 'AMD',
      'supportedAlgorithms': gpuAlgorithms,
    },
    {
      'name': 'AMD Radeon HD 6990',
      'cost': 250,
      'hashRate': 35.0,
      'hashRateUnit': 'MH/s', 
      'power': 375,
      'imageUrl': 'assets/images/shop/gpu_hd_6990_real.png',
      'description': 'Legendary dual-GPU (2011)',
      'tier': 'Vintage',
      'releaseYear': 2011,
      'manufacturer': 'AMD',
      'supportedAlgorithms': gpuAlgorithms,
    },
    {
      'name': 'AMD RX 580 8GB',
      'cost': 140,
      'hashRate': 31.0,
      'hashRateUnit': 'MH/s', 
      'power': 185,
      'imageUrl': 'assets/images/shop/gpu_rx_580_real.png',
      'description': 'Classic mining card (Multi-Algo)',
      'tier': 'Entry',
      'releaseYear': 2017,
      'manufacturer': 'AMD',
      'supportedAlgorithms': gpuAlgorithms,
    },
    {
      'name': 'NVIDIA GTX 1660 Super',
      'cost': 180,
      'hashRate': 31.5,
      'hashRateUnit': 'MH/s',
      'power': 125,
      'imageUrl': 'assets/images/shop/gpu_gtx_1660_super_new_1768018209942.png',
      'description': 'Budget-friendly entry GPU',
      'tier': 'Entry',
      'releaseYear': 2019,
      'manufacturer': 'NVIDIA',
      'supportedAlgorithms': gpuAlgorithms,
    },
    {
      'name': 'NVIDIA RTX 3060',
      'cost': 299,
      'hashRate': 49.0,
      'hashRateUnit': 'MH/s',
      'power': 170,
      'imageUrl': 'assets/images/shop/gpu_rtx_3060_1767825088343.png',
      'description': 'Solid mid-range performer',
      'tier': 'Mid-Range',
      'releaseYear': 2021,
      'manufacturer': 'NVIDIA',
      'supportedAlgorithms': gpuAlgorithms,
    },
    {
      'name': 'NVIDIA RTX 3080',
      'cost': 699,
      'hashRate': 99.0,
      'hashRateUnit': 'MH/s',
      'power': 320,
      'imageUrl': 'assets/images/shop/gpu_rtx_3080_1767825113923.png',
      'description': 'Enthusiast mining card',
      'tier': 'High-End',
      'releaseYear': 2020,
      'manufacturer': 'NVIDIA',
      'supportedAlgorithms': gpuAlgorithms,
    },
    {
      'name': 'NVIDIA RTX 4090',
      'cost': 1599,
      'hashRate': 133.0,
      'hashRateUnit': 'MH/s',
      'power': 450,
      'imageUrl': 'assets/images/shop/gpu_rtx_4090_1767825177799.png',
      'description': 'Flagship GPU (2022)',
      'tier': 'Ultimate',
      'releaseYear': 2022,
      'manufacturer': 'NVIDIA',
      'supportedAlgorithms': gpuAlgorithms,
    },
    {
      'name': 'Antminer S19 Pro',
      'cost': 2200,
      'hashRate': 110.0,
      'hashRateUnit': 'TH/s',
      'algorithm': 'SHA-256',
      'power': 3250,
      'imageUrl': 'assets/images/shop/asic_antminer_s19_1767825216075.png',
      'description': 'Bitcoin ASIC miner (2020)',
      'tier': 'ASIC',
      'releaseYear': 2020,
      'isASIC': true,
      'manufacturer': 'Bitmain'
    },
    {
      'name': 'Antminer L7',
      'cost': 5500,
      'hashRate': 9.5,
      'hashRateUnit': 'GH/s',
      'algorithm': 'Scrypt',
      'power': 3425,
      'imageUrl': 'assets/images/shop/asic_antminer_l7_1767915171261.png',
      'description': 'Scrypt ASIC for LTC/DOGE (2021)',
      'tier': 'ASIC',
      'releaseYear': 2021,
      'isASIC': true,
      'manufacturer': 'Bitmain'
    },
  ];

  // ===========================================================================
  // CPU DEFINITIONS
  // ===========================================================================

  static final List<Map<String, dynamic>> cpus = [
    {
      'name': 'Intel Core i7-920',
      'cost': 80,
      'hashRate': 1.2,
      'hashRateUnit': 'KH/s',
      'algorithm': 'RandomX',
      'power': 130,
      'imageUrl': 'assets/images/shop/cpu_i7_920_real.png',
      'description': 'Quad-core classic (2008)',
      'tier': 'Vintage',
      'releaseYear': 2008,
      'manufacturer': 'Intel',
      'cores': 4,
    },
    {
      'name': 'AMD Phenom II X6 1100T',
      'cost': 110,
      'hashRate': 2.5,
      'hashRateUnit': 'KH/s',
      'algorithm': 'RandomX',
      'power': 125,
      'imageUrl': 'assets/images/shop/cpu_phenom_x6_real.png',
      'description': '6-core beast (2010)',
      'tier': 'Vintage',
      'releaseYear': 2010,
      'manufacturer': 'AMD',
      'cores': 6,
    },
    {
      'name': 'Intel Core i5-10400',
      'cost': 120,
      'hashRate': 3.8,
      'hashRateUnit': 'KH/s',
      'algorithm': 'RandomX',
      'power': 65,
      'imageUrl': 'assets/images/shop/cpu_i5_10400_real.png',
      'description': '6 cores (2020)',
      'tier': 'Entry',
      'releaseYear': 2020,
      'manufacturer': 'Intel',
      'cores': 6,
    },
    {
      'name': 'AMD Ryzen 5 5600X',
      'cost': 140,
      'hashRate': 7.8,
      'hashRateUnit': 'KH/s',
      'algorithm': 'RandomX',
      'power': 65,
      'imageUrl': 'assets/images/shop/cpu_ryzen_5600x_real.png',
      'description': '6 cores, Zen 3 (2020)',
      'tier': 'Entry',
      'releaseYear': 2020,
      'manufacturer': 'AMD',
      'cores': 6,
    },
    {
      'name': 'AMD Ryzen 9 7950X',
      'cost': 700,
      'hashRate': 22.5,
      'hashRateUnit': 'KH/s',
      'algorithm': 'RandomX',
      'power': 170,
      'imageUrl': 'assets/images/shop/cpu_ryzen_7950x_real.png',
      'description': '16 cores, FASTEST XMR CPU (2022)',
      'tier': 'Ultimate',
      'releaseYear': 2022,
      'manufacturer': 'AMD',
      'cores': 16,
    },
  ];

  // ===========================================================================
  // BUILDING DEFINITIONS
  // ===========================================================================

  static final List<Map<String, dynamic>> buildings = [
    {
      'name': 'Home Garage Setup',
      'cost': 500,
      'discount': 5,
      'imageUrl': 'assets/images/shop/building_garage_real.png',
      'description': 'Start small with basic ventilation',
      'capacity': '2-4 GPUs',
      'releaseYear': 2000,
    },
    {
      'name': 'Spare Bedroom Mining',
      'cost': 1500,
      'discount': 8,
      'imageUrl': 'assets/images/shop/building_bedroom_real.png',
      'description': 'Dedicated room with AC cooling',
      'capacity': '6-8 GPUs',
      'releaseYear': 2000,
    },
    {
      'name': 'Container Mining Farm',
      'cost': 15000,
      'discount': 12,
      'imageUrl': 'assets/images/shop/building_container_real.png',
      'description': 'Modified shipping container',
      'capacity': '20-30 GPUs',
      'releaseYear': 2014,
    },
    {
      'name': 'Industrial Facility',
      'cost': 150000,
      'discount': 20,
      'imageUrl': 'assets/images/shop/building_industrial_real.png',
      'description': 'Large-scale mining complex',
      'capacity': '200-500 GPUs',
      'releaseYear': 2017,
    },
  ];
}
