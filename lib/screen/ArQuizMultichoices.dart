import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class MultipleChoiceQuizPage extends StatefulWidget {
  const MultipleChoiceQuizPage({super.key});

  @override
  State<MultipleChoiceQuizPage> createState() => _MultipleChoiceQuizPageState();
}

class _MultipleChoiceQuizPageState extends State<MultipleChoiceQuizPage>
    with TickerProviderStateMixin {
  int currentLevel = 1;
  int currentQuestionIndex = 0;
  String? selectedOption;
  Map<int, String?> userAnswers = {};
  bool levelCompleted = false;
  bool allLevelsCompleted = false;
  int totalScore = 0;
  Map<int, int> levelScores = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

  // Audio player for sound effects
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation controllers
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Color?> _colorAnimation;

  // Random number generator
  final Random _random = Random();

  // Original questions with correct numbering
  final List<Map<String, dynamic>> _originalLevel1Questions = [
    {
      'question': 'What is the Bahay Kubo made primarily of?',
      'options': ['Concrete', 'Bamboo and nipa palm', 'Metal sheets', 'Bricks'],
      'correctAnswer': 'b',
      'image': 'assets/images/q11.png',
      'originalNumber': 1
    },
    {
      'question': 'The Bahay Kubo represents what kind of Filipino living?',
      'options': [
        'Modern urban life',
        'Simple rural life',
        'Luxury living',
        'Industrial life'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q2.png',
      'originalNumber': 2
    },
    {
      'question':
          'What is the main purpose of raising the Bahay Kubo above the ground?',
      'options': [
        'For design only',
        'To prevent flood and allow airflow',
        'To look taller',
        'For animal shelter'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q3.png',
      'originalNumber': 3
    },
    {
      'question': 'The floor of the Bahay Kubo is usually made of what?',
      'options': ['Tiles', 'Wood or bamboo slats', 'Metal', 'Cement'],
      'correctAnswer': 'b',
      'image': 'assets/images/q4.png',
      'originalNumber': 4
    },
    {
      'question':
          'What material is commonly used for the roof of a Bahay Kubo?',
      'options': ['Nipa leaves', 'Steel sheet', 'Clay tiles', 'Cement'],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 5
    },
    {
      'question':
          'The Bahay Kubo design promotes what environmental principle?',
      'options': [
        'Sustainability',
        'Industrialization',
        'Urbanization',
        'Commercialization'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 6
    },
    {
      'question':
          'Which part of the Bahay Kubo serves as the resting or social area?',
      'options': ['Silong', 'Sala or bulwagan', 'Kusina', 'Bintana'],
      'correctAnswer': 'b',
      'image': 'assets/images/q11.png',
      'originalNumber': 7
    },
    {
      'question': 'What is the "silong" of the Bahay Kubo used for?',
      'options': [
        'Sleeping area',
        'Storage or animal shelter',
        'Cooking area',
        'Dining area'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q2.png',
      'originalNumber': 8
    },
    {
      'question': 'What makes the Bahay Kubo energy efficient?',
      'options': [
        'Air conditioning',
        'Natural ventilation and lighting',
        'Solar panels',
        'Electric fans'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q3.png',
      'originalNumber': 9
    },
    {
      'question': 'The Bahay Kubo is often built using what type of labor?',
      'options': [
        'Imported labor',
        'Community or bayanihan effort',
        'Contractors',
        'Robots'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q4.png',
      'originalNumber': 10
    },
  ];

  final List<Map<String, dynamic>> _originalLevel2Questions = [
    {
      'question': 'The Bahay Kubo song lists what type of items?',
      'options': ['Farm tools', 'Vegetables', 'Animals', 'Fruits'],
      'correctAnswer': 'b',
      'image': 'assets/images/q5.png',
      'originalNumber': 11
    },
    {
      'question':
          'What agricultural concept is reflected in Bahay Kubo living?',
      'options': [
        'Organic farming',
        'Chemical farming',
        'Hydroponics',
        'Plantation agriculture'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 12
    },
    {
      'question':
          'Farmers living in a Bahay Kubo often plant vegetables in what kind of soil?',
      'options': [
        'Fertile loam soil',
        'Sandy soil',
        'Rocky soil',
        'Salty soil'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 13
    },
    {
      'question':
          'Which TVL strand subject teaches about planting and gardening near Bahay Kubo?',
      'options': [
        'Bread and Pastry',
        'Horticulture or Crop Production',
        'Electrical Installation',
        'Automotive Servicing'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q2.png',
      'originalNumber': 14
    },
    {
      'question': 'The area surrounding Bahay Kubo is usually used for what?',
      'options': [
        'Parking',
        'Backyard farming or livestock raising',
        'Sports',
        'Warehouse'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q3.png',
      'originalNumber': 15
    },
    {
      'question':
          'What type of irrigation do farmers near Bahay Kubo commonly use?',
      'options': [
        'Automatic system',
        'Manual watering or rain-fed',
        'Underground system',
        'Sprinkler system'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q4.png',
      'originalNumber': 16
    },
    {
      'question': 'The Bahay Kubo supports which sustainable practice?',
      'options': [
        'Waste segregation and composting',
        'Use of plastics',
        'Burning waste',
        'Chemical disposal'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 17
    },
    {
      'question': 'What livestock is commonly raised near Bahay Kubo?',
      'options': ['Cows', 'Chickens', 'Elephants', 'Goats'],
      'correctAnswer': 'b',
      'image': 'assets/images/q6.png',
      'originalNumber': 18
    },
    {
      'question':
          'What TVL subject connects with the design of Bahay Kubo for sustainable farming?',
      'options': [
        'Landscape and Gardening',
        'Dressmaking',
        'Front Office Services',
        'Animation'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 19
    },
    {
      'question': 'The Bahay Kubo encourages what kind of living?',
      'options': [
        'Self-sufficient and eco-friendly lifestyle',
        'Industrial lifestyle',
        'City living',
        'Dependent lifestyle'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 20
    },
  ];

  final List<Map<String, dynamic>> _originalLevel3Questions = [
    {
      'question':
          'The Bahay Kubo structure is an example of what kind of architecture?',
      'options': [
        'Vernacular architecture',
        'Modern architecture',
        'Gothic style',
        'Baroque style'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 21
    },
    {
      'question':
          'In Home Economics, what skill can be practiced in a Bahay Kubo kitchen?',
      'options': [
        'Cooking native Filipino dishes',
        'Programming',
        'Car maintenance',
        'Plumbing'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 22
    },
    {
      'question':
          'The materials used in Bahay Kubo construction are examples of what?',
      'options': [
        'Indigenous materials',
        'Synthetic materials',
        'Metallic materials',
        'Imported materials'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 23
    },
    {
      'question':
          'The process of weaving sawali walls is related to which TVL skill?',
      'options': [
        'Carpentry and bamboo craft',
        'Automotive',
        'Electrical installation',
        'Barbering'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 24
    },
    {
      'question':
          'Maintaining cleanliness in a Bahay Kubo is part of which TVL subject?',
      'options': ['Housekeeping', 'Food Processing', 'Welding', 'Electronics'],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 25
    },
    {
      'question':
          'When building a Bahay Kubo, measuring bamboo accurately applies which skill?',
      'options': [
        'Mathematics',
        'Drafting or Carpentry',
        'Accounting',
        'Drawing'
      ],
      'correctAnswer': 'b',
      'image': 'assets/images/q2.png',
      'originalNumber': 26
    },
    {
      'question':
          'The design of Bahay Kubo promotes safety during what natural event?',
      'options': [
        'Earthquake or flood',
        'Snowstorm',
        'Tornado',
        'Volcanic eruption'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 27
    },
    {
      'question':
          'In Industrial Arts, making furniture for Bahay Kubo involves which material?',
      'options': ['Bamboo and rattan', 'Steel', 'Plastic', 'Glass'],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 28
    },
    {
      'question':
          'The Bahay Kubo is an inspiration for what type of modern architecture?',
      'options': [
        'Eco-houses or green homes',
        'Skyscrapers',
        'Office buildings',
        'Factories'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 29
    },
    {
      'question': 'The Bahay Kubo symbolizes what core Filipino value?',
      'options': [
        'Bayanihan and simplicity',
        'Greed',
        'Isolation',
        'Competition'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 30
    },
  ];

  // Additional levels 4-7
  final List<Map<String, dynamic>> _originalLevel4Questions = [
    {
      'question':
          'What traditional Filipino value is embodied in Bahay Kubo construction?',
      'options': [
        'Bayanihan spirit',
        'Individualism',
        'Competition',
        'Urbanization'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 31
    },
    {
      'question': 'The Bahay Kubo design is optimized for what climate?',
      'options': [
        'Tropical climate',
        'Temperate climate',
        'Desert climate',
        'Arctic climate'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 32
    },
    {
      'question': 'What makes Bahay Kubo environmentally sustainable?',
      'options': [
        'Use of renewable materials',
        'Plastic components',
        'Concrete foundation',
        'Steel framework'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 33
    },
    {
      'question': 'The Bahay Kubo represents what aspect of Filipino culture?',
      'options': [
        'Agricultural heritage',
        'Industrial development',
        'Digital innovation',
        'Maritime history'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 34
    },
    {
      'question':
          'What traditional cooking method is associated with Bahay Kubo?',
      'options': [
        'Wood-fired cooking',
        'Electric stoves',
        'Gas ranges',
        'Microwave cooking'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 35
    },
    {
      'question': 'The Bahay Kubo layout typically includes what feature?',
      'options': [
        'Open floor plan',
        'Multiple stories',
        'Basement',
        'Attic storage'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 36
    },
    {
      'question': 'What natural ventilation system does Bahay Kubo utilize?',
      'options': [
        'Cross ventilation',
        'Air conditioning',
        'Central heating',
        'Mechanical fans'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 37
    },
    {
      'question': 'The Bahay Kubo foundation is designed to be what?',
      'options': [
        'Flexible and earthquake-resistant',
        'Rigid and permanent',
        'Underground',
        'Multi-level'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 38
    },
    {
      'question':
          'What traditional Filipino art form is often found in Bahay Kubo?',
      'options': [
        'Weaving and bamboo craft',
        'Digital art',
        'Oil painting',
        'Sculpture'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 39
    },
    {
      'question':
          'The Bahay Kubo represents what type of architectural adaptation?',
      'options': [
        'Climate-responsive design',
        'International style',
        'Modernist approach',
        'Post-modern design'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 40
    },
  ];

  final List<Map<String, dynamic>> _originalLevel5Questions = [
    {
      'question':
          'What traditional building technique is used in Bahay Kubo construction?',
      'options': ['Mortise and tenon joints', 'Welding', 'Nailing', 'Gluing'],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 41
    },
    {
      'question': 'The Bahay Kubo design minimizes what environmental impact?',
      'options': [
        'Carbon footprint',
        'Water usage',
        'Noise pollution',
        'Light pollution'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 42
    },
    {
      'question':
          'What traditional Filipino storage solution is found in Bahay Kubo?',
      'options': [
        'Bamboo shelves and cabinets',
        'Plastic containers',
        'Metal lockers',
        'Wooden chests'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 43
    },
    {
      'question': 'The Bahay Kubo roof design is effective for what purpose?',
      'options': [
        'Water drainage during heavy rain',
        'Snow accumulation',
        'Solar panel installation',
        'Wind resistance'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 44
    },
    {
      'question': 'What traditional lighting method is used in Bahay Kubo?',
      'options': [
        'Natural light through windows',
        'Electric bulbs',
        'Gas lamps',
        'Candles'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 45
    },
    {
      'question': 'The Bahay Kubo represents what type of economic approach?',
      'options': [
        'Subsistence economy',
        'Capitalist economy',
        'Socialist economy',
        'Digital economy'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 46
    },
    {
      'question':
          'What traditional water source is associated with Bahay Kubo?',
      'options': [
        'Deep well or natural spring',
        'Tap water',
        'Bottled water',
        'Filtered water'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 47
    },
    {
      'question':
          'The Bahay Kubo design incorporates what natural element for cooling?',
      'options': [
        'Surrounding vegetation',
        'Air conditioning',
        'Electric fans',
        'Water mist'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 48
    },
    {
      'question':
          'What traditional Filipino social gathering is held in Bahay Kubo?',
      'options': [
        'Family celebrations and fiestas',
        'Business meetings',
        'Political rallies',
        'Sports events'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 49
    },
    {
      'question': 'The Bahay Kubo construction uses what type of foundation?',
      'options': [
        'Wooden posts on rocks',
        'Concrete slab',
        'Steel beams',
        'Brick foundation'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 50
    },
  ];

  final List<Map<String, dynamic>> _originalLevel6Questions = [
    {
      'question':
          'What traditional Filipino cooking utensil is used in Bahay Kubo?',
      'options': [
        'Clay pots and wooden spoons',
        'Non-stick pans',
        'Electric cookers',
        'Microwave oven'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 51
    },
    {
      'question':
          'The Bahay Kubo design promotes what type of community relationship?',
      'options': [
        'Close-knit neighborhood',
        'Individual privacy',
        'Competitive environment',
        'Isolated living'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 52
    },
    {
      'question':
          'What traditional sleeping arrangement is common in Bahay Kubo?',
      'options': [
        'Banig (woven mats) on floor',
        'Beds with mattresses',
        'Hammocks',
        'Bunk beds'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 53
    },
    {
      'question': 'The Bahay Kubo represents what aspect of Filipino identity?',
      'options': [
        'Cultural heritage and simplicity',
        'Modern sophistication',
        'Urban lifestyle',
        'Western influence'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 54
    },
    {
      'question':
          'What traditional waste management practice is used in Bahay Kubo?',
      'options': [
        'Composting and recycling',
        'Landfill disposal',
        'Incineration',
        'Ocean dumping'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 55
    },
    {
      'question': 'The Bahay Kubo design is adaptable to what type of terrain?',
      'options': [
        'Various landscapes and slopes',
        'Only flat land',
        'Only coastal areas',
        'Only mountainous regions'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 56
    },
    {
      'question':
          'What traditional Filipino musical instrument might be played in Bahay Kubo?',
      'options': ['Bamboo instruments', 'Electric guitar', 'Piano', 'Violin'],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 57
    },
    {
      'question':
          'The Bahay Kubo construction requires what type of skilled labor?',
      'options': [
        'Traditional carpentry',
        'Modern engineering',
        'Digital design',
        'Robotic assembly'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 58
    },
    {
      'question':
          'What traditional Filipino game might be played near Bahay Kubo?',
      'options': [
        'Traditional outdoor games',
        'Video games',
        'Board games',
        'Card games'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 59
    },
    {
      'question': 'The Bahay Kubo represents what approach to material usage?',
      'options': [
        'Resource efficiency and local materials',
        'Imported materials',
        'Synthetic materials',
        'Luxury materials'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 60
    },
  ];

  final List<Map<String, dynamic>> _originalLevel7Questions = [
    {
      'question':
          'What traditional Filipino spiritual belief is reflected in Bahay Kubo orientation?',
      'options': [
        'Harmony with nature',
        'Modern spirituality',
        'Western religion',
        'Scientific principles'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 61
    },
    {
      'question':
          'The Bahay Kubo design incorporates what natural cooling principle?',
      'options': [
        'Stack ventilation',
        'Mechanical cooling',
        'Radiant cooling',
        'Evaporative cooling'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 62
    },
    {
      'question':
          'What traditional Filipino textile might be found in Bahay Kubo?',
      'options': [
        'Handwoven fabrics',
        'Synthetic textiles',
        'Imported silk',
        'Digital prints'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 63
    },
    {
      'question':
          'The Bahay Kubo represents what type of architectural heritage?',
      'options': [
        'Indigenous architecture',
        'Colonial architecture',
        'Modern architecture',
        'International style'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 64
    },
    {
      'question':
          'What traditional Filipino healing practice might be associated with Bahay Kubo?',
      'options': [
        'Herbal medicine',
        'Modern medicine',
        'Alternative therapy',
        'Surgical procedures'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q6.png',
      'originalNumber': 65
    },
    {
      'question':
          'The Bahay Kubo construction follows what building philosophy?',
      'options': [
        'Sustainable and adaptive design',
        'Fixed and permanent design',
        'Modular construction',
        'Prefabricated design'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q11.png',
      'originalNumber': 66
    },
    {
      'question':
          'What traditional Filipino artistic expression is visible in Bahay Kubo?',
      'options': [
        'Wood carving and weaving',
        'Digital art',
        'Graffiti',
        'Sculpture'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q2.png',
      'originalNumber': 67
    },
    {
      'question':
          'The Bahay Kubo design supports what type of family structure?',
      'options': [
        'Extended family living',
        'Nuclear family only',
        'Single person household',
        'Community living'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q3.png',
      'originalNumber': 68
    },
    {
      'question':
          'What traditional Filipino agricultural practice is integrated with Bahay Kubo?',
      'options': [
        'Mixed cropping and backyard farming',
        'Monoculture farming',
        'Hydroponics',
        'Greenhouse farming'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q4.png',
      'originalNumber': 69
    },
    {
      'question': 'The Bahay Kubo represents what ultimate Filipino value?',
      'options': [
        'Resilience and adaptability',
        'Wealth accumulation',
        'Urban development',
        'Technological advancement'
      ],
      'correctAnswer': 'a',
      'image': 'assets/images/q5.png',
      'originalNumber': 70
    },
  ];

  // Shuffled questions that will be used in the quiz
  late List<Map<String, dynamic>> level1Questions;
  late List<Map<String, dynamic>> level2Questions;
  late List<Map<String, dynamic>> level3Questions;
  late List<Map<String, dynamic>> level4Questions;
  late List<Map<String, dynamic>> level5Questions;
  late List<Map<String, dynamic>> level6Questions;
  late List<Map<String, dynamic>> level7Questions;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true); // Continuous confetti animation

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true); // Continuous scale animation

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true); // Continuous bounce animation

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    _bounceAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: _getLevelColor(currentLevel).withOpacity(0.7),
      end: _getLevelColor(currentLevel).withOpacity(1),
    ).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _shuffleAllQuestions();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _shuffleAllQuestions() {
    // Shuffle all levels questions and options
    level1Questions = _shuffleQuestions(_originalLevel1Questions);
    level2Questions = _shuffleQuestions(_originalLevel2Questions);
    level3Questions = _shuffleQuestions(_originalLevel3Questions);
    level4Questions = _shuffleQuestions(_originalLevel4Questions);
    level5Questions = _shuffleQuestions(_originalLevel5Questions);
    level6Questions = _shuffleQuestions(_originalLevel6Questions);
    level7Questions = _shuffleQuestions(_originalLevel7Questions);
  }

  // Play sound effect
  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.play(AssetSource('audio/mahusay.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Start all animations
  void _startAnimations() {
    // Stop all animations first
    _confettiController.stop();
    _scaleController.stop();
    _bounceController.stop();

    // Reset and restart with continuous animations
    _confettiController.reset();
    _scaleController.reset();
    _bounceController.reset();

    _confettiController.repeat(reverse: true);
    _scaleController.repeat(reverse: true);
    _bounceController.repeat(reverse: true);

    // Play success sound
    _playSuccessSound();
  }

  List<Map<String, dynamic>> _shuffleQuestions(
      List<Map<String, dynamic>> questions) {
    // Create a copy of the questions list to avoid modifying the original
    List<Map<String, dynamic>> shuffledQuestions = List.from(questions);

    // Shuffle the order of questions
    shuffledQuestions.shuffle(_random);

    // Shuffle options for each question and update correct answer
    for (int i = 0; i < shuffledQuestions.length; i++) {
      shuffledQuestions[i] = _shuffleQuestionOptions(shuffledQuestions[i]);
    }

    return shuffledQuestions;
  }

  Map<String, dynamic> _shuffleQuestionOptions(Map<String, dynamic> question) {
    List<String> options = List.from(question['options']);

    // Create a list of option indices
    List<int> indices = List.generate(options.length, (index) => index);

    // Shuffle the indices
    indices.shuffle(_random);

    // Create new shuffled options
    List<String> shuffledOptions = [];
    for (int index in indices) {
      shuffledOptions.add(options[index]);
    }

    // Find the new position of the correct answer
    String newCorrectAnswer = '';
    for (int i = 0; i < indices.length; i++) {
      // Convert the original correct answer to index (a=0, b=1, c=2, d=3)
      int originalCorrectIndex =
          question['correctAnswer'].codeUnitAt(0) - 'a'.codeUnitAt(0);

      if (indices[i] == originalCorrectIndex) {
        newCorrectAnswer = String.fromCharCode('a'.codeUnitAt(0) + i);
        break;
      }
    }

    return {
      'question': question['question'],
      'options': shuffledOptions,
      'correctAnswer': newCorrectAnswer,
      'image': question['image'],
      'originalNumber': question['originalNumber'],
    };
  }

  // Get the sequential question number for display (Q1, Q2, Q3...)
  String _getQuestionNumber(int currentIndex) {
    // Calculate the base number for the current level
    int baseNumber = (currentLevel - 1) * 10;
    return 'Q${baseNumber + currentIndex + 1}';
  }

  List<Map<String, dynamic>> get currentLevelQuestions {
    switch (currentLevel) {
      case 1:
        return level1Questions;
      case 2:
        return level2Questions;
      case 3:
        return level3Questions;
      case 4:
        return level4Questions;
      case 5:
        return level5Questions;
      case 6:
        return level6Questions;
      case 7:
        return level7Questions;
      default:
        return level1Questions;
    }
  }

  int get totalQuestions => currentLevelQuestions.length;

  void _resetQuizForLevel(int level) {
    // Stop all animations when resetting
    _confettiController.stop();
    _scaleController.stop();
    _bounceController.stop();

    setState(() {
      currentLevel = level;
      currentQuestionIndex = 0;
      selectedOption = null;
      userAnswers.clear();
      levelCompleted = false;

      // Update color animation for new level
      _colorAnimation = ColorTween(
        begin: _getLevelColor(level).withOpacity(0.7),
        end: _getLevelColor(level).withOpacity(1),
      ).animate(
        CurvedAnimation(
          parent: _bounceController,
          curve: Curves.easeInOut,
        ),
      );

      // Reshuffle questions when starting a new level
      _shuffleAllQuestions();
    });
  }

  void _nextLevel() {
    if (currentLevel < 7) {
      _resetQuizForLevel(currentLevel + 1);
    } else {
      // All levels completed
      setState(() {
        allLevelsCompleted = true;
      });
      _startAnimations(); // Start animations for final results
    }
  }

  void _retryLevel() {
    _resetQuizForLevel(currentLevel);
  }

  @override
  Widget build(BuildContext context) {
    if (allLevelsCompleted) {
      return _buildFinalResultsScreen();
    }

    if (levelCompleted) {
      return _buildLevelCompleteScreen();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Multiple Choice Quiz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Level $currentLevel',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: _getLevelColor(currentLevel),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: _getLevelColor(currentLevel).withOpacity(0.1),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Level indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: _getLevelColor(currentLevel).withOpacity(0.2),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLevelIndicator(1, 'General'),
                      _buildLevelIndicator(2, 'Agri-Fishery'),
                      _buildLevelIndicator(3, 'Home Economics'),
                      _buildLevelIndicator(4, 'Culture'),
                      _buildLevelIndicator(5, 'Construction'),
                      _buildLevelIndicator(6, 'Lifestyle'),
                      _buildLevelIndicator(7, 'Integration'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor:
                      _getLevelColor(currentLevel).withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getLevelColor(currentLevel)),
                ),
              ),
              const SizedBox(height: 5),
              // Question counter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level $currentLevel - ${_getQuestionNumber(currentQuestionIndex)} of Q${(currentLevel * 10)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getLevelColor(currentLevel),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score: ${levelScores[currentLevel] ?? 0}/$totalQuestions',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getLevelColor(currentLevel),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Question image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _getLevelColor(currentLevel).withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      currentLevelQuestions[currentQuestionIndex]['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.quiz,
                          size: 50,
                          color: _getLevelColor(currentLevel),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Question text - Now with sequential numbering
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '${_getQuestionNumber(currentQuestionIndex)}. ${currentLevelQuestions[currentQuestionIndex]['question']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(currentLevel),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),
              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: List.generate(
                    currentLevelQuestions[currentQuestionIndex]['options']
                        .length,
                    (index) => Column(
                      children: [
                        _buildOption(
                          String.fromCharCode(97 + index), // a, b, c, d
                          currentLevelQuestions[currentQuestionIndex]['options']
                              [index],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              // Next/Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedOption != null
                        ? () {
                            // Save the answer
                            userAnswers[currentQuestionIndex] = selectedOption;

                            // Check if it's the last question
                            if (currentQuestionIndex < totalQuestions - 1) {
                              // Move to next question
                              setState(() {
                                currentQuestionIndex++;
                                selectedOption =
                                    userAnswers[currentQuestionIndex];
                              });
                            } else {
                              // Show level results
                              _showLevelResults();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getLevelColor(currentLevel),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex < totalQuestions - 1
                          ? 'Next →'
                          : 'Submit Level $currentLevel',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCompleteScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Level $currentLevel Completed!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _getLevelColor(currentLevel),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Continuous confetti animation in background
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ContinuousConfettiPainter(
                  animationValue: _confettiController.value,
                  color: _getLevelColor(currentLevel),
                ),
                child: Container(),
              );
            },
          ),
          // Pulsating background effect
          AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: _scaleAnimation.value,
                    colors: [
                      _getLevelColor(currentLevel).withOpacity(0.05),
                      _getLevelColor(currentLevel).withOpacity(0.01),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated trophy with continuous scale and bounce effects
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Icon(
                              Icons.emoji_events,
                              size: 120,
                              color: _colorAnimation.value,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Bouncing title text
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value * 0.5),
                          child: Text(
                            'Level $currentLevel Completed!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _getLevelColor(currentLevel),
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: _getLevelColor(currentLevel)
                                      .withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Animated score display
                    AnimatedBuilder(
                      animation: _scaleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_scaleAnimation.value - 1) * 0.5,
                          child: Column(
                            children: [
                              Text(
                                'Score: ${levelScores[currentLevel]}/$totalQuestions',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${((levelScores[currentLevel]! / totalQuestions) * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(currentLevel),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    // Animated buttons
                    Column(
                      children: [
                        if (currentLevel < 7) ...[
                          AnimatedBuilder(
                            animation: _bounceController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _bounceAnimation.value * 0.3),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _nextLevel,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _getLevelColor(currentLevel + 1),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      shadowColor:
                                          _getLevelColor(currentLevel + 1)
                                              .withOpacity(0.5),
                                    ),
                                    child: const Text(
                                      'Continue to Next Level →',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                        ],
                        AnimatedBuilder(
                          animation: _bounceController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset:
                                  Offset(0, _bounceAnimation.value * 0.3 * -1),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _retryLevel,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    'Retry Level $currentLevel',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor: Colors.blue.withOpacity(0.5),
                            ),
                            child: const Text(
                              'Back to Quiz Selection',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalResultsScreen() {
    int totalPossible = level1Questions.length +
        level2Questions.length +
        level3Questions.length +
        level4Questions.length +
        level5Questions.length +
        level6Questions.length +
        level7Questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Quiz Completed! 🎉',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Continuous confetti animation in background
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ContinuousConfettiPainter(
                  animationValue: _confettiController.value,
                  color: Colors.green,
                ),
                child: Container(),
              );
            },
          ),
          // Pulsating background effect
          AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: _scaleAnimation.value * 1.5,
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated gold trophy with continuous effects
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: const Icon(
                              Icons.emoji_events,
                              size: 140,
                              color: Color.fromARGB(255, 255, 193, 7),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Bouncing congratulations text
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value * 0.5),
                          child: const Text(
                            'Congratulations!',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.green,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You have completed all levels.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Animated score display
                    AnimatedBuilder(
                      animation: _scaleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_scaleAnimation.value - 1) * 0.5,
                          child: Column(
                            children: [
                              Text(
                                'Total Score: $totalScore/$totalPossible',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${((totalScore / totalPossible) * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _getScoreColor(totalScore, totalPossible),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Level Scores:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildAnimatedLevelScoreRow(
                                1, level1Questions.length, 'General'),
                            _buildAnimatedLevelScoreRow(
                                2, level2Questions.length, 'Agri-Fishery'),
                            _buildAnimatedLevelScoreRow(
                                3, level3Questions.length, 'Home Economics'),
                            _buildAnimatedLevelScoreRow(
                                4, level4Questions.length, 'Culture'),
                            _buildAnimatedLevelScoreRow(
                                5, level5Questions.length, 'Construction'),
                            _buildAnimatedLevelScoreRow(
                                6, level6Questions.length, 'Lifestyle'),
                            _buildAnimatedLevelScoreRow(
                                7, level7Questions.length, 'Integration'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value * 0.3),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: Colors.green.withOpacity(0.5),
                              ),
                              child: const Text(
                                'Back to Quiz Selection',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
// ==================== LEVEL INDICATOR METHODS ====================

Widget _buildLevelIndicator(int level, String title) {
  final bool isCurrent = level == currentLevel;
  final bool isCompleted = levelScores[level]! > 0;
  final bool isUnlocked = level == 1 || levelScores[level - 1]! > 0;
  final Color levelColor = _getLevelColor(level);

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 5),
    child: Column(
      children: [
        _buildLevelCircle(level, isCurrent, isCompleted, isUnlocked, levelColor),
        const SizedBox(height: 4),
        _buildLevelTitle(title, isCurrent, levelColor),
      ],
    ),
  );
}

// Helper method to build level circle
Widget _buildLevelCircle(
  int level,
  bool isCurrent,
  bool isCompleted,
  bool isUnlocked,
  Color levelColor,
) {
  return Container(
    width: 35,
    height: 35,
    decoration: _buildCircleDecoration(isCurrent, isCompleted, isUnlocked, levelColor),
    child: Center(
      child: isCompleted
          ? _buildCheckIcon()
          : _buildLevelNumber(level, isUnlocked),
    ),
  );
}

// Helper method to build circle decoration
BoxDecoration _buildCircleDecoration(
  bool isCurrent,
  bool isCompleted,
  bool isUnlocked,
  Color levelColor,
) {
  return BoxDecoration(
    color: _getCircleColor(isCurrent, isCompleted, isUnlocked, levelColor),
    shape: BoxShape.circle,
    border: isCurrent ? _buildCurrentLevelBorder(levelColor) : null,
  );
}

// Helper method to get circle color
Color _getCircleColor(
  bool isCurrent,
  bool isCompleted,
  bool isUnlocked,
  Color levelColor,
) {
  if (isCurrent) return levelColor;
  if (isCompleted) return levelColor.withOpacity(0.7);
  if (isUnlocked) return Colors.grey[300]!;
  return Colors.grey[200]!;
}

// Helper method to build current level border
BoxBorder _buildCurrentLevelBorder(Color levelColor) {
  return Border.all(color: levelColor, width: 3);
}

// Helper method to build check icon
Widget _buildCheckIcon() {
  return const Icon(
    Icons.check,
    color: Colors.white,
    size: 18,
  );
}

// Helper method to build level number
Widget _buildLevelNumber(int level, bool isUnlocked) {
  return Text(
    '$level',
    style: TextStyle(
      color: isUnlocked ? Colors.black : Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  );
}

// Helper method to build level title
Widget _buildLevelTitle(String title, bool isCurrent, Color levelColor) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 9,
      color: isCurrent ? levelColor : Colors.grey,
      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
    ),
    textAlign: TextAlign.center,
  );
}

// ==================== ANIMATED LEVEL SCORE ROW METHODS ====================

Widget _buildAnimatedLevelScoreRow(
  int level,
  int totalQuestions,
  String title,
) {
  return AnimatedBuilder(
    animation: _bounceController,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(_bounceAnimation.value * 0.2, 0),
        child: _buildScoreRowContainer(level, totalQuestions, title),
      );
    },
  );
}

// Helper method to build score row container
Widget _buildScoreRowContainer(
  int level,
  int totalQuestions,
  String title,
) {
  final Color levelColor = _getLevelColor(level);
  
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: _buildScoreRowDecoration(levelColor),
    child: _buildScoreRowContent(level, totalQuestions, title, levelColor),
  );
}

// Helper method to build score row decoration
BoxDecoration _buildScoreRowDecoration(Color levelColor) {
  return BoxDecoration(
    color: levelColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: levelColor.withOpacity(0.3),
      width: 1,
    ),
  );
}

// Helper method to build score row content
Widget _buildScoreRowContent(
  int level,
  int totalQuestions,
  String title,
  Color levelColor,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildScoreTitle(title, levelColor),
      _buildScoreValue(level, totalQuestions, levelColor),
    ],
  );
}

// Helper method to build score title
Widget _buildScoreTitle(String title, Color levelColor) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: levelColor,
    ),
  );
}

// Helper method to build score value
Widget _buildScoreValue(int level, int totalQuestions, Color levelColor) {
  return Text(
    '${levelScores[level]}/$totalQuestions',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: levelColor,
    ),
  );
}
  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.teal;
      case 6:
        return Colors.pink;
      case 7:
        return Colors.deepPurple;
      default:
        return Colors.green;
    }
  }

  void _showLevelResults() {
    // Calculate score for current level
    int score = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (userAnswers[i] == currentLevelQuestions[i]['correctAnswer']) {
        score++;
      }
    }

    // Update level score
    levelScores[currentLevel] = score;
    totalScore += score;

    // Start continuous animations
    _startAnimations();

    // Set level completed
    setState(() {
      levelCompleted = true;
    });
  }

  Color _getScoreColor(int score, int total) {
    double percentage = score / total;
    if (percentage >= 0.8) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildOption(String option, String text) {
    bool isSelected = selectedOption == option;
    return InkWell(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? _getLevelColor(currentLevel).withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? _getLevelColor(currentLevel) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _getLevelColor(currentLevel) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? _getLevelColor(currentLevel)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$option) $text',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected ? _getLevelColor(currentLevel) : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom continuous confetti painter for animation
class ContinuousConfettiPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final Random _random = Random();
  final List<ConfettiParticle> _particles = [];

  ContinuousConfettiPainter({
    required this.animationValue,
    required this.color,
  }) {
    // Initialize particles if empty
    if (_particles.isEmpty) {
      for (int i = 0; i < 80; i++) {
        _particles.add(ConfettiParticle.random(_random));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Update and draw particles
    for (final particle in _particles) {
      // Update particle position based on animation
      particle.update(animationValue, size);

      // Set color with opacity based on particle life
      paint.color = color.withOpacity(particle.opacity);

      // Save canvas state
      canvas.save();

      // Translate to particle position and rotate
      canvas.translate(particle.x * size.width, particle.y * size.height);
      canvas.rotate(particle.rotation);

      // Draw confetti piece
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.width,
          height: particle.height,
        ),
        paint,
      );

      // Restore canvas state
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Confetti particle class for continuous animation
class ConfettiParticle {
  double x;
  double y;
  double speed;
  double rotation;
  double rotationSpeed;
  double width;
  double height;
  double opacity;
  double life;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.width,
    required this.height,
    required this.opacity,
    required this.life,
  });

  factory ConfettiParticle.random(Random random) {
    return ConfettiParticle(
      x: random.nextDouble(),
      y: random.nextDouble() * 1.5 - 0.5, // Start above the screen
      speed: random.nextDouble() * 0.5 + 0.2,
      rotation: random.nextDouble() * 2 * pi,
      rotationSpeed: random.nextDouble() * 0.1 - 0.05,
      width: random.nextDouble() * 8 + 4,
      height: random.nextDouble() * 3 + 2,
      opacity: random.nextDouble() * 0.5 + 0.5,
      life: random.nextDouble(),
    );
  }

  void update(double animationValue, Size size) {
    // Move particle down
    y += speed * 0.01;

    // Update rotation
    rotation += rotationSpeed;

    // Update life cycle
    life += 0.01;
    if (life > 1.0) life = 0.0;

    // Calculate opacity based on life
    opacity = 0.7 * (1.0 - life);

    // Reset particle when it goes off screen
    if (y > 1.5) {
      y = -0.5;
      x = _random.nextDouble();
      speed = _random.nextDouble() * 0.5 + 0.2;
      rotationSpeed = _random.nextDouble() * 0.1 - 0.05;
      opacity = _random.nextDouble() * 0.5 + 0.5;
      life = _random.nextDouble();
    }
  }

  Random get _random => Random();
}
