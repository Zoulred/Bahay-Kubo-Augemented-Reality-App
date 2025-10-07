import 'package:flutter/material.dart';

import '../pages/ARHomepageFront.dart';

class LoadingScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const LoadingScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  double _progress = 0.0;

  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _swayController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _swayController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _swayAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _scaleController.forward();
    _rotationController.repeat();
    _floatController.repeat(reverse: true);
    _swayController.repeat(reverse: true);

    _simulateLoading();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  void _simulateLoading() {
    const int duration = 3000;
    const int totalSteps = 100;
    const int stepDuration = duration ~/ totalSteps;

    for (int i = 0; i <= totalSteps; i++) {
      Future.delayed(Duration(milliseconds: i * stepDuration), () {
        if (mounted) {
          setState(() {
            _progress = i / totalSteps;
            if (_progress >= 1.0) {
              _isLoading = false;
            }
          });
        }
      });
    }
  }

  void _navigateToHome() {
    if (!_isLoading) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(user: widget.user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/adobe1.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.brown.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.7,
              child: Stack(
                children: [
                  _buildFloatingVegetable(
                      0.1, 0.1, 0.8, 1.2, 'assets/images/talong.png'),
                  _buildFloatingVegetable(
                      0.9, 0.2, 1.0, 1.5, 'assets/images/sitaw.png'),
                  _buildFloatingVegetable(
                      0.5, 0.7, 0.7, 1.0, 'assets/images/sibuyas.png'),
                  _buildFloatingVegetable(
                      0.3, 0.5, 1.2, 0.8, 'assets/images/kalabasa.png'),
                  _buildFloatingVegetable(
                      0.7, 0.3, 0.9, 1.3, 'assets/images/upo.png'),
                  _buildFloatingVegetable(
                      0.2, 0.8, 1.1, 0.9, 'assets/images/bawang.png'),
                  _buildFloatingVegetable(
                      0.8, 0.6, 0.8, 1.1, 'assets/images/singskamas.png'),
                  _buildFloatingVegetable(
                      0.4, 0.4, 1.0, 1.2, 'assets/images/sigarilyas.png'),
                ],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _swayAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          MediaQuery.of(context).size.width *
                              _swayAnimation.value,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.brown.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.brown[800]!,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Welcome to Bahay Kubo AR Adventure!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 30, 230, 12),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(0, 00, 000, 00),
                            Colors.brown[200]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.brown[400]!,
                          width: 4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'BAHAY KUBO',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 235, 233, 233),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.brown[300]!,
                                  Colors.brown[500]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.brown[700]!,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        _rotationAnimation.value * 2 * 3.14159,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/logo.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAnimatedVegetableImage(Colors.red[300]!, 0,
                                  'assets/images/talong.png'),
                              const SizedBox(width: 8),
                              _buildAnimatedVegetableImage(Colors.orange[300]!,
                                  100, 'assets/images/sitaw.png'),
                              const SizedBox(width: 8),
                              _buildAnimatedVegetableImage(Colors.green[300]!,
                                  200, 'assets/images/sibuyas.png'),
                              const SizedBox(width: 8),
                              _buildAnimatedVegetableImage(Colors.purple[300]!,
                                  300, 'assets/images/kalabasa.png'),
                              const SizedBox(width: 8),
                              _buildAnimatedVegetableImage(Colors.yellow[300]!,
                                  400, 'assets/images/upo.png'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'TRADITIONAL FILIPINO PRODUCE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 196, 194, 194),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value * 10),
                        child: child,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.brown[600]!,
                            Colors.brown[800]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: _isLoading
                                ? Colors.transparent
                                : const Color.fromARGB(255, 16, 206, 38)
                                    .withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.brown[900]!,
                          width: 2,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: _navigateToHome,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Enter Bahay Kubo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.brown[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.brown[300]!,
                              width: 1,
                            ),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.brown[600]!,
                                    Colors.brown[800]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isLoading
                                ? 'Loading Bahay Kubo...'
                                : 'Ready to Explore!',
                            key: ValueKey(_isLoading),
                            style: TextStyle(
                              fontSize: 16,
                              color: _isLoading
                                  ? Colors.brown[700]
                                  : const Color.fromARGB(255, 5, 232, 16),
                              fontWeight: _isLoading
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
// ==================== ANIMATED VEGETABLE IMAGE METHODS ====================

  Widget _buildAnimatedVegetableImage(
    Color color,
    int delay,
    String imagePath,
  ) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        final double opacity = _calculateOpacity(delay);
        return _buildAnimatedImage(imagePath, opacity);
      },
    );
  }

// Helper method to calculate opacity based on delay
  double _calculateOpacity(int delay) {
    double opacity = 0.0;
    final currentAnimationValue = _fadeAnimation.value * 1000;

    if (currentAnimationValue > delay) {
      opacity = (currentAnimationValue - delay) / 500;
      opacity = _clampOpacity(opacity);
    }

    return opacity;
  }

// Helper method to clamp opacity between 0 and 1
  double _clampOpacity(double opacity) {
    if (opacity > 1.0) return 1.0;
    if (opacity < 0.0) return 0.0;
    return opacity;
  }

// Helper method to build animated image widget
  Widget _buildAnimatedImage(String imagePath, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: opacity,
        child: _buildVegetableImage(imagePath),
      ),
    );
  }

// Helper method to build vegetable image with error handling
  Widget _buildVegetableImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: 22,
      height: 22,
      errorBuilder: _buildImageErrorWidget,
    );
  }

// Helper method to build error widget for image loading failures
  Widget _buildImageErrorWidget(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return const Icon(
      Icons.error,
      color: Colors.white,
      size: 14,
    );
  }

  Widget _buildFloatingVegetable(double leftFactor, double topFactor,
      double size, double speed, String imagePath) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * leftFactor,
          top: MediaQuery.of(context).size.height * topFactor -
              (_floatAnimation.value * 120),
          child: Transform.rotate(
            angle: _floatAnimation.value * 2 * 3.14159 * speed,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 20 + size * 12,
              height: 20 + size * 12,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image,
                  color: const Color.fromARGB(0, 158, 158, 158),
                  size: 20 + size * 12,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
