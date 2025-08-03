import 'package:ar_capstone2/utils/ARDatabaseSQL.dart';

class VegetableScannerAPI {
  static final VegetableScannerAPI _instance = VegetableScannerAPI._internal();
  factory VegetableScannerAPI() => _instance;
  VegetableScannerAPI._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final Map<String, Map<String, dynamic>> _vegetableDatabase = {
    'singkamas': {
      'name': 'Singkamas',
      'english': 'Jicama',
      'scientific': 'Pachyrhizus erosus',
      'info':
          'A crispy, sweet root vegetable native to Mexico with a texture similar to pear or raw potato.',
      'lifespan': '150-180 days from planting to harvest',
      'location': 'Native to Mexico, grown in tropical regions worldwide',
      'nutrition': 'Rich in Vitamin C, Fiber, and Potassium. Low in calories.',
      'recipes': [
        'Singkamas Salad with shrimp and mango',
        'Fresh Singkamas sticks with chili powder',
        'Singkamas and carrot spring rolls',
        'Singkamas juice with lime and honey'
      ],
      'growing_tips':
          'Prefers warm climate, well-drained soil, and regular watering',
      'image': 'assets/images/singkamas.png',
      'types': [
        {
          'name': 'Common Jicama',
          'description':
              'The most widely available variety with light brown skin and white flesh.',
          'characteristics': 'Round shape, crisp texture, sweet flavor'
        },
        {
          'name': 'Jicama de Aqua',
          'description':
              'A variety with higher water content and milder flavor.',
          'characteristics': 'Larger size, more watery, less sweet'
        },
        {
          'name': 'Chinese Jicama',
          'description':
              'A smaller variety with a more intense flavor and crunchier texture.',
          'characteristics': 'Smaller size, denser texture, stronger flavor'
        }
      ]
    },
    'talong': {
      'name': 'Talong',
      'english': 'Eggplant',
      'scientific': 'Solanum melongena',
      'info':
          'Purple-colored vegetable with spongy texture, commonly used in various Asian dishes.',
      'lifespan': '100-150 days from planting to harvest',
      'location':
          'Native to South Asia, grown in tropical and subtropical regions',
      'nutrition': 'Good source of Fiber, Manganese, and antioxidants',
      'recipes': [
        'Tortang Talong (Eggplant omelette)',
        'Grilled Eggplant with bagoong',
        'Eggplant curry with coconut milk',
        'Stuffed Eggplant with ground meat'
      ],
      'growing_tips': 'Requires warm weather, full sun, and well-drained soil',
      'image': 'assets/images/talong.png',
      'types': [
        {
          'name': 'Globe Eggplant',
          'description':
              'The common large pear-shaped variety with deep purple skin.',
          'characteristics': 'Large size, pear shape, deep purple skin'
        },
        {
          'name': 'Italian Eggplant',
          'description':
              'A smaller, more slender variety with tender skin and fewer seeds.',
          'characteristics': 'Slender shape, tender skin, fewer seeds'
        },
        {
          'name': 'Thai Eggplant',
          'description':
              'Small round variety with green and white stripes, commonly used in Thai cuisine.',
          'characteristics':
              'Small round shape, green and white stripes, bitter flavor'
        }
      ]
    },
    'sigarilyas': {
      'name': 'Sigarilyas',
      'english': 'Winged Beans',
      'scientific': 'Psophocarpus tetragonolobus',
      'info':
          'Nutritious legume with winged edges, all parts are edible including leaves, flowers, and tubers.',
      'lifespan': '75-120 days from planting to harvest',
      'location': 'Native to Southeast Asia, common in Philippine gardens',
      'nutrition': 'High in Protein, Calcium, and Iron',
      'recipes': [
        'Ginisang Sigarilyas with pork',
        'Sigarilyas salad with tomatoes',
        'Sigarilyas with coconut milk',
        'Stir-fried Sigarilyas with shrimp'
      ],
      'growing_tips': 'Prefers warm climate, needs trellis for support',
      'image': 'assets/images/sigarilyas.png',
      'types': [
        {
          'name': 'Common Winged Bean',
          'description':
              'The most widely cultivated variety with four distinct wings.',
          'characteristics': 'Four-winged pods, green color, crunchy texture'
        },
        {
          'name': 'Asparagus Winged Bean',
          'description':
              'A variety with longer, more slender pods resembling asparagus.',
          'characteristics': 'Long slender pods, tender texture, mild flavor'
        },
        {
          'name': 'Purple Winged Bean',
          'description':
              'A variety with purple-tinged pods and slightly sweeter flavor.',
          'characteristics':
              'Purple-tinged pods, sweeter flavor, tender texture'
        }
      ]
    },
    'mani': {
      'name': 'Mani',
      'english': 'Peanuts',
      'scientific': 'Arachis hypogaea',
      'info':
          'Legume crop grown for its edible seeds, rich in healthy fats and protein.',
      'lifespan': '120-150 days from planting to harvest',
      'location':
          'Native to South America, grown in tropical and subtropical regions',
      'nutrition': 'Excellent source of Protein, Healthy Fats, and Vitamin E',
      'recipes': [
        'Boiled peanuts with salt',
        'Kare-kare with peanut sauce',
        'Peanut butter',
        'Roasted peanuts as snack'
      ],
      'growing_tips':
          'Requires sandy soil, warm climate, and moderate watering',
      'image': 'assets/images/mani.png',
      'types': [
        {
          'name': 'Virginia Peanut',
          'description':
              'The most common variety used for peanut butter and snacks.',
          'characteristics': 'Small to medium size, red skin, high oil content'
        },
        {
          'name': 'Spanish Peanut',
          'description':
              'A variety with smaller kernels and reddish-brown skin.',
          'characteristics': 'Small kernels, reddish-brown skin, sweet flavor'
        },
        {
          'name': 'Valencia Peanut',
          'description': 'A sweet variety with three to five kernels per pod.',
          'characteristics':
              'Three to five kernels per pod, sweet flavor, bright red skin'
        }
      ]
    },
    'sitaw': {
      'name': 'Sitaw',
      'english': 'Long Beans',
      'scientific': 'Vigna unguiculata subsp. sesquipedalis',
      'info':
          'Long, slender green beans that can grow up to 1-3 feet in length.',
      'lifespan': '60-90 days from planting to harvest',
      'location': 'Native to Southeast Asia, common in tropical regions',
      'nutrition': 'Rich in Fiber, Protein, and various vitamins',
      'recipes': [
        'Ginisang Sitaw with pork',
        'Adobong Sitaw',
        'Sitaw with coconut milk',
        'Stir-fried long beans with garlic'
      ],
      'growing_tips':
          'Needs trellis support, regular harvesting encourages more production',
      'image': 'assets/images/sitaw.png',
      'types': [
        {
          'name': 'Yard Long Bean',
          'description':
              'The most common variety with pods that can grow up to 3 feet long.',
          'characteristics': 'Very long pods, pale green color, crisp texture'
        },
        {
          'name': 'Red Noodle Bean',
          'description':
              'A variety with reddish pods and slightly sweeter flavor.',
          'characteristics': 'Reddish pods, sweeter flavor, tender texture'
        },
        {
          'name': 'Chinese Long Bean',
          'description':
              'A variety with dark green pods and more robust flavor.',
          'characteristics': 'Dark green pods, robust flavor, crunchy texture'
        }
      ]
    },
    'bataw': {
      'name': 'Bataw',
      'english': 'Hyacinth Beans',
      'scientific': 'Lablab purpureus',
      'info':
          'Versatile legume with edible pods, seeds, and leaves, known for its nutritional value.',
      'lifespan': '70-100 days from planting to harvest',
      'location': 'Native to Africa, widely grown in tropical Asia',
      'nutrition': 'High in Protein, Iron, and Calcium',
      'recipes': [
        'Ginisang Bataw with shrimp',
        'Bataw soup with malunggay',
        'Sauteed Bataw with garlic',
        'Bataw with coconut cream'
      ],
      'growing_tips': 'Drought tolerant, grows well in various soil types',
      'image': 'assets/images/bataw.png',
      'types': [
        {
          'name': 'White Hyacinth Bean',
          'description':
              'The most common variety with white seeds and pale green pods.',
          'characteristics': 'White seeds, pale green pods, mild flavor'
        },
        {
          'name': 'Red Hyacinth Bean',
          'description':
              'A variety with red seeds and slightly stronger flavor.',
          'characteristics':
              'Red seeds, stronger flavor, slightly tougher texture'
        },
        {
          'name': 'Black Hyacinth Bean',
          'description': 'A variety with black seeds and robust flavor.',
          'characteristics': 'Black seeds, robust flavor, dense texture'
        }
      ]
    },
    'patani': {
      'name': 'Patani',
      'english': 'Lima Beans',
      'scientific': 'Phaseolus lunatus',
      'info':
          'Buttery-flavored beans that are highly nutritious and protein-rich.',
      'lifespan': '65-80 days from planting to harvest',
      'location': 'Native to Central and South America',
      'nutrition': 'Excellent source of Protein, Fiber, and Manganese',
      'recipes': [
        'Ginisang Patani with coconut milk',
        'Patani soup with vegetables',
        'Patani salad with vinaigrette',
        'Sauteed Patani with tomatoes'
      ],
      'growing_tips': 'Prefers warm weather, well-drained soil',
      'image': 'assets/images/patani.png',
      'types': [
        {
          'name': 'Fordhook Lima Bean',
          'description': 'The most common variety with large, flat pods.',
          'characteristics': 'Large flat pods, creamy texture, buttery flavor'
        },
        {
          'name': 'Christmas Lima',
          'description':
              'A variety with colorful speckled seeds and rich flavor.',
          'characteristics': 'Speckled seeds, rich flavor, creamy texture'
        },
        {
          'name': 'Sieva Lima',
          'description':
              'A smaller variety with delicate flavor and tender texture.',
          'characteristics': 'Small seeds, delicate flavor, tender texture'
        }
      ]
    },
    'kundol': {
      'name': 'Kundol',
      'english': 'Wax Gourd / Winter Melon',
      'scientific': 'Benincasa hispida',
      'info':
          'Large vine vegetable with mild flavor, often used in soups and desserts.',
      'lifespan': '100-120 days from planting to harvest',
      'location': 'Native to Southeast Asia',
      'nutrition': 'Low in calories, rich in Vitamin C and Calcium',
      'recipes': [
        'Ginataang Kundol with shrimp',
        'Winter melon soup',
        'Kundol candy (crystallized)',
        'Stir-fried kundol with meat'
      ],
      'growing_tips': 'Needs plenty of space to spread, regular watering',
      'image': 'assets/images/kundol.png',
      'types': [
        {
          'name': 'Round Winter Melon',
          'description':
              'The most common variety with round shape and dark green skin.',
          'characteristics': 'Round shape, dark green skin, white flesh'
        },
        {
          'name': 'Oblong Winter Melon',
          'description': 'A variety with elongated shape and milder flavor.',
          'characteristics': 'Oblong shape, milder flavor, juicy texture'
        },
        {
          'name': 'Mini Winter Melon',
          'description': 'A smaller variety perfect for home gardens.',
          'characteristics': 'Small size, sweet flavor, tender skin'
        }
      ]
    },
    'patola': {
      'name': 'Patola',
      'english': 'Sponge Gourd',
      'scientific': 'Luffa cylindrica',
      'info':
          'Mild-flavored gourd that becomes sponge-like when mature and dried.',
      'lifespan': '60-90 days from planting to harvest',
      'location': 'Native to Southeast Asia',
      'nutrition': 'Good source of Vitamin C, Magnesium, and Fiber',
      'recipes': [
        'Miswa with Patola soup',
        'Ginisang Patola with eggs',
        'Patola with misua noodles',
        'Stir-fried patola with garlic'
      ],
      'growing_tips': 'Needs trellis support, harvest when young and tender',
      'image': 'assets/images/patola.png',
      'types': [
        {
          'name': 'Smooth Luffa',
          'description': 'The most common variety with smooth skin and ridges.',
          'characteristics': 'Smooth skin with ridges, tender when young'
        },
        {
          'name': 'Angled Luffa',
          'description':
              'A variety with distinct angled ridges and more robust flavor.',
          'characteristics': 'Angled ridges, robust flavor, firm texture'
        },
        {
          'name': 'Wild Luffa',
          'description':
              'A variety with more bitter flavor and tougher texture.',
          'characteristics': 'Bitter flavor, tough texture, best when young'
        }
      ]
    },
    'upo': {
      'name': 'Upo',
      'english': 'Bottle Gourd',
      'scientific': 'Lagenaria siceraria',
      'info':
          'Mild-flavored gourd with high water content, excellent for soups and stir-fries.',
      'lifespan': '60-100 days from planting to harvest',
      'location': 'Native to Africa, widely grown in tropical regions',
      'nutrition': 'Very low in calories, high in Water content and Fiber',
      'recipes': [
        'Ginisang Upo with shrimp',
        'Upo soup with miswa',
        'Stuffed Upo with ground meat',
        'Upo with coconut milk'
      ],
      'growing_tips': 'Needs support for climbing, regular watering required',
      'image': 'assets/images/upo.png',
      'types': [
        {
          'name': 'Calabash Bottle Gourd',
          'description': 'The most common variety with bottle-like shape.',
          'characteristics': 'Bottle-like shape, light green skin, mild flavor'
        },
        {
          'name': 'Long Bottle Gourd',
          'description': 'A variety with elongated neck and rounded bottom.',
          'characteristics': 'Elongated neck, rounded bottom, tender flesh'
        },
        {
          'name': 'Round Bottle Gourd',
          'description': 'A variety with round shape and thicker skin.',
          'characteristics': 'Round shape, thick skin, sweet flavor'
        }
      ]
    },
    'kalabasa': {
      'name': 'Kalabasa',
      'english': 'Squash',
      'scientific': 'Cucurbita maxima',
      'info':
          'Versatile vegetable with sweet orange flesh, rich in vitamins and antioxidants.',
      'lifespan': '90-120 days from planting to harvest',
      'location': 'Native to South America',
      'nutrition': 'Rich in Vitamin A, Vitamin C, and Beta-carotene',
      'recipes': [
        'Ginataang Kalabasa with sitaw',
        'Kalabasa soup',
        'Kalabasa puree',
        'Roasted squash with herbs'
      ],
      'growing_tips': 'Needs plenty of space, full sun, and well-drained soil',
      'image': 'assets/images/kalabasa.png',
      'types': [
        {
          'name': 'Butternut Squash',
          'description': 'A variety with pear shape and sweet, nutty flavor.',
          'characteristics': 'Pear shape, tan skin, sweet orange flesh'
        },
        {
          'name': 'Kabocha Squash',
          'description':
              'A Japanese variety with sweet, dry flesh and dark green skin.',
          'characteristics': 'Dark green skin, sweet dry flesh, dense texture'
        },
        {
          'name': 'Acorn Squash',
          'description': 'A small variety with acorn shape and mild flavor.',
          'characteristics': 'Acorn shape, dark green ridges, mild flavor'
        }
      ]
    },
    'labanos': {
      'name': 'Labanos',
      'english': 'Radish',
      'scientific': 'Raphanus sativus',
      'info':
          'Crispy root vegetable with peppery flavor, grows quickly and easily.',
      'lifespan': '25-45 days from planting to harvest',
      'location': 'Native to Southeast Asia',
      'nutrition': 'High in Vitamin C, Potassium, and Antioxidants',
      'recipes': [
        'Fresh labanos salad',
        'Pickled radish (atchara)',
        'Labanos in sinigang',
        'Grated radish as condiment'
      ],
      'growing_tips': 'Fast-growing, prefers cool weather and loose soil',
      'image': 'assets/images/labanos.png',
      'types': [
        {
          'name': 'Daikon Radish',
          'description':
              'A large white variety with mild flavor and crisp texture.',
          'characteristics':
              'Large size, white skin, mild flavor, crisp texture'
        },
        {
          'name': 'Red Radish',
          'description':
              'A small variety with bright red skin and peppery flavor.',
          'characteristics': 'Small size, red skin, white flesh, peppery flavor'
        },
        {
          'name': 'Watermelon Radish',
          'description': 'A variety with green and white skin and mild flavor.',
          'characteristics': 'Green and white skin, mild flavor, juicy texture'
        }
      ]
    },
    'mustasa': {
      'name': 'Mustasa',
      'english': 'Mustard Greens',
      'scientific': 'Brassica juncea',
      'info':
          'Leafy green vegetable with peppery flavor, highly nutritious and fast-growing.',
      'lifespan': '40-50 days from planting to harvest',
      'location': 'Native to the Himalayas',
      'nutrition': 'Rich in Vitamin K, Vitamin A, and Antioxidants',
      'recipes': [
        'Ginisang Mustasa with tofu',
        'Mustasa salad with salted egg',
        'Mustasa in sinigang',
        'Stir-fried mustard greens'
      ],
      'growing_tips': 'Fast-growing, prefers cool weather, regular harvesting',
      'image': 'assets/images/mustasa.png',
      'types': [
        {
          'name': 'Green Mustard',
          'description': 'The most common variety with frilly green leaves.',
          'characteristics':
              'Frilly green leaves, peppery flavor, tender texture'
        },
        {
          'name': 'Red Mustard',
          'description':
              'A variety with reddish-purple leaves and stronger flavor.',
          'characteristics':
              'Reddish-purple leaves, stronger flavor, slightly tougher'
        },
        {
          'name': 'Giant Red Mustard',
          'description':
              'A large variety with broad red leaves and robust flavor.',
          'characteristics': 'Broad red leaves, robust flavor, thick texture'
        }
      ]
    },
    'sibuyas': {
      'name': 'Sibuyas',
      'english': 'Onion',
      'scientific': 'Allium cepa',
      'info':
          'Bulb vegetable widely used as base flavoring in countless dishes worldwide.',
      'lifespan': '100-175 days from planting to harvest',
      'location': 'Native to Central Asia',
      'nutrition': 'Good source of Vitamin C, Vitamin B6, and Antioxidants',
      'recipes': [
        'Caramelized onions for toppings',
        'Onion rings',
        'Sauteed onions as base for dishes',
        'Pickled onions'
      ],
      'growing_tips':
          'Requires well-drained soil, full sun, and moderate watering',
      'image': 'assets/images/sibuyas.png',
      'types': [
        {
          'name': 'Yellow Onion',
          'description':
              'The most common variety with papery yellow skin and white flesh.',
          'characteristics': 'Yellow papery skin, white flesh, pungent flavor'
        },
        {
          'name': 'Red Onion',
          'description':
              'A variety with reddish-purple skin and milder flavor.',
          'characteristics': 'Reddish-purple skin, white flesh, milder flavor'
        },
        {
          'name': 'White Onion',
          'description': 'A variety with white skin and sharp, pungent flavor.',
          'characteristics': 'White papery skin, white flesh, sharp flavor'
        }
      ]
    },
    'kamatis': {
      'name': 'Kamatis',
      'english': 'Tomato',
      'scientific': 'Solanum lycopersicum',
      'info':
          'Red, edible berry technically a fruit but commonly used as vegetable in cooking.',
      'lifespan': '60-100 days from planting to harvest',
      'location': 'Native to South America',
      'nutrition': 'Rich in Vitamin C, Lycopene, and Potassium',
      'recipes': [
        'Fresh tomato salad',
        'Tomato sauce for pasta',
        'Sinigang with tomatoes',
        'Grilled tomatoes'
      ],
      'growing_tips': 'Needs full sun, regular watering, and support for vines',
      'image': 'assets/images/kamatis.png',
      'types': [
        {
          'name': 'Beefsteak Tomato',
          'description': 'A large variety with meaty texture and rich flavor.',
          'characteristics': 'Large size, meaty texture, rich flavor'
        },
        {
          'name': 'Cherry Tomato',
          'description':
              'A small, sweet variety perfect for salads and snacking.',
          'characteristics': 'Small size, sweet flavor, juicy texture'
        },
        {
          'name': 'Roma Tomato',
          'description':
              'An oval variety with fewer seeds and dense flesh, ideal for sauces.',
          'characteristics': 'Oval shape, fewer seeds, dense flesh'
        }
      ]
    },
    'bawang': {
      'name': 'Bawang',
      'english': 'Garlic',
      'scientific': 'Allium sativum',
      'info':
          'Pungent bulb used as seasoning, known for its medicinal properties and strong flavor.',
      'lifespan': '90-240 days from planting to harvest',
      'location': 'Native to Central Asia',
      'nutrition': 'Rich in Manganese, Vitamin B6, and Allicin compound',
      'recipes': [
        'Sauteed garlic as flavor base',
        'Garlic fried rice',
        'Roasted garlic',
        'Garlic sauce for dishes'
      ],
      'growing_tips':
          'Plant in well-drained soil, requires cool period for bulb formation',
      'image': 'assets/images/bawang.png',
      'types': [
        {
          'name': 'Softneck Garlic',
          'description':
              'The most common variety with soft stems and multiple cloves.',
          'characteristics': 'Soft stems, multiple cloves, mild flavor'
        },
        {
          'name': 'Hardneck Garlic',
          'description': 'A variety with stiff central stem and larger cloves.',
          'characteristics':
              'Stiff central stem, larger cloves, stronger flavor'
        },
        {
          'name': 'Elephant Garlic',
          'description':
              'A large variety with milder flavor, actually a type of leek.',
          'characteristics': 'Large bulbs, mild flavor, fewer cloves'
        }
      ]
    },
    'luya': {
      'name': 'Luya',
      'english': 'Ginger',
      'scientific': 'Zingiber officinale',
      'info':
          'Aromatic rhizome with spicy flavor, used both as spice and traditional medicine.',
      'lifespan': '8-10 months from planting to harvest',
      'location': 'Native to Southeast Asia',
      'nutrition': 'Contains Gingerol, anti-inflammatory compound',
      'recipes': [
        'Salabat (ginger tea)',
        'Ginger in stir-fries',
        'Pickled ginger',
        'Ginger candy'
      ],
      'growing_tips': 'Prefers warm, humid climate with partial shade',
      'image': 'assets/images/luya.png',
      'types': [
        {
          'name': 'Yellow Ginger',
          'description':
              'The most common variety with pale yellow skin and pungent flavor.',
          'characteristics': 'Pale yellow skin, pungent flavor, fibrous texture'
        },
        {
          'name': 'Blue Hawaiian Ginger',
          'description': 'A variety with bluish skin and milder flavor.',
          'characteristics': 'Bluish skin, milder flavor, less fibrous'
        },
        {
          'name': 'Japanese Ginger',
          'description': 'A variety with thin skin and delicate flavor.',
          'characteristics': 'Thin skin, delicate flavor, tender texture'
        }
      ]
    },
  };

  Map<String, Map<String, dynamic>> getAllVegetables() {
    return _vegetableDatabase;
  }

  Map<String, dynamic>? getVegetableByKey(String key) {
    return _vegetableDatabase[key];
  }

  Future<String> scanVegetable() async {
    final vegetableKeys = _vegetableDatabase.keys.toList();
    final randomIndex = DateTime.now().millisecond % vegetableKeys.length;
    final vegetableKey = vegetableKeys[randomIndex];

    await recordVegetableScan(vegetableKey);

    return vegetableKey;
  }

  Future<void> recordVegetableScan(String vegetableKey) async {
    await _databaseHelper.recordVegetableScan(vegetableKey);
  }

  Future<Map<String, dynamic>?> getVegetableInfo(String key) async {
    final vegetable = _vegetableDatabase[key];
    if (vegetable == null) return null;

    final scanCount = await _databaseHelper.getVegetableScanCount(key);

    return Map<String, dynamic>.from(vegetable)..['scan_count'] = scanCount;
  }

  Future<List<Map<String, dynamic>>> getAllVegetablesWithScanCounts() async {
    final List<Map<String, dynamic>> result = [];

    for (final key in _vegetableDatabase.keys) {
      final vegetable = Map<String, dynamic>.from(_vegetableDatabase[key]!);
      final scanCount = await _databaseHelper.getVegetableScanCount(key);
      vegetable['scan_count'] = scanCount;
      vegetable['key'] = key;
      result.add(vegetable);
    }

    result.sort(
        (a, b) => (b['scan_count'] as int).compareTo(a['scan_count'] as int));

    return result;
  }

  Future<int> getTotalScanCount() async {
    try {
      return await _databaseHelper.getTotalScanCount();
    } catch (e) {
      print('Error getting total scan count: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getMostScannedVegetables(
      {int limit = 10}) async {
    final allVegetables = await getAllVegetablesWithScanCounts();
    allVegetables.sort(
        (a, b) => (b['scan_count'] as int).compareTo(a['scan_count'] as int));
    return limit > 0 ? allVegetables.take(limit).toList() : allVegetables;
  }

  Future<Map<String, dynamic>> getScanStatistics() async {
    final allVegetables = await getAllVegetablesWithScanCounts();
    final totalScans = await getTotalScanCount();
    final mostScanned = await getMostScannedVegetables(limit: 5);

    return {
      'total_vegetables': allVegetables.length,
      'total_scans': totalScans,
      'most_scanned': mostScanned,
      'average_scans':
          allVegetables.isNotEmpty ? totalScans / allVegetables.length : 0,
    };
  }

  Future<int> getVegetableScanCountByName(String vegetableName) async {
    try {
      String vegetableKey = vegetableName.toLowerCase().replaceAll(' ', '_');
      return await _databaseHelper.getVegetableScanCount(vegetableKey);
    } catch (e) {
      print('Error getting vegetable scan count by name: $e');
      return 0;
    }
  }

  Future<void> recordVegetableScanByName(String vegetableName) async {
    try {
      String vegetableKey = vegetableName.toLowerCase().replaceAll(' ', '_');
      await _databaseHelper.recordVegetableScan(vegetableKey);
    } catch (e) {
      print('Error recording vegetable scan by name: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDatabaseStatistics() async {
    try {
      return await _databaseHelper.getDatabaseStats();
    } catch (e) {
      print('Error getting database statistics: $e');
      return {
        'total_users': 0,
        'pending_users': 0,
        'total_scans': 0,
        'total_vegetables': 0,
        'approved_users': 0,
      };
    }
  }
}
