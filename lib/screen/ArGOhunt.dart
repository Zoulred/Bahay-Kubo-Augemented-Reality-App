import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:ar_capstone2/services/ARAudioservice.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VeggieHuntApp());
}

class VeggieHuntApp extends StatelessWidget {
  const VeggieHuntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veggie Hunt GO',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[850],
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const ARAdventure3DPage(user: {}),
    );
  }
}

class ARAdventure3DPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ARAdventure3DPage({super.key, required this.user});

  @override
  State<ARAdventure3DPage> createState() => _ARAdventure3DPageState();
}

class _ARAdventure3DPageState extends State<ARAdventure3DPage>
    with TickerProviderStateMixin {
  Position? _currentPosition;
  bool _isLoading = true;
  bool _locationEnabled = false;
  String _locationStatus = 'Checking location...';
  String _currentAddress = 'Getting address...';
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _previousPosition;
  double _totalDistance = 0.0;
  int _steps = 0;
  bool _hasMoved = false;

  List<Vegetable> _collectedVegetables = [];
  List<ARVegetable> _arVegetables = [];
  Timer? _vegetableSpawnTimer;
  int _stepsSinceLastSpawn = 0;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isARView = false;

  double? _heading;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _pitch = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  Timer? _arDetectionTimer;
  List<ARVegetable> _vegetablesInView = [];

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  bool _showDiscoveryAnimation = false;

  final FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;

  Language _currentLanguage = Language.english;
  String _currentLocale = "en-US";

  double _accelerometerMagnitude = 0.0;
  double _previousMagnitude = 0.0;
  DateTime? _lastStepTime;
  Timer? _stepResetTimer;
  bool _isDeviceMoving = false;
  static const double STEP_THRESHOLD = 12.0;
  static const int STEP_COOLDOWN_MS = 300;

  Vegetable? _currentDisplayedVegetable;

  bool _isEnglishHovered = false;
  bool _isTagalogHovered = false;

  File? _avatarImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAvatarMoving = false;
  Timer? _avatarAnimationTimer;
  double _avatarBounceValue = 0.0;
  late AnimationController _avatarBounceController;
  late Animation<double> _avatarBounceAnimation;

  // Audio service
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
    _initializeCamera();
    _initializeSensors();
    _initializeTTS();
    _initializeAvatarAnimations();

    // Start background music
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.playBackgroundMusic();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);

    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.linear),
    );
    _scanAnimationController.repeat();
  }

  void _initializeAvatarAnimations() {
    _avatarBounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _avatarBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _avatarBounceController,
      curve: Curves.easeInOut,
    ));

    _avatarBounceAnimation.addListener(() {
      setState(() {
        _avatarBounceValue = _avatarBounceAnimation.value;
      });
    });
  }

  void _startAvatarAnimation() {
    if (!_isAvatarMoving) {
      _isAvatarMoving = true;
      _avatarBounceController.repeat(reverse: true);
    }
  }

  void _stopAvatarAnimation() {
    if (_isAvatarMoving) {
      _isAvatarMoving = false;
      _avatarBounceController.stop();
      _avatarBounceController.reset();
      setState(() {
        _avatarBounceValue = 0.0;
      });
    }
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage(_currentLocale);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Set up TTS handlers
    flutterTts.setStartHandler(() {
      // When TTS starts speaking, pause background music
      _audioService.onTTSStart();
    });

    flutterTts.setCompletionHandler(() {
      // When TTS finishes speaking, resume background music
      _audioService.onTTSComplete();
      setState(() {
        _isSpeaking = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      // If TTS encounters an error, still resume background music
      _audioService.onTTSComplete();
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void _toggleLanguage() {
    setState(() {
      if (_currentLanguage == Language.english) {
        _currentLanguage = Language.tagalog;
        _currentLocale = "fil-PH";
      } else {
        _currentLanguage = Language.english;
        _currentLocale = "en-US";
      }
    });

    _initializeTTS();

    if (_currentDisplayedVegetable != null) {
      _speakVegetableDetails(_currentDisplayedVegetable!);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission != PermissionStatus.granted) return;

      _cameras = await availableCameras();
      if (_cameras!.isEmpty) return;

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  void _initializeSensors() {
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() => _heading = event.heading);
        _updateVegetablesInView();
      }
    });

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        _accelerometerMagnitude =
            sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        _detectStep();
        setState(() {
          _pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) *
              180 /
              pi;
        });
      }
    });
  }

  void _detectStep() {
    final now = DateTime.now();

    if (_lastStepTime != null &&
        now.difference(_lastStepTime!).inMilliseconds < STEP_COOLDOWN_MS) {
      return;
    }

    if (_previousMagnitude < STEP_THRESHOLD &&
        _accelerometerMagnitude >= STEP_THRESHOLD) {
      _lastStepTime = now;
      _setDeviceMoving();
      setState(() {
        _steps++;
        _stepsSinceLastSpawn++;
      });

      if (!_isAvatarMoving) {
        _startAvatarAnimation();
      }

      if (_steps % 10 == 0) {
        _showMovementFeedback();
      }
    }
    _previousMagnitude = _accelerometerMagnitude;
  }

  void _setDeviceMoving() {
    _isDeviceMoving = true;
    _stepResetTimer?.cancel();
    _stepResetTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isDeviceMoving = false;
        _stopAvatarAnimation();
      });
    });
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Checking location services...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleLocationError(
            'Location services are disabled. Please enable them.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleLocationError(
              'Location permission denied. Please grant permission.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _handleLocationError(
            'Location permission permanently denied. Please enable in app settings.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 10));

      await _getAddressFromLatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        _previousPosition = position;
        _isLoading = false;
        _locationEnabled = true;
        _locationStatus = 'Location found! Start walking to find vegetables!';
      });

      _startLocationUpdates();
      _startVegetableSpawning();
    } catch (e) {
      _handleLocationError('Error getting location: $e');
    }
  }

  void _handleLocationError(String message) {
    setState(() {
      _isLoading = false;
      _locationEnabled = false;
      _locationStatus = message;
    });
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 3,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      if (mounted) {
        setState(() => _currentPosition = position);

        if (_previousPosition != null) {
          double distance = _calculateDistance(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          if (distance > 3) {
            _hasMoved = true;
            _totalDistance += distance;
            _previousPosition = position;
            _updateARVegetablesPosition();
          }
        }
      }
    });
  }

  void _startVegetableSpawning() {
    _spawnVegetablesAroundUser();

    _vegetableSpawnTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_hasMoved && _stepsSinceLastSpawn > 10) {
        _spawnVegetablesAroundUser();
        _stepsSinceLastSpawn = 0;
      }
    });
  }

  void _spawnVegetablesAroundUser() {
    if (_currentPosition == null) return;

    final random = Random();
    final newVegetables = <ARVegetable>[];

    int spawnCount = 4 + random.nextInt(6);

    for (int i = 0; i < spawnCount; i++) {
      double distance = 10 + random.nextDouble() * 90;
      double bearing = random.nextDouble() * 360;

      var newPos = _calculateNewPosition(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        distance,
        bearing,
      );

      final vegetableTypes = [
        _createVegetable('Singkamas', 'assets/images/singkmas.png',
            Rarity.common, Colors.brown[200]!, 'Jicama'),
        _createVegetable('Talong', 'assets/images/talong.png', Rarity.common,
            Colors.purple, 'Eggplant'),
        _createVegetable('Sigarilyas', 'assets/images/sigarilyas.png',
            Rarity.uncommon, Colors.green, 'Winged beans'),
        _createVegetable('Mani', 'assets/images/mani.png', Rarity.common,
            Colors.brown, 'Peanuts'),
        _createVegetable('Sitaw', 'assets/images/sitaw.png', Rarity.common,
            Colors.green, 'String beans'),
        _createVegetable('Bataw', 'assets/images/bataw.png', Rarity.uncommon,
            Colors.lightGreen, 'Hyacinth beans'),
        _createVegetable('Patani', 'assets/images/patani.png', Rarity.uncommon,
            Colors.green[700]!, 'Lima beans'),
        _createVegetable('Kundol', 'assets/images/kundol.png', Rarity.rare,
            Colors.lightGreen[100]!, 'Winter melon'),
        _createVegetable('Patola', 'assets/images/patola.png', Rarity.uncommon,
            Colors.green, 'Sponge gourd'),
        _createVegetable('Upo', 'assets/images/upo.png', Rarity.common,
            Colors.green[100]!, 'Bottle gourd'),
        _createVegetable('Kalabasa', 'assets/images/kalabasa.png',
            Rarity.common, Colors.orange, 'Squash'),
        _createVegetable('Labanos', 'assets/images/labanos.png', Rarity.common,
            Colors.red[200]!, 'Radish'),
        _createVegetable('Mustasa', 'assets/images/mustasa.png',
            Rarity.uncommon, Colors.green[800]!, 'Mustard greens'),
        _createVegetable('Sibuyas', 'assets/images/sibuyas.png', Rarity.common,
            Colors.purple[200]!, 'Onion'),
        _createVegetable('Kamatis', 'assets/images/kamatis.png', Rarity.common,
            Colors.red, 'Tomato'),
        _createVegetable('Bawang', 'assets/images/bawang.png', Rarity.uncommon,
            Colors.white, 'Garlic'),
        _createVegetable('Luya', 'assets/images/luya.png', Rarity.rare,
            Colors.brown[400]!, 'Ginger'),
        _createVegetable('Linga', 'assets/images/linga.png', Rarity.rare,
            Colors.yellow[700]!, 'Sesame seeds'),
      ];

      final vegetable = vegetableTypes[random.nextInt(vegetableTypes.length)];

      newVegetables.add(ARVegetable(
        vegetable: vegetable,
        latitude: newPos['lat']!,
        longitude: newPos['lng']!,
        distance: distance,
        bearing: bearing,
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
      ));
    }

    setState(() {
      _arVegetables.addAll(newVegetables);
      _arVegetables.removeWhere((arVeg) => arVeg.distance > 250);
    });

    _showSpawnAnimation();
  }

  void _updateARVegetablesPosition() {
    if (_currentPosition == null) return;

    setState(() {
      for (var arVegetable in _arVegetables) {
        arVegetable.distance = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          arVegetable.latitude,
          arVegetable.longitude,
        );

        arVegetable.bearing = _calculateBearing(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          arVegetable.latitude,
          arVegetable.longitude,
        );
      }
    });
  }

  void _updateVegetablesInView() {
    if (_currentPosition == null || _heading == null) return;

    List<ARVegetable> newVegetablesInView = [];

    for (var arVegetable in _arVegetables) {
      if (arVegetable.distance <= 50) {
        double bearingDiff = (_heading! - arVegetable.bearing).abs();
        if (bearingDiff < 45 || bearingDiff > 315) {
          newVegetablesInView.add(arVegetable);
        }
      }
    }

    setState(() => _vegetablesInView = newVegetablesInView);
  }

  Vegetable _createVegetable(String name, String imagePath, Rarity rarity,
      Color color, String englishName) {
    final vegetableData = _getVegetableData(name, englishName);
    return Vegetable(
      id: '${name}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      englishName: englishName,
      imagePath: imagePath,
      rarity: rarity,
      color: color,
      scientificName: vegetableData['scientificName']!,
      varieties: vegetableData['varieties']!,
      nutritionalFacts: vegetableData['nutritionalFacts']!,
      healthBenefits: vegetableData['healthBenefits']!,
      commonRecipes: vegetableData['commonRecipes']!,
      growingTips: vegetableData['growingTips']!,
      description: vegetableData['description']!,
      tagalogDescription: vegetableData['tagalogDescription']!,
      tagalogNutritionalFacts: vegetableData['tagalogNutritionalFacts']!,
      tagalogHealthBenefits: vegetableData['tagalogHealthBenefits']!,
      tagalogCommonRecipes: vegetableData['tagalogCommonRecipes']!,
      tagalogGrowingTips: vegetableData['tagalogGrowingTips']!,
      growingMonths: vegetableData['growingMonths']!,
      growingRegions: vegetableData['growingRegions']!,
      tagalogGrowingMonths: vegetableData['tagalogGrowingMonths']!,
      tagalogGrowingRegions: vegetableData['tagalogGrowingRegions']!,
    );
  }

  Map<String, String> _getVegetableData(String name, String englishName) {
    switch (name) {
      case 'Singkamas':
        return {
          'scientificName': 'Pachyrhizus erosus',
          'varieties':
              'Several varieties including Mexican jicama and jicama de agua',
          'nutritionalFacts':
              'Low in calories, high in fiber, vitamin C, and potassium. Contains inulin, a prebiotic fiber.',
          'healthBenefits':
              'Aids digestion, supports gut health, helps regulate blood sugar, promotes hydration, and boosts immunity',
          'commonRecipes':
              'Fresh salads, spring rolls, stir-fries, fruit platters, and pickled jicama',
          'growingTips':
              'Warm climate plant, needs well-drained soil, 5-9 months to harvest, avoid frost',
          'description':
              'Singkamas or jicama is a crispy, sweet, and juicy root vegetable popular in Filipino cuisine.',
          'tagalogDescription':
              'Ang singkamas o jicama ay isang malutong, matamis, at mamasa-masang gulay na ugat na popular sa lutuing Pilipino.',
          'tagalogNutritionalFacts':
              'Mababa sa calories, mataas sa fiber, vitamin C, at potassium. Naglalaman ng inulin, isang prebiotic fiber.',
          'tagalogHealthBenefits':
              'Tumutulong sa pagtunaw ng pagkain, sumusuporta sa kalusugan ng bituka, tumutulong sa pag-regulate ng blood sugar, nagpapaubos ng hydration, at nagpapalakas ng immunity',
          'tagalogCommonRecipes':
              'Sariwang salad, lumpia, stir-fry, prutas na platter, at atcharang singkamas',
          'tagalogGrowingTips':
              'Halaman na mainit na klima, kailangan ng well-drained na lupa, 5-9 na buwan bago ani, iwasan ang frost',
          'growingMonths': 'November to February',
          'growingRegions': 'Batangas, Pangasinan, Cagayan Valley, Mindoro',
          'tagalogGrowingMonths': 'Nobyembre hanggang Pebrero',
          'tagalogGrowingRegions':
              'Batangas, Pangasinan, Lambak ng Cagayan, Mindoro',
        };
      case 'Talong':
        return {
          'scientificName': 'Solanum melongena',
          'varieties':
              '5 main types including Globe, Japanese, Chinese, Indian, and Thai varieties',
          'nutritionalFacts':
              'High in fiber (12% DV), manganese (13% DV), folate (5% DV), and vitamins K (4% DV) and C (3% DV)',
          'healthBenefits':
              'Supports heart health, aids digestion, helps control blood sugar, promotes bone health, and contains antioxidants',
          'commonRecipes':
              'Eggplant parmesan, tortang talong, pinakbet, ensaladang talong, and grilled eggplant',
          'growingTips':
              'Warm season crop, needs full sun, space plants 18-24 inches apart, harvest when skin is glossy',
          'description':
              'Talong or eggplant is a versatile vegetable with a meaty texture that absorbs flavors well in cooking.',
          'tagalogDescription':
              'Ang talong o eggplant ay isang malaking gulay na may malaman na tekstura na sumisips ng mabuti sa lasa sa pagluluto.',
          'tagalogNutritionalFacts':
              'Mataas sa fiber (12% DV), manganese (13% DV), folate (5% DV), at mga bitamina K (4% DV) at C (3% DV)',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng puso, tumutulong sa pagtunaw ng pagkain, tumutulong sa pagkontrol ng blood sugar, nagpapaunlad sa kalusugan ng buto, at naglalaman ng antioxidants',
          'tagalogCommonRecipes':
              'Eggplant parmesan, tortang talong, pinakbet, ensaladang talong, at inihaw na talong',
          'tagalogGrowingTips':
              'Pananim na mainit na panahon, kailangan ng buong araw, maglagay ng halaman 18-24 pulgada ang pagitan, anihin kapag ang balat ay makinis',
          'growingMonths': 'Year-round, best from March to July',
          'growingRegions': 'Ilocos, Cagayan Valley, Central Luzon, Quezon',
          'tagalogGrowingMonths':
              'Buong taon, pinakamabuti mula Marso hanggang Hulyo',
          'tagalogGrowingRegions':
              'Ilocos, Lambak ng Cagayan, Gitnang Luzon, Quezon',
        };
      case 'Sigarilyas':
        return {
          'scientificName': 'Psophocarpus tetragonolobus',
          'varieties':
              'Several varieties with different pod colors including green, purple, and red',
          'nutritionalFacts':
              'Rich in protein, vitamin A, vitamin C, calcium, and iron. Contains all essential amino acids.',
          'healthBenefits':
              'Supports bone health, boosts immunity, aids digestion, helps regulate blood sugar, and has anti-inflammatory properties',
          'commonRecipes':
              'Adobong sigarilyas, ginataang sigarilyas, stir-fries, and vegetable curries',
          'growingTips':
              'Tropical climbing plant, needs trellis support, warm and humid conditions, harvest when pods are young',
          'description':
              'Sigarilyas or winged bean is a nutrient-dense vegetable with distinctive winged pods.',
          'tagalogDescription':
              'Ang sigarilyas o winged bean ay isang masustansyang gulay na may natatanging pakpak na mga pods.',
          'tagalogNutritionalFacts':
              'Mayaman sa protina, bitamina A, bitamina C, calcium, at iron. Naglalaman ng lahat ng mahahalagang amino acids.',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng buto, nagpapalakas ng immunity, tumutulong sa pagtunaw ng pagkain, tumutulong sa pag-regulate ng blood sugar, at may anti-inflammatory na katangian',
          'tagalogCommonRecipes':
              'Adobong sigarilyas, ginataang sigarilyas, stir-fries, at mga gulay na curry',
          'tagalogGrowingTips':
              'Tropikal na umahon na halaman, kailangan ng suporta ng trellis, mainit at mahalumigmig na kondisyon, anihin kapag ang mga pods ay bata pa',
          'growingMonths': 'June to December',
          'growingRegions': 'Laguna, Batangas, Cavite, Quezon, Bicol Region',
          'tagalogGrowingMonths': 'Hunyo hanggang Disyembre',
          'tagalogGrowingRegions':
              'Laguna, Batangas, Cavite, Quezon, Rehiyon ng Bicol',
        };
      case 'Mani':
        return {
          'scientificName': 'Arachis hypogaea',
          'varieties':
              'Four major types: Runner, Spanish, Virginia, and Valencia',
          'nutritionalFacts':
              'High in protein (25g per 100g), healthy fats, vitamin E, niacin, folate, and manganese',
          'healthBenefits':
              'Supports heart health, aids weight management, helps regulate blood sugar, promotes brain health, and has antioxidant properties',
          'commonRecipes':
              'Boiled peanuts, adobong mani, peanut butter, kare-kare, and peanut brittle',
          'growingTips':
              'Warm season crop, well-drained sandy soil, 120-150 days to harvest, pods develop underground',
          'description':
              'Mani or peanuts are legumes that grow underground and are popular snacks and ingredients in Filipino cuisine.',
          'tagalogDescription':
              'Ang mani o peanuts ay mga legume na lumalago sa ilalim ng lupa at sikat na meryenda at sangkap sa lutuing Pilipino.',
          'tagalogNutritionalFacts':
              'Mataas sa protina (25g bawat 100g), malusog na taba, bitamina E, niacin, folate, at manganese',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng puso, tumutulong sa pamamahala ng timbang, tumutulong sa pag-regulate ng blood sugar, nagpapaunlad sa kalusugan ng utak, at may antioxidant na katangian',
          'tagalogCommonRecipes':
              'Nilagang mani, adobong mani, peanut butter, kare-kare, at peanut brittle',
          'tagalogGrowingTips':
              'Pananim na mainit na panahon, well-drained na buhangin na lupa, 120-150 na araw bago ani, ang mga pods ay lumalago sa ilalim ng lupa',
          'growingMonths': 'January to March for harvest',
          'growingRegions': 'Pangasinan, Isabela, Nueva Ecija, Tarlac',
          'tagalogGrowingMonths': 'Enero hanggang Marso para sa ani',
          'tagalogGrowingRegions': 'Pangasinan, Isabela, Nueva Ecija, Tarlac',
        };
      case 'Sitaw':
        return {
          'scientificName': 'Vigna unguiculata subsp. sesquipedalis',
          'varieties':
              'Multiple varieties including green, purple, and red string beans',
          'nutritionalFacts':
              'High in Vitamin C (27% DV), Vitamin K (20% DV), manganese (18% DV), and fiber (16% DV). Good source of plant protein.',
          'healthBenefits':
              'Supports bone health, boosts immunity, aids digestion, helps regulate blood sugar, and promotes heart health',
          'commonRecipes':
              'Adobong sitaw, ginisang sitaw, kare-kare, sinigang, and vegetable stir-fries',
          'growingTips':
              'Plant after last frost, provide support for climbing varieties, harvest regularly to encourage production',
          'description':
              'Sitaw or string beans are long, slender green pods that are a staple in Filipino cuisine.',
          'tagalogDescription':
              'Ang sitaw o string beans ay mahabang, manipis na berdeng mga pods na pangunahing sangkap sa lutuing Pilipino.',
          'tagalogNutritionalFacts':
              'Mataas sa Bitamina C (27% DV), Bitamina K (20% DV), manganese (18% DV), at fiber (16% DV). Mahusay na mapagkukunan ng protina sa halaman.',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng buto, nagpapalakas ng immunity, tumutulong sa pagtunaw ng pagkain, tumutulong sa pag-regulate ng blood sugar, at nagpapaunlad sa kalusugan ng puso',
          'tagalogCommonRecipes':
              'Adobong sitaw, ginisang sitaw, kare-kare, sinigang, at mga stir-fry ng gulay',
          'tagalogGrowingTips':
              'Magtanim pagkatapos ng huling frost, magbigay ng suporta sa mga umahon na uri, anihin nang regular upang hikayatin ang produksyon',
          'growingMonths': 'Year-round, peak from October to February',
          'growingRegions': 'Benguet, Ifugao, Mountain Province, Nueva Vizcaya',
          'tagalogGrowingMonths':
              'Buong taon, rurok mula Oktubre hanggang Pebrero',
          'tagalogGrowingRegions':
              'Benguet, Ifugao, Lalawigang Bulubundukin, Nueva Vizcaya',
        };
      case 'Bataw':
        return {
          'scientificName': 'Lablab purpureus',
          'varieties':
              'Several varieties with different pod colors including green, purple, and red',
          'nutritionalFacts':
              'Rich in protein, fiber, iron, calcium, and B vitamins. Low in calories.',
          'healthBenefits':
              'Supports bone health, aids digestion, helps regulate blood sugar, boosts immunity, and has antioxidant properties',
          'commonRecipes':
              'Ginataang bataw, vegetable stews, stir-fries, and curries',
          'growingTips':
              'Warm climate plant, needs trellis support, well-drained soil, harvest when pods are young and tender',
          'description':
              'Bataw or hyacinth bean is a climbing plant with edible pods, seeds, and leaves.',
          'tagalogDescription':
              'Ang bataw o hyacinth bean ay isang umahon na halaman na may nakakain na mga pods, buto, at dahon.',
          'tagalogNutritionalFacts':
              'Mayaman sa protina, fiber, iron, calcium, at mga bitamina B. Mababa sa calories.',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng buto, tumutulong sa pagtunaw ng pagkain, tumutulong sa pag-regulate ng blood sugar, nagpapalakas ng immunity, at may antioxidant na katangian',
          'tagalogCommonRecipes':
              'Ginataang bataw, mga stew ng gulay, stir-fries, at mga curry',
          'tagalogGrowingTips':
              'Halaman na mainit na klima, kailangan ng suporta ng trellis, well-drained na lupa, anihin kapag ang mga pods ay bata at malambot',
          'growingMonths': 'May to November',
          'growingRegions': 'Ilocos Region, Pangasinan, Tarlac, Nueva Ecija',
          'tagalogGrowingMonths': 'Mayo hanggang Nobyembre',
          'tagalogGrowingRegions':
              'Rehiyon ng Ilocos, Pangasinan, Tarlac, Nueva Ecija',
        };
      case 'Patani':
        return {
          'scientificName': 'Phaseolus lunatus',
          'varieties':
              'Two main types: large-seeded (lima) and small-seeded (butter) beans',
          'nutritionalFacts':
              'High in protein, fiber, iron, magnesium, potassium, and B vitamins',
          'healthBenefits':
              'Supports heart health, aids digestion, helps regulate blood sugar, promotes bone health, and boosts immunity',
          'commonRecipes':
              'Ginataang patani, vegetable stews, soups, and mixed vegetable dishes',
          'growingTips':
              'Warm season crop, needs full sun, well-drained soil, harvest when pods are fully developed',
          'description':
              'Patani or lima beans are flat, kidney-shaped beans with a buttery texture when cooked.',
          'tagalogDescription':
              'Ang patani o lima beans ay mga patag, hugis-kidney na buto na may mantekilyang tekstura kapag niluto.',
          'tagalogNutritionalFacts':
              'Mataas sa protina, fiber, iron, magnesium, potassium, at mga bitamina B',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng puso, tumutulong sa pagtunaw ng pagkain, tumutulong sa pag-regulate ng blood sugar, nagpapaunlad sa kalusugan ng buto, at nagpapalakas ng immunity',
          'tagalogCommonRecipes':
              'Ginataang patani, mga stew ng gulay, sabaw, at mga halo-halong lutong gulay',
          'tagalogGrowingTips':
              'Pananim na mainit na panahon, kailangan ng buong araw, well-drained na lupa, anihin kapag ang mga pods ay ganap na naunlad',
          'growingMonths': 'October to February',
          'growingRegions': 'Bicol Region, Quezon, Laguna, Mindoro',
          'tagalogGrowingMonths': 'Oktubre hanggang Pebrero',
          'tagalogGrowingRegions': 'Rehiyon ng Bicol, Quezon, Laguna, Mindoro',
        };
      case 'Kundol':
        return {
          'scientificName': 'Benincasa hispida',
          'varieties': 'Several varieties with different sizes and shapes',
          'nutritionalFacts':
              'Low in calories, high in fiber, vitamin C, riboflavin, and zinc. Contains antioxidants.',
          'healthBenefits':
              'Aids digestion, supports weight loss, helps regulate blood sugar, promotes hydration, and has cooling properties',
          'commonRecipes':
              'Ginataang kundol, buko pandan with kundol, sweet preserves, and vegetable soups',
          'growingTips':
              'Warm season crop, needs space to spread, consistent moisture, harvest when mature and waxy',
          'description':
              'Kundol or winter melon is a large, mild-flavored gourd commonly used in Filipino desserts and savory dishes.',
          'tagalogDescription':
              'Ang kundol o winter melon ay isang malaking, banayad na lasang gourd na karaniwang ginagamit sa mga dessert at maanghang na lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mababa sa calories, mataas sa fiber, bitamina C, riboflavin, at zinc. Naglalaman ng antioxidants.',
          'tagalogHealthBenefits':
              'Tumutulong sa pagtunaw ng pagkain, sumusuporta sa pagbaba ng timbang, tumutulong sa pag-regulate ng blood sugar, nagpapaubos ng hydration, at may cooling na katangian',
          'tagalogCommonRecipes':
              'Ginataang kundol, buko pandan with kundol, matamis na preserve, at mga sabaw ng gulay',
          'tagalogGrowingTips':
              'Pananim na mainit na panahon, kailangan ng espasyo para magkalat, patuloy na moisture, anihin kapag mature at waxy',
          'growingMonths': 'December to May',
          'growingRegions': 'Batangas, Cavite, Laguna, Quezon',
          'tagalogGrowingMonths': 'Disyembre hanggang Mayo',
          'tagalogGrowingRegions': 'Batangas, Cavite, Laguna, Quezon',
        };
      case 'Patola':
        return {
          'scientificName': 'Luffa acutangula',
          'varieties': 'Several varieties with different ridge patterns',
          'nutritionalFacts':
              'Low in calories, high in fiber, vitamin C, vitamin A, and manganese',
          'healthBenefits':
              'Supports digestion, aids weight management, boosts immunity, promotes skin health, and has anti-inflammatory properties',
          'commonRecipes':
              'Ginisang patola with miswa, dinengdeng, vegetable soups, and stir-fries',
          'growingTips':
              'Warm season crop, needs trellis support, regular watering, harvest when young and tender',
          'description':
              'Patola or sponge gourd is a ridged vegetable commonly used in Filipino soups and stir-fried dishes.',
          'tagalogDescription':
              'Ang patola o sponge gourd ay isang ridged na gulay na karaniwang ginagamit sa mga sabaw at stir-fried na lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mababa sa calories, mataas sa fiber, bitamina C, bitamina A, at manganese',
          'tagalogHealthBenefits':
              'Sumusuporta sa pagtunaw ng pagkain, tumutulong sa pamamahala ng timbang, nagpapalakas ng immunity, nagpapaunlad sa kalusugan ng balat, at may anti-inflammatory na katangian',
          'tagalogCommonRecipes':
              'Ginisang patola with miswa, dinengdeng, mga sabaw ng gulay, at mga stir-fry',
          'tagalogGrowingTips':
              'Pananim na mainit na panahon, kailangan ng suporta ng trellis, regular na pagtubig, anihin kapag bata at malambot',
          'growingMonths': 'Year-round in tropical areas',
          'growingRegions': 'Central Luzon, Southern Tagalog, Bicol Region',
          'tagalogGrowingMonths': 'Buong taon sa mga tropikal na lugar',
          'tagalogGrowingRegions':
              'Gitnang Luzon, Katimugang Tagalog, Rehiyon ng Bicol',
        };
      case 'Upo':
        return {
          'scientificName': 'Lagenaria siceraria',
          'varieties': '2 main varieties: long and round bottle gourd shapes',
          'nutritionalFacts':
              'Rich in Vitamin C (11% DV), Vitamin B complex, iron, magnesium, and zinc. Very low in calories (15 cal per 100g)',
          'healthBenefits':
              'Promotes weight loss, supports heart health, aids digestion, has cooling properties, and helps control blood pressure',
          'commonRecipes':
              'Ginisang upo, bulanglang, vegetable stews, and soups',
          'growingTips':
              'Warm climate plant, needs trellis support, regular watering, harvest when young and tender',
          'description':
              'Upo or bottle gourd is a light green, mild-flavored vegetable commonly used in Filipino cuisine.',
          'tagalogDescription':
              'Ang upo o bottle gourd ay isang maliwanag na berde, banayad na lasang gulay na karaniwang ginagamit sa lutuing Pilipino.',
          'tagalogNutritionalFacts':
              'Mayaman sa Bitamina C (11% DV), Bitamina B complex, iron, magnesium, at zinc. Napakababa sa calories (15 cal bawat 100g)',
          'tagalogHealthBenefits':
              'Nagpapaunlad ng pagbaba ng timbang, sumusuporta sa kalusugan ng puso, tumutulong sa pagtunaw ng pagkain, may cooling na katangian, at tumutulong sa pagkontrol ng blood pressure',
          'tagalogCommonRecipes':
              'Ginisang upo, bulanglang, mga stew ng gulay, at mga sabaw',
          'tagalogGrowingTips':
              'Halaman na mainit na klima, kailangan ng suporta ng trellis, regular na pagtubig, anihin kapag bata at malambot',
          'growingMonths': 'June to November',
          'growingRegions': 'Ilocos Region, Central Luzon, Cagayan Valley',
          'tagalogGrowingMonths': 'Hunyo hanggang Nobyembre',
          'tagalogGrowingRegions':
              'Rehiyon ng Ilocos, Gitnang Luzon, Lambak ng Cagayan',
        };
      case 'Kalabasa':
        return {
          'scientificName': 'Cucurbita maxima',
          'varieties':
              'Several varieties including butternut, acorn, spaghetti, and kabocha squash',
          'nutritionalFacts':
              'Rich in Vitamin A (457% DV), Vitamin C (52% DV), potassium (17% DV), and fiber (11% DV). High in beta-carotene.',
          'healthBenefits':
              'Supports eye health, boosts immunity, promotes skin health, aids digestion, and has anti-inflammatory properties',
          'commonRecipes':
              'Ginataang kalabasa, sinigang na kalabasa, kalabasa flan, and roasted squash',
          'growingTips':
              'Warm season crop, needs space to spread, full sun, harvest when skin is hard and cannot be pierced with thumbnail',
          'description':
              'Kalabasa or squash is a versatile vegetable with sweet, dense flesh used in both savory and sweet Filipino dishes.',
          'tagalogDescription':
              'Ang kalabasa o squash ay isang malawak na gulay na may matamis, makapal na laman na ginagamit sa parehong maanghang at matamis na lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mayaman sa Bitamina A (457% DV), Bitamina C (52% DV), potassium (17% DV), at fiber (11% DV). Mataas sa beta-carotene.',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng mata, nagpapalakas ng immunity, nagpapaunlad sa kalusugan ng balat, tumutulong sa pagtunaw ng pagkain, at may anti-inflammatory na katangian',
          'tagalogCommonRecipes':
              'Ginataang kalabasa, sinigang na kalabasa, kalabasa flan, at inihaw na kalabasa',
          'tagalogGrowingTips':
              'Pananim na mainit na panahon, kailangan ng espasyo para magkalat, buong araw, anihin kapag ang balat ay matigas at hindi maipit sa thumbnail',
          'growingMonths': 'October to February',
          'growingRegions': 'Ilocos, Cagayan Valley, Central Luzon, Bicol',
          'tagalogGrowingMonths': 'Oktubre hanggang Pebrero',
          'tagalogGrowingRegions':
              'Ilocos, Lambak ng Cagayan, Gitnang Luzon, Bicol',
        };
      case 'Labanos':
        return {
          'scientificName': 'Raphanus sativus',
          'varieties':
              '3 main types: red globe, white icicle, and black Spanish radishes',
          'nutritionalFacts':
              'High in Vitamin C (25% DV), folate (7% DV), fiber (8% DV), and potassium (5% DV). Low in calories.',
          'healthBenefits':
              'Supports digestion, boosts immunity, helps detoxify the body, promotes hydration, and supports skin health',
          'commonRecipes':
              'Ensaladang labanos, pickled radish, sinigang, and vegetable stir-fries',
          'growingTips':
              'Fast-growing (3-4 weeks), cool weather crop, plant in loose soil, harvest when roots are 1 inch in diameter',
          'description':
              'Labanos or radish is a crisp, peppery root vegetable that adds crunch and flavor to Filipino dishes.',
          'tagalogDescription':
              'Ang labanos o radish ay isang malutong, maanghang na gulay na ugat na nagdaragdag ng crunch at lasa sa mga lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mataas sa Bitamina C (25% DV), folate (7% DV), fiber (8% DV), at potassium (5% DV). Mababa sa calories.',
          'tagalogHealthBenefits':
              'Sumusuporta sa pagtunaw ng pagkain, nagpapalakas ng immunity, tumutulong sa pag-detoxify ng katawan, nagpapaubos ng hydration, at sumusuporta sa kalusugan ng balat',
          'tagalogCommonRecipes':
              'Ensaladang labanos, pickled radish, sinigang, at mga stir-fry ng gulay',
          'tagalogGrowingTips':
              'Mabilis na lumaki (3-4 na linggo), malamig na pananim ng panahon, magtanim sa maluwag na lupa, anihin kapag ang mga ugat ay 1 pulgada ang diametro',
          'growingMonths': 'October to March',
          'growingRegions': 'Benguet, Mountain Province, Ifugao, Nueva Vizcaya',
          'tagalogGrowingMonths': 'Oktubre hanggang Marso',
          'tagalogGrowingRegions':
              'Benguet, Lalawigang Bulubundukin, Ifugao, Nueva Vizcaya',
        };
      case 'Mustasa':
        return {
          'scientificName': 'Brassica juncea',
          'varieties':
              'Several varieties including green, red, and brown mustard greens',
          'nutritionalFacts':
              'Rich in Vitamin K (500% DV), Vitamin A (118% DV), Vitamin C (65% DV), and folate (12% DV)',
          'healthBenefits':
              'Supports bone health, boosts immunity, promotes eye health, aids digestion, and has anti-inflammatory properties',
          'commonRecipes':
              'Ensaladang mustasa, sautéed mustard greens, sinigang, and vegetable stews',
          'growingTips':
              'Cool season crop, well-drained soil, consistent moisture, harvest when leaves are young and tender',
          'description':
              'Mustasa or mustard greens are peppery leafy vegetables commonly used in Filipino salads and cooked dishes.',
          'tagalogDescription':
              'Ang mustasa o mustard greens ay maanghang na leafy na gulay na karaniwang ginagamit sa mga salad at lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mayaman sa Bitamina K (500% DV), Bitamina A (118% DV), Bitamina C (65% DV), at folate (12% DV)',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng buto, nagpapalakas ng immunity, nagpapaunlad sa kalusugan ng mata, tumutulong sa pagtunaw ng pagkain, at may anti-inflammatory na katangian',
          'tagalogCommonRecipes':
              'Ensaladang mustasa, ginisa na mustard greens, sinigang, at mga stew ng gulay',
          'tagalogGrowingTips':
              'Malamig na pananim ng panahon, well-drained na lupa, patuloy na moisture, anihin kapag ang mga dahon ay bata at malambot',
          'growingMonths': 'November to February',
          'growingRegions': 'Benguet, Mountain Province, Bukidnon, Davao',
          'tagalogGrowingMonths': 'Nobyembre hanggang Pebrero',
          'tagalogGrowingRegions':
              'Benguet, Lalawigang Bulubundukin, Bukidnon, Davao',
        };
      case 'Sibuyas':
        return {
          'scientificName': 'Allium cepa',
          'varieties': 'Yellow, red, white, and sweet onion varieties',
          'nutritionalFacts':
              'Good source of Vitamin C (11% DV), Vitamin B6 (10% DV), folate (5% DV), and potassium (4% DV)',
          'healthBenefits':
              'Supports heart health, aids digestion, has antibacterial properties, helps regulate blood sugar, and has antioxidant properties',
          'commonRecipes':
              'Base for many Filipino dishes, fried onions, onion rings, and pickled onions',
          'growingTips':
              'Cool season crop, well-drained soil, full sun, harvest when tops fall over and dry',
          'description':
              'Sibuyas or onions are aromatic bulbs that form the flavor base for many Filipino dishes.',
          'tagalogDescription':
              'Ang sibuyas o onions ay mga aromatic na bulb na bumubuo sa base ng lasa para sa maraming lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mahusay na mapagkukunan ng Bitamina C (11% DV), Bitamina B6 (10% DV), folate (5% DV), at potassium (4% DV)',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng puso, tumutulong sa pagtunaw ng pagkain, may antibacterial na katangian, tumutulong sa pag-regulate ng blood sugar, at may antioxidant na katangian',
          'tagalogCommonRecipes':
              'Base para sa maraming lutong Pilipino, pritong sibuyas, onion rings, at atcharang sibuyas',
          'tagalogGrowingTips':
              'Malamig na pananim ng panahon, well-drained na lupa, buong araw, anihin kapag ang mga taas ay bumagsak at tuyo',
          'growingMonths': 'October to March for dry season onions',
          'growingRegions':
              'Nueva Ecija, Pangasinan, Ilocos, Mindoro Occidental',
          'tagalogGrowingMonths':
              'Oktubre hanggang Marso para sa dry season onions',
          'tagalogGrowingRegions':
              'Nueva Ecija, Pangasinan, Ilocos, Occidental Mindoro',
        };
      case 'Kamatis':
        return {
          'scientificName': 'Solanum lycopersicum',
          'varieties':
              'Over 10,000 varieties worldwide including Cherry, Beefsteak, and Roma',
          'nutritionalFacts':
              'Rich in Vitamin C (21% DV), Vitamin K (12% DV), potassium, and folate. Contains antioxidant lycopene.',
          'healthBenefits':
              'Supports heart health, reduces cancer risk, improves skin health, boosts immunity, and promotes eye health',
          'commonRecipes':
              'Ensaladang kamatis, sinigang, pasta sauces, and fried rice dishes',
          'growingTips':
              'Plant in full sun, support with stakes or cages, water consistently, harvest when fully colored',
          'description':
              'Kamatis or tomatoes are juicy fruits used as vegetables in Filipino cooking, adding acidity and flavor to dishes.',
          'tagalogDescription':
              'Ang kamatis o tomatoes ay mamasa-masang prutas na ginagamit bilang gulay sa pagluluto ng Pilipino, nagdaragdag ng acidity at lasa sa mga lutuin.',
          'tagalogNutritionalFacts':
              'Mayaman sa Bitamina C (21% DV), Bitamina K (12% DV), potassium, at folate. Naglalaman ng antioxidant na lycopene.',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng puso, nagbabawas ng panganib ng kanser, nagpapabuti sa kalusugan ng balat, nagpapalakas ng immunity, at nagpapaunlad sa kalusugan ng mata',
          'tagalogCommonRecipes':
              'Ensaladang kamatis, sinigang, mga sauce ng pasta, at mga lutong kanin na prito',
          'tagalogGrowingTips':
              'Magtanim sa buong araw, suportahan ng mga stakes o cages, tubig nang patuloy, anihin kapag ganap na nakulay',
          'growingMonths': 'Year-round, best from November to April',
          'growingRegions': 'Benguet, Bukidnon, Davao, South Cotabato',
          'tagalogGrowingMonths':
              'Buong taon, pinakamabuti mula Nobyembre hanggang Abril',
          'tagalogGrowingRegions': 'Benguet, Bukidnon, Davao, South Cotabato',
        };
      case 'Bawang':
        return {
          'scientificName': 'Allium sativum',
          'varieties':
              'Hardneck and softneck varieties with different flavor profiles',
          'nutritionalFacts':
              'Good source of manganese (23% DV), Vitamin B6 (17% DV), Vitamin C (15% DV), and selenium (6% DV)',
          'healthBenefits':
              'Supports heart health, boosts immunity, has antibacterial properties, helps regulate blood pressure, and has antioxidant properties',
          'commonRecipes':
              'Base for many Filipino dishes, garlic rice, adobo, and roasted garlic',
          'growingTips':
              'Plant in fall, well-drained soil, full sun, harvest when tops yellow and dry',
          'description':
              'Bawang or garlic is a pungent bulb used extensively in Filipino cuisine for its distinctive flavor.',
          'tagalogDescription':
              'Ang bawang o garlic ay isang maanghang na bulb na malawakang ginagamit sa lutuing Pilipino para sa natatanging lasa nito.',
          'tagalogNutritionalFacts':
              'Mahusay na mapagkukunan ng manganese (23% DV), Bitamina B6 (17% DV), Bitamina C (15% DV), at selenium (6% DV)',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng puso, nagpapalakas ng immunity, may antibacterial na katangian, tumutulong sa pag-regulate ng blood pressure, at may antioxidant na katangian',
          'tagalogCommonRecipes':
              'Base para sa maraming lutong Pilipino, kanin na bawang, adobo, at inihaw na bawang',
          'tagalogGrowingTips':
              'Magtanim sa taglagas, well-drained na lupa, buong araw, anihin kapag ang mga taas ay dilaw at tuyo',
          'growingMonths': 'October to February for harvest',
          'growingRegions': 'Ilocos Norte, Batac, Mindoro, Nueva Ecija',
          'tagalogGrowingMonths': 'Oktubre hanggang Pebrero para sa ani',
          'tagalogGrowingRegions': 'Ilocos Norte, Batac, Mindoro, Nueva Ecija',
        };
      case 'Luya':
        return {
          'scientificName': 'Zingiber officinale',
          'varieties':
              'Several varieties with different levels of pungency and flavor',
          'nutritionalFacts':
              'Good source of gingerol, potassium (5% DV), magnesium (5% DV), and Vitamin B6 (4% DV)',
          'healthBenefits':
              'Aids digestion, has anti-inflammatory properties, helps relieve nausea, supports immune system, and has antioxidant properties',
          'commonRecipes':
              'Ginger tea, tinola, ginger-based marinades, and pickled ginger',
          'growingTips':
              'Tropical plant, needs warm, humid conditions, well-drained soil, harvest when leaves yellow',
          'description':
              'Luya or ginger is a rhizome with a pungent, spicy flavor used in both savory and sweet Filipino dishes.',
          'tagalogDescription':
              'Ang luya o ginger ay isang rhizome na may maanghang, maanghang na lasa na ginagamit sa parehong maanghang at matamis na lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mahusay na mapagkukunan ng gingerol, potassium (5% DV), magnesium (5% DV), at Bitamina B6 (4% DV)',
          'tagalogHealthBenefits':
              'Tumutulong sa pagtunaw ng pagkain, may anti-inflammatory na katangian, tumutulong sa paglunas ng nausea, sumusuporta sa immune system, at may antioxidant na katangian',
          'tagalogCommonRecipes':
              'Ginger tea, tinola, mga marinade na batay sa luya, at atcharang luya',
          'tagalogGrowingTips':
              'Tropikal na halaman, kailangan ng mainit, mahalumigmig na kondisyon, well-drained na lupa, anihin kapag ang mga dahon ay dilaw',
          'growingMonths': 'Year-round, harvest 8-10 months after planting',
          'growingRegions': 'Laguna, Batangas, Quezon, Oriental Mindoro',
          'tagalogGrowingMonths':
              'Buong taon, anihin 8-10 buwan pagkatapos itanim',
          'tagalogGrowingRegions':
              'Laguna, Batangas, Quezon, Silangang Mindoro',
        };
      case 'Linga':
        return {
          'scientificName': 'Sesamum indicum',
          'varieties': 'White, black, and brown sesame seed varieties',
          'nutritionalFacts':
              'Rich in healthy fats, protein (18g per 100g), fiber (11g per 100g), calcium (98% DV), iron (81% DV), and magnesium (87% DV)',
          'healthBenefits':
              'Supports bone health, aids digestion, helps regulate blood pressure, promotes heart health, and has antioxidant properties',
          'commonRecipes':
              'Bibingka with linga, kutsinta, sesame balls, and as a topping for various dishes',
          'growingTips':
              'Warm season crop, well-drained soil, drought-tolerant, harvest when capsules turn brown',
          'description':
              'Linga or sesame seeds are tiny, oil-rich seeds used as toppings and ingredients in Filipino desserts and savory dishes.',
          'tagalogDescription':
              'Ang linga o sesame seeds ay maliliit, mayaman sa langis na buto na ginagamit bilang mga topping at sangkap sa mga dessert at maanghang na lutong Pilipino.',
          'tagalogNutritionalFacts':
              'Mayaman sa malusog na taba, protina (18g bawat 100g), fiber (11g bawat 100g), calcium (98% DV), iron (81% DV), at magnesium (87% DV)',
          'tagalogHealthBenefits':
              'Sumusuporta sa kalusugan ng buto, tumutulong sa pagtunaw ng pagkain, tumutulong sa pag-regulate ng blood pressure, nagpapaunlad sa kalusugan ng puso, at may antioxidant na katangian',
          'tagalogCommonRecipes':
              'Bibingka with linga, kutsinta, sesame balls, at bilang topping para sa iba\'t ibang lutuin',
          'tagalogGrowingTips':
              'Pananim na mainit na panahon, well-drained na lupa, tolerante sa tagtuyot, anihin kapag ang mga capsules ay naging kayumanggi',
          'growingMonths': 'April to August',
          'growingRegions': 'Ilocos Region, Pangasinan, Cagayan Valley',
          'tagalogGrowingMonths': 'Abril hanggang Agosto',
          'tagalogGrowingRegions':
              'Rehiyon ng Ilocos, Pangasinan, Lambak ng Cagayan',
        };
      default:
        return {
          'scientificName': 'Unknown',
          'varieties': 'Various cultivated varieties',
          'nutritionalFacts':
              'Rich in essential vitamins, minerals, and antioxidants',
          'healthBenefits':
              'Provides numerous health benefits including vitamins and dietary fiber',
          'commonRecipes':
              'Various culinary preparations including raw, cooked, and preserved forms',
          'growingTips':
              'Follow general vegetable gardening practices for optimal growth',
          'description':
              'A nutritious vegetable commonly used in various cuisines worldwide.',
          'tagalogDescription':
              'Isang masustansyang gulay na karaniwang ginagamit sa iba\'t ibang lutuin sa buong mundo.',
          'tagalogNutritionalFacts':
              'Mayaman sa mahahalagang bitamina, mineral, at antioxidants',
          'tagalogHealthBenefits':
              'Nagbibigay ng maraming benepisy sa kalusugan kabilang ang mga bitamina at dietary fiber',
          'tagalogCommonRecipes':
              'Iba\'t ibang paghahanda sa lutuin kabilang ang hilaw, lutuin, at napanatili na anyo',
          'tagalogGrowingTips':
              'Sundin ang pangkalahatang pagtatanim ng gulay para sa optimal na paglago',
          'growingMonths': 'Year-round in suitable climates',
          'growingRegions': 'Various regions across the Philippines',
          'tagalogGrowingMonths': 'Buong taon sa angkop na klima',
          'tagalogGrowingRegions': 'Iba\'t ibang rehiyon sa Pilipinas',
        };
    }
  }

  Map<String, double> _calculateNewPosition(
      double lat, double lng, double distance, double bearing) {
    const R = 6371.0;
    double latRad = lat * pi / 180;
    double lngRad = lng * pi / 180;
    double bearingRad = bearing * pi / 180;

    double newLat = asin(sin(latRad) * cos(distance / 1000 / R) +
        cos(latRad) * sin(distance / 1000 / R) * cos(bearingRad));
    double newLng = lngRad +
        atan2(sin(bearingRad) * sin(distance / 1000 / R) * cos(latRad),
            cos(distance / 1000 / R) - sin(latRad) * sin(newLat));

    return {'lat': newLat * 180 / pi, 'lng': newLng * 180 / pi};
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double lat1Rad = lat1 * pi / 180;
    double lat2Rad = lat2 * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double y = sin(dLon) * cos(lat2Rad);
    double x =
        cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);
    double bearing = atan2(y, x);

    return (bearing * 180 / pi + 360) % 360;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c * 1000;
  }

  double _toRadians(double degree) => degree * pi / 180;

  void _collectVegetable(ARVegetable arVegetable) {
    if (_collectedVegetables.any((v) => v.id == arVegetable.vegetable.id))
      return;

    setState(() {
      _collectedVegetables.add(arVegetable.vegetable);
      _arVegetables.remove(arVegetable);
    });

    // Play success sound
    _audioService.playSuccessSound();

    _speakVegetableDetails(arVegetable.vegetable);

    _showVegetableInfo(arVegetable.vegetable);
  }

  Future<void> _speakVegetableDetails(Vegetable vegetable) async {
    setState(() {
      _isSpeaking = true;
      _currentDisplayedVegetable = vegetable;
    });

    await flutterTts.stop();

    String speechText;
    if (_currentLanguage == Language.english) {
      speechText = """
      You found ${vegetable.englishName}! 
      Scientific name: ${vegetable.scientificName}.
      Growing season: ${vegetable.growingMonths}.
      Typically grows in: ${vegetable.growingRegions}.
      Nutritional facts: ${vegetable.nutritionalFacts}.
      Health benefits: ${vegetable.healthBenefits}.
      """;
    } else {
      speechText = """
      Nakapulot ka ng ${vegetable.name}! 
      Siyentipikong pangalan: ${vegetable.scientificName}.
      Panahon ng paglaki: ${vegetable.tagalogGrowingMonths}.
      Karaniwang lumalaki sa: ${vegetable.tagalogGrowingRegions}.
      Mga katotohanan sa nutrisyon: ${vegetable.tagalogNutritionalFacts}.
      Mga benepisyo sa kalusugan: ${vegetable.tagalogHealthBenefits}.
      """;
    }

    // TTS will automatically handle audio control through the TTS handlers
    await flutterTts.speak(speechText);
  }

  Future<void> _stopSpeaking() async {
    await flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _currentDisplayedVegetable = null;
    });
  }

  void _showVegetableInfo(Vegetable vegetable) {
    setState(() {
      _currentDisplayedVegetable = vegetable;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.9,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: _getRarityColor(vegetable.rarity),
                  width: 3,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                    Colors.grey[900]!,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(vegetable.rarity).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: _getRarityColor(vegetable.rarity),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentLanguage == Language.english
                                    ? vegetable.englishName
                                    : vegetable.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vegetable.scientificName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green[300],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getRarityColor(vegetable.rarity)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getRarityColor(vegetable.rarity),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getRarityColor(vegetable.rarity)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: _getRarityColor(vegetable.rarity),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vegetable.rarity.name.toUpperCase(),
                                style: TextStyle(
                                  color: _getRarityColor(vegetable.rarity),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getRarityColor(vegetable.rarity),
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getRarityColor(vegetable.rarity)
                                        .withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getRarityColor(vegetable.rarity)
                                        .withOpacity(0.1),
                                    Colors.transparent,
                                    _getRarityColor(vegetable.rarity)
                                        .withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.grey[850]!,
                                            Colors.grey[900]!,
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Image.asset(
                                        vegetable.imagePath,
                                        fit: BoxFit.contain,
                                        width: 120,
                                        height: 120,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.eco,
                                            size: 70,
                                            color: _getRarityColor(
                                                vegetable.rarity),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Icon(
                                        Icons.spa,
                                        color: _getRarityColor(vegetable.rarity)
                                            .withOpacity(0.5),
                                        size: 16,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.eco,
                                        color: _getRarityColor(vegetable.rarity)
                                            .withOpacity(0.5),
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.green[700]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.translate,
                                          color: Colors.green[300],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currentLanguage == Language.english
                                              ? 'Language: English'
                                              : 'Wika: Tagalog',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: _isSpeaking
                                          ? _stopSpeaking
                                          : () =>
                                              _speakVegetableDetails(vegetable),
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green[700],
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _isSpeaking
                                              ? Icons.volume_off
                                              : Icons.volume_up,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MouseRegion(
                                        onEnter: (_) {
                                          if (_currentLanguage !=
                                              Language.english) {
                                            setState(() {
                                              _isEnglishHovered = true;
                                            });
                                          }
                                        },
                                        onExit: (_) {
                                          setState(() {
                                            _isEnglishHovered = false;
                                          });
                                        },
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_currentLanguage !=
                                                Language.english) {
                                              _toggleLanguage();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _currentLanguage ==
                                                      Language.english
                                                  ? Colors.green
                                                  : _isEnglishHovered
                                                      ? Colors.green
                                                          .withOpacity(0.3)
                                                      : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: _isEnglishHovered
                                                    ? Colors.green[300]!
                                                    : _currentLanguage ==
                                                            Language.english
                                                        ? Colors.green
                                                        : Colors.grey[400]!,
                                                width: 2,
                                              ),
                                              boxShadow: _isEnglishHovered
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.green
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Text(
                                              'ENGLISH',
                                              style: TextStyle(
                                                color: _currentLanguage ==
                                                        Language.english
                                                    ? Colors.white
                                                    : _isEnglishHovered
                                                        ? Colors.green[300]
                                                        : Colors.grey[400],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      MouseRegion(
                                        onEnter: (_) {
                                          if (_currentLanguage !=
                                              Language.tagalog) {
                                            setState(() {
                                              _isTagalogHovered = true;
                                            });
                                          }
                                        },
                                        onExit: (_) {
                                          setState(() {
                                            _isTagalogHovered = false;
                                          });
                                        },
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_currentLanguage !=
                                                Language.tagalog) {
                                              _toggleLanguage();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _currentLanguage ==
                                                      Language.tagalog
                                                  ? Colors.green
                                                  : _isTagalogHovered
                                                      ? Colors.green
                                                          .withOpacity(0.3)
                                                      : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: _isTagalogHovered
                                                    ? Colors.green[300]!
                                                    : _currentLanguage ==
                                                            Language.tagalog
                                                        ? Colors.green
                                                        : Colors.grey[400]!,
                                                width: 2,
                                              ),
                                              boxShadow: _isTagalogHovered
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.green
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Text(
                                              'TAGALOG',
                                              style: TextStyle(
                                                color: _currentLanguage ==
                                                        Language.tagalog
                                                    ? Colors.white
                                                    : _isTagalogHovered
                                                        ? Colors.green[300]
                                                        : Colors.grey[400],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildEducationalCard(
                            icon: Icons.info,
                            title: _currentLanguage == Language.english
                                ? 'Description'
                                : 'Paglalarawan',
                            content: _currentLanguage == Language.english
                                ? vegetable.description
                                : vegetable.tagalogDescription,
                            color: Colors.blue[700]!,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[900]!.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.green[700]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.green[300],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentLanguage == Language.english
                                          ? 'Growing Information'
                                          : 'Impormasyon sa Pagtatanim',
                                      style: TextStyle(
                                        color: Colors.green[300],
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  _currentLanguage == Language.english
                                      ? 'Growing Season'
                                      : 'Panahon ng Paglaki',
                                  _currentLanguage == Language.english
                                      ? vegetable.growingMonths
                                      : vegetable.tagalogGrowingMonths,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  _currentLanguage == Language.english
                                      ? 'Growing Regions'
                                      : 'Mga Rehiyon na Lumalaki',
                                  _currentLanguage == Language.english
                                      ? vegetable.growingRegions
                                      : vegetable.tagalogGrowingRegions,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  _currentLanguage == Language.english
                                      ? 'Growing Tips'
                                      : 'Mga Tip sa Pagtatanim',
                                  vegetable.growingTips,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  _currentLanguage == Language.english
                                      ? 'Known Varieties'
                                      : 'Kilalang Mga Uri',
                                  vegetable.varieties,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildEducationalCard(
                            icon: Icons.health_and_safety,
                            title: _currentLanguage == Language.english
                                ? 'Nutrition Facts'
                                : 'Mga Katotohanan sa Nutrisyon',
                            content: _currentLanguage == Language.english
                                ? vegetable.nutritionalFacts
                                : vegetable.tagalogNutritionalFacts,
                            color: Colors.orange[700]!,
                          ),
                          const SizedBox(height: 16),
                          _buildEducationalCard(
                            icon: Icons.medical_services,
                            title: _currentLanguage == Language.english
                                ? 'Health Benefits'
                                : 'Mga Benepisyo sa Kalusugan',
                            content: _currentLanguage == Language.english
                                ? vegetable.healthBenefits
                                : vegetable.tagalogHealthBenefits,
                            color: Colors.red[700]!,
                          ),
                          const SizedBox(height: 16),
                          _buildEducationalCard(
                            icon: Icons.restaurant,
                            title: _currentLanguage == Language.english
                                ? 'Common Recipes'
                                : 'Karaniwang Mga Luto',
                            content: _currentLanguage == Language.english
                                ? vegetable.commonRecipes
                                : vegetable.tagalogCommonRecipes,
                            color: Colors.purple[700]!,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  _getRarityColor(vegetable.rarity),
                                  _getRarityColor(vegetable.rarity)
                                      .withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _getRarityColor(vegetable.rarity)
                                      .withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _stopSpeaking();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_circle,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _currentLanguage == Language.english
                                        ? 'Add to Collection'
                                        : 'Idagdag sa Koleksyon',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _currentLanguage == Language.english
                                  ? 'Learn • Discover • Grow'
                                  : 'Matuto • Tuklasin • Lumago',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _stopSpeaking();
      setState(() {
        _isEnglishHovered = false;
        _isTagalogHovered = false;
      });
    });
  }

  Widget _buildEducationalCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return Colors.green;
      case Rarity.uncommon:
        return Colors.blue;
      case Rarity.rare:
        return Colors.purple;
      case Rarity.epic:
        return Colors.orange;
      case Rarity.legendary:
        return Colors.red;
    }
  }

  void _toggleARView() {
    setState(() {
      _isARView = !_isARView;
    });
  }

  void _showSpawnAnimation() {
    setState(() => _showDiscoveryAnimation = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showDiscoveryAnimation = false);
    });
  }

  void _showMovementFeedback() {
    if (_arVegetables.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_arVegetables.length} vegetables in your area! Keep walking!'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress = "${place.street ?? ''}, ${place.locality ?? ''}";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress =
            "Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}";
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _buildAvatarWidget({double size = 80.0}) {
    double bounceOffset = _avatarBounceValue * 10.0;

    return GestureDetector(
      onTap: _pickAvatarImage,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _avatarImage != null ? Colors.green : Colors.grey,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (_avatarImage != null ? Colors.green : Colors.grey)
                  .withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (_avatarImage != null)
              ClipOval(
                child: Image.file(
                  _avatarImage!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: Colors.white,
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(0, 76, 175, 79),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 12,
                  color: Color.fromARGB(0, 255, 255, 255),
                ),
              ),
            ),
            if (_isAvatarMoving)
              Positioned(
                top: -bounceOffset,
                child: Container(
                  width: size,
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarAvatar() {
    return GestureDetector(
      onTap: _showAvatarSettings,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _avatarImage != null
                ? const Color.fromARGB(0, 0, 0, 0)
                : Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (_avatarImage != null
                      ? const Color.fromARGB(0, 76, 175, 79)
                      : Colors.white)
                  .withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: _avatarImage != null
              ? Image.file(
                  _avatarImage!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                )
              : Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.green,
                  ),
                ),
        ),
      ),
    );
  }

  void _showAvatarSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Avatar Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              _buildAvatarWidget(size: 120),
              const SizedBox(height: 20),
              Text(
                'Tap the avatar to change your profile picture',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_isAvatarMoving)
                Text(
                  'Your avatar is moving!',
                  style: TextStyle(color: Colors.green[300], fontSize: 16),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickAvatarImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('Change Avatar'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanAnimationController.dispose();
    _avatarBounceController.dispose();
    _positionStreamSubscription?.cancel();
    _compassSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _cameraController?.dispose();
    _vegetableSpawnTimer?.cancel();
    _arDetectionTimer?.cancel();
    _stepResetTimer?.cancel();
    flutterTts.stop();
    _audioService.dispose();
    super.dispose();
  }
// ==================== MAIN WIDGET ====================

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildBody(),
  );
}

// ==================== APP BAR COMPONENTS ====================

class VeggieHuntAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isARView;
  final int collectedCount;
  final VoidCallback onCollectionPressed;
  final VoidCallback onToggleView;
  final Widget avatar;
  
  const VeggieHuntAppBar({
    super.key,
    required this.isARView,
    required this.collectedCount,
    required this.onCollectionPressed,
    required this.onToggleView,
    required this.avatar,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        isARView ? AppBarConstants.arTitle : AppBarConstants.mapTitle,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.green[700],
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        CollectionBadgeButton(
          count: collectedCount,
          onPressed: onCollectionPressed,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: avatar,
        ),
        ViewToggleButton(
          isARView: isARView,
          onPressed: onToggleView,
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CollectionBadgeButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;
  
  const CollectionBadgeButton({
    super.key,
    required this.count,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        label: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppBarConstants.badgeFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        child: Image.asset(
          ImagePaths.collectionIcon,
          width: AppBarConstants.collectionIconSize,
          height: AppBarConstants.collectionIconSize,
        ),
      ),
      onPressed: onPressed,
    );
  }
}

class ViewToggleButton extends StatelessWidget {
  final bool isARView;
  final VoidCallback onPressed;
  
  const ViewToggleButton({
    super.key,
    required this.isARView,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        isARView ? ImagePaths.arMapIcon : ImagePaths.cameraIcon,
        width: AppBarConstants.toggleIconSize,
        height: AppBarConstants.toggleIconSize,
      ),
      onPressed: onPressed,
    );
  }
}

// ==================== LOADING SCREEN COMPONENTS ====================

class LoadingScreen extends StatelessWidget {
  final String locationStatus;
  final VoidCallback onDemoModePressed;
  
  const LoadingScreen({
    super.key,
    required this.locationStatus,
    required this.onDemoModePressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getGradientColors(),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(),
            const SizedBox(height: LoadingScreenConstants.spacingSmall),
            LocationStatusText(status: locationStatus),
            const SizedBox(height: LoadingScreenConstants.spacingSmall),
            DemoModeButton(onPressed: onDemoModePressed),
          ],
        ),
      ),
    );
  }
  
  List<Color> _getGradientColors() {
    return [
      Colors.green[900]!,
      Colors.green[800]!,
      Colors.grey[900]!,
    ];
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      strokeWidth: LoadingScreenConstants.indicatorStrokeWidth,
    );
  }
}

class LocationStatusText extends StatelessWidget {
  final String status;
  
  const LocationStatusText({super.key, required this.status});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      status,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: LoadingScreenConstants.statusTextFontSize,
        color: Colors.white,
      ),
    );
  }
}

class DemoModeButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const DemoModeButton({super.key, required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: LoadingScreenConstants.buttonHorizontalPadding,
          vertical: LoadingScreenConstants.buttonVerticalPadding,
        ),
      ),
      child: const Text('Try Demo Mode First'),
    );
  }
}

// ==================== CONSTANTS ====================

class AppBarConstants {
  static const String arTitle = 'AR Veggie Hunt';
  static const String mapTitle = 'Veggie Hunt Map';
  static const double collectionIconSize = 26;
  static const double toggleIconSize = 28;
  static const double badgeFontSize = 10;
}

class LoadingScreenConstants {
  static const double indicatorStrokeWidth = 3;
  static const double statusTextFontSize = 16;
  static const double buttonHorizontalPadding = 30;
  static const double buttonVerticalPadding = 12;
  static const double spacingSmall = 20;
}

class ImagePaths {
  static const String collectionIcon = 'assets/images/collect.png';
  static const String arMapIcon = 'assets/images/armap.png';
  static const String cameraIcon = 'assets/images/cam1.png';
}


  Widget _buildPermissionScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green[900]!, Colors.green[800]!, Colors.grey[900]!],
        ),
      ),
      child: Center(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              const Text('Veggie Hunt GO',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(_locationStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _initializeLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Enable Real Location'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: _useDemoMode,
                  child: const Text('Try Demo Mode First')),
            ])),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[900]!,
                Colors.green[800]!,
                Colors.grey[900]!
              ],
            ),
          ),
        ),
        if (_isAvatarMoving)
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -_avatarBounceValue * 20),
                child: _buildAvatarWidget(size: 100),
              ),
            ),
          ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(Icons.map, size: 100, color: Colors.green[300]),
                    const SizedBox(height: 20),
                    const Text(
                      'Map View',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Switch to AR Camera to find vegetables!',
                      style: TextStyle(fontSize: 16, color: Colors.green[300]),
                    ),
                    const SizedBox(height: 10),
                    if (!_isDeviceMoving)
                      Text(
                        'Start walking to discover vegetables!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_isAvatarMoving)
                      Text(
                        'Your avatar is moving! Keep walking!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_pin,
                        color: Colors.green[400], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_arVegetables.length} vegetables nearby • ${_collectedVegetables.length} collected',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.directions_walk,
                        color: _isAvatarMoving
                            ? Colors.green[300]
                            : Colors.grey[400],
                        size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Steps: $_steps • Distance: ${_totalDistance.toStringAsFixed(1)}m',
                      style: TextStyle(
                          color: _isAvatarMoving
                              ? Colors.green[300]
                              : Colors.white70,
                          fontSize: 12,
                          fontWeight: _isAvatarMoving
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ],
                ),
                if (_isDeviceMoving) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Device is moving - keep walking!',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (_arVegetables.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Walk around to discover vegetables!',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_heading != null && _arVegetables.isNotEmpty)
          _buildCompassIndicator(),
      ],
    );
  }

  Widget _buildCompassIndicator() {
    ARVegetable? nearestVeg = _arVegetables.isNotEmpty
        ? _arVegetables.reduce((a, b) => a.distance < b.distance ? a : b)
        : null;

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Column(
          children: [
            const Text(
              'Compass Guide',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (nearestVeg != null) ...[
              Text(
                'Nearest: ${nearestVeg.vegetable.name} (${nearestVeg.distance.toStringAsFixed(0)}m)',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.navigation, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Bearing: ${nearestVeg.bearing.toStringAsFixed(0)}°',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Your heading: ${_heading!.toStringAsFixed(0)}°',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARView() {
    return Stack(children: [
      if (_isCameraInitialized && _cameraController != null)
        SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_cameraController!))
      else
        Container(
            color: Colors.black,
            child: const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text('Initializing camera...',
                      style: TextStyle(color: Colors.white)),
                ]))),
      _buildRadioWaveScannerOverlay(),
      _buildARVegetables(),
      if (_isAvatarMoving)
        Positioned(
          bottom: 200,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.translate(
              offset: Offset(0, -_avatarBounceValue * 15),
              child: _buildAvatarWidget(size: 70),
            ),
          ),
        ),
      if (_heading != null) _buildARCompassGuide(),
      _buildARControls(),
    ]);
  }

  Widget _buildRadioWaveScannerOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _scanAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: RadioWavePainter(
              animationValue: _scanAnimation.value,
              color: Colors.green.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildARVegetables() {
    return Stack(
      children: _vegetablesInView.map((arVegetable) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        double relativeBearing = (arVegetable.bearing - _heading! + 360) % 360;
        double screenX = (relativeBearing / 360) * screenWidth;

        double size = 80 - (arVegetable.distance / 50) * 40;
        double opacity = 1.0 - (arVegetable.distance / 50) * 0.7;
        double screenY = screenHeight / 2 + (arVegetable.distance - 10) * 3;

        return Positioned(
          left: screenX - size / 2,
          top: screenY - size / 2,
          child: GestureDetector(
            onTap: () => _collectVegetable(arVegetable),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(size / 2),
                      border: Border.all(
                          color: arVegetable.vegetable.color, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: arVegetable.vegetable.color.withOpacity(0.7),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Stack(children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(size / 2 - 4),
                          child: Image.asset(
                            arVegetable.vegetable.imagePath,
                            fit: BoxFit.cover,
                            width: size - 8,
                            height: size - 8,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                size: size * 0.5,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(
                              '${arVegetable.distance.toStringAsFixed(0)}m',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildARCompassGuide() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Column(
          children: [
            const Text(
              'AR Scanner Active',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isAvatarMoving)
              Text(
                'Your avatar is moving! Keep going!',
                style: TextStyle(
                  color: Colors.green[300],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!_isDeviceMoving && !_isAvatarMoving)
              Text(
                'Move your device to detect steps!',
                style: TextStyle(
                  color: Colors.orange[300],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              'Point camera around to find vegetables\nWalk to discover more!',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_arVegetables.isNotEmpty)
              Text(
                '${_arVegetables.length} vegetables in area • ${_vegetablesInView.length} in view',
                style: TextStyle(color: Colors.green[300], fontSize: 12),
              ),
            const SizedBox(height: 8),
            Text(
              'Heading: ${_heading!.toStringAsFixed(0)}°',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARControls() {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 20,
          child: FloatingActionButton(
            onPressed: _toggleARView,
            backgroundColor: Colors.transparent,
            foregroundColor: const Color.fromARGB(0, 76, 175, 79),
            mini: true,
            child: const Icon(Icons.arrow_back),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green, width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_walk,
                        color: _isAvatarMoving
                            ? Colors.green[300]
                            : Colors.grey[400],
                        size: 14),
                    const SizedBox(width: 4),
                    Text('Steps: $_steps',
                        style: TextStyle(
                            color: _isAvatarMoving
                                ? Colors.green[300]
                                : Colors.white,
                            fontSize: 12)),
                  ],
                ),
                Text('Distance: ${_totalDistance.toStringAsFixed(1)}m',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                if (_isAvatarMoving)
                  Text('Avatar moving...',
                      style: TextStyle(
                          color: Colors.green[300],
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCollection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Column(children: [
          Container(
              width: 60,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2))),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                  'My Vegetable Collection (${_collectedVegetables.length})',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
          Expanded(
            child: _collectedVegetables.isEmpty
                ? const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.eco, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                            'No vegetables collected yet!\nWalk around to discover vegetables in your area!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ]))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9),
                    itemCount: _collectedVegetables.length,
                    itemBuilder: (context, index) {
                      final vegetable = _collectedVegetables[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showVegetableInfo(vegetable);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ],
                            border: Border.all(
                                color: _getRarityColor(vegetable.rarity),
                                width: 2),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: _getRarityColor(vegetable.rarity)
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      vegetable.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.broken_image,
                                          size: 20,
                                          color: Colors.grey[400],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(vegetable.name,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: _getRarityColor(vegetable.rarity)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                      vegetable.rarity.name.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 8,
                                          color:
                                              _getRarityColor(vegetable.rarity),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }

  void _useDemoMode() {
    setState(() {
      _currentPosition = Position(
        longitude: -122.4194,
        latitude: 37.7749,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );
      _isLoading = false;
      _locationEnabled = true;
      _locationStatus = 'Demo Mode - San Francisco';
      _currentAddress = 'San Francisco, CA';
    });
    _startVegetableSpawning();
  }
}

enum Language { english, tagalog }

class Vegetable {
  final String id;
  final String name;
  final String englishName;
  final String imagePath;
  final Rarity rarity;
  final Color color;
  final String scientificName;
  final String varieties;
  final String nutritionalFacts;
  final String healthBenefits;
  final String commonRecipes;
  final String growingTips;
  final String description;
  final String tagalogDescription;
  final String tagalogNutritionalFacts;
  final String tagalogHealthBenefits;
  final String tagalogCommonRecipes;
  final String tagalogGrowingTips;
  final String growingMonths;
  final String growingRegions;
  final String tagalogGrowingMonths;
  final String tagalogGrowingRegions;

  Vegetable({
    required this.id,
    required this.name,
    required this.englishName,
    required this.imagePath,
    required this.rarity,
    required this.color,
    required this.scientificName,
    required this.varieties,
    required this.nutritionalFacts,
    required this.healthBenefits,
    required this.commonRecipes,
    required this.growingTips,
    required this.description,
    required this.tagalogDescription,
    required this.tagalogNutritionalFacts,
    required this.tagalogHealthBenefits,
    required this.tagalogCommonRecipes,
    required this.tagalogGrowingTips,
    required this.growingMonths,
    required this.growingRegions,
    required this.tagalogGrowingMonths,
    required this.tagalogGrowingRegions,
  });
}

class ARVegetable {
  final Vegetable vegetable;
  final String id;
  double latitude;
  double longitude;
  double distance;
  double bearing;

  ARVegetable({
    required this.vegetable,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.bearing,
  });
}

enum Rarity { common, uncommon, rare, epic, legendary }

class RadioWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RadioWavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;

    for (int i = 0; i < 5; i++) {
      final progress = (animationValue + i * 0.2) % 1.0;
      final radius = maxRadius * progress;
      final opacity = 1.0 - progress;

      paint.color = color.withOpacity(opacity * 0.7);
      canvas.drawCircle(center, radius, paint);
    }

    final cornerSize = 30.0;
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawLine(
        const Offset(20, 20), Offset(20 + cornerSize, 20), cornerPaint);
    canvas.drawLine(
        const Offset(20, 20), Offset(20, 20 + cornerSize), cornerPaint);

    canvas.drawLine(Offset(size.width - 20, 20),
        Offset(size.width - 20 - cornerSize, 20), cornerPaint);
    canvas.drawLine(Offset(size.width - 20, 20),
        Offset(size.width - 20, 20 + cornerSize), cornerPaint);

    canvas.drawLine(Offset(20, size.height - 20),
        Offset(20 + cornerSize, size.height - 20), cornerPaint);
    canvas.drawLine(Offset(20, size.height - 20),
        Offset(20, size.height - 20 - cornerSize), cornerPaint);

    canvas.drawLine(Offset(size.width - 20, size.height - 20),
        Offset(size.width - 20 - cornerSize, size.height - 20), cornerPaint);
    canvas.drawLine(Offset(size.width - 20, size.height - 20),
        Offset(size.width - 20, size.height - 20 - cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
