import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ar_capstone2/services/ARAudioservice.dart';
import 'package:audioplayers/audioplayers.dart';

class ARGamesPage extends StatefulWidget {
  const ARGamesPage({super.key});

  @override
  State<ARGamesPage> createState() => _ARGamesPageState();
}

class _ARGamesPageState extends State<ARGamesPage> {
  bool _isGameActive = false;
  bool _isGameCompleted = false;
  String _currentDifficulty = 'easy';

  int _score = 0;
  int _moves = 0;
  int _matchesFound = 0;
  int _timeElapsed = 0;
  Timer? _gameTimer;

  List<VegetableCard> _cards = [];
  int? _firstSelectedIndex;
  int? _secondSelectedIndex;
  bool _canClick = true;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  final AudioService _audioService = AudioService();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioInitialized = false;

  int _hintsAvailable = 0;
  int _consecutiveMatches = 0;
  int _currentCombo = 0;

  final Map<String, Map<String, dynamic>> _vegetables = {
    'singkamas': {
      'name': 'Singkamas',
      'english': 'Jicama',
      'image': 'assets/images/ss.png',
      'trivia':
          'Jicama is rich in vitamin C and fiber. It can be eaten raw in salads or cooked in stir-fries.',
      'growing':
          'Jicama grows well in sandy loam soil with good drainage. It takes four to six months to mature.',
      'health':
          'Jicama helps digestion, boosts immunity, and is low in calories.',
      'history':
          'Jicama originated in Mexico and Central America. It was introduced to the Philippines by Spanish traders and became a popular root vegetable in Filipino cuisine.'
    },
    'talong': {
      'name': 'Talong',
      'english': 'Eggplant',
      'image': 'assets/images/talong.png',
      'trivia':
          'Eggplants are technically berries and come in various colors and shapes.',
      'growing':
          'Eggplant thrives in warm climate. It requires regular watering and well-drained soil.',
      'health':
          'Eggplant is rich in antioxidants and may help control blood sugar.',
      'history':
          'Eggplant originated in India and was introduced to the Philippines through trade with neighboring Asian countries. It has been cultivated in the Philippines for centuries.'
    },
    'sigarilyas': {
      'name': 'Sigarilyas',
      'english': 'Winged Bean',
      'image': 'assets/images/sigarilyas.png',
      'trivia':
          'All parts of winged bean are edible - pods, leaves, flowers, and roots.',
      'growing':
          'Winged bean is a climbing plant that needs support. It grows best in tropical climates.',
      'health':
          'Winged bean is high in protein and contains various vitamins and minerals.',
      'history':
          'Winged bean is native to New Guinea and Southeast Asia. It has been cultivated in the Philippines for generations and is valued for its nutritional content.'
    },
    'mani': {
      'name': 'Mani',
      'english': 'Peanut',
      'image': 'assets/images/mani.png',
      'trivia': 'Peanuts grow underground and are actually legumes, not nuts.',
      'growing':
          'Peanuts require loose, well-drained soil. Harvest when leaves turn yellow.',
      'health':
          'Peanuts are a good source of protein, healthy fats, and various vitamins.',
      'history':
          'Peanuts originated in South America and were brought to the Philippines by Spanish traders during the colonial period. They became a staple crop and are used in many Filipino dishes.'
    },
    'sitaw': {
      'name': 'Sitaw',
      'english': 'String Beans',
      'image': 'assets/images/sitaw.png',
      'trivia':
          'String beans are also known as yardlong beans due to their length.',
      'growing':
          'String beans are fast-growing climbing plants. They produce beans within sixty to seventy days.',
      'health':
          'String beans are rich in fiber, vitamin C, and folate. They help in weight management.',
      'history':
          'String beans are native to Southeast Asia and have been cultivated in the Philippines for centuries. They are a common ingredient in Filipino vegetable dishes.'
    },
    'bataw': {
      'name': 'Bataw',
      'english': 'Hyacinth Bean',
      'image': 'assets/images/bataw.png',
      'trivia':
          'Bataw beans must be cooked thoroughly as raw beans can be toxic.',
      'growing':
          'Bataw is a drought-resistant vine that grows well in tropical regions.',
      'health': 'Bataw is a good source of protein and essential amino acids.',
      'history':
          'Hyacinth bean is native to Africa and was introduced to the Philippines through trade. It has been cultivated in the country for its edible beans and ornamental value.'
    },
    'patani': {
      'name': 'Patani',
      'english': 'Lima Bean',
      'image': 'assets/images/patani.png',
      'trivia': 'Lima beans are named after the capital city of Peru.',
      'growing':
          'Lima beans prefer warm weather and well-drained soil. They fix nitrogen in soil.',
      'health':
          'Lima beans are high in fiber, protein, and important minerals like manganese.',
      'history':
          'Lima beans originated in Central and South America. They were introduced to the Philippines during the Spanish colonial period and have been adapted to local growing conditions.'
    },
    'kundol': {
      'name': 'Kundol',
      'english': 'Winter Melon',
      'image': 'assets/images/kun.png',
      'trivia': 'Winter melon can be stored for long periods, hence the name.',
      'growing':
          'Winter melon is a spreading vine that requires ample space. Harvest when mature.',
      'health':
          'Winter melon is low in calories, high in water content, and contains vitamin C.',
      'history':
          'Winter melon originated in Southeast Asia and has been cultivated in the Philippines for centuries. It is commonly used in soups and traditional medicines.'
    },
    'patola': {
      'name': 'Patola',
      'english': 'Sponge Gourd',
      'image': 'assets/images/pat.png',
      'trivia':
          'When dried, patola becomes the loofah sponge used for bathing.',
      'growing':
          'Patola is a fast-growing vine that needs trellis support. Harvest young.',
      'health':
          'Patola is rich in vitamin A and C, helps in digestion and skin health.',
      'history':
          'Sponge gourd is native to Asia and has been cultivated in the Philippines for generations. It is valued both as a food source and for its utility when dried.'
    },
    'upo': {
      'name': 'Upo',
      'english': 'Bottle Gourd',
      'image': 'assets/images/upo.png',
      'trivia':
          'Dried upo shells are used as containers, musical instruments, and crafts.',
      'growing':
          'Upo is a vigorous climber that produces large fruits. It needs strong support.',
      'health':
          'Upo is very low in calories, helps in hydration and weight loss.',
      'history':
          'Bottle gourd is one of the oldest cultivated plants, originating in Africa. It was introduced to the Philippines through ancient trade routes and has become a common vegetable in Filipino cuisine.'
    },
    'kalabasa': {
      'name': 'Kalabasa',
      'english': 'Squash',
      'image': 'assets/images/kalabasa.png',
      'trivia':
          'Squash flowers are also edible and often used in Filipino cuisine.',
      'growing':
          'Squash is a spreading vine that produces large fruits. It is drought tolerant.',
      'health':
          'Squash is rich in beta-carotene, vitamin C, and fiber. It is good for eye health.',
      'history':
          'Squash originated in the Americas and was introduced to the Philippines during the Spanish colonial period. It has become a staple vegetable in Filipino dishes.'
    },
    'labanos': {
      'name': 'Labanos',
      'english': 'Radish',
      'image': 'assets/images/labanos.png',
      'trivia':
          'Radishes come in various colors - red, white, black, and even purple.',
      'growing':
          'Radish is a fast-growing root vegetable. Ready to harvest in three to four weeks.',
      'health':
          'Radish contains antioxidants and supports liver function and digestion.',
      'history':
          'Radish originated in Asia and has been cultivated in the Philippines for centuries. It is commonly used in salads and as a condiment in Filipino cuisine.'
    },
    'mustasa': {
      'name': 'Mustasa',
      'english': 'Mustard Greens',
      'image': 'assets/images/mustasa.png',
      'trivia':
          'Mustard greens have a peppery flavor that mellows when cooked.',
      'growing':
          'Mustard greens are cool-season crops that grow quickly. They can be harvested multiple times.',
      'health':
          'Mustard greens are high in vitamins K, A, and C. They support bone and eye health.',
      'history':
          'Mustard greens originated in the Himalayan region and were introduced to the Philippines through trade. They have become a popular leafy vegetable in Filipino cooking.'
    },
    'sibuyas': {
      'name': 'Sibuyas',
      'english': 'Onion',
      'image': 'assets/images/sibuyas.png',
      'trivia':
          'Onions make you cry because of sulfuric compounds released when cut.',
      'growing':
          'Onions are grown from sets or seeds. They require well-drained soil and full sun.',
      'health':
          'Onions contain antioxidants and compounds with anti-inflammatory effects.',
      'history':
          'Onions originated in Central Asia and were introduced to the Philippines by Spanish traders. They have become an essential ingredient in Filipino cuisine, used in countless dishes.'
    },
    'bawang': {
      'name': 'Bawang',
      'english': 'Garlic',
      'image': 'assets/images/bawang.png',
      'trivia':
          'Garlic has been used for both culinary and medicinal purposes for centuries.',
      'growing':
          'Garlic is planted as individual cloves. Harvest when tops begin to dry and fall over.',
      'health':
          'Garlic is known for its antimicrobial properties and cardiovascular benefits.',
      'history':
          'Garlic originated in Central Asia and was introduced to the Philippines during the Spanish colonial period. It has become a fundamental ingredient in Filipino cooking, valued for its flavor and medicinal properties.'
    },
    'linga': {
      'name': 'Linga',
      'english': 'Sesame',
      'image': 'assets/images/linga.png',
      'trivia':
          'Sesame seeds are one of the oldest oilseed crops known to humanity.',
      'growing':
          'Sesame is a tropical plant that produces small seeds in pods.',
      'health':
          'Sesame is rich in healthy fats, protein, B vitamins, and minerals.',
      'history':
          'Sesame is one of the oldest cultivated plants, originating in Africa. It was introduced to the Philippines through ancient trade routes and has been used in Filipino cuisine for both its seeds and oil.'
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAudio();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _flutterTts.stop();
    _audioPlayer.dispose();
    _audioService.onTTSComplete();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        setState(() {
          _isSpeaking = true;
        });
      });

      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
        _audioService.onTTSComplete();
      });

      _flutterTts.setErrorHandler((msg) {
        setState(() {
          _isSpeaking = false;
        });
        _audioService.onTTSComplete();
        print("TTS Error: $msg");
      });
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _audioInitialized = true;
    } catch (e) {
      print("Error initializing audio: $e");
      _audioInitialized = false;
    }
  }

  Future<void> _playSound(String soundFile) async {
    if (!_audioInitialized) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      print("Error playing sound $soundFile: $e");
    }
  }

  Future<void> _stopSpeaking() async {
    try {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      _audioService.onTTSComplete();
    } catch (e) {
      print("Error stopping TTS: $e");
    }
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _isGameCompleted = false;
      _score = 0;
      _moves = 0;
      _matchesFound = 0;
      _timeElapsed = 0;
      _hintsAvailable = 0;
      _consecutiveMatches = 0;
      _currentCombo = 0;
      _cards = _generateCards();
      _firstSelectedIndex = null;
      _secondSelectedIndex = null;
      _canClick = true;
    });

    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameActive && !_isGameCompleted) {
        setState(() {
          _timeElapsed++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  List<VegetableCard> _generateCards() {
    final List<VegetableCard> cards = [];
    final List<String> vegetableKeys = _vegetables.keys.toList();

    int pairCount;
    switch (_currentDifficulty) {
      case 'easy':
        pairCount = 6;
        break;
      case 'medium':
        pairCount = 8;
        break;
      case 'hard':
        pairCount = 12;
        break;
      default:
        pairCount = 6;
    }

    vegetableKeys.shuffle();
    final selectedVegetables = vegetableKeys.take(pairCount).toList();

    for (String vegKey in selectedVegetables) {
      final vegetable = _vegetables[vegKey]!;
      cards.add(VegetableCard(
        key: ValueKey('$vegKey-1'),
        vegetableKey: vegKey,
        name: vegetable['name']!,
        english: vegetable['english']!,
        image: vegetable['image']!,
        isFlipped: false,
        isMatched: false,
      ));
      cards.add(VegetableCard(
        key: ValueKey('$vegKey-2'),
        vegetableKey: vegKey,
        name: vegetable['name']!,
        english: vegetable['english']!,
        image: vegetable['image']!,
        isFlipped: false,
        isMatched: false,
      ));
    }

    cards.shuffle();
    return cards;
  }

  void _onCardTap(int index) {
    if (!_canClick ||
        _cards[index].isFlipped ||
        _cards[index].isMatched ||
        !_isGameActive ||
        index == _firstSelectedIndex) {
      return;
    }

    setState(() {
      _cards[index] = _cards[index].copyWith(isFlipped: true);

      if (_firstSelectedIndex == null) {
        _firstSelectedIndex = index;
      } else if (_secondSelectedIndex == null) {
        _secondSelectedIndex = index;
        _moves++;
        _checkForMatch();
      }
    });
  }

  void _checkForMatch() {
    _canClick = false;

    if (_cards[_firstSelectedIndex!].vegetableKey ==
        _cards[_secondSelectedIndex!].vegetableKey) {
      _playSound('audio/correct.mp3');

      int timeBonus = (300 - _timeElapsed) ~/ 10;
      if (timeBonus > 0) {
        setState(() {
          _score += timeBonus * 20;
        });
      }

      _handleMatch();
    } else {
      _playSound('audio/error.mp3');

      _handleNoMatch();
    }
  }

  void _handleMatch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _cards[_firstSelectedIndex!] =
            _cards[_firstSelectedIndex!].copyWith(isMatched: true);
        _cards[_secondSelectedIndex!] =
            _cards[_secondSelectedIndex!].copyWith(isMatched: true);

        _matchesFound++;

        _consecutiveMatches++;
        _currentCombo = _consecutiveMatches;

        int comboBonus = 0;
        if (_consecutiveMatches >= 2) {
          comboBonus = 50 * (_consecutiveMatches - 1);

          if (_consecutiveMatches == 2) {
            _hintsAvailable += 1;
          } else if (_consecutiveMatches >= 3) {
            _hintsAvailable += 1;
          }
        }

        _score += 100 + comboBonus;

        _firstSelectedIndex = null;
        _secondSelectedIndex = null;
        _canClick = true;

        if (_matchesFound * 2 == _cards.length) {
          _endGame();
        }
      });
    });
  }

  void _handleNoMatch() {
    _consecutiveMatches = 0;
    _currentCombo = 0;

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _cards[_firstSelectedIndex!] =
            _cards[_firstSelectedIndex!].copyWith(isFlipped: false);
        _cards[_secondSelectedIndex!] =
            _cards[_secondSelectedIndex!].copyWith(isFlipped: false);

        _firstSelectedIndex = null;
        _secondSelectedIndex = null;
        _canClick = true;
      });
    });
  }

  void _useHint() {
    if (_hintsAvailable <= 0 || !_isGameActive || _cards.isEmpty) {
      return;
    }

    List<int> availableIndices = [];
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isMatched && !_cards[i].isFlipped) {
        availableIndices.add(i);
      }
    }

    if (availableIndices.isEmpty) {
      return;
    }

    setState(() {
      _hintsAvailable--;
    });

    availableIndices.shuffle();
    int hintIndex = availableIndices.first;

    if (_firstSelectedIndex != null) {
      if (_cards[hintIndex].vegetableKey ==
          _cards[_firstSelectedIndex!].vegetableKey) {
        _secondSelectedIndex = hintIndex;
        _moves++;
        _checkForMatch();
      } else {
        setState(() {
          _cards[hintIndex] = _cards[hintIndex].copyWith(isFlipped: true);
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_cards[hintIndex].isMatched) {
            setState(() {
              _cards[hintIndex] = _cards[hintIndex].copyWith(isFlipped: false);
            });
          }
        });
      }
    } else {
      setState(() {
        _cards[hintIndex] = _cards[hintIndex].copyWith(isFlipped: true);
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_cards[hintIndex].isMatched) {
          setState(() {
            _cards[hintIndex] = _cards[hintIndex].copyWith(isFlipped: false);
          });
        }
      });
    }
  }

  void _endGame() {
    setState(() {
      _isGameCompleted = true;
      _isGameActive = false;
    });

    _gameTimer?.cancel();
    _stopSpeaking();

    int timeBonus = (300 - _timeElapsed) ~/ 10;
    if (timeBonus > 0) {
      _score += timeBonus * 20;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _showGameCompletionDialog();
    });
  }

  void _showGameCompletionDialog() {
    _stopSpeaking();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Congratulations! 🎉',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'You completed the ${_currentDifficulty.toUpperCase()} level!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.brown[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildScoreRow('Final Score', '$_score points'),
                      _buildScoreRow('Time', '$_timeElapsed seconds'),
                      _buildScoreRow('Moves', '$_moves moves'),
                      _buildScoreRow('Matches', '$_matchesFound pairs'),
                      _buildScoreRow('Max Combo', '$_currentCombo×'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Great job matching all the Bahay Kubo vegetables!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Play Again'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isGameActive = false;
                            _isGameCompleted = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[500],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Change Level'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _changeDifficulty(String difficulty) {
    setState(() {
      _currentDifficulty = difficulty;
    });
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[800]!,
            Colors.green[600]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Match-A-Veggie: Bahay Kubo Edition',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem('Score', '$_score'),
                _buildStatItem('Time', '$_timeElapsed s'),
                _buildStatItem('Moves', '$_moves'),
                _buildStatItem('Matches', '$_matchesFound'),
                _buildStatItem('Hints', '$_hintsAvailable'),
                if (_currentCombo > 1)
                  _buildStatItem('Combo', '$_currentCombo×'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.brown[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.games,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Select Difficulty:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDifficultyButton(
                  'Easy', '6 pairs', 'easy', Icons.child_care),
              _buildDifficultyButton(
                  'Medium', '8 pairs', 'medium', Icons.person),
              _buildDifficultyButton(
                  'Hard', '12 pairs', 'hard', Icons.psychology),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
      String title, String subtitle, String difficulty, IconData icon) {
    bool isSelected = _currentDifficulty == difficulty;
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => _changeDifficulty(difficulty),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.green[700] : Colors.brown[100],
            foregroundColor: isSelected ? Colors.white : Colors.brown[800],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? Colors.green[900]! : Colors.brown[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            elevation: isSelected ? 3 : 1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.brown[700],
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.brown[800],
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : Colors.brown[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameGrid() {
    int crossAxisCount;
    double childAspectRatio;
    double padding;
    double crossAxisSpacing;
    double mainAxisSpacing;

    switch (_currentDifficulty) {
      case 'easy':
        crossAxisCount = 3;
        childAspectRatio = 0.75;
        padding = 12.0;
        crossAxisSpacing = 6.0;
        mainAxisSpacing = 6.0;
        break;
      case 'medium':
        crossAxisCount = 4;
        childAspectRatio = 0.7;
        padding = 8.0;
        crossAxisSpacing = 5.0;
        mainAxisSpacing = 5.0;
        break;
      case 'hard':
        crossAxisCount = 6;
        childAspectRatio = 0.55;
        padding = 4.0;
        crossAxisSpacing = 3.0;
        mainAxisSpacing = 3.0;
        break;
      default:
        crossAxisCount = 3;
        childAspectRatio = 0.75;
        padding = 12.0;
        crossAxisSpacing = 6.0;
        mainAxisSpacing = 6.0;
    }

    return Expanded(
      child: Container(
        margin: EdgeInsets.all(padding),
        padding: EdgeInsets.all(padding / 2),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.brown[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final card = _cards[index];
            return VegetableCardWidget(
              card: card,
              onTap: () => _onCardTap(index),
              isHardMode: _currentDifficulty == 'hard',
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber[600]!,
              Colors.amber[800]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, size: 24),
              const SizedBox(width: 6),
              const Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      child: ElevatedButton(
        onPressed: _hintsAvailable > 0 ? _useHint : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _hintsAvailable > 0 ? Colors.purple[700] : Colors.grey[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          minimumSize: const Size(70, 36),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb,
              size: 16,
              color: _hintsAvailable > 0 ? Colors.yellow : Colors.white,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Hint ($_hintsAvailable)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComboDisplay() {
    if (_currentCombo < 2) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange[600]!,
            Colors.red[600]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            color: Colors.yellow[100],
            size: 14,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$_currentCombo×',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Match-A-Veggie',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isSpeaking)
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white),
              onPressed: _stopSpeaking,
              tooltip: 'Stop Voice',
            ),
          if (_isGameActive) ...[
            _buildComboDisplay(),
            _buildHintButton(),
          ],
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[100]!,
              Colors.brown[100]!,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildGameHeader(),
            if (!_isGameActive && !_isGameCompleted) _buildDifficultySelector(),
            if (_isGameActive) _buildGameGrid(),
            if (!_isGameActive && !_isGameCompleted) const Spacer(),
            if (!_isGameActive) _buildStartButton(),
            if (_isGameCompleted) ...[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber[700],
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Game Completed!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Final Score: $_score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildStartButton(),
            ],
          ],
        ),
      ),
    );
  }
}

class VegetableCard {
  final Key key;
  final String vegetableKey;
  final String name;
  final String english;
  final String image;
  final bool isFlipped;
  final bool isMatched;

  VegetableCard({
    required this.key,
    required this.vegetableKey,
    required this.name,
    required this.english,
    required this.image,
    required this.isFlipped,
    required this.isMatched,
  });

  VegetableCard copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) {
    return VegetableCard(
      key: key,
      vegetableKey: vegetableKey,
      name: name,
      english: english,
      image: image,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

class VegetableCardWidget extends StatelessWidget {
  final VegetableCard card;
  final VoidCallback onTap;
  final bool isHardMode;

  const VegetableCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.isHardMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isHardMode ? 8 : 12),
          color: card.isMatched
              ? Colors.green.withOpacity(0.3)
              : card.isFlipped
                  ? Colors.white
                  : Colors.green[700],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: isHardMode ? 2 : 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: card.isMatched
              ? Border.all(color: Colors.green, width: isHardMode ? 1 : 2)
              : Border.all(
                  color: Colors.brown[300]!, width: isHardMode ? 0.5 : 1),
        ),
        child: card.isFlipped || card.isMatched
            ? _buildCardFront()
            : _buildCardBack(),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isHardMode ? 8 : 12),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(isHardMode ? 2.0 : 4.0),
              child: Image.asset(
                card.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.eco,
                    color: Colors.green[400],
                    size: isHardMode ? 20 : 24,
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isHardMode ? 1.0 : 2.0),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isHardMode ? 8 : 12),
                  bottomRight: Radius.circular(isHardMode ? 8 : 12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.name,
                    style: TextStyle(
                      fontSize: isHardMode ? 7 : 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    card.english,
                    style: TextStyle(
                      fontSize: isHardMode ? 5 : 7,
                      color: Colors.brown[700],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isHardMode ? 8 : 12),
        gradient: LinearGradient(
          colors: [
            Colors.green[700]!,
            Colors.green[900]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isHardMode ? 3.0 : 4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco,
              color: Colors.white,
              size: isHardMode ? 16 : 20,
            ),
          ),
          SizedBox(height: isHardMode ? 2.0 : 4.0),
          Text(
            'Find Me!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isHardMode ? 6 : 8,
            ),
          ),
        ],
      ),
    );
  }
}
