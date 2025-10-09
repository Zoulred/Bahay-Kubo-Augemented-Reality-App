import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class TrueOrFalseQuizPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const TrueOrFalseQuizPage({super.key, required this.user});

  @override
  State<TrueOrFalseQuizPage> createState() => _TrueOrFalseQuizPageState();
}

class _TrueOrFalseQuizPageState extends State<TrueOrFalseQuizPage>
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

  // Original Level 1 Questions - Bahay Kubo (1-10)
  final List<Map<String, dynamic>> _originalLevel1Questions = [
    {
      'question':
          'The Bahay Kubo is known as the traditional Filipino house made mostly from natural materials.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'The Bahay Kubo is originally influenced by Western architecture.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'The open windows and elevated design of the Bahay Kubo help reduce heat and improve air flow.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'The walls of a Bahay Kubo are usually made from glass and steel.',
      'correctAnswer': 'False',
      'image': 'assets/images/q4.png'
    },
    {
      'question':
          'The Bahay Kubo design promotes harmony with nature and the environment.',
      'correctAnswer': 'True',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'The roof of the Bahay Kubo is steeply pitched to help rainwater flow easily.',
      'correctAnswer': 'True',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'The Bahay Kubo does not use nails or screws; it often uses bamboo ties and ropes.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'The Bahay Kubo cannot withstand strong winds or floods.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'The Bahay Kubo encourages sustainable living through the use of renewable resources.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'The Bahay Kubo is only found in Luzon and not in Visayas or Mindanao.',
      'correctAnswer': 'False',
      'image': 'assets/images/q4.png'
    },
  ];

  // Original Level 2 Questions - Augmented Reality (AR) and Technology (11-20)
  final List<Map<String, dynamic>> _originalLevel2Questions = [
    {
      'question':
          'Augmented Reality (AR) adds computer-generated images or information to the real world using a device.',
      'correctAnswer': 'True',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'AR is completely the same as Virtual Reality (VR).',
      'correctAnswer': 'False',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'TVL ICT students can create educational AR content using mobile apps and coding.',
      'correctAnswer': 'True',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'AR can be used to design interactive Bahay Kubo models for architecture learning.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'AR cannot be applied to agricultural studies.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'With AR, students can scan pictures of vegetables and see their nutritional values instantly.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'AR can make learning about healthy foods more interesting and visual.',
      'correctAnswer': 'True',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'AR only works on expensive and professional devices.',
      'correctAnswer': 'False',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'Teachers can use AR to demonstrate how a vegetable grows from seed to harvest.',
      'correctAnswer': 'True',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'Augmented Reality is not beneficial to any of the TVL strands.',
      'correctAnswer': 'False',
      'image': 'assets/images/q11.png'
    },
  ];

  // Original Level 3 Questions - Vegetable Nutrition (21-30)
  final List<Map<String, dynamic>> _originalLevel3Questions = [
    {
      'question':
          'Vegetables from the Bahay Kubo song provide essential nutrients for the human body.',
      'correctAnswer': 'True',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Talong (eggplant) is a good source of protein like meat.',
      'correctAnswer': 'False',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'Kalabasa (squash) helps improve eyesight because it contains Vitamin A.',
      'correctAnswer': 'True',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Kangkong is rich in iron, which is good for the blood.',
      'correctAnswer': 'True',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'Tomatoes contain Vitamin C and lycopene, which help strengthen the immune system.',
      'correctAnswer': 'True',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'Eating vegetables regularly can reduce the risk of diseases.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Malunggay leaves are low in nutrients and are mostly used as decoration.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'TVL students in Home Economics can apply nutrition knowledge to plan healthy menus.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'Using AR to identify nutrients in vegetables helps make nutrition learning more engaging.',
      'correctAnswer': 'True',
      'image': 'assets/images/q4.png'
    },
    {
      'question':
          'Combining traditional farming practices with modern technology like AR is not possible.',
      'correctAnswer': 'False',
      'image': 'assets/images/q5.png'
    },
  ];

  // Original Level 4 Questions - Farming Practices (31-40)
  final List<Map<String, dynamic>> _originalLevel4Questions = [
    {
      'question':
          'Organic farming avoids the use of synthetic pesticides and fertilizers.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Crop rotation is not important for maintaining soil health.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'Composting is a natural way to recycle organic waste into fertilizer.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'Traditional farming methods are always less efficient than modern industrial farming.',
      'correctAnswer': 'False',
      'image': 'assets/images/q4.png'
    },
    {
      'question':
          'Intercropping involves growing two or more crops in proximity to promote biodiversity.',
      'correctAnswer': 'True',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'Water conservation is not a concern in traditional farming practices.',
      'correctAnswer': 'False',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'Natural pest control methods can be as effective as chemical pesticides.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Traditional farming always requires large amounts of land to be profitable.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'Seed saving is an important practice in traditional farming to preserve crop diversity.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'Modern technology has no place in traditional farming systems.',
      'correctAnswer': 'False',
      'image': 'assets/images/q4.png'
    },
  ];

  // Original Level 5 Questions - Filipino Culture and Values (41-50)
  final List<Map<String, dynamic>> _originalLevel5Questions = [
    {
      'question':
          'Bayanihan refers to the Filipino tradition of communal unity and cooperation.',
      'correctAnswer': 'True',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'Respect for elders is not an important value in Filipino culture.',
      'correctAnswer': 'False',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'The Bahay Kubo reflects the Filipino value of simplicity and harmony with nature.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Filipino culture does not value family relationships and strong family ties.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Hospitality is a well-known trait in Filipino culture.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'Traditional Filipino homes like the Bahay Kubo have no cultural significance.',
      'correctAnswer': 'False',
      'image': 'assets/images/q4.png'
    },
    {
      'question':
          'Filipino culture values close community relationships and mutual support.',
      'correctAnswer': 'True',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'The concept of "utang na loob" or debt of gratitude is not important in Filipino society.',
      'correctAnswer': 'False',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'Traditional Filipino architecture reflects the country\'s history and cultural values.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Modern Filipino society has completely abandoned traditional cultural values.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
  ];

  // Original Level 6 Questions - Environmental Sustainability (51-60)
  final List<Map<String, dynamic>> _originalLevel6Questions = [
    {
      'question':
          'Sustainable living aims to reduce the use of Earth\'s natural resources.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Renewable energy sources include solar, wind, and hydro power.',
      'correctAnswer': 'True',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'The Bahay Kubo design is not environmentally sustainable.',
      'correctAnswer': 'False',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'Waste segregation and recycling are important practices for sustainability.',
      'correctAnswer': 'True',
      'image': 'assets/images/q4.png'
    },
    {
      'question':
          'Water conservation has no impact on environmental sustainability.',
      'correctAnswer': 'False',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'Traditional building materials like bamboo are more sustainable than concrete.',
      'correctAnswer': 'True',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'Sustainable agriculture practices can help combat climate change.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Individual actions have no significant impact on environmental sustainability.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'The Bahay Kubo promotes natural ventilation, reducing the need for air conditioning.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Sustainable living is incompatible with modern lifestyles.',
      'correctAnswer': 'False',
      'image': 'assets/images/q4.png'
    },
  ];

  // Original Level 7 Questions - Modern Applications (61-70)
  final List<Map<String, dynamic>> _originalLevel7Questions = [
    {
      'question':
          'Modern technology can be integrated with traditional farming practices.',
      'correctAnswer': 'True',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'Smart farming techniques cannot increase crop yields sustainably.',
      'correctAnswer': 'False',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'Mobile apps can help farmers monitor weather conditions and crop health.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Traditional knowledge has no value in modern agricultural practices.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
    },
    {
      'question':
          'Drones can be used in agriculture for crop monitoring and spraying.',
      'correctAnswer': 'True',
      'image': 'assets/images/q3.png'
    },
    {
      'question':
          'The Bahay Kubo design cannot be adapted for modern urban settings.',
      'correctAnswer': 'False',
      'image': 'assets/images/q4.png'
    },
    {
      'question':
          'Hydroponic systems can be used to grow vegetables without soil.',
      'correctAnswer': 'True',
      'image': 'assets/images/q5.png'
    },
    {
      'question':
          'Traditional and modern farming methods are mutually exclusive.',
      'correctAnswer': 'False',
      'image': 'assets/images/q6.png'
    },
    {
      'question':
          'Solar panels can be integrated into modern housing designs inspired by the Bahay Kubo.',
      'correctAnswer': 'True',
      'image': 'assets/images/q11.png'
    },
    {
      'question':
          'Technology has no role in preserving traditional cultural practices.',
      'correctAnswer': 'False',
      'image': 'assets/images/q2.png'
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
    // Shuffle level 1 questions
    level1Questions = List.from(_originalLevel1Questions);
    level1Questions.shuffle(_random);

    // Shuffle level 2 questions
    level2Questions = List.from(_originalLevel2Questions);
    level2Questions.shuffle(_random);

    // Shuffle level 3 questions
    level3Questions = List.from(_originalLevel3Questions);
    level3Questions.shuffle(_random);

    // Shuffle level 4 questions
    level4Questions = List.from(_originalLevel4Questions);
    level4Questions.shuffle(_random);

    // Shuffle level 5 questions
    level5Questions = List.from(_originalLevel5Questions);
    level5Questions.shuffle(_random);

    // Shuffle level 6 questions
    level6Questions = List.from(_originalLevel6Questions);
    level6Questions.shuffle(_random);

    // Shuffle level 7 questions
    level7Questions = List.from(_originalLevel7Questions);
    level7Questions.shuffle(_random);
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
              'True or False Quiz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Level $currentLevel - ${_getLevelTitle(currentLevel)}',
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
                      _buildLevelIndicator(1, 'Bahay Kubo'),
                      _buildLevelIndicator(2, 'AR Tech'),
                      _buildLevelIndicator(3, 'Nutrition'),
                      _buildLevelIndicator(4, 'Farming'),
                      _buildLevelIndicator(5, 'Culture'),
                      _buildLevelIndicator(6, 'Environment'),
                      _buildLevelIndicator(7, 'Modern Apps'),
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
                      '${_getLevelTitle(currentLevel)} - ${_getQuestionNumber(currentQuestionIndex)} of Q${(currentLevel * 10)}',
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
              // Options - True and False
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    _buildOption('True'),
                    const SizedBox(height: 10),
                    _buildOption('False'),
                    const SizedBox(height: 10),
                  ],
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
          '${_getLevelTitle(currentLevel)} Completed!',
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
                    // Animated icon with continuous scale and bounce effects
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
                            '${_getLevelTitle(currentLevel)} Completed!',
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
                                    child: Text(
                                      'Continue to ${_getLevelTitle(currentLevel + 1)} →',
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
                                    'Retry ${_getLevelTitle(currentLevel)}',
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
                                1, level1Questions.length, 'Bahay Kubo'),
                            _buildAnimatedLevelScoreRow(
                                2, level2Questions.length, 'AR Technology'),
                            _buildAnimatedLevelScoreRow(
                                3, level3Questions.length, 'Nutrition'),
                            _buildAnimatedLevelScoreRow(
                                4, level4Questions.length, 'Farming'),
                            _buildAnimatedLevelScoreRow(
                                5, level5Questions.length, 'Culture'),
                            _buildAnimatedLevelScoreRow(
                                6, level6Questions.length, 'Environment'),
                            _buildAnimatedLevelScoreRow(
                                7, level7Questions.length, 'Modern Apps'),
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

  Widget _buildLevelIndicator(int level, String title) {
    bool isCurrent = level == currentLevel;
    bool isCompleted = levelScores[level]! > 0;
    bool isUnlocked = level == 1 || levelScores[level - 1]! > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent
                  ? _getLevelColor(level)
                  : isCompleted
                      ? _getLevelColor(level).withOpacity(0.7)
                      : isUnlocked
                          ? Colors.grey[300]
                          : Colors.grey[200],
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: _getLevelColor(level), width: 3)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '$level',
                      style: TextStyle(
                        color: isUnlocked ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: isCurrent ? _getLevelColor(level) : Colors.grey,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLevelScoreRow(
      int level, int totalQuestions, String title) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_bounceAnimation.value * 0.2, 0),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _getLevelColor(level).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getLevelColor(level).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(level),
                  ),
                ),
                Text(
                  '${levelScores[level]}/$totalQuestions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(level),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLevelTitle(int level) {
    switch (level) {
      case 1:
        return 'Bahay Kubo';
      case 2:
        return 'AR Technology';
      case 3:
        return 'Vegetable Nutrition';
      case 4:
        return 'Farming Practices';
      case 5:
        return 'Filipino Culture';
      case 6:
        return 'Environment';
      case 7:
        return 'Modern Applications';
      default:
        return 'Bahay Kubo';
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.red;
      case 6:
        return Colors.teal;
      case 7:
        return Colors.amber;
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

  Widget _buildOption(String option) {
    bool isSelected = selectedOption == option;
    Color optionColor = option == 'True' ? Colors.green : Colors.red;

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
          color: isSelected ? optionColor.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? optionColor : Colors.grey[300]!,
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
                color: isSelected ? optionColor : Colors.white,
                border: Border.all(
                  color: isSelected ? optionColor : Colors.grey[400]!,
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
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? optionColor : Colors.black,
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
  
  // Factory constructor
  factory ConfettiParticle.random(Random random) {
    return ConfettiParticle(
      x: random.nextDouble(),
      y: _calculateStartY(random),
      speed: _calculateSpeed(random),
      rotation: _calculateRotation(random),
      rotationSpeed: _calculateRotationSpeed(random),
      width: _calculateWidth(random),
      height: _calculateHeight(random),
      opacity: _calculateOpacity(random),
      life: random.nextDouble(),
    );
  }
  
  // Update method
  void update(double animationValue, Size size) {
    _moveDown();
    _rotate();
    _advanceLife();
    _updateOpacityFromLife();
    _resetIfOffScreen();
  }
  
  // Private update methods
  void _moveDown() {
    y += speed * ConfettiConstants.speedMultiplier;
  }
  
  void _rotate() {
    rotation += rotationSpeed;
  }
  
  void _advanceLife() {
    life += ConfettiConstants.lifeIncrement;
    if (life > ConfettiConstants.maxLife) {
      life = ConfettiConstants.minLife;
    }
  }
  
  void _updateOpacityFromLife() {
    opacity = ConfettiConstants.opacityFactor * (ConfettiConstants.maxLife - life);
  }
  
  void _resetIfOffScreen() {
    if (y > ConfettiConstants.resetYThreshold) {
      _resetParticle();
    }
  }
  
  void _resetParticle() {
    y = ConfettiConstants.resetYPosition;
    x = _random.nextDouble();
    speed = _calculateSpeed(_random);
    rotationSpeed = _calculateRotationSpeed(_random);
    opacity = _calculateOpacity(_random);
    life = _random.nextDouble();
  }
  
  // Random generator
  Random get _random => Random();
  
  // Static calculation methods
  static double _calculateStartY(Random random) {
    return random.nextDouble() * ConfettiConstants.startYMax - ConfettiConstants.startYMin.abs();
  }
  
  static double _calculateSpeed(Random random) {
    return random.nextDouble() * (ConfettiConstants.speedMax - ConfettiConstants.speedMin) 
        + ConfettiConstants.speedMin;
  }
  
  static double _calculateRotation(Random random) {
    return random.nextDouble() * ConfettiConstants.rotationMax;
  }
  
  static double _calculateRotationSpeed(Random random) {
    return random.nextDouble() * (ConfettiConstants.rotationSpeedMax - ConfettiConstants.rotationSpeedMin)
        + ConfettiConstants.rotationSpeedMin;
  }
  
  static double _calculateWidth(Random random) {
    return random.nextDouble() * (ConfettiConstants.widthMax - ConfettiConstants.widthMin)
        + ConfettiConstants.widthMin;
  }
  
  static double _calculateHeight(Random random) {
    return random.nextDouble() * (ConfettiConstants.heightMax - ConfettiConstants.heightMin)
        + ConfettiConstants.heightMin;
  }
  
  static double _calculateOpacity(Random random) {
    return random.nextDouble() * (ConfettiConstants.opacityMax - ConfettiConstants.opacityMin)
        + ConfettiConstants.opacityMin;
  }
}

// ==================== CONSTANTS ====================

class ConfettiConstants {
  static const double startYMin = -0.5;
  static const double startYMax = 1.5;
  static const double resetYThreshold = 1.5;
  static const double resetYPosition = -0.5;
  
  static const double speedMin = 0.2;
  static const double speedMax = 0.7;
  static const double speedMultiplier = 0.01;
  
  static const double rotationMax = 2 * pi;
  static const double rotationSpeedMin = -0.05;
  static const double rotationSpeedMax = 0.05;
  
  static const double widthMin = 4;
  static const double widthMax = 12;
  static const double heightMin = 2;
  static const double heightMax = 5;
  
  static const double opacityMin = 0.5;
  static const double opacityMax = 1.0;
  static const double opacityFactor = 0.7;
  
  static const double lifeIncrement = 0.01;
  static const double maxLife = 1.0;
  static const double minLife = 0.0;
}