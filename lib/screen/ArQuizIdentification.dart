import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class IdentificationQuizPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const IdentificationQuizPage({super.key, required this.user});

  @override
  State<IdentificationQuizPage> createState() => _IdentificationQuizPageState();
}

class _IdentificationQuizPageState extends State<IdentificationQuizPage>
    with TickerProviderStateMixin {
  int currentLevel = 1;
  int currentQuestionIndex = 0;
  TextEditingController answerController = TextEditingController();
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

  // Level 1 Questions - Madali (Basic Identification)
  final List<Map<String, dynamic>> _originalLevel1Questions = [
    {
      'question': 'Mahaba at manipis na gulay na niluluto bilang adobo.',
      'correctAnswer': 'Sitaw',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Kulay lila na gulay na pwedeng iprito.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Pulang gulay na ginagamit sa sawsawan at ulam.',
      'correctAnswer': 'Kamatis',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Puting ugat na gulay na pwedeng kainin nang hilaw.',
      'correctAnswer': 'Singkamas',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Dahon na gulay na madalas isahog sa sabaw.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Maanghang na gulay na pampalasa.',
      'correctAnswer': 'Luya',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Bilog na gulay na kulay pula kapag hinog.',
      'correctAnswer': 'Kamatis',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na mahaba at berde, gumagapang.',
      'correctAnswer': 'Patola',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na kulay dilaw o kahel kapag hinog.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Mabango at bilog na gulay na pampalasa.',
      'correctAnswer': 'Sibuyas',
      'image': 'assets/images/q4.png'
    },
  ];

  // Level 2 Questions - Madali hanggang Katamtaman
  final List<Map<String, dynamic>> _originalLevel2Questions = [
    {
      'question': 'Isang ugat na gulay na kulay pula o puti.',
      'correctAnswer': 'Labanos',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na ginagamit sa tinola.',
      'correctAnswer': 'Sayote',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Dahon na gulay na madalas itanim sa bakuran.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Mahabang gulay na may buto sa loob.',
      'correctAnswer': 'Patola',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na karaniwang ginagawang ensalada.',
      'correctAnswer': 'Kamatis',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na ginagamit sa pinakbet.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Gulay na bilog at mapait.',
      'correctAnswer': 'Ampalaya',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Isang gumagapang na gulay na malaki ang bunga.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Gulay na karaniwang ginagawang prito.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Ugat na gulay na kulay kayumanggi sa labas.',
      'correctAnswer': 'Luya',
      'image': 'assets/images/q2.png'
    },
  ];

  // Level 3 Questions - Katamtaman
  final List<Map<String, dynamic>> _originalLevel3Questions = [
    {
      'question': 'Gulay na dahon na mabilis malanta.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na ugat na kadalasang ginagawang atsara.',
      'correctAnswer': 'Labanos',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Mahabang gulay na madulas kapag niluto.',
      'correctAnswer': 'Okra',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na ginagamit bilang pampabango ng ulam.',
      'correctAnswer': 'Sibuyas',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Gulay na bilog na karaniwang sangkap sa sinigang.',
      'correctAnswer': 'Kamatis',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na pwedeng kainin ng hilaw o luto.',
      'correctAnswer': 'Singkamas',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na tumutubo sa baging.',
      'correctAnswer': 'Sitaw',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na karaniwang sangkap sa chop suey.',
      'correctAnswer': 'Sayote',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Isang gulay na may maraming buto sa loob.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na kinakain ang dahon at tangkay.',
      'correctAnswer': 'Kangkong',
      'image': 'assets/images/q6.png'
    },
  ];

  // Level 4 Questions - Medyo Mahirap
  final List<Map<String, dynamic>> _originalLevel4Questions = [
    {
      'question': 'Gulay na ugat na tumutubo sa ilalim ng lupa.',
      'correctAnswer': 'Singkamas',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na dahon na may mapait na lasa.',
      'correctAnswer': 'Ampalaya',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na karaniwang tinatanim sa tag-init.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Mahabang gulay na inaani habang bata pa.',
      'correctAnswer': 'Sitaw',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Gulay na ginagamit sa ginataan.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na may matigas na balat kapag hinog.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Gulay na ginagamit bilang sahog at sawsawan.',
      'correctAnswer': 'Kamatis',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na may mabalahibong balat.',
      'correctAnswer': 'Patola',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na madalas isama sa ulam na gulay-gulay.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na ginagamit sa mga sabaw.',
      'correctAnswer': 'Kangkong',
      'image': 'assets/images/q4.png'
    },
  ];

  // Level 5 Questions - Mahirap
  final List<Map<String, dynamic>> _originalLevel5Questions = [
    {
      'question': 'Gulay na kabilang sa mga dahon sa Bahay Kubo.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Ugat na gulay na pampainit ng katawan.',
      'correctAnswer': 'Luya',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Gulay na kailangang balatan bago lutuin.',
      'correctAnswer': 'Sayote',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na may buto na tinatanggal bago lutuin.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na kadalasang ginagawang rekado.',
      'correctAnswer': 'Sibuyas',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na madaling masira kapag hindi sariwa.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Gulay na pwedeng gawing juice.',
      'correctAnswer': 'Kamatis',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na ginagamit sa pinakuluan at ginisa.',
      'correctAnswer': 'Sitaw',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Gulay na may malambot na loob kapag niluto.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na tumutubo sa bakod o balag.',
      'correctAnswer': 'Patola',
      'image': 'assets/images/q2.png'
    },
  ];

  // Level 6 Questions - Mas Mahirap
  final List<Map<String, dynamic>> _originalLevel6Questions = [
    {
      'question': 'Gulay na parehong gulay at pampalasa.',
      'correctAnswer': 'Sibuyas',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na inaani bago tuluyang mahinog.',
      'correctAnswer': 'Sitaw',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Gulay na may masangsang na amoy kapag hilaw.',
      'correctAnswer': 'Sibuyas',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na kinakain ang bunga, hindi ang dahon.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Gulay na tumutubo sa malamig na panahon.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na ginagamit sa sabaw at ginisa.',
      'correctAnswer': 'Kangkong',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na mahaba at may maraming hibla.',
      'correctAnswer': 'Sitaw',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na kailangang lutuin bago kainin.',
      'correctAnswer': 'Ampalaya',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Gulay na madalas itanim sa paso.',
      'correctAnswer': 'Sibuyas',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na bahagi ng tradisyonal na awiting Filipino.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q6.png'
    },
  ];

  // Level 7 Questions - Pinakamahirap
  final List<Map<String, dynamic>> _originalLevel7Questions = [
    {
      'question': 'Gulay sa Bahay Kubo na parehong ugat at pampalasa.',
      'correctAnswer': 'Luya',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na tumutubo sa baging at may dilaw na bulaklak.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na kinakain habang bata pa ang bunga.',
      'correctAnswer': 'Sitaw',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na may mapait na lasa ngunit masustansya.',
      'correctAnswer': 'Ampalaya',
      'image': 'assets/images/q4.png'
    },
    {
      'question': 'Gulay na karaniwang sangkap sa mga lutong Pilipino.',
      'correctAnswer': 'Kamatis',
      'image': 'assets/images/q5.png'
    },
    {
      'question': 'Gulay na ginagamit sa mga sabaw at ulam.',
      'correctAnswer': 'Kangkong',
      'image': 'assets/images/q6.png'
    },
    {
      'question': 'Gulay na may matigas na balat at malambot sa loob.',
      'correctAnswer': 'Kalabasa',
      'image': 'assets/images/q11.png'
    },
    {
      'question': 'Gulay na mahalaga sa kalusugan ng mata.',
      'correctAnswer': 'Talong',
      'image': 'assets/images/q2.png'
    },
    {
      'question': 'Gulay na tinatanim sa bakuran ng bahay kubo.',
      'correctAnswer': 'Pechay',
      'image': 'assets/images/q3.png'
    },
    {
      'question': 'Gulay na simbolo ng masustansyang pagkain sa Pilipinas.',
      'correctAnswer': 'Bahay Kubo',
      'image': 'assets/images/q4.png'
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
    level1Questions = List.from(_originalLevel1Questions);
    level1Questions.shuffle(_random);
    level2Questions = List.from(_originalLevel2Questions);
    level2Questions.shuffle(_random);
    level3Questions = List.from(_originalLevel3Questions);
    level3Questions.shuffle(_random);
    level4Questions = List.from(_originalLevel4Questions);
    level4Questions.shuffle(_random);
    level5Questions = List.from(_originalLevel5Questions);
    level5Questions.shuffle(_random);
    level6Questions = List.from(_originalLevel6Questions);
    level6Questions.shuffle(_random);
    level7Questions = List.from(_originalLevel7Questions);
    level7Questions.shuffle(_random);
  }

  // Play sound effect
  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.play(AssetSource('audio/galing.mp3'));
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
      answerController.clear();
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

      _shuffleAllQuestions();
    });
  }

  void _nextLevel() {
    if (currentLevel < 7) {
      _resetQuizForLevel(currentLevel + 1);
    } else {
      setState(() {
        allLevelsCompleted = true;
      });
      _startAnimations(); // Start animations for final results
    }
  }

  void _retryLevel() {
    _resetQuizForLevel(currentLevel);
  }

  bool _checkAnswer(String userAnswer, String correctAnswer) {
    // Simple case-insensitive comparison
    return userAnswer.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();
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
              'Gulay Identification Quiz',
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
                      _buildLevelIndicator(1, 'Madali'),
                      _buildLevelIndicator(2, 'Madali-Kat.'),
                      _buildLevelIndicator(3, 'Katamtaman'),
                      _buildLevelIndicator(4, 'Medyo Mahirap'),
                      _buildLevelIndicator(5, 'Mahirap'),
                      _buildLevelIndicator(6, 'Mas Mahirap'),
                      _buildLevelIndicator(7, 'Pinakamahirap'),
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
                          Icons.eco,
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
              // Answer input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: 'Type the gulay name here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _getLevelColor(currentLevel),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 15),
              // Next/Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: answerController.text.trim().isNotEmpty
                        ? () {
                            // Save the answer
                            userAnswers[currentQuestionIndex] =
                                answerController.text;

                            // Check if it's the last question
                            if (currentQuestionIndex < totalQuestions - 1) {
                              // Move to next question
                              setState(() {
                                currentQuestionIndex++;
                                answerController.text =
                                    userAnswers[currentQuestionIndex] ?? '';
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), // More realistic iOS-style arrow
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
        elevation: 0,
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
                      _getLevelColor(currentLevel).withOpacity(0.15),
                      _getLevelColor(currentLevel).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated trophy icon with enhanced effects
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value * 0.3),
                          child: Transform.scale(
                            scale: 1 + (_scaleAnimation.value - 1) * 0.5,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getLevelColor(currentLevel).withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                  radius: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                size: 130,
                                color: _colorAnimation.value,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: _colorAnimation.value.withOpacity(0.5),
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Success animation with checkmark
                    AnimatedBuilder(
                      animation: _scaleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getLevelColor(currentLevel).withOpacity(0.15),
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 60,
                              color: _getLevelColor(currentLevel),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // Bouncing title text with better animation
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value * 0.2),
                          child: Column(
                            children: [
                              Text(
                                '${_getLevelTitle(currentLevel)}',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(currentLevel),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: _getLevelColor(currentLevel).withOpacity(0.4),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Complete! 🎉',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: _getLevelColor(currentLevel).withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Action buttons
                    Column(
                      children: [
                        // Next level button
                        if (currentLevel < _totalLevels)
                          ElevatedButton(
                            onPressed: () {
                              _goToNextLevel();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getLevelColor(currentLevel),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                              shadowColor: _getLevelColor(currentLevel).withOpacity(0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Next Level',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(Icons.arrow_forward_ios, size: 18), // Matching arrow style
                              ],
                            ),
                          ),
                        
                        if (currentLevel < _totalLevels)
                          const SizedBox(height: 15),
                        
                        // Home button
                        OutlinedButton(
                          onPressed: () {
                            _goToHomeScreen();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _getLevelColor(currentLevel),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            side: BorderSide(
                              color: _getLevelColor(currentLevel),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home, size: 20),
                              const SizedBox(width: 10),
                              const Text(
                                'Back to Home',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Score display (optional - add if you have scoring system)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(currentLevel).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '★ Level Complete! ★',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getLevelColor(currentLevel),
                          letterSpacing: 2,
                        ),
                      ),
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
                                1, level1Questions.length, 'Madali'),
                            _buildAnimatedLevelScoreRow(
                                2, level2Questions.length, 'Madali-Kat.'),
                            _buildAnimatedLevelScoreRow(
                                3, level3Questions.length, 'Katamtaman'),
                            _buildAnimatedLevelScoreRow(
                                4, level4Questions.length, 'Medyo Mahirap'),
                            _buildAnimatedLevelScoreRow(
                                5, level5Questions.length, 'Mahirap'),
                            _buildAnimatedLevelScoreRow(
                                6, level6Questions.length, 'Mas Mahirap'),
                            _buildAnimatedLevelScoreRow(
                                7, level7Questions.length, 'Pinakamahirap'),
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
        return 'Madali (Basic)';
      case 2:
        return 'Madali-Katamtaman';
      case 3:
        return 'Katamtaman';
      case 4:
        return 'Medyo Mahirap';
      case 5:
        return 'Mahirap';
      case 6:
        return 'Mas Mahirap';
      case 7:
        return 'Pinakamahirap';
      default:
        return 'Madali';
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.purple;
      case 6:
        return Colors.red;
      case 7:
        return Colors.black;
      default:
        return Colors.green;
    }
  }

  void _showLevelResults() {
    // Calculate score for current level
    int score = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (_checkAnswer(
          userAnswers[i] ?? '', currentLevelQuestions[i]['correctAnswer'])) {
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
