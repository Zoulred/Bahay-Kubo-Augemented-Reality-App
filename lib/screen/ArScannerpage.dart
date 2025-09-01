import 'package:ar_capstone2/services/ARApiegetablescannerapi.dart';
import 'package:ar_capstone2/utils/ARDatabaseSQL.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ARActivityPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ARActivityPage({super.key, required this.user});

  @override
  State<ARActivityPage> createState() => _ARActivityPageState();
}

class _ARActivityPageState extends State<ARActivityPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _scannedVegetable = '';
  String _selectedVegetable = '';
  bool _showVegetableList = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isScanning = false;

  XFile? _capturedImage;
  bool _showCapturedImage = false;

  late AnimationController _scanAnimationController;
  late AnimationController _vegetableAnimationController;
  late AnimationController _scanLineController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scanLineAnimation;
  bool _showVegetableAnimation = false;
  bool _showScanningAnimation = false;

  bool _showNoVegetableError = false;
  bool _isNoVegetableScanning = false;

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  var _scannerAPI = VegetableScannerAPI();

  final Map<String, String> _vegetableVideoMap = {
    'singkamas': 'assets/video/t2.mp4',
    'talong': 'assets/video/tutorial1talong.mp4',
    'sigarilyas': 'assets/video/sigarilyasvid.mp4',
    'mani': 'assets/video/Manivid.mp4',
    'sitaw': 'assets/video/Sitaw.mp4',
    'bataw': 'assets/video/bataw.mp4',
    'patani': 'assets/video/patanivid.mp4',
    'kundol': 'assets/video/Kundoltuts.mp4',
    'patola': 'assets/video/patolatuts.mp4',
    'upo': 'assets/video/Upovid.mp4',
    'kalabasa': 'assets/video/kalabasa.mp4',
    'labanos': 'assets/video/labanos.mp4',
    'mustasa': 'assets/video/mustasa1.mp4',
    'sibuyas': 'assets/video/tutorial2sibuyas.mp4',
    'kamatis': 'assets/video/tutorial3tomato.mp4',
    'bawang': 'assets/video/bawang.mp4',
    'luya': 'assets/videos/luyatuts.mp4',
    'default': 'assets/videos/default_vegetable.mp4',
  };

  final Map<String, Map<String, dynamic>> _vegetableDatabase = {
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

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _vegetableAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scanLineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _vegetableAnimationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _vegetableAnimationController, curve: Curves.easeIn),
    );

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _scanAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scanAnimationController.reset();
        _scanAnimationController.forward();
      }
    });

    _vegetableAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _showVegetableAnimation = false;
            });
          }
        });
      }
    });

    _scanLineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scanLineController.reset();
        _scanLineController.forward();
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    _scanAnimationController.dispose();
    _vegetableAnimationController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      _showErrorSnackBar('Failed to initialize camera');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _selectVegetable(String vegetableKey) {
    setState(() {
      _selectedVegetable = vegetableKey;
      _showVegetableList = false;
      _scannedVegetable = '';
      _showVegetableAnimation = false;
      _showScanningAnimation = false;
      _isScanning = false;
      _capturedImage = null;
      _showCapturedImage = false;
      _showNoVegetableError = false;
      _isNoVegetableScanning = false;
    });

    _initializeVideo(vegetableKey);
  }

  void _startScanning() async {
    if (_selectedVegetable.isEmpty) {
      try {
        final XFile image = await _cameraController!.takePicture();
        setState(() {
          _capturedImage = image;
          _showCapturedImage = true;
          _isScanning = true;
          _showScanningAnimation = true;
          _isNoVegetableScanning = true;
        });
      } catch (e) {
        print('Error capturing image: $e');
        _showErrorSnackBar('Failed to capture image');
        return;
      }

      _scanAnimationController.forward();
      _scanLineController.forward();

      Future.delayed(const Duration(seconds: 7), () {
        if (mounted) {
          _scanAnimationController.stop();
          _scanLineController.stop();

          setState(() {
            _showNoVegetableError = true;
            _isScanning = false;
            _showScanningAnimation = false;
            _isNoVegetableScanning = false;
          });

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showNoVegetableError = false;
                _capturedImage = null;
                _showCapturedImage = false;
              });
            }
          });
        }
      });

      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
        _showCapturedImage = true;
        _isScanning = true;
        _showScanningAnimation = true;
        _showNoVegetableError = false;
        _isNoVegetableScanning = false;
      });
    } catch (e) {
      print('Error capturing image: $e');
      _showErrorSnackBar('Failed to capture image');
      return;
    }

    _scanAnimationController.forward();
    _scanLineController.forward();

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        _scanAnimationController.stop();
        _startVegetableScan();
      }
    });
  }

  Future<void> _initializeVideo(String vegetableKey) async {
    _videoController?.dispose();

    final videoPath =
        _vegetableVideoMap[vegetableKey] ?? _vegetableVideoMap['default']!;

    _videoController = VideoPlayerController.asset(videoPath);

    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true);

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      _showErrorSnackBar('Failed to load vegetable video');

      try {
        final defaultVideoPath = _vegetableVideoMap['default']!;
        _videoController = VideoPlayerController.asset(defaultVideoPath);
        await _videoController!.initialize();
        await _videoController!.setLooping(true);

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e2) {
        print('Error loading default video: $e2');
      }
    }
  }

  void _startVegetableScan() {
    if (_selectedVegetable.isEmpty) return;

    Future.delayed(const Duration(seconds: 1), () async {
      final vegetableData = _vegetableDatabase[_selectedVegetable]!;

      try {
        await _databaseHelper.recordVegetableScanForUser(
            widget.user['id'], _selectedVegetable);

        print('User ${widget.user['username']} scanned $_selectedVegetable');
      } catch (e) {
        print('Error recording scan: $e');
      }
      setState(() {
        _scannedVegetable = vegetableData['name']!;
        _showVegetableAnimation = true;
        _showScanningAnimation = false;
        _isScanning = false;
      });

      _scanLineController.stop();

      _vegetableAnimationController.reset();
      _vegetableAnimationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully scanned ${vegetableData['name']}!'),
          backgroundColor: const Color.fromARGB(139, 76, 175, 79),
        ),
      );
    });
  }

  void _resetScan() {
    setState(() {
      _scannedVegetable = '';
      _selectedVegetable = '';
      _isVideoInitialized = false;
      _showVegetableAnimation = false;
      _showScanningAnimation = false;
      _isScanning = false;
      _capturedImage = null;
      _showCapturedImage = false;
      _showNoVegetableError = false;
      _isNoVegetableScanning = false;
    });
    _scanAnimationController.stop();
    _vegetableAnimationController.stop();
    _scanLineController.stop();
    _videoController?.pause();
  }

  void _showVegetableListScreen() {
    setState(() {
      _showVegetableList = true;
      _selectedVegetable = '';
      _scannedVegetable = '';
      _isVideoInitialized = false;
      _showVegetableAnimation = false;
      _showScanningAnimation = false;
      _isScanning = false;
      _capturedImage = null;
      _showCapturedImage = false;
      _showNoVegetableError = false;
      _isNoVegetableScanning = false;
    });
    _scanAnimationController.stop();
    _vegetableAnimationController.stop();
    _scanLineController.stop();
    _videoController?.pause();
  }

  Widget _buildVegetableList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Vegetable',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            const Color.fromARGB(255, 10, 181, 24),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _showVegetableList = false;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Vegetable to Scan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 150, 28),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose from our comprehensive list of Filipino vegetables:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _vegetableDatabase.length,
                itemBuilder: (context, index) {
                  final vegetableKey = _vegetableDatabase.keys.elementAt(index);
                  final vegetable = _vegetableDatabase[vegetableKey]!;
                  return _buildVegetableCard(vegetableKey, vegetable);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVegetableCard(String key, Map<String, dynamic> vegetable) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _selectVegetable(key),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green[200]!, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    vegetable['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green[100],
                        child: Icon(
                          Icons.eco,
                          size: 40,
                          color: Colors.green[700],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                vegetable['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                vegetable['english']!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: const Color.fromARGB(0, 0, 0, 0),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        _showCapturedImage && _capturedImage != null
            ? Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : CameraPreview(_cameraController!),

        if (_isNoVegetableScanning && _showScanningAnimation)
          _buildScanningOverlay(),

        if (_showNoVegetableError)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No vegetable detected.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try selecting one manually.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showNoVegetableError = false;
                          _capturedImage = null;
                          _showCapturedImage = false;
                        });
                        _showVegetableListScreen();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        'SELECT VEGETABLE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (_selectedVegetable.isNotEmpty &&
            _scannedVegetable.isEmpty &&
            !_isNoVegetableScanning)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Selected: ${_vegetableDatabase[_selectedVegetable]!['name']}',
                    style: const TextStyle(
                      color: Color.fromARGB(0, 0, 0, 0),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(${_vegetableDatabase[_selectedVegetable]!['english']})',
                    style: const TextStyle(
                      color: Color.fromARGB(0, 0, 0, 0),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        if (_showScanningAnimation && !_isNoVegetableScanning)
          _buildScanningOverlay(),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'AR Vegetable Scanner',
                  style: TextStyle(
                    color: Color.fromARGB(0, 0, 0, 0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedVegetable.isEmpty && !_isNoVegetableScanning
                      ? 'Select a vegetable from the list to start scanning'
                      : _selectedVegetable.isEmpty && _isNoVegetableScanning
                          ? 'Scanning for vegetables...'
                          : _isScanning
                              ? 'Scanning ${_vegetableDatabase[_selectedVegetable]!['name']}...'
                              : 'Ready to scan ${_vegetableDatabase[_selectedVegetable]!['name']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromARGB(0, 0, 0, 0),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningOverlay() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isNoVegetableScanning
                    ? const Color.fromARGB(255, 15, 104, 24).withOpacity(0.8)
                    : Colors.green.withOpacity(0.8),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _scanLineAnimation,
          builder: (context, child) {
            double animationValue = _scanLineAnimation.value;
            if (animationValue < 0.1428) {
              animationValue = 0.0;
            } else {
              animationValue = (animationValue - 0.1428) *
                  1.1667;
            }

            return Positioned(
              top: MediaQuery.of(context).size.height * 0.25 +
                  (MediaQuery.of(context).size.height * 0.5) * animationValue,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _isNoVegetableScanning
                          ? const Color.fromARGB(255, 17, 124, 17)
                          : Colors.green,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.25 - 10,
          left: MediaQuery.of(context).size.width * 0.1 - 10,
          child: _buildCornerMarker(CornerPosition.TopLeft),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.25 - 10,
          right: MediaQuery.of(context).size.width * 0.1 - 10,
          child: _buildCornerMarker(CornerPosition.TopRight),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.25 - 10,
          left: MediaQuery.of(context).size.width * 0.1 - 10,
          child: _buildCornerMarker(CornerPosition.BottomLeft),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.25 - 10,
          right: MediaQuery.of(context).size.width * 0.1 - 10,
          child: _buildCornerMarker(CornerPosition.BottomRight),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isNoVegetableScanning
                    ? const Color.fromARGB(255, 11, 129, 44).withOpacity(0.7)
                    : Colors.green.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isNoVegetableScanning ? 'SCANNING... ' : 'SCANNING... ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 7.0, end: 0.0),
                    duration: const Duration(seconds: 7),
                    builder: (context, value, child) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerMarker(CornerPosition position) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: position == CornerPosition.TopLeft ||
                  position == CornerPosition.TopRight
              ? BorderSide(
                  color: _isNoVegetableScanning
                      ? const Color.fromARGB(255, 16, 172, 10)
                      : Colors.green,
                  width: 3)
              : BorderSide.none,
          left: position == CornerPosition.TopLeft ||
                  position == CornerPosition.BottomLeft
              ? BorderSide(
                  color: _isNoVegetableScanning
                      ? const Color.fromARGB(255, 20, 125, 34)
                      : Colors.green,
                  width: 3)
              : BorderSide.none,
          right: position == CornerPosition.TopRight ||
                  position == CornerPosition.BottomRight
              ? BorderSide(
                  color: _isNoVegetableScanning
                      ? const Color.fromARGB(255, 21, 107, 13)
                      : Colors.green,
                  width: 3)
              : BorderSide.none,
          bottom: position == CornerPosition.BottomLeft ||
                  position == CornerPosition.BottomRight
              ? BorderSide(
                  color: _isNoVegetableScanning
                      ? const Color.fromARGB(255, 12, 113, 11)
                      : Colors.green,
                  width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildVegetableAnimation() {
    if (!_showVegetableAnimation || _selectedVegetable.isEmpty)
      return const SizedBox();

    final vegetable = _vegetableDatabase[_selectedVegetable]!;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromARGB(
                          0, 00, 0, 0),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(0, 00, 00, 00)
                            .withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        16),
                    child: Image.asset(
                      vegetable['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.green[100],
                          child: Icon(
                            Icons.eco,
                            size: 80,
                            color: const Color.fromARGB(0, 00, 00, 00),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  vegetable['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vegetable['english']!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  vegetable['scientific']!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color.fromARGB(255, 56, 216, 8)
                          .withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'Scan Complete!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVegetableInfo() {
    if (_scannedVegetable.isEmpty) return const SizedBox();

    return FutureBuilder<Map<String, dynamic>?>(
      future: _scannerAPI.getVegetableInfo(_selectedVegetable),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }

        final vegetableData = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              vegetableData['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.green[700],
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color.fromARGB(0, 255, 255, 255)),
              onPressed: _resetScan,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        vegetableData['english']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '(${vegetableData['scientific']})',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  'Scan Count',
                  '${vegetableData['scan_count']} times',
                  Icons.bar_chart,
                  Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                    'Description', vegetableData['info']!, Icons.info),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Lifespan',
                        vegetableData['lifespan']!,
                        Icons.schedule,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Native Location',
                        vegetableData['location']!,
                        Icons.location_on,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                    'Nutrition', vegetableData['nutrition']!, Icons.food_bank),
                const SizedBox(height: 16),
                _buildVegetableTypesSection(
                    vegetableData['types'] as List<Map<String, dynamic>>),
                const SizedBox(height: 16),
                _buildInfoSection(
                    'Growing Tips', vegetableData['growing_tips']!, Icons.eco),
                const SizedBox(height: 16),
                _buildRecipesSection(vegetableData['recipes'] as List<String>),
                const SizedBox(height: 16),
                _buildCustomVideoSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomVideoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.agriculture, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Growing Guide Video',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Learn how to cultivate ${_vegetableDatabase[_selectedVegetable]!['name']}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_isVideoInitialized && _videoController != null)
            Column(
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_videoController!),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                        child: AnimatedOpacity(
                          opacity:
                              _videoController!.value.isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.replay, color: Colors.blue),
                        onPressed: () {
                          _videoController!.seekTo(Duration.zero);
                          _videoController!.play();
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: VideoProgressIndicator(
                            _videoController!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              backgroundColor: Colors.grey,
                              playedColor: Colors.blue,
                              bufferedColor: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Custom animated cultivation video for ${_vegetableDatabase[_selectedVegetable]!['name']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Loading cultivation video...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVegetableTypesSection(List<Map<String, dynamic>> types) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Text(
                'Varieties',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: types
                .map((type) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            type['description']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.teal,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  type['characteristics']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSectionColor(title),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(title)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _getIconColor(title), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTitleColor(title),
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

 Widget _buildRecipesSection(List<String> recipes) {
  if (recipes.isEmpty) return const SizedBox.shrink();
  
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: _buildSectionDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 12),
        _buildRecipeList(recipes),
      ],
    ),
  );
}

// Helper method to build section decoration
BoxDecoration _buildSectionDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.purple[50]!,
        Colors.purple[50]!.withOpacity(0.5),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.purple[100]!,
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.purple.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

// Helper method to build section header
Widget _buildSectionHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.purple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.restaurant_menu, color: Colors.purple, size: 22),
        SizedBox(width: 8),
        Text(
          'Popular Recipes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}

// Helper method to build recipe list
Widget _buildRecipeList(List<String> recipes) {
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: recipes.length,
    separatorBuilder: (context, index) => const Divider(
      height: 4,
      thickness: 0.5,
      color: Colors.purple,
      indent: 28,
    ),
    itemBuilder: (context, index) {
      final recipe = recipes[index];
      return _buildRecipeItem(recipe, index);
    },
  );
}

// Helper method to build individual recipe item
Widget _buildRecipeItem(String recipe, int index) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecipeIcon(index),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRecipeText(recipe),
        ),
        _buildRecipeActionButton(),
      ],
    ),
  );
}

// Helper method to build recipe icon with index
Widget _buildRecipeIcon(int index) {
  return Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: Colors.purple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Center(
      child: Text(
        '${index + 1}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.purple[700],
        ),
      ),
    ),
  );
}

// Helper method to build recipe text
Widget _buildRecipeText(String recipe) {
  return Text(
    recipe,
    style: const TextStyle(
      fontSize: 15,
      height: 1.4,
      color: Colors.black87,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

// Helper method to build action button for each recipe
Widget _buildRecipeActionButton() {
  return IconButton(
    icon: Icon(
      Icons.chevron_right,
      size: 20,
      color: Colors.purple[300],
    ),
    onPressed: () {
      // Add navigation or action logic here
      // _onRecipeTap(recipe);
    },
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),
    splashRadius: 20,
  );
}

// Optional: Add loading skeleton for better UX
Widget _buildRecipesLoadingSkeleton() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _buildSectionDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => _buildRecipeSkeletonItem(index)),
      ],
    ),
  );
}

Widget _buildRecipeSkeletonItem(int index) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Optional: Add empty state widget
Widget _buildEmptyRecipesState() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: _buildSectionDecoration(),
    child: Column(
      children: [
        Icon(
          Icons.restaurant_menu,
          size: 48,
          color: Colors.purple[200],
        ),
        const SizedBox(height: 12),
        Text(
          'No recipes available',
          style: TextStyle(
            fontSize: 14,
            color: Colors.purple[400],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Check back later for delicious suggestions!',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    ),
  );
}

  Color _getSectionColor(String title) {
    switch (title) {
      case 'Nutrition':
        return Colors.blue[50]!;
      case 'Description':
        return Colors.green[50]!;
      case 'Growing Tips':
        return Colors.orange[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getBorderColor(String title) {
    switch (title) {
      case 'Nutrition':
        return Colors.blue[100]!;
      case 'Description':
        return Colors.green[100]!;
      case 'Growing Tips':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getIconColor(String title) {
    switch (title) {
      case 'Nutrition':
        return Colors.blue;
      case 'Description':
        return Colors.green;
      case 'Growing Tips':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTitleColor(String title) {
    switch (title) {
      case 'Nutrition':
        return Colors.blue;
      case 'Description':
        return Colors.green;
      case 'Growing Tips':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCaptureButton() {
    if (_isScanning || _showVegetableAnimation) {
      return const SizedBox();
    }

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.green,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _startScanning,
              borderRadius: BorderRadius.circular(35),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildBody(),
  );
}

// ==================== APP BAR METHODS ====================

AppBar? _buildAppBar() {
  if (_showVegetableList) return null;
  
  return AppBar(
    title: const Text(
      'AR Vegetable Scanner',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.green[700],
    iconTheme: const IconThemeData(color: Colors.white),
    actions: [_buildAppBarActions()],
  );
}

Widget _buildAppBarActions() {
  return IconButton(
    icon: const Icon(
      Icons.list,
      color: Color.fromARGB(250, 255, 255, 255),
    ),
    onPressed: _showVegetableListScreen,
    tooltip: 'View Vegetable List',
  );
}

// ==================== BODY METHODS ====================

Widget _buildBody() {
  if (_showVegetableList) {
    return _buildVegetableList();
  }
  
  return _buildScannerView();
}

Widget _buildScannerView() {
  return Stack(
    children: [
      _buildCameraPreview(),
      if (_showVegetableAnimation) _buildVegetableAnimation(),
      if (_scannedVegetable.isNotEmpty && !_showVegetableAnimation)
        _buildVegetableInfo(),
      _buildCaptureButton(),
    ],
  );
}

// ==================== CAMERA METHODS ====================

Widget _buildCameraPreview() {
  // Your camera preview implementation
  // Return the camera widget here
  return Container(); // Placeholder
}

// ==================== ANIMATION METHODS ====================

Widget _buildVegetableAnimation() {
  // Your vegetable scanning animation implementation
  return Container(); // Placeholder
}

// ==================== VEGETABLE INFO METHODS ====================

Widget _buildVegetableInfo() {
  // Your vegetable information display implementation
  return Container(); // Placeholder
}

// ==================== BUTTON METHODS ====================

Widget _buildCaptureButton() {
  // Your capture button implementation
  return Container(); // Placeholder
}

// ==================== VEGETABLE LIST METHODS ====================

Widget _buildVegetableList() {
  // Your vegetable list implementation
  return Container(); // Placeholder
}

// ==================== HELPER METHODS ====================

void _showVegetableListScreen() {
  // Implementation for showing vegetable list
  setState(() {
    _showVegetableList = true;
  });
}

// ==================== ENUMS ====================

enum CornerPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// Extension for CornerPosition (optional but useful)
extension CornerPositionExtension on CornerPosition {
  Alignment get alignment {
    switch (this) {
      case CornerPosition.topLeft:
        return Alignment.topLeft;
      case CornerPosition.topRight:
        return Alignment.topRight;
      case CornerPosition.bottomLeft:
        return Alignment.bottomLeft;
      case CornerPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }
  
  String get label {
    switch (this) {
      case CornerPosition.topLeft:
        return 'Top Left';
      case CornerPosition.topRight:
        return 'Top Right';
      case CornerPosition.bottomLeft:
        return 'Bottom Left';
      case CornerPosition.bottomRight:
        return 'Bottom Right';
    }
  }
}