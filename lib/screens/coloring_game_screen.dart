import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class ColoringGameScreen extends StatefulWidget {
  const ColoringGameScreen({super.key});

  @override
  State<ColoringGameScreen> createState() => _ColoringGameScreenState();
}

class _ColoringGameScreenState extends State<ColoringGameScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  int _currentSketch = 0;
  Color _selectedColor = Colors.red;
  List<DrawingPoint> _drawingPoints = [];
  double _brushSize = 15.0;

  final List<ColoringImage> _images = [
    ColoringImage(
      name: 'Flower',
      emoji: '🌸',
      sampleColors: [Colors.pink, Colors.green, Colors.yellow],
      sketchBuilder: _buildFlowerSketch,
      sampleBuilder: _buildFlowerSample,
    ),
    ColoringImage(
      name: 'Sun',
      emoji: '☀️',
      sampleColors: [Colors.yellow, Colors.orange],
      sketchBuilder: _buildSunSketch,
      sampleBuilder: _buildSunSample,
    ),
    ColoringImage(
      name: 'Tree',
      emoji: '🌳',
      sampleColors: [Colors.green, Colors.brown],
      sketchBuilder: _buildTreeSketch,
      sampleBuilder: _buildTreeSample,
    ),
    ColoringImage(
      name: 'Fish',
      emoji: '🐟',
      sampleColors: [Colors.blue, Colors.orange, Colors.yellow],
      sketchBuilder: _buildFishSketch,
      sampleBuilder: _buildFishSample,
    ),
    ColoringImage(
      name: 'House',
      emoji: '🏠',
      sampleColors: [Colors.red, Colors.brown, Colors.blue],
      sketchBuilder: _buildHouseSketch,
      sampleBuilder: _buildHouseSample,
    ),
  ];

  final List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _speak('Color the ${_images[_currentSketch].name} like the picture above!');
      }
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _drawingPoints.add(
        DrawingPoint(
          offset: details.localPosition,
          color: _selectedColor,
          strokeWidth: _brushSize,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _drawingPoints.add(
        DrawingPoint(
          offset: details.localPosition,
          color: _selectedColor,
          strokeWidth: _brushSize,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _drawingPoints.add(DrawingPoint.empty());
    });
  }

  void _nextImage() {
    _confettiController.play();
    _speak('Great job! Beautiful ${_images[_currentSketch].name}!');

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (_currentSketch < _images.length - 1) {
        setState(() {
          _currentSketch++;
          _drawingPoints = [];
        });
        _speak('Now color the ${_images[_currentSketch].name}!');
      } else {
        _speak('You colored all the pictures! Amazing artist!');
        _showWinDialog();
      }
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.purple.shade100,
        title: const Text(
          '🎨 Amazing Artist! 🎨',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You colored all the pictures!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _images.map((img) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(img.emoji, style: const TextStyle(fontSize: 28)),
              )).toList(),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentSketch = 0;
                  _drawingPoints = [];
                });
                _speak('Color the ${_images[0].name}!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Color Again!',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _images[_currentSketch];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 28),
                          color: Colors.purple,
                        ),
                        Expanded(
                          child: Text(
                            'Color the ${image.name}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                        // Next button
                        IconButton(
                          onPressed: _nextImage,
                          icon: const Icon(Icons.check_circle, size: 32),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: index <= _currentSketch
                              ? Colors.purple
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 8),

                  // Sample image (colored reference)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.purple.shade200, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Sample - Color like this:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 100,
                          child: CustomPaint(
                            size: const Size(double.infinity, 100),
                            painter: image.sampleBuilder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Drawing canvas with sketch outline
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: ColoringPainter(
                              drawingPoints: _drawingPoints,
                              sketchPainter: image.sketchBuilder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Brush size slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.brush, size: 18, color: Colors.grey),
                        Expanded(
                          child: Slider(
                            value: _brushSize,
                            min: 5,
                            max: 40,
                            activeColor: _selectedColor,
                            onChanged: (value) {
                              setState(() {
                                _brushSize = value;
                              });
                            },
                          ),
                        ),
                        Container(
                          width: _brushSize,
                          height: _brushSize,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Color palette
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _colors.map((color) {
                        final isSelected = color == _selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 38 : 28,
                            height: isSelected ? 38 : 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _drawingPoints = [];
                            });
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                          label: const Text('Clear', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: _nextImage,
                          icon: const Icon(Icons.done, color: Colors.white, size: 20),
                          label: const Text('Done', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: _colors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Drawing point class
class DrawingPoint {
  final Offset? offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    this.offset,
    this.color = Colors.black,
    this.strokeWidth = 10,
  });

  factory DrawingPoint.empty() => DrawingPoint(offset: null);
}

// Main painter that combines user drawing and sketch outline
class ColoringPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  final CustomPainter sketchPainter;

  ColoringPainter({
    required this.drawingPoints,
    required this.sketchPainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // First draw user's coloring
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset != null && drawingPoints[i + 1].offset != null) {
        final paint = Paint()
          ..color = drawingPoints[i].color
          ..strokeWidth = drawingPoints[i].strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawLine(
          drawingPoints[i].offset!,
          drawingPoints[i + 1].offset!,
          paint,
        );
      }
    }

    // Then draw sketch outline on top
    sketchPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Coloring image model
class ColoringImage {
  final String name;
  final String emoji;
  final List<Color> sampleColors;
  final CustomPainter Function() sketchBuilder;
  final CustomPainter Function() sampleBuilder;

  ColoringImage({
    required this.name,
    required this.emoji,
    required this.sampleColors,
    required this.sketchBuilder,
    required this.sampleBuilder,
  });
}

// ============ SKETCH PAINTERS (Black outlines) ============

CustomPainter _buildFlowerSketch() => _FlowerSketchPainter();
CustomPainter _buildSunSketch() => _SunSketchPainter();
CustomPainter _buildTreeSketch() => _TreeSketchPainter();
CustomPainter _buildFishSketch() => _FishSketchPainter();
CustomPainter _buildHouseSketch() => _HouseSketchPainter();

// ============ SAMPLE PAINTERS (Colored examples) ============

CustomPainter _buildFlowerSample() => _FlowerSamplePainter();
CustomPainter _buildSunSample() => _SunSamplePainter();
CustomPainter _buildTreeSample() => _TreeSamplePainter();
CustomPainter _buildFishSample() => _FishSamplePainter();
CustomPainter _buildHouseSample() => _HouseSamplePainter();

// ============ FLOWER ============

class _FlowerSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final petalRadius = size.width * 0.12;

    // Petals
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * pi / 180;
      final x = centerX + petalRadius * 1.5 * cos(angle);
      final y = centerY + petalRadius * 1.5 * sin(angle);
      canvas.drawCircle(Offset(x, y), petalRadius, paint);
    }

    // Center
    canvas.drawCircle(Offset(centerX, centerY), petalRadius * 0.7, paint);

    // Stem
    canvas.drawLine(
      Offset(centerX, centerY + petalRadius),
      Offset(centerX, size.height * 0.95),
      paint,
    );

    // Leaves
    final leafPath = Path();
    leafPath.moveTo(centerX, centerY + petalRadius * 2);
    leafPath.quadraticBezierTo(
      centerX - 30, centerY + petalRadius * 2.5,
      centerX - 10, centerY + petalRadius * 3,
    );
    canvas.drawPath(leafPath, paint);

    final leafPath2 = Path();
    leafPath2.moveTo(centerX, centerY + petalRadius * 2.5);
    leafPath2.quadraticBezierTo(
      centerX + 30, centerY + petalRadius * 3,
      centerX + 10, centerY + petalRadius * 3.5,
    );
    canvas.drawPath(leafPath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlowerSamplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final petalRadius = size.width * 0.06;

    // Petals (pink)
    final petalPaint = Paint()..color = Colors.pink;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * pi / 180;
      final x = centerX + petalRadius * 1.5 * cos(angle);
      final y = centerY + petalRadius * 1.5 * sin(angle);
      canvas.drawCircle(Offset(x, y), petalRadius, petalPaint);
    }

    // Center (yellow)
    canvas.drawCircle(Offset(centerX, centerY), petalRadius * 0.7, Paint()..color = Colors.yellow);

    // Stem (green)
    final stemPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(centerX, centerY + petalRadius),
      Offset(centerX, size.height * 0.95),
      stemPaint,
    );

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * pi / 180;
      final x = centerX + petalRadius * 1.5 * cos(angle);
      final y = centerY + petalRadius * 1.5 * sin(angle);
      canvas.drawCircle(Offset(x, y), petalRadius, outlinePaint);
    }
    canvas.drawCircle(Offset(centerX, centerY), petalRadius * 0.7, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============ SUN ============

class _SunSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.15;

    // Center circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final x1 = centerX + radius * 1.2 * cos(angle);
      final y1 = centerY + radius * 1.2 * sin(angle);
      final x2 = centerX + radius * 2 * cos(angle);
      final y2 = centerY + radius * 2 * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SunSamplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.08;

    // Rays (orange)
    final rayPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final x1 = centerX + radius * 1.2 * cos(angle);
      final y1 = centerY + radius * 1.2 * sin(angle);
      final x2 = centerX + radius * 2 * cos(angle);
      final y2 = centerY + radius * 2 * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), rayPaint);
    }

    // Center (yellow)
    canvas.drawCircle(Offset(centerX, centerY), radius, Paint()..color = Colors.yellow);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, centerY), radius, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============ TREE ============

class _TreeSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;

    // Trunk
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 15, size.height * 0.95);
    trunkPath.lineTo(centerX - 15, size.height * 0.55);
    trunkPath.lineTo(centerX + 15, size.height * 0.55);
    trunkPath.lineTo(centerX + 15, size.height * 0.95);
    canvas.drawPath(trunkPath, paint);

    // Foliage (3 circles)
    canvas.drawCircle(Offset(centerX, size.height * 0.35), size.width * 0.2, paint);
    canvas.drawCircle(Offset(centerX - 25, size.height * 0.5), size.width * 0.15, paint);
    canvas.drawCircle(Offset(centerX + 25, size.height * 0.5), size.width * 0.15, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TreeSamplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Trunk (brown)
    final trunkPaint = Paint()..color = Colors.brown;
    canvas.drawRect(
      Rect.fromLTWH(centerX - 8, size.height * 0.55, 16, size.height * 0.4),
      trunkPaint,
    );

    // Foliage (green)
    final foliagePaint = Paint()..color = Colors.green;
    canvas.drawCircle(Offset(centerX, size.height * 0.35), size.width * 0.1, foliagePaint);
    canvas.drawCircle(Offset(centerX - 12, size.height * 0.5), size.width * 0.08, foliagePaint);
    canvas.drawCircle(Offset(centerX + 12, size.height * 0.5), size.width * 0.08, foliagePaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, size.height * 0.35), size.width * 0.1, outlinePaint);
    canvas.drawCircle(Offset(centerX - 12, size.height * 0.5), size.width * 0.08, outlinePaint);
    canvas.drawCircle(Offset(centerX + 12, size.height * 0.5), size.width * 0.08, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============ FISH ============

class _FishSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Body (oval)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY), width: size.width * 0.5, height: size.height * 0.4),
      paint,
    );

    // Tail
    final tailPath = Path();
    tailPath.moveTo(centerX - size.width * 0.25, centerY);
    tailPath.lineTo(centerX - size.width * 0.4, centerY - 30);
    tailPath.lineTo(centerX - size.width * 0.4, centerY + 30);
    tailPath.close();
    canvas.drawPath(tailPath, paint);

    // Eye
    canvas.drawCircle(Offset(centerX + size.width * 0.12, centerY - 10), 8, paint);

    // Fin
    final finPath = Path();
    finPath.moveTo(centerX, centerY - size.height * 0.15);
    finPath.lineTo(centerX - 15, centerY - size.height * 0.35);
    finPath.lineTo(centerX + 15, centerY - size.height * 0.15);
    canvas.drawPath(finPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FishSamplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Body (blue)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY), width: size.width * 0.3, height: size.height * 0.5),
      Paint()..color = Colors.blue,
    );

    // Tail (orange)
    final tailPath = Path();
    tailPath.moveTo(centerX - size.width * 0.15, centerY);
    tailPath.lineTo(centerX - size.width * 0.25, centerY - 15);
    tailPath.lineTo(centerX - size.width * 0.25, centerY + 15);
    tailPath.close();
    canvas.drawPath(tailPath, Paint()..color = Colors.orange);

    // Fin (yellow)
    final finPath = Path();
    finPath.moveTo(centerX, centerY - size.height * 0.2);
    finPath.lineTo(centerX - 8, centerY - size.height * 0.4);
    finPath.lineTo(centerX + 8, centerY - size.height * 0.2);
    canvas.drawPath(finPath, Paint()..color = Colors.yellow);

    // Eye
    canvas.drawCircle(Offset(centerX + size.width * 0.06, centerY - 5), 4, Paint()..color = Colors.black);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY), width: size.width * 0.3, height: size.height * 0.5),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============ HOUSE ============

class _HouseSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;

    // House body
    canvas.drawRect(
      Rect.fromLTWH(centerX - 60, size.height * 0.4, 120, size.height * 0.55),
      paint,
    );

    // Roof
    final roofPath = Path();
    roofPath.moveTo(centerX - 70, size.height * 0.4);
    roofPath.lineTo(centerX, size.height * 0.1);
    roofPath.lineTo(centerX + 70, size.height * 0.4);
    roofPath.close();
    canvas.drawPath(roofPath, paint);

    // Door
    canvas.drawRect(
      Rect.fromLTWH(centerX - 15, size.height * 0.65, 30, size.height * 0.3),
      paint,
    );

    // Window
    canvas.drawRect(
      Rect.fromLTWH(centerX + 25, size.height * 0.5, 25, 25),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 50, size.height * 0.5, 25, 25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HouseSamplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // House body (cream/beige)
    canvas.drawRect(
      Rect.fromLTWH(centerX - 35, size.height * 0.4, 70, size.height * 0.55),
      Paint()..color = Colors.orange.shade100,
    );

    // Roof (red)
    final roofPath = Path();
    roofPath.moveTo(centerX - 40, size.height * 0.4);
    roofPath.lineTo(centerX, size.height * 0.15);
    roofPath.lineTo(centerX + 40, size.height * 0.4);
    roofPath.close();
    canvas.drawPath(roofPath, Paint()..color = Colors.red);

    // Door (brown)
    canvas.drawRect(
      Rect.fromLTWH(centerX - 8, size.height * 0.65, 16, size.height * 0.3),
      Paint()..color = Colors.brown,
    );

    // Windows (blue)
    canvas.drawRect(
      Rect.fromLTWH(centerX + 12, size.height * 0.5, 15, 15),
      Paint()..color = Colors.blue.shade200,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 27, size.height * 0.5, 15, 15),
      Paint()..color = Colors.blue.shade200,
    );

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromLTWH(centerX - 35, size.height * 0.4, 70, size.height * 0.55),
      outlinePaint,
    );
    canvas.drawPath(roofPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
