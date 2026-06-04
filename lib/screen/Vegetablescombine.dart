import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ar_capstone2/services/ARAudioservice.dart'; // Add this import

class VegetableCombinePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const VegetableCombinePage({super.key, required this.user});

  @override
  State<VegetableCombinePage> createState() => _VegetableCombinePageState();
}

class _VegetableCombinePageState extends State<VegetableCombinePage>
    with TickerProviderStateMixin {
  List<String> selectedVegetables = [];
  String? selectedProtein;
  late FlutterTts flutterTts;
  late AnimationController _flowerController;
  late AnimationController _butterflyController;
  late Animation<double> _flowerAnimation;
  late Animation<Offset> _butterflyAnimation;
  final AudioService _audioService =
      AudioService(); // Add AudioService instance

  final Map<String, Map<String, dynamic>> dishCombinations = {
    'pinakbet': {
      'name': 'Pinakbet',
      'description':
          'A popular Filipino vegetable stew with shrimp paste and pork',
      'requiredVegetables': ['talong', 'kalabasa', 'sitaw', 'ampalaya', 'okra'],
      'protein': 'pork',
      'image': 'assets/images/pinakbet.png',
      'culturalSignificance':
          'Pinakbet represents the ingenuity of Filipino cuisine in creating flavorful dishes from simple garden vegetables and pork.',
      'origin': 'Ilocos Region',
      'commonProvinces': [
        'Ilocos Norte',
        'Ilocos Sur',
        'La Union',
        'Pangasinan',
        'Abra'
      ],
      'regionalVariations': [
        'Pinakbet Ilocano (with bagoong)',
        'Pinakbet Tagalog (with shrimp paste)',
        'Pinakbet with Lechon Kawali'
      ],
      'bestServedWith': ['Steamed rice', 'Fried fish', 'Grilled pork'],
      'seasonality': 'Year-round, but best during vegetable harvest season',
      'ttsMessage':
          'You can make Pinakbet! This traditional vegetable stew originates from the Ilocos Region and is commonly cooked throughout Northern Luzon.',
    },
    'sinigang': {
      'name': 'Sinigang',
      'description':
          'A sour soup usually made with tamarind and various vegetables with pork or chicken',
      'requiredVegetables': ['sitaw', 'labanos', 'kamatis', 'gabi', 'sili'],
      'protein': 'pork',
      'image': 'assets/images/sinigang.png',
      'culturalSignificance':
          'Sinigang is considered the national dish of the Philippines, known for its comforting sour taste and tender meat.',
      'origin': 'Tagalog Region',
      'commonProvinces': [
        'Batangas',
        'Laguna',
        'Rizal',
        'Quezon',
        'Bulacan',
        'Pampanga',
        'Nationwide'
      ],
      'regionalVariations': [
        'Sinigang na Baboy (pork)',
        'Sinigang na Hipon (shrimp)',
        'Sinigang sa Bayabas (guava)',
        'Sinigang sa Miso',
        'Sinigang sa Sampalok (tamarind)'
      ],
      'bestServedWith': ['Steamed rice', 'Fish sauce with chili', 'Fried fish'],
      'seasonality': 'Year-round comfort food',
      'ttsMessage':
          'You can make Sinigang! This beloved sour soup is the national dish of the Philippines, enjoyed throughout the country especially in Luzon provinces.',
    },
    'dinengdeng': {
      'name': 'Dinengdeng',
      'description':
          'An Ilocano vegetable dish similar to pinakbet but with bagoong and grilled fish',
      'requiredVegetables': ['kalabasa', 'sitaw', 'patola', 'ampalaya', 'okra'],
      'protein': null,
      'image': 'assets/images/dinengdeng.png',
      'culturalSignificance':
          'Dinengdeng showcases the Ilocano tradition of using fermented fish paste to enhance vegetable flavors.',
      'origin': 'Ilocos Region',
      'commonProvinces': [
        'Ilocos Norte',
        'Ilocos Sur',
        'Abra',
        'La Union',
        'Mountain Province'
      ],
      'regionalVariations': [
        'Dinengdeng with Bagoong',
        'Dinengdeng with Grilled Fish',
        'Dinengdeng with Inihaw na Baboy'
      ],
      'bestServedWith': ['Steamed rice', 'Grilled meat', 'Bagoong with chili'],
      'seasonality': 'Year-round, popular during fiestas',
      'ttsMessage':
          'You can make Dinengdeng! This authentic Ilocano dish is a staple in Northern Luzon provinces like Ilocos Norte and Ilocos Sur.',
    },
    'laswa': {
      'name': 'Laswa',
      'description':
          'A simple vegetable soup from the Visayas region with shrimp',
      'requiredVegetables': ['kalabasa', 'patola', 'sitaw', 'okra', 'talong'],
      'protein': null,
      'image': 'assets/images/laswa.png',
      'culturalSignificance':
          'Laswa represents the simple yet nutritious cooking style of the Visayan people.',
      'origin': 'Western Visayas',
      'commonProvinces': [
        'Iloilo',
        'Negros Occidental',
        'Guimaras',
        'Capiz',
        'Aklan',
        'Antique'
      ],
      'regionalVariations': [
        'Laswa with Shrimp',
        'Laswa with Fish',
        'Laswa with Pork',
        'Laswa with Crab'
      ],
      'bestServedWith': ['Steamed rice', 'Fried fish', 'Inasal na Manok'],
      'seasonality': 'Year-round, abundant vegetable dish',
      'ttsMessage':
          'You can make Laswa! This vegetable soup is a specialty of the Visayas region, particularly popular in Iloilo and Negros Occidental.',
    },
    'bulanglang': {
      'name': 'Bulanglang',
      'description':
          'A vegetable soup with a sour broth similar to sinigang with pork',
      'requiredVegetables': [
        'kalabasa',
        'sitaw',
        'patola',
        'labanos',
        'kamatis'
      ],
      'protein': 'pork',
      'image': 'assets/images/bulanglang.png',
      'culturalSignificance':
          'Bulanglang is a traditional dish that highlights the natural flavors of vegetables without overpowering spices.',
      'origin': 'Batangas',
      'commonProvinces': ['Batangas', 'Laguna', 'Cavite', 'Quezon', 'Rizal'],
      'regionalVariations': [
        'Bulanglang na Baboy',
        'Bulanglang na Manok',
        'Bulanglang with Seafood'
      ],
      'bestServedWith': ['Steamed rice', 'Bagoong Balayan', 'Tawilis'],
      'seasonality': 'Year-round, especially during rainy season',
      'ttsMessage':
          'You can make Bulanglang! This vegetable soup is a specialty of Batangas and surrounding provinces in Southern Luzon.',
    },
    'adobongSitaw': {
      'name': 'Adobong Sitaw',
      'description': 'String beans cooked in vinegar and soy sauce with pork',
      'requiredVegetables': ['sitaw', 'bawang', 'sibuyas'],
      'protein': 'pork',
      'image': 'assets/images/adobong_sitaw.png',
      'culturalSignificance':
          'Adobong Sitaw is a popular Filipino dish that combines the flavors of adobo with fresh string beans.',
      'origin': 'Tagalog Region',
      'commonProvinces': [
        'Metro Manila',
        'Bulacan',
        'Pampanga',
        'Laguna',
        'Rizal',
        'Nationwide'
      ],
      'regionalVariations': [
        'Adobong Sitaw with Pork',
        'Adobong Sitaw with Chicken',
        'Adobong Sitaw with Tofu'
      ],
      'bestServedWith': ['Steamed rice', 'Fried fish', 'Atchara'],
      'seasonality': 'Year-round, string beans are always available',
      'ttsMessage':
          'You can make Adobong Sitaw! This adobo-style vegetable dish is popular throughout the Philippines, especially in urban areas.',
    },
    'ginataangKalabasa': {
      'name': 'Ginataang Kalabasa',
      'description': 'Squash cooked in coconut milk with pork and spices',
      'requiredVegetables': ['kalabasa', 'sili', 'sitaw', 'luya'],
      'protein': 'pork',
      'image': 'assets/images/ginataang_kalabasa.png',
      'culturalSignificance':
          'This dish represents the Filipino love for coconut milk-based dishes, especially in the Bicol region.',
      'origin': 'Bicol Region',
      'commonProvinces': [
        'Albay',
        'Camarines Sur',
        'Sorsogon',
        'Camarines Norte',
        'Catanduanes',
        'Masbate'
      ],
      'regionalVariations': [
        'Ginataang Kalabasa with Shrimp',
        'Ginataang Kalabasa with Crab',
        'Ginataang Kalabasa with Malunggay'
      ],
      'bestServedWith': ['Steamed rice', 'Fried fish', 'Grilled pork'],
      'seasonality': 'Year-round, coconut and squash are abundant',
      'ttsMessage':
          'You can make Ginataang Kalabasa! This coconut milk dish is a specialty of the Bicol Region, known for its creamy and spicy flavors.',
    },
    'bicolExpress': {
      'name': 'Bicol Express',
      'description':
          'Spicy pork dish cooked in coconut milk with lots of chili peppers',
      'requiredVegetables': ['sili', 'luya', 'bawang', 'sibuyas'],
      'protein': 'pork',
      'image': 'assets/images/bicol_express.png',
      'culturalSignificance':
          'Bicol Express is a fiery dish from the Bicol region, known for its generous use of chili peppers and coconut milk.',
      'origin': 'Bicol Region',
      'commonProvinces': [
        'Albay',
        'Camarines Sur',
        'Naga City',
        'Sorsogon',
        'Camarines Norte'
      ],
      'regionalVariations': [
        'Bicol Express with Pork',
        'Bicol Express with Chicken',
        'Bicol Express with Seafood',
        'Extra Spicy Bicol Express'
      ],
      'bestServedWith': ['Steamed rice', 'Fresh vegetables', 'Buko juice'],
      'seasonality': 'Year-round, perfect with cold weather',
      'ttsMessage':
          'You can make Bicol Express! This iconic spicy dish hails from the Bicol Region, famous for its volcanic chili peppers.',
    },
    'pakbetIlocano': {
      'name': 'Pinakbet Ilocano',
      'description':
          'Ilocano-style vegetable stew with bagoong (fermented fish paste)',
      'requiredVegetables': ['ampalaya', 'talong', 'sitaw', 'okra', 'kamatis'],
      'protein': null,
      'image': 'assets/images/pakbetilocano.png',
      'culturalSignificance':
          'This version of Pinakbet uses bagoong and is a staple in Ilocano cuisine.',
      'origin': 'Ilocos Region',
      'commonProvinces': [
        'Ilocos Norte',
        'Ilocos Sur',
        'La Union',
        'Abra',
        'Pangasinan'
      ],
      'regionalVariations': [
        'Pakbet with Bagoong Isda',
        'Pakbet with Bagoong Alamang',
        'Pakbet with Inihaw na Bangus'
      ],
      'bestServedWith': ['Steamed rice', 'Grilled meat', 'Fried fish'],
      'seasonality': 'Year-round, traditional fiesta dish',
      'ttsMessage':
          'You can make Pinakbet Ilocano! This authentic version with bagoong is a favorite in the Ilocos Region.',
    },
    'tortangTalong': {
      'name': 'Tortang Talong',
      'description': 'Eggplant omelet with ground pork',
      'requiredVegetables': ['talong', 'kamatis', 'sibuyas'],
      'protein': 'pork',
      'image': 'assets/images/tortangtalong.png',
      'culturalSignificance':
          'Tortang Talong is a simple yet beloved Filipino dish, often served for breakfast or as a side dish.',
      'origin': 'Tagalog Region',
      'commonProvinces': [
        'Metro Manila',
        'Bulacan',
        'Pampanga',
        'Laguna',
        'Cavite',
        'Nationwide'
      ],
      'regionalVariations': [
        'Tortang Talong with Ground Pork',
        'Tortang Talong with Giniling',
        'Tortang Talong with Vegetables'
      ],
      'bestServedWith': ['Steamed rice', 'Banana ketchup', 'Atchara'],
      'seasonality': 'Year-round, eggplant is always available',
      'ttsMessage':
          'You can make Tortang Talong! This eggplant omelet is a breakfast favorite throughout the Philippines.',
    },
    'chopsuey': {
      'name': 'Chopsuey',
      'description': 'Filipino-style vegetable stir-fry with pork and seafood',
      'requiredVegetables': [
        'kalabasa',
        'sitaw',
        'patola',
        'kamatis',
        'sibuyas'
      ],
      'protein': 'pork',
      'image': 'assets/images/chopsuey.png',
      'culturalSignificance':
          'Chopsuey is a Filipino adaptation of a Chinese dish, showing the influence of Chinese cuisine in Filipino cooking.',
      'origin': 'Chinese-Filipino',
      'commonProvinces': [
        'Metro Manila',
        'Pampanga',
        'Cebu',
        'Davao',
        'Iloilo',
        'Baguio'
      ],
      'regionalVariations': [
        'Chopsuey Guisado',
        'Chopsuey with Quail Eggs',
        'Chopsuey with Liver'
      ],
      'bestServedWith': ['Steamed rice', 'Fried rice', 'Lumpiang Shanghai'],
      'seasonality': 'Year-round, party and celebration dish',
      'ttsMessage':
          'You can make Chopsuey! This Chinese-inspired vegetable dish is popular in urban centers across the Philippines.',
    },
    'ginisangMonggo': {
      'name': 'Ginisang Monggo',
      'description': 'Mung bean soup with vegetables and pork',
      'requiredVegetables': ['ampalaya', 'sili', 'bawang', 'sibuyas'],
      'protein': 'pork',
      'image': 'assets/images/ginisang_monggo.png',
      'culturalSignificance':
          'Ginisang Monggo is a staple dish in Filipino households, especially during Lent.',
      'origin': 'Throughout the Philippines',
      'commonProvinces': [
        'Nationwide',
        'All provinces',
        'Especially during Lent'
      ],
      'regionalVariations': [
        'Ginisang Monggo with Chicharon',
        'Ginisang Monggo with Tinapa',
        'Ginisang Monggo with Dilis'
      ],
      'bestServedWith': ['Steamed rice', 'Fried fish', 'Inihaw na Baboy'],
      'seasonality': 'Year-round, especially Fridays during Lent',
      'ttsMessage':
          'You can make Ginisang Monggo! This mung bean soup is a nationwide favorite, especially popular during Lenten season.',
    },
    'laing': {
      'name': 'Laing',
      'description': 'Taro leaves cooked in coconut milk and pork',
      'requiredVegetables': ['gabi', 'sili', 'luya', 'bawang'],
      'protein': 'pork',
      'image': 'assets/images/laing.png',
      'culturalSignificance':
          'Laing is a Bicolano dish known for its spicy and creamy flavor.',
      'origin': 'Bicol Region',
      'commonProvinces': [
        'Albay',
        'Camarines Sur',
        'Catanduanes',
        'Sorsogon',
        'Camarines Norte'
      ],
      'regionalVariations': [
        'Laing with Pork',
        'Laing with Shrimp',
        'Laing with Dried Fish',
        'Laing with Coconut Cream'
      ],
      'bestServedWith': ['Steamed rice', 'Grilled meat', 'Fresh vegetables'],
      'seasonality': 'Year-round, taro leaves are abundant',
      'ttsMessage':
          'You can make Laing! This taro leaf dish is another famous specialty from the Bicol Region.',
    },
    'utanBisaya': {
      'name': 'Utan Bisaya',
      'description': 'A simple vegetable soup from Cebu with fish',
      'requiredVegetables': [
        'kalabasa',
        'talong',
        'sitaw',
        'patola',
        'kamatis'
      ],
      'protein': null,
      'image': 'assets/images/utanbisaya.png',
      'culturalSignificance':
          'Utan Bisaya is a humble yet nutritious dish that represents the simple cooking style of the Visayan people.',
      'origin': 'Cebu',
      'commonProvinces': ['Cebu', 'Bohol', 'Negros Oriental', 'Leyte', 'Samar'],
      'regionalVariations': [
        'Utan with Fish',
        'Utan with Shrimp',
        'Utan with Pork',
        'Utan with Chicken'
      ],
      'bestServedWith': ['Steamed rice', 'Fried fish', 'Grilled seafood'],
      'seasonality': 'Year-round, daily vegetable dish',
      'ttsMessage':
          'You can make Utan Bisaya! This vegetable soup is a staple in Cebuano households throughout Central Visayas.',
    },
    'tinola': {
      'name': 'Tinola',
      'description': 'Chicken soup with green papaya and chili leaves',
      'requiredVegetables': ['patola', 'luya', 'sili', 'malunggay'],
      'protein': 'chicken',
      'image': 'assets/images/tinola.png',
      'culturalSignificance':
          'Tinola is a comforting Filipino soup dish often served to those feeling unwell, similar to chicken soup in Western cultures.',
      'origin': 'Tagalog Region',
      'commonProvinces': [
        'Nationwide',
        'All regions',
        'Especially Luzon provinces'
      ],
      'regionalVariations': [
        'Tinola with Chicken',
        'Tinola with Fish',
        'Tinola with Pork',
        'Tinola with Sayote'
      ],
      'bestServedWith': ['Steamed rice', 'Fish sauce with calamansi', 'Patis'],
      'seasonality': 'Year-round, especially during rainy days',
      'ttsMessage':
          'You can make Tinola! This comforting chicken soup is a nationwide favorite, often called the Filipino chicken soup.',
    },
    'afritada': {
      'name': 'Afritada',
      'description': 'Chicken stewed in tomato sauce with vegetables',
      'requiredVegetables': ['kamatis', 'kalabasa', 'sitaw', 'patola'],
      'protein': 'chicken',
      'image': 'assets/images/afritada.png',
      'culturalSignificance':
          'Afritada is a Spanish-influenced Filipino dish that showcases the love for tomato-based stews.',
      'origin': 'Spanish-Filipino',
      'commonProvinces': [
        'Metro Manila',
        'Pampanga',
        'Cavite',
        'Laguna',
        'Cebu',
        'Davao'
      ],
      'regionalVariations': [
        'Afritada with Chicken',
        'Afritada with Pork',
        'Afritada with Beef',
        'Afritada with Liver'
      ],
      'bestServedWith': ['Steamed rice', 'Garlic rice', 'Pan de sal'],
      'seasonality': 'Year-round, celebration dish',
      'ttsMessage':
          'You can make Afritada! This Spanish-inspired stew is popular in urban areas and served during special occasions.',
    },
  };

  final Map<String, Map<String, dynamic>> vegetableInfo = {
    'singkamas': {
      'name': 'Singkamas',
      'english': 'Jicama',
      'image': 'assets/images/singkmas.png',
    },
    'talong': {
      'name': 'Talong',
      'english': 'Eggplant',
      'image': 'assets/images/talong.png',
    },
    'sigarilyas': {
      'name': 'Sigarilyas',
      'english': 'Winged Bean',
      'image': 'assets/images/sigarilyas.png',
    },
    'mani': {
      'name': 'Mani',
      'english': 'Peanut',
      'image': 'assets/images/mani.png',
    },
    'sitaw': {
      'name': 'Sitaw',
      'english': 'String Bean',
      'image': 'assets/images/sitaw.png',
    },
    'bataw': {
      'name': 'Bataw',
      'english': 'Hyacinth Bean',
      'image': 'assets/images/bataw.png',
    },
    'patani': {
      'name': 'Patani',
      'english': 'Lima Bean',
      'image': 'assets/images/patani.png',
    },
    'kundol': {
      'name': 'Kundol',
      'english': 'Winter Melon',
      'image': 'assets/images/kundol.png',
    },
    'patola': {
      'name': 'Patola',
      'english': 'Sponge Gourd',
      'image': 'assets/images/patola.png',
    },
    'upo': {
      'name': 'Upo',
      'english': 'Bottle Gourd',
      'image': 'assets/images/upo.png',
    },
    'kalabasa': {
      'name': 'Kalabasa',
      'english': 'Squash',
      'image': 'assets/images/kalabasa.png',
    },
    'labanos': {
      'name': 'Labanos',
      'english': 'Radish',
      'image': 'assets/images/labanos.png',
    },
    'mustasa': {
      'name': 'Mustasa',
      'english': 'Mustard Greens',
      'image': 'assets/images/mustasa.png',
    },
    'sibuyas': {
      'name': 'Sibuyas',
      'english': 'Onion',
      'image': 'assets/images/sibuyas.png',
    },
    'kamatis': {
      'name': 'Kamatis',
      'english': 'Tomato',
      'image': 'assets/images/kamatis.png',
    },
    'bawang': {
      'name': 'Bawang',
      'english': 'Garlic',
      'image': 'assets/images/bawang.png',
    },
    'luya': {
      'name': 'Luya',
      'english': 'Ginger',
      'image': 'assets/images/luya.png',
    },
    'linga': {
      'name': 'Linga',
      'english': 'Sesame',
      'image': 'assets/images/linga.png',
    },
    'ampalaya': {
      'name': 'Ampalaya',
      'english': 'Bitter Gourd',
      'image': 'assets/images/ampalaya.png',
    },
    'okra': {
      'name': 'Okra',
      'english': 'Okra',
      'image': 'assets/images/okra.png',
    },
    'gabi': {
      'name': 'Gabi',
      'english': 'Taro',
      'image': 'assets/images/gabi.png',
    },
    'sili': {
      'name': 'Sili',
      'english': 'Chili Pepper',
      'image': 'assets/images/sili.png',
    },
    'malunggay': {
      'name': 'Malunggay',
      'english': 'Moringa',
      'image': 'assets/images/malunggay.png',
    },
  };

  final Map<String, Map<String, dynamic>> proteinOptions = {
    'pork': {
      'name': 'Pork',
      'image': 'assets/images/pork.png',
    },
    'chicken': {
      'name': 'Chicken',
      'image': 'assets/images/chicken.png',
    },
  };

  List<Map<String, dynamic>> suggestedDishes = [];

  @override
  void initState() {
    super.initState();
    initTts();
    _flowerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _butterflyController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _flowerAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _flowerController,
        curve: Curves.easeInOut,
      ),
    );

    _butterflyAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.3),
      end: const Offset(1.0, 0.1),
    ).animate(
      CurvedAnimation(
        parent: _butterflyController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _flowerController.dispose();
    _butterflyController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> initTts() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    // Setup TTS completion handler
    flutterTts.setCompletionHandler(() {
      // When TTS completes, restore background music
      _audioService.onTTSComplete();
    });

    // Setup TTS error handler
    flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      // Restore background music on error too
      _audioService.onTTSComplete();
    });
  }

  Future<void> _speak(String text) async {
    try {
      // Notify audio service that TTS is starting
      await _audioService.onTTSStart();

      // Speak the text
      await flutterTts.speak(text);

      // The completion handler will call onTTSComplete automatically
    } catch (e) {
      print('Error with TTS: $e');
      // Restore background music on error
      await _audioService.onTTSComplete();
    }
  }

  Future<void> _stopTTS() async {
    try {
      await flutterTts.stop();
      await _audioService.onTTSComplete();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightGreen[100]!,
                  Colors.green[200]!,
                  Colors.brown[100]!,
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            child: AnimatedBuilder(
              animation: _flowerAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _flowerAnimation.value,
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.pink[300],
                    size: 40,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 200,
            right: 30,
            child: AnimatedBuilder(
              animation: _flowerAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _flowerAnimation.value,
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.yellow[300],
                    size: 35,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 150,
            right: 60,
            child: AnimatedBuilder(
              animation: _flowerAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _flowerAnimation.value,
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.purple[300],
                    size: 30,
                  ),
                );
              },
            ),
          ),
          SlideTransition(
            position: _butterflyAnimation,
            child: Icon(
              Icons.emoji_nature,
              color: Colors.orange[300],
              size: 30,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Vegetable Garden',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create Your Filipino Dish!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select vegetables and protein to see what Filipino dish you can make. Try different combinations!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[100],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
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
                          Icon(Icons.set_meal, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Select Protein (Optional):',
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProteinOption('None', null, null),
                          _buildProteinOption(
                              'Pork', 'pork', 'assets/images/pork.png'),
                          _buildProteinOption('Chicken', 'chicken',
                              'assets/images/chicken.png'),
                        ],
                      ),
                    ],
                  ),
                ),
                if (selectedVegetables.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
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
                            Icon(Icons.eco, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Selected Vegetables:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: selectedVegetables.map((vegKey) {
                            final veg = vegetableInfo[vegKey]!;
                            return Chip(
                              label: Text(veg['name']),
                              avatar: CircleAvatar(
                                backgroundImage: AssetImage(veg['image']),
                                backgroundColor: Colors.white,
                              ),
                              backgroundColor: Colors.green[100],
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  selectedVegetables.remove(vegKey);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _checkCombination,
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('See Result'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: vegetableInfo.length,
                      itemBuilder: (context, index) {
                        final vegKey = vegetableInfo.keys.elementAt(index);
                        final veg = vegetableInfo[vegKey]!;
                        final isSelected = selectedVegetables.contains(vegKey);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedVegetables.remove(vegKey);
                              } else {
                                selectedVegetables.add(vegKey);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green[100]
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green[700]!
                                    : Colors.brown[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      veg['image'],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  veg['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.green[800]
                                        : Colors.brown[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  veg['english'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProteinOption(String name, String? value, String? image) {
    final isSelected = selectedProtein == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProtein = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green[700]! : Colors.brown[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green[800] : Colors.brown[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkCombination() {
    suggestedDishes.clear();

    for (final dishEntry in dishCombinations.entries) {
      final dishKey = dishEntry.key;
      final dish = dishEntry.value;
      final requiredVegs = List<String>.from(dish['requiredVegetables']);
      final requiredProtein = dish['protein'];

      // Calculate matching vegetables
      final matchingVegs = requiredVegs
          .where((veg) => selectedVegetables.contains(veg))
          .toList();
      final missingVegs = requiredVegs
          .where((veg) => !selectedVegetables.contains(veg))
          .toList();

      // Calculate matching protein
      bool proteinMatches = false;
      String? missingProtein;

      if (requiredProtein == null && selectedProtein == null) {
        proteinMatches = true;
      } else if (requiredProtein != null &&
          selectedProtein == requiredProtein) {
        proteinMatches = true;
      } else if (requiredProtein != null &&
          selectedProtein != requiredProtein) {
        missingProtein = requiredProtein;
      }

      // Calculate match score based on percentage of matched vegetables
      final matchScore = matchingVegs.length / requiredVegs.length;

      // Only suggest dishes that have at least 60% matching ingredients
      if (matchScore >= 0.6) {
        // Create a modified dish entry with additional information
        final suggestedDish = Map<String, dynamic>.from(dish);
        suggestedDish['matchScore'] = matchScore;
        suggestedDish['matchingVegs'] = matchingVegs;
        suggestedDish['missingVegs'] = missingVegs;
        suggestedDish['proteinMatches'] = proteinMatches;
        suggestedDish['missingProtein'] = missingProtein;
        suggestedDish['key'] = dishKey;

        suggestedDishes.add(suggestedDish);
      }
    }

    // Sort by match score (highest first)
    suggestedDishes.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));

    // Take top 5 suggestions
    if (suggestedDishes.length > 5) {
      suggestedDishes = suggestedDishes.sublist(0, 5);
    }

    _speak(suggestedDishes.isNotEmpty
        ? "Found ${suggestedDishes.length} dish suggestions based on your selection."
        : "No dish matches your selection. Try adding more vegetables.");

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[50]!,
                Colors.brown[50]!,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                suggestedDishes.isNotEmpty
                    ? 'Dish Suggestions'
                    : 'No Dish Found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: suggestedDishes.isNotEmpty
                      ? Colors.green[800]
                      : Colors.red[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                suggestedDishes.isNotEmpty
                    ? 'Found ${suggestedDishes.length} dish${suggestedDishes.length > 1 ? 'es' : ''} that match your selection'
                    : 'No dish matches your selection',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Scrollable content for dish suggestions
              if (suggestedDishes.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: suggestedDishes
                          .map((dish) => _buildDishSuggestionCard(dish))
                          .toList(),
                    ),
                  ),
                )
              else ...[
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_food,
                        size: 80,
                        color: Colors.brown[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different combination!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No dish matches your selection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try selecting at least 3 vegetables and matching protein for better suggestions.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              // Fixed button row that stays at bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (suggestedDishes.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _stopTTS(); // Stop any ongoing TTS
                          Navigator.of(context).pop();
                          setState(() {
                            selectedVegetables.clear();
                            selectedProtein = null;
                          });
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildDishSuggestionCard(Map<String, dynamic> dish) {
  final matchPercentage = (dish['matchScore'] * 100).toInt();
  final isCompleteMatch = dish['missingVegs'].isEmpty && dish['proteinMatches'];
  final cardColors = _getCardColors(isCompleteMatch);
  
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: _buildCardDecoration(cardColors),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onDishCardTap(dish),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(dish, matchPercentage, isCompleteMatch, cardColors),
              const SizedBox(height: 8),
              _buildMatchDetails(dish, isCompleteMatch, cardColors),
              if (!isCompleteMatch) ...[
                const SizedBox(height: 12),
                _buildMissingIngredients(dish['missingVegs'], cardColors),
              ],
              const SizedBox(height: 12),
              _buildActionButton(dish, isCompleteMatch, cardColors),
            ],
          ),
        ),
      ),
    ),
  );
}

// Helper method to get card colors based on match status
Map<String, dynamic> _getCardColors(bool isCompleteMatch) {
  return {
    'primary': isCompleteMatch ? Colors.green : Colors.orange,
    'background': isCompleteMatch ? Colors.green[50] : Colors.orange[50],
    'border': isCompleteMatch ? Colors.green[300] : Colors.orange[300],
    'text': isCompleteMatch ? Colors.green[700] : Colors.orange[700],
  };
}

// Helper method to build card decoration
BoxDecoration _buildCardDecoration(Map<String, dynamic> colors) {
  return BoxDecoration(
    color: Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: colors['border']!, width: 2),
    boxShadow: [
      BoxShadow(
        color: colors['primary']!.withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// Helper method to build card header
Widget _buildCardHeader(
  Map<String, dynamic> dish,
  int matchPercentage,
  bool isCompleteMatch,
  Map<String, dynamic> colors,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          dish['name'],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
            height: 1.3,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _buildMatchBadge(matchPercentage, isCompleteMatch, colors),
    ],
  );
}

// Helper method to build match badge
Widget _buildMatchBadge(
  int matchPercentage,
  bool isCompleteMatch,
  Map<String, dynamic> colors,
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: colors['background'],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: colors['primary']!.withOpacity(0.3),
        width: 0.5,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCompleteMatch ? Icons.check_circle : Icons.trending_up,
          size: 14,
          color: colors['text'],
        ),
        const SizedBox(width: 6),
        Text(
          '$matchPercentage% Match',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors['text'],
          ),
        ),
      ],
    ),
  );
}

// Helper method to build match details
Widget _buildMatchDetails(
  Map<String, dynamic> dish,
  bool isCompleteMatch,
  Map<String, dynamic> colors,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (dish['proteinMatches'])
        _buildDetailChip(
          icon: Icons.fitness_center,
          label: 'Protein match found',
          color: Colors.green,
        ),
      if (dish['proteinMatches'] && dish['missingVegs'].isNotEmpty)
        const SizedBox(height: 6),
      if (!isCompleteMatch && dish['missingVegs'].isNotEmpty)
        Text(
          'Add these to complete:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
    ],
  );
}

// Helper method to build detail chip
Widget _buildDetailChip({
  required IconData icon,
  required String label,
  required MaterialColor color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color[700]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color[700],
          ),
        ),
      ],
    ),
  );
}

// Helper method to build missing ingredients
Widget _buildMissingIngredients(
  List<String> missingVegs,
  Map<String, dynamic> colors,
) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: missingVegs.map((veg) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors['background'],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors['primary']!.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_circle_outline,
              size: 12,
              color: colors['text'],
            ),
            const SizedBox(width: 6),
            Text(
              veg,
              style: TextStyle(
                fontSize: 12,
                color: colors['text'],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

// Helper method to build action button
Widget _buildActionButton(
  Map<String, dynamic> dish,
  bool isCompleteMatch,
  Map<String, dynamic> colors,
) {
  return Align(
    alignment: Alignment.centerRight,
    child: TextButton.icon(
      onPressed: () => _onViewRecipeTap(dish),
      icon: Icon(
        Icons.restaurant_menu,
        size: 16,
        color: colors['primary'],
      ),
      label: Text(
        isCompleteMatch ? 'View Recipe' : 'See Suggestions',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors['primary'],
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}


          // Match Information
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 16,
                color: Colors.brown[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dish['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Matching Vegetables
          if (dish['matchingVegs'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Matching Vegetables:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: dish['matchingVegs'].map<Widget>((vegKey) {
                    final veg = vegetableInfo[vegKey]!;
                    return Chip(
                      label: Text(
                        veg['name'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      avatar: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(veg['image']),
                      ),
                      backgroundColor: Colors.green[50],
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),

          // Missing Ingredients Section
          if (dish['missingVegs'].isNotEmpty || dish['missingProtein'] != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color.fromARGB(255, 198, 149, 75)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add these to complete the dish:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Missing Vegetables
                  if (dish['missingVegs'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: dish['missingVegs'].map<Widget>((vegKey) {
                            final veg = vegetableInfo[vegKey]!;
                            return Chip(
                              label: Text(
                                veg['name'],
                                style: const TextStyle(fontSize: 12),
                              ),
                              avatar: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(veg['image']),
                              ),
                              backgroundColor: Colors.orange[100],
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  // Missing Protein
                  if (dish['missingProtein'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Protein needed: ${proteinOptions[dish['missingProtein']]!['name']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Dish Information Button
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showDishDetails(dish);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                foregroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Text('View Dish Details'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDishDetails(Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green[50]!,
                  Colors.brown[50]!,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dish['name'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      dish['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.brown[400],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  dish['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[700],
                  ),
                ),
                const SizedBox(height: 16),

                // All Required Ingredients
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Required Ingredients:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Vegetables
                      Text(
                        'Vegetables:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (dish['requiredVegetables'] as List<dynamic>)
                            .map<Widget>((vegKey) {
                          final veg = vegetableInfo[vegKey]!;
                          final isSelected =
                              selectedVegetables.contains(vegKey);
                          return Chip(
                            label: Text(
                              veg['name'],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.green[800]
                                    : Colors.brown[700],
                              ),
                            ),
                            avatar: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(veg['image']),
                            ),
                            backgroundColor: isSelected
                                ? Colors.green[100]
                                : Colors.brown[50],
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),

                      // Protein
                      if (dish['protein'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Protein:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            proteinOptions[dish['protein']]!['name'],
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedProtein == dish['protein']
                                  ? Colors.green[800]
                                  : Colors.brown[700],
                            ),
                          ),
                          backgroundColor: selectedProtein == dish['protein']
                              ? Colors.green[100]
                              : Colors.brown[50],
                          side: BorderSide.none,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Educational Information
                _buildInfoRow(
                  Icons.place,
                  'Origin:',
                  dish['origin'],
                  Colors.green[700]!,
                ),
                const SizedBox(height: 8),

                if (dish['culturalSignificance'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cultural Significance:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dish['culturalSignificance'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _speak(dish['ttsMessage'] ??
                          'You can make ${dish['name']}!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up),
                        SizedBox(width: 8),
                        Text('Hear About This Dish'),
                      ],
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.brown[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
