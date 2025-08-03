import 'package:flutter/material.dart';
import 'package:ar_capstone2/screen/ARTutorialvideo.dart';

class WatchTutorialsPage extends StatelessWidget {
  const WatchTutorialsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Planting Tutorials',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Deep green
              Color(0xFF4CAF50), // Medium green
              Color(0xFF8BC34A), // Light green
              Color(0xFF795548), // Brown
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.brown[700]!,
                    Colors.green[800]!,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.eco,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school,
                          size: 40,
                          color: const Color.fromARGB(0, 255, 236, 179),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gardening Academy',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Learn to grow your own vegetables',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green[100],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.brown[50]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.brown[300]!.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.library_books,
                            color: Colors.brown[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Available Tutorials',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D4037),
                              fontFamily: 'Serif',
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '18 lessons',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tutorials List
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTutorialCard(
                            context: context,
                            title: 'Singkamas Time!',
                            description: 'Learn how to grow singkamas (jicama)',
                            imagePath: 'assets/images/singkmas.png',
                            videoPath: 'assets/video/singkamas.mp4',
                            difficulty: 'Beginner',
                            duration: '15 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Talong Time!',
                            description: 'Learn how to grow talong (eggplant)',
                            imagePath: 'assets/images/talong.png',
                            videoPath: 'assets/video/tutorial1talong.mp4',
                            difficulty: 'Intermediate',
                            duration: '20 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Sigarilyas Time!',
                            description:
                                'Learn how to grow sigarilyas (winged beans)',
                            imagePath: 'assets/images/sigarilyas.png',
                            videoPath: 'assets/video/sigarilyasvid.mp4',
                            difficulty: 'Beginner',
                            duration: '12 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Mani Time!',
                            description: 'Learn how to grow mani (peanuts)',
                            imagePath: 'assets/images/mani.png',
                            videoPath: 'assets/video/manii.mp4',
                            difficulty: 'Intermediate',
                            duration: '18 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Sitaw Time!',
                            description:
                                'Learn how to grow sitaw (string beans)',
                            imagePath: 'assets/images/sitaw.png',
                            videoPath: 'assets/video/Sitaw.mp4',
                            difficulty: 'Beginner',
                            duration: '14 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Bataw Time!',
                            description:
                                'Learn how to grow bataw (hyacinth beans)',
                            imagePath: 'assets/images/bataw.png',
                            videoPath: 'assets/video/bataw.mp4',
                            difficulty: 'Intermediate',
                            duration: '16 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Patani Time!',
                            description:
                                'Learn how to grow patani (lima beans)',
                            imagePath: 'assets/images/patani.png',
                            videoPath: 'assets/video/patanivid.mp4',
                            difficulty: 'Beginner',
                            duration: '13 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Kundol Time!',
                            description:
                                'Learn how to grow kundol (winter melon)',
                            imagePath: 'assets/images/kundol.png',
                            videoPath: 'assets/video/Kundoltuts.mp4',
                            difficulty: 'Intermediate',
                            duration: '22 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Patola Time!',
                            description:
                                'Learn how to grow patola (sponge gourd)',
                            imagePath: 'assets/images/patola.png',
                            videoPath: 'assets/video/patolatuts.mp4',
                            difficulty: 'Beginner',
                            duration: '15 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Upo Time!',
                            description: 'Learn how to grow upo (bottle gourd)',
                            imagePath: 'assets/images/upo.png',
                            videoPath: 'assets/video/Upovid.mp4',
                            difficulty: 'Intermediate',
                            duration: '19 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Kalabasa Time!',
                            description: 'Learn how to grow kalabasa (squash)',
                            imagePath: 'assets/images/kalabasa.png',
                            videoPath: 'assets/video/kalabasa.mp4',
                            difficulty: 'Beginner',
                            duration: '17 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Labanos Time!',
                            description: 'Learn how to grow labanos (radish)',
                            imagePath: 'assets/images/labanos.png',
                            videoPath: 'assets/video/labanos.mp4',
                            difficulty: 'Beginner',
                            duration: '11 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Mustasa Time!',
                            description:
                                'Learn how to grow mustasa (mustard leaves)',
                            imagePath: 'assets/images/mustasa.png',
                            videoPath: 'assets/video/mustasa1.mp4',
                            difficulty: 'Beginner',
                            duration: '10 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Sibuyas Time!',
                            description: 'Learn how to grow sibuyas (onion)',
                            imagePath: 'assets/images/sibuyas.png',
                            videoPath: 'assets/video/tutorial2sibuyas.mp4',
                            difficulty: 'Intermediate',
                            duration: '21 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Kamatis Time!',
                            description: 'Learn how to grow kamatis (tomato)',
                            imagePath: 'assets/images/kamatis.png',
                            videoPath: 'assets/video/tutorial3tomato.mp4',
                            difficulty: 'Intermediate',
                            duration: '23 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Bawang Time!',
                            description: 'Learn how to grow bawang (garlic)',
                            imagePath: 'assets/images/bawang.png',
                            videoPath: 'assets/video/bawang.mp4',
                            difficulty: 'Beginner',
                            duration: '14 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Luya Time!',
                            description: 'Learn how to grow luya (ginger)',
                            imagePath: 'assets/images/luya.png',
                            videoPath: 'assets/video/luyatuts.mp4',
                            difficulty: 'Intermediate',
                            duration: '20 min',
                          ),
                          const SizedBox(height: 12),
                          _buildTutorialCard(
                            context: context,
                            title: 'Linga Time!',
                            description:
                                'Learn how to grow linga (sesame seeds)',
                            imagePath: 'assets/images/linga.png',
                            videoPath: 'assets/video/linga.mp4',
                            difficulty: 'Advanced',
                            duration: '25 min',
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
      ),
    );
  }

  Widget _buildTutorialCard({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required String videoPath,
    required String difficulty,
    required String duration,
  }) {
    Color difficultyColor = Colors.green;
    if (difficulty == 'Intermediate') {
      difficultyColor = Colors.orange;
    } else if (difficulty == 'Advanced') {
      difficultyColor = Colors.red;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[50]!,
              Colors.brown[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.brown[100]!,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TutorialVideoPage(
                  title: title,
                  videoPath: videoPath,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Image Container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green[300]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown[300]!.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green[100]!,
                            Colors.brown[100]!,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.eco,
                              size: 30,
                              color: Colors.green[700],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown[700],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: difficultyColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: difficultyColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              difficulty,
                              style: TextStyle(
                                fontSize: 10,
                                color: difficultyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.brown[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.brown[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Play Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green[600]!,
                        Colors.brown[600]!,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown[400]!.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
