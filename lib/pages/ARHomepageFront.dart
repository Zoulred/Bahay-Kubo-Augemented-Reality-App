import 'package:flutter/material.dart';
import 'package:ar_capstone2/pages/ARLoginscreen.dart';
import 'package:ar_capstone2/screen/ARLoginRegister.dart';
import 'package:ar_capstone2/screen/ArGOhunt.dart' show ARAdventure3DPage;
import 'package:ar_capstone2/screen/Vegetablescombine.dart';
import 'package:ar_capstone2/screen/ArScannerpage.dart';
import 'package:ar_capstone2/screen/ARWatchtuts.dart';
import 'package:ar_capstone2/screen/ArGamespage.dart';
import 'package:ar_capstone2/screen/ArQuizpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ARGuidelines.dart';
import 'ARHomepageView.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _carouselImages = [
    'assets/images/q2.png',
    'assets/images/q3.png',
    'assets/images/q4.png',
    'assets/images/q5.png',
    'assets/images/q6.png',
    'assets/images/q11.png',
  ];

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'Welcome to Bahay Kubo AR!',
      description:
          'This app helps you learn about Filipino vegetables through Augmented Reality experiences.',
      target: TutorialTarget.appBar,
    ),
    TutorialStep(
      title: 'Image Carousel',
      description:
          'Swipe down or use arrows to browse featured content. The dots show your current position.',
      target: TutorialTarget.carousel,
    ),
    TutorialStep(
      title: 'Vegetables of Bahay Kubo',
      description:
          'Learn about the 18 vegetables mentioned in the Bahay Kubo folk song. Swipe to see each vegetable.',
      target: TutorialTarget.educational,
    ),
    TutorialStep(
      title: 'AR Features',
      description:
          'Tap on any feature card to explore different AR activities like scanning, 3D placement, quizzes, adventure and games.',
      target: TutorialTarget.features,
    ),
    TutorialStep(
      title: 'Navigation Menu',
      description:
          'Tap the menu icon to access tutorials, about info, contact details, and logout option.',
      target: TutorialTarget.menu,
    ),
    TutorialStep(
      title: 'User Profile',
      description:
          'Tap your profile icon to view your account details and quickly logout.',
      target: TutorialTarget.profile,
    ),
  ];

  int _currentTutorialStep = 0;
  bool _showTutorial = false;
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _carouselKey = GlobalKey();
  final GlobalKey _educationalKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  void _checkAndShowTutorial() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showTutorial = true;
          _currentTutorialStep = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_pageController.hasClients && mounted) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _carouselImages.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  void _nextTutorialStep() {
    if (_currentTutorialStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentTutorialStep++;
      });
    } else {
      setState(() {
        _showTutorial = false;
        _currentTutorialStep = 0;
      });
    }
  }

  void _previousTutorialStep() {
    if (_currentTutorialStep > 0) {
      setState(() {
        _currentTutorialStep--;
      });
    }
  }

  void _skipTutorial() {
    setState(() {
      _showTutorial = false;
      _currentTutorialStep = 0;
    });
  }

  void _startTutorial() {
    setState(() {
      _showTutorial = true;
      _currentTutorialStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, _appBarKey, _menuKey, _showProfileDialog),
      drawer: buildDrawer(
        context,
        widget.user,
        _showProfileDialog,
        _showAboutDialog,
        _showContactDialog,
        _logout,
        _navigateToAdminScreen,
        _startTutorial,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green[50]!,
                  Colors.brown[50]!,
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      buildBahayKuboHeader(),
                      buildCarouselImage(
                        _carouselKey,
                        _pageController,
                        _currentPage,
                        _carouselImages,
                        (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      buildEducationalSection(_educationalKey),
                      const SizedBox(height: 16),
                      _buildFeaturesGrid(),
                      const SizedBox(height: 24),
                      _buildBottomLogoutButton(),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_showTutorial)
            buildTutorialOverlay(
              _tutorialSteps,
              _currentTutorialStep,
              _nextTutorialStep,
              (step) => buildTutorialContent(
                step,
                _currentTutorialStep,
                _tutorialSteps.length,
                _previousTutorialStep,
                _nextTutorialStep,
                _skipTutorial,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: _logoutWithConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        icon: const Icon(Icons.admin_panel_settings, size: 20),
        label: const Text(
          'Go to Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _logoutWithConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout from the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logoutAlternative();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logoutAlternative() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            const LoginRegisterScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  Icons.apps,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AR Experiences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            key: _featuresKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              buildFeatureCard(
                title: 'Watch Tutorials',
                description: 'Learn planting techniques',
                imagePath: 'assets/images/watch_tutorials.png',
                color: Colors.teal[700]!,
                backgroundColor: Colors.teal[50]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WatchTutorialsPage()),
                  );
                },
              ),
              buildFeatureCard(
                title: 'AR Scanner',
                description: 'Scan vegetables to learn about them',
                imagePath: 'assets/images/scan.png',
                color: const Color.fromARGB(255, 255, 255, 255),
                backgroundColor: const Color.fromARGB(255, 54, 167, 63),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ARActivityPage(user: widget.user)),
                  );
                },
              ),
              buildFeatureCard(
                title: 'AR Games',
                description: 'Vegetable matching game',
                imagePath: 'assets/images/argames.png',
                color: const Color.fromARGB(255, 255, 255, 255),
                backgroundColor: const Color.fromARGB(255, 200, 128, 211),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ARGamesPage()),
                  );
                },
              ),
              buildFeatureCard(
                title: 'AR Adventure ',
                description: 'Explore and collect vegetables in AR',
                imagePath: 'assets/images/ven.png',
                color: const Color.fromARGB(255, 255, 255, 255),
                backgroundColor: const Color.fromARGB(255, 190, 117, 128),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ARAdventure3DPage(user: widget.user),
                    ),
                  );
                },
              ),
              buildFeatureCard(
                title: 'Veggie Combine',
                description:
                    'Combine different vegetables to see the dishes you can make',
                imagePath: 'assets/images/vegetable_combine.png',
                color: const Color.fromARGB(255, 253, 253, 253),
                backgroundColor: const Color.fromARGB(255, 185, 158, 125),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VegetableCombinePage(user: widget.user),
                    ),
                  );
                },
              ),
              buildFeatureCard(
                title: 'AR Quiz',
                description: 'Test your knowledge',
                imagePath: 'assets/images/quiz1.png',
                color: const Color.fromARGB(255, 239, 240, 241),
                backgroundColor: const Color.fromARGB(255, 70, 160, 225),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ARQuizPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.brown[800]!, Colors.brown[600]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      top: 20,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          gradient: LinearGradient(
                            colors: [Colors.amber[700]!, Colors.orange[400]!],
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 20,
                      bottom: 20,
                      child: Text(
                        'User Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    buildProfileInfoRow(
                        Icons.email, 'Email', widget.user['email'] ?? ''),
                    const SizedBox(height: 12),
                    buildProfileInfoRow(
                        Icons.work, 'Role', widget.user['role'] ?? ''),
                    const SizedBox(height: 12),
                    buildProfileInfoRow(Icons.person, 'Username',
                        widget.user['username'] ?? ''),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildStatItem('12', 'Plants\nViewed'),
                          buildStatItem('5', 'AR\nSessions'),
                          buildStatItem('8h', 'Learning\nTime'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[800]!, Colors.green[600]!],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 20,
                        top: 20,
                        child: Opacity(
                          opacity: 0.2,
                          child: Icon(
                            Icons.eco,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/logo.png'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Bahay Kubo AR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bahay Kubo AR is an educational Augmented Reality app that teaches users about traditional Filipino vegetables mentioned in the Bahay Kubo folk song. Through interactive AR experiences, users can learn about the cultural significance, nutritional value, and agricultural aspects of these vegetables.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      buildSectionHeader('Development Team'),
                      const SizedBox(height: 16),
                      buildTeamMember(
                        image: 'assets/images/red.jpg',
                        name: 'Johnrey Iglesia',
                        role: 'Lead Developer & UI/UX Designer',
                      ),
                      const SizedBox(height: 12),
                      buildTeamMember(
                        image: 'assets/images/torres.jpg',
                        name: 'Clark Harries Torres',
                        role: 'Co-Developer',
                      ),
                      const SizedBox(height: 24),
                      buildTeamMember(
                        image: 'assets/images/jake.jpg',
                        name: 'Jake Soriano',
                        role: 'Tester',
                      ),
                      const SizedBox(height: 12),
                      buildSectionHeader('Advisers & Faculty'),
                      const SizedBox(height: 16),
                      buildTeamMember(
                        image: 'assets/images/Sirrdean.png',
                        name: 'FREDERICK J. SORIANO, MIT',
                        role:
                            'Chairperson & Dean,College of Information Technology',
                      ),
                      const SizedBox(height: 12),
                      buildTeamMember(
                        image: 'assets/images/SirEdr.png',
                        name: 'EDRIAN M. RAMOS, MIT',
                        role: 'Thesis Adviser',
                      ),
                      const SizedBox(height: 12),
                      buildTeamMember(
                        image: 'assets/images/pm.png',
                        name: 'PHILIP MICHAEL F. AOANAN,MIT',
                        role: 'Technical Panel',
                      ),
                      const SizedBox(height: 24),
                      buildSectionHeader('Institution'),
                      const SizedBox(height: 16),
                      buildInstitutionInfo(
                        image: 'assets/images/uep_logo.png',
                        title: 'University of Eastern Pangasinan',
                        subtitle: 'Binalonan, Pangasinan',
                      ),
                      const SizedBox(height: 12),
                      buildInstitutionInfo(
                        image: 'assets/images/it logo.png',
                        title: 'College of Information Technology',
                        subtitle:
                            'Bachelor of Science in Information Technology',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[800]!, Colors.blue[600]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      right: 20,
                      top: 20,
                      child: Icon(
                        Icons.contact_mail,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Text(
                        'Contact Us',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "We're here to help! Get in touch with us through any of the following methods:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildContactMethod(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: 'Johnreyiglesia308.com',
                      onTap: () => _launchEmail(),
                    ),
                    const SizedBox(height: 12),
                    buildContactMethod(
                      icon: Icons.phone,
                      title: 'Phone',
                      subtitle: '(0985) 456-7890',
                      onTap: () => _launchPhoneCall(),
                    ),
                    const SizedBox(height: 12),
                    buildContactMethod(
                      icon: Icons.access_time,
                      title: 'Response Time',
                      subtitle: 'Within 24 hours',
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'Johnreyiglesia308@gmail.com',
      queryParameters: {
        'subject': 'Bahay Kubo AR Support',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email client'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening email client'),
        ),
      );
    }
  }

  Future<void> _launchPhoneCall() async {
    final Uri telUri = Uri(scheme: 'tel', path: '09854567890');

    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not initiate phone call'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error initiating phone call'),
        ),
      );
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void _navigateToAdminScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            const LoginRegisterScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
