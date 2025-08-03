import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class ARActivity3DPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ARActivity3DPage({super.key, required this.user});

  @override
  State<ARActivity3DPage> createState() => _ARActivity3DPageState();
}

class _ARActivity3DPageState extends State<ARActivity3DPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showControls = true;
  bool _isPlacingObject = false;

  // 3D Object properties
  String _selectedVegetable = 'kalabasa';
  double _objectScale = 1.0;
  double _objectRotationX = 0.0;
  double _objectRotationY = 0.0;
  double _objectRotationZ = 0.0;
  Offset _objectPosition = Offset.zero;

  // Drag and gesture properties
  bool _isDragging = false;
  Offset _dragStartOffset = Offset.zero;
  Offset _objectStartOffset = Offset.zero;
  double _startScale = 1.0;
  double _startRotation = 0.0;
  int _pointers = 0;

  // Animation controllers
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  // Gyroscope simulation (for camera movement tracking)
  double _cameraTilt = 0.0;
  double _cameraPan = 0.0;
  Timer? _gyroSimulationTimer;

  // Vegetable database with 3D model information
  final Map<String, Map<String, dynamic>> _vegetable3DModels = {
    'kalabasa': {
      'name': 'Kalabasa',
      'modelPath': 'assets/models/kalabasa.glb',
      'image': 'assets/images/kalabasa.png',
      'scale': 0.3,
      'info': 'Squash - Versatile vegetable with sweet orange flesh',
      'floatAmplitude': 15.0,
      'floatSpeed': 2.0,
    },
    'talong': {
      'name': 'Talong',
      'modelPath': 'assets/models/talongt.glb',
      'image': 'assets/images/talong.png',
      'scale': 0.2,
      'info': 'Eggplant - Purple vegetable with spongy texture',
      'floatAmplitude': 20.0,
      'floatSpeed': 2.5,
    },
    'sitaw': {
      'name': 'Sitaw',
      'modelPath': 'assets/models/sitaw.glb',
      'image': 'assets/images/sitaw.png',
      'scale': 0.4,
      'info': 'Long Beans - Slender green beans up to 3 feet long',
      'floatAmplitude': 25.0,
      'floatSpeed': 3.0,
    },
    'sibuyas': {
      'name': 'Sibuyas',
      'modelPath': 'assets/models/sibuyas.glb',
      'image': 'assets/images/sibuyas.png',
      'scale': 0.15,
      'info': 'Onion - Essential flavor base in Filipino cooking',
      'floatAmplitude': 12.0,
      'floatSpeed': 1.8,
    },
    'kamatis': {
      'name': 'Kamatis',
      'modelPath': 'assets/models/kamatis.glb',
      'image': 'assets/images/kamatis.png',
      'scale': 0.1,
      'info': 'Tomato - Red, juicy fruit used as vegetable',
      'floatAmplitude': 10.0,
      'floatSpeed': 2.2,
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAnimations();
    _startGyroSimulation();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _gyroSimulationTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  void _startGyroSimulation() {
    // Simulate gyroscope data for camera movement
    _gyroSimulationTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isPlacingObject && !_isDragging) {
        setState(() {
          _cameraTilt = sin(DateTime.now().millisecondsSinceEpoch * 0.001) * 10;
          _cameraPan = cos(DateTime.now().millisecondsSinceEpoch * 0.0005) * 15;
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _showErrorSnackBar('Camera permission is required for AR features');
      return;
    }

    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      _showErrorSnackBar('Failed to initialize camera');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _selectVegetable(String vegetableKey) {
    setState(() {
      _selectedVegetable = vegetableKey;
      _objectScale = _vegetable3DModels[vegetableKey]!['scale'] ?? 1.0;
      _objectRotationX = 0.0;
      _objectRotationY = 0.0;
      _objectRotationZ = 0.0;
      _objectPosition = Offset.zero;
      _isPlacingObject = true;
    });
  }

  void _resetObject() {
    setState(() {
      _objectScale = _vegetable3DModels[_selectedVegetable]!['scale'] ?? 1.0;
      _objectRotationX = 0.0;
      _objectRotationY = 0.0;
      _objectRotationZ = 0.0;
      _objectPosition = Offset.zero;
    });
  }

  void _removeObject() {
    setState(() {
      _isPlacingObject = false;
      _isDragging = false;
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartOffset = details.focalPoint;
      _objectStartOffset = _objectPosition;
      _startScale = _objectScale;
      _startRotation = _objectRotationY;
      _pointers = details.pointerCount;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (_pointers == 1) {
        // Single finger drag
        final delta = details.focalPoint - _dragStartOffset;
        _objectPosition = _objectStartOffset + delta;
      } else if (_pointers == 2) {
        // Two finger pinch/rotate
        // Scale
        _objectScale = (_startScale * details.scale).clamp(0.1, 5.0);

        // Rotation
        _objectRotationY = _startRotation + details.rotation * 180 / pi;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _isDragging = false;
      _pointers = 0;
    });
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing AR Camera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        CameraPreview(_cameraController!),

        // AR Object Placement Guide
        if (_isPlacingObject)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showControls ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      _pointers == 2
                          ? 'Pinch to scale • Rotate with two fingers'
                          : 'Drag to move • Pinch to scale • Two fingers to rotate',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 3D Floating Vegetable with Gesture Controls
        if (_isPlacingObject)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 +
                _objectPosition.dx +
                (_isDragging ? 0 : _cameraPan),
            top: MediaQuery.of(context).size.height * 0.5 +
                _objectPosition.dy +
                (_isDragging ? 0 : _cameraTilt),
            child: GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              child: AnimatedBuilder(
                animation: Listenable.merge(
                    [_floatController, _pulseController, _rotationController]),
                builder: (context, child) {
                  final floatValue = _floatController.value;
                  final pulseValue = _pulseController.value;
                  final rotationValue = _rotationController.value;

                  final vegetable = _vegetable3DModels[_selectedVegetable]!;
                  final floatAmplitude = vegetable['floatAmplitude'] ?? 15.0;
                  final verticalOffset = _isDragging
                      ? 0.0
                      : sin(floatValue * 2 * pi) * floatAmplitude;
                  final scalePulse = _isDragging ? 1.0 : 1.0 + pulseValue * 0.1;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(0.0, verticalOffset, 0.0)
                      ..rotateX(vector.radians(_objectRotationX))
                      ..rotateY(vector.radians(_objectRotationY +
                          (_isDragging ? 0 : rotationValue * 360)))
                      ..rotateZ(vector.radians(_objectRotationZ))
                      ..scale(_objectScale * scalePulse),
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Stack(
                        children: [
                          // Glow effect (only when not dragging)
                          if (!_isDragging)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.green.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.1, 0.8],
                                  ),
                                ),
                              ),
                            ),

                          // Vegetable image
                          Center(
                            child: Image.asset(
                              vegetable['image'],
                              width: 120 * _objectScale,
                              height: 120 * _objectScale,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.eco,
                                  color: Colors.green[700],
                                  size: 80 * _objectScale,
                                );
                              },
                            ),
                          ),

                          // Floating particles (only when not dragging)
                          if (!_isDragging)
                            ...List.generate(3, (index) {
                              final particleOffset = Offset(
                                cos(rotationValue * 2 * pi +
                                        index * 2 * pi / 3) *
                                    60,
                                sin(rotationValue * 2 * pi +
                                        index * 2 * pi / 3) *
                                    60,
                              );
                              return Positioned(
                                left: 75 + particleOffset.dx,
                                top: 75 + particleOffset.dy,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                          // Scale indicator when dragging
                          if (_isDragging)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(_objectScale * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          // Rotation handles
                          if (_isDragging)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _objectRotationY -= 15;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.rotate_left,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _objectRotationY += 15;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.rotate_right,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
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
    );
  }

  Widget _buildVegetableSelection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(_showControls ? 0.8 : 0.0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: _showControls
          ? Column(
              children: [
                const Text(
                  'Select Vegetable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _vegetable3DModels.length,
                    itemBuilder: (context, index) {
                      final vegetableKey =
                          _vegetable3DModels.keys.elementAt(index);
                      final vegetable = _vegetable3DModels[vegetableKey]!;

                      return GestureDetector(
                        onTap: () => _selectVegetable(vegetableKey),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedVegetable == vegetableKey
                                ? Colors.green.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                vegetable['image'],
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.eco,
                                    color: Colors.green[400],
                                    size: 35,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vegetable['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget _buildControlPanel() {
    if (!_isPlacingObject) return const SizedBox();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showControls ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildControlSection(
              title: 'SCALE',
              value: _objectScale,
              min: 0.1,
              max: 5.0,
              onChanged: (value) {
                setState(() {
                  _objectScale = value;
                });
              },
              formatValue: (value) => '${(value * 100).toInt()}%',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRotationControl(
                    axis: 'X',
                    value: _objectRotationX,
                    onChanged: (value) {
                      setState(() {
                        _objectRotationX = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRotationControl(
                    axis: 'Y',
                    value: _objectRotationY,
                    onChanged: (value) {
                      setState(() {
                        _objectRotationY = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRotationControl(
                    axis: 'Z',
                    value: _objectRotationZ,
                    onChanged: (value) {
                      setState(() {
                        _objectRotationZ = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetObject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _removeObject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Remove'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String Function(double) formatValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formatValue(value),
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveColor: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildRotationControl({
    required String axis,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Text(
          'Rotate $axis',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  onChanged(value - 15);
                },
                icon: const Icon(Icons.rotate_left,
                    color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
              ),
              Text(
                '${value.toInt()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              IconButton(
                onPressed: () {
                  onChanged(value + 15);
                },
                icon: const Icon(Icons.rotate_right,
                    color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVegetableInfo() {
    if (!_isPlacingObject) return const SizedBox();

    final vegetable = _vegetable3DModels[_selectedVegetable]!;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showControls ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  vegetable['image'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.eco,
                      color: Colors.green[400],
                      size: 30,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vegetable['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vegetable['info'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AR 3D Activity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _showControls ? Icons.visibility : Icons.visibility_off,
                key: ValueKey(_showControls),
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            tooltip: 'Toggle Controls',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildCameraPreview(),

          // Top Info Panel
          if (_isPlacingObject)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildVegetableInfo(),
            ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isPlacingObject) _buildControlPanel(),
                _buildVegetableSelection(),
              ],
            ),
          ),

          // Placement Instructions
          if (!_isPlacingObject && _showControls)
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showControls ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.threed_rotation,
                          color: Colors.green, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'AR 3D Vegetable Placement',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Drag to move • Pinch to scale • Two fingers to rotate\nSelect a vegetable to start!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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
}
