import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TutorialVideoPage extends StatefulWidget {
  final String title;
  final String videoPath;

  const TutorialVideoPage({
    Key? key,
    required this.title,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<TutorialVideoPage> createState() => _TutorialVideoPageState();
}

class _TutorialVideoPageState extends State<TutorialVideoPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Add listener to track video state
        _controller.addListener(() {
          if (!mounted) return;

          final bool isPlaying = _controller.value.isPlaying;
          if (isPlaying != _isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        });

        // Start playing the video automatically
        _controller.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.brown[700]!,
                      Colors.green[800]!,
                    ],
                  ),
                ),
              ),
            ),
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
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Header for full screen mode
            if (_isFullScreen) ...[
              Container(
                height: 80,
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.brown[700]!,
                      Colors.green[800]!,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isFullScreen = false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Serif',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen_exit,
                          color: Colors.white),
                      onPressed: _toggleFullScreen,
                    ),
                  ],
                ),
              ),
            ],

            // Video player section
            Expanded(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Stack(
                  children: [
                    // Video player
                    Center(
                      child: _isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green[100]!,
                                    Colors.brown[100]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading video...',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    // Overlay controls
                    if (_showControls && _isInitialized)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _showControls ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Video controls panel
            if (!_isFullScreen || _showControls)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showControls ? 140 : 0,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.brown[50]!.withOpacity(0.9),
                          Colors.green[50]!.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown[300]!.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Progress bar
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.green[700]!,
                            bufferedColor: Colors.green[200]!,
                            backgroundColor: Colors.brown[200]!,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Control buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Skip backward button
                            _buildControlButton(
                              icon: Icons.replay_10,
                              label: '10s',
                              onPressed: () {
                                final position = _controller.value.position;
                                if (position.inSeconds > 10) {
                                  _controller.seekTo(Duration(
                                      seconds: position.inSeconds - 10));
                                } else {
                                  _controller.seekTo(Duration.zero);
                                }
                              },
                            ),

                            // Play/Pause button
                            _buildControlButton(
                              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                              label: _isPlaying ? 'Pause' : 'Play',
                              isPrimary: true,
                              onPressed: () {
                                setState(() {
                                  _isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                            ),

                            // Skip forward button
                            _buildControlButton(
                              icon: Icons.forward_10,
                              label: '10s',
                              onPressed: () {
                                final position = _controller.value.position;
                                final duration = _controller.value.duration;
                                if (position.inSeconds <
                                    duration.inSeconds - 10) {
                                  _controller.seekTo(Duration(
                                      seconds: position.inSeconds + 10));
                                } else {
                                  _controller.seekTo(duration);
                                }
                              },
                            ),

                            // Fullscreen button
                            _buildControlButton(
                              icon: Icons.fullscreen,
                              label: 'Full',
                              onPressed: _toggleFullScreen,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Time indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: Colors.brown[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(_controller.value.position),
                              style: TextStyle(
                                color: Colors.brown[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' / ',
                              style: TextStyle(
                                color: Colors.brown[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: TextStyle(
                                color: Colors.brown[700],
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // ==================== CONTROL BUTTON METHODS ====================

Widget _buildControlButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  bool isPrimary = false,
}) {
  return Column(
    children: [
      _buildButtonContainer(icon, label, onPressed, isPrimary),
      const SizedBox(height: 4),
      _buildButtonLabel(label, isPrimary),
    ],
  );
}

// Helper method to build button container
Container _buildButtonContainer(
  IconData icon,
  String label,
  VoidCallback onPressed,
  bool isPrimary,
) {
  return Container(
    width: isPrimary ? 60 : 50,
    height: isPrimary ? 60 : 50,
    decoration: _buildButtonDecoration(isPrimary),
    child: _buildIconButton(icon, onPressed, isPrimary),
  );
}

// Helper method to build button decoration
BoxDecoration _buildButtonDecoration(bool isPrimary) {
  return BoxDecoration(
    gradient: isPrimary ? _buildPrimaryGradient() : _buildSecondaryGradient(),
    shape: BoxShape.circle,
    boxShadow: [_buildButtonShadow()],
    border: Border.all(
      color: isPrimary ? Colors.white : Colors.brown[300]!,
      width: 2,
    ),
  );
}

// Helper method to build primary gradient
LinearGradient _buildPrimaryGradient() {
  return LinearGradient(
    colors: [
      Colors.green[600]!,
      Colors.brown[600]!,
    ],
  );
}

// Helper method to build secondary gradient
LinearGradient _buildSecondaryGradient() {
  return LinearGradient(
    colors: [
      Colors.green[100]!,
      Colors.brown[100]!,
    ],
  );
}

// Helper method to build button shadow
BoxShadow _buildButtonShadow() {
  return BoxShadow(
    color: Colors.brown[300]!.withOpacity(0.5),
    blurRadius: 6,
    offset: const Offset(2, 2),
  );
}

// Helper method to build icon button
IconButton _buildIconButton(
  IconData icon,
  VoidCallback onPressed,
  bool isPrimary,
) {
  return IconButton(
    icon: Icon(
      icon,
      color: isPrimary ? Colors.white : Colors.green[700],
      size: isPrimary ? 28 : 22,
    ),
    onPressed: onPressed,
  );
}

// Helper method to build button label
Widget _buildButtonLabel(String label, bool isPrimary) {
  return Text(
    label,
    style: TextStyle(
      color: Colors.brown[700],
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );
}

// ==================== DURATION FORMATTING METHODS ====================

String _formatDuration(Duration duration) {
  final minutes = _formatTwoDigits(duration.inMinutes.remainder(60));
  final seconds = _formatTwoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

// Helper method to format two digits
String _formatTwoDigits(int n) {
  return n.toString().padLeft(2, '0');
}

// Alternative formatting method (optional, kept for compatibility)
String _formatDurationAlt(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}