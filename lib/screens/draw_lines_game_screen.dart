import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class DrawLinesGameScreen extends StatefulWidget {
  const DrawLinesGameScreen({super.key});

  @override
  State<DrawLinesGameScreen> createState() => _DrawLinesGameScreenState();
}

class _DrawLinesGameScreenState extends State<DrawLinesGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  int _currentLevel = 0;
  List<Offset> _userPath = [];
  bool _isDrawing = false;
  bool _levelComplete = false;
  int _completedLevels = 0;
  double _accuracy = 0;

  final List<String> _encouragements = [
    'Great job!',
    'Well done!',
    'Awesome!',
    'Perfect!',
    'Fantastic!',
    'Super!',
    'Amazing!',
    'Wonderful!',
  ];

  final List<LineLesson> _lessons = [
    LineLesson(
      name: 'Sleeping Line',
      description: 'Draw a line lying down! →',
      emoji: '😴',
      color: Colors.blue,
      lineType: LineType.horizontal,
    ),
    LineLesson(
      name: 'Standing Line',
      description: 'Draw a line standing up! ↓',
      emoji: '🧍',
      color: Colors.green,
      lineType: LineType.vertical,
    ),
    LineLesson(
      name: 'Slanting Left',
      description: 'Draw a line going down-left! ↙',
      emoji: '↙️',
      color: Colors.orange,
      lineType: LineType.slantLeft,
    ),
    LineLesson(
      name: 'Slanting Right',
      description: 'Draw a line going down-right! ↘',
      emoji: '↘️',
      color: Colors.purple,
      lineType: LineType.slantRight,
    ),
    LineLesson(
      name: 'Semicircle',
      description: 'Draw half a circle! ⌒',
      emoji: '🌙',
      color: Colors.teal,
      lineType: LineType.semicircle,
    ),
    LineLesson(
      name: 'Circle',
      description: 'Draw a round circle! ⭕',
      emoji: '⭕',
      color: Colors.red,
      lineType: LineType.circle,
    ),
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
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  String _getRandomEncouragement() {
    return _encouragements[Random().nextInt(_encouragements.length)];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _userPath = [details.localPosition];
      _levelComplete = false;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;
    setState(() {
      _userPath.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details, Size size) {
    if (!_isDrawing || _userPath.length < 10) {
      setState(() {
        _userPath = [];
        _isDrawing = false;
      });
      return;
    }

    _isDrawing = false;
    _checkAccuracy(size);
  }

  void _checkAccuracy(Size size) async {
    final lesson = _lessons[_currentLevel];
    double score = 0;

    switch (lesson.lineType) {
      case LineType.horizontal:
        score = _checkHorizontal(size);
        break;
      case LineType.vertical:
        score = _checkVertical(size);
        break;
      case LineType.slantLeft:
        score = _checkSlantLeft(size);
        break;
      case LineType.slantRight:
        score = _checkSlantRight(size);
        break;
      case LineType.semicircle:
        score = _checkSemicircle(size);
        break;
      case LineType.circle:
        score = _checkCircle(size);
        break;
    }

    setState(() {
      _accuracy = score;
    });

    if (score >= 60) {
      try {
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } catch (e) {
        // Sound file may not exist
      }
      _confettiController.play();

      setState(() {
        _levelComplete = true;
        _completedLevels++;
      });

      // Speak encouragement with line name
      final lesson = _lessons[_currentLevel];
      _speak('${_getRandomEncouragement()} You drew a ${lesson.name}!');

      await Future.delayed(const Duration(seconds: 2));

      if (_currentLevel < _lessons.length - 1) {
        setState(() {
          _currentLevel++;
          _userPath = [];
          _levelComplete = false;
          _accuracy = 0;
        });
      } else {
        _speak('You learned all the lines! Amazing!');
        _showWinDialog();
      }
    } else {
      try {
        await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
      } catch (e) {
        // Sound file may not exist
      }
      _speak('Try again!');
    }
  }

  double _checkHorizontal(Size size) {
    if (_userPath.isEmpty) return 0;
    final centerY = size.height / 2;
    double totalDeviation = 0;

    for (var point in _userPath) {
      totalDeviation += (point.dy - centerY).abs();
    }

    final avgDeviation = totalDeviation / _userPath.length;
    final maxDeviation = size.height / 4;
    return (1 - (avgDeviation / maxDeviation).clamp(0, 1)) * 100;
  }

  double _checkVertical(Size size) {
    if (_userPath.isEmpty) return 0;
    final centerX = size.width / 2;
    double totalDeviation = 0;

    for (var point in _userPath) {
      totalDeviation += (point.dx - centerX).abs();
    }

    final avgDeviation = totalDeviation / _userPath.length;
    final maxDeviation = size.width / 4;
    return (1 - (avgDeviation / maxDeviation).clamp(0, 1)) * 100;
  }

  double _checkSlantLeft(Size size) {
    if (_userPath.isEmpty) return 0;

    // For slant left, we expect y to increase as x decreases
    final firstPoint = _userPath.first;
    final lastPoint = _userPath.last;

    // Check direction
    final correctDirection = lastPoint.dx < firstPoint.dx && lastPoint.dy > firstPoint.dy;
    if (!correctDirection) return 30;

    double totalDeviation = 0;
    for (int i = 0; i < _userPath.length; i++) {
      final t = i / (_userPath.length - 1);
      final expectedX = firstPoint.dx + (lastPoint.dx - firstPoint.dx) * t;
      final expectedY = firstPoint.dy + (lastPoint.dy - firstPoint.dy) * t;
      totalDeviation += ((_userPath[i].dx - expectedX).abs() + (_userPath[i].dy - expectedY).abs()) / 2;
    }

    final avgDeviation = totalDeviation / _userPath.length;
    final maxDeviation = size.width / 4;
    return (1 - (avgDeviation / maxDeviation).clamp(0, 1)) * 100;
  }

  double _checkSlantRight(Size size) {
    if (_userPath.isEmpty) return 0;

    final firstPoint = _userPath.first;
    final lastPoint = _userPath.last;

    // Check direction - x should increase, y should increase
    final correctDirection = lastPoint.dx > firstPoint.dx && lastPoint.dy > firstPoint.dy;
    if (!correctDirection) return 30;

    double totalDeviation = 0;
    for (int i = 0; i < _userPath.length; i++) {
      final t = i / (_userPath.length - 1);
      final expectedX = firstPoint.dx + (lastPoint.dx - firstPoint.dx) * t;
      final expectedY = firstPoint.dy + (lastPoint.dy - firstPoint.dy) * t;
      totalDeviation += ((_userPath[i].dx - expectedX).abs() + (_userPath[i].dy - expectedY).abs()) / 2;
    }

    final avgDeviation = totalDeviation / _userPath.length;
    final maxDeviation = size.width / 4;
    return (1 - (avgDeviation / maxDeviation).clamp(0, 1)) * 100;
  }

  double _checkSemicircle(Size size) {
    if (_userPath.isEmpty) return 0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    double totalDeviation = 0;
    for (var point in _userPath) {
      final distance = (point - center).distance;
      totalDeviation += (distance - radius).abs();
    }

    // Check if it's roughly the top half
    final avgY = _userPath.map((p) => p.dy).reduce((a, b) => a + b) / _userPath.length;
    final isTopHalf = avgY < center.dy + radius / 2;

    final avgDeviation = totalDeviation / _userPath.length;
    final maxDeviation = radius / 2;
    var score = (1 - (avgDeviation / maxDeviation).clamp(0, 1)) * 100;

    if (!isTopHalf) score *= 0.7;
    return score.toDouble();
  }

  double _checkCircle(Size size) {
    if (_userPath.isEmpty) return 0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    double totalDeviation = 0;
    for (var point in _userPath) {
      final distance = (point - center).distance;
      totalDeviation += (distance - radius).abs();
    }

    // Check if it's closed (start and end near each other)
    final isClosed = (_userPath.first - _userPath.last).distance < radius / 2;

    final avgDeviation = totalDeviation / _userPath.length;
    final maxDeviation = radius / 2;
    var score = (1 - (avgDeviation / maxDeviation).clamp(0, 1)) * 100;

    if (!isClosed) score *= 0.8;
    return score.toDouble();
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.pink.shade100,
        title: const Text(
          '✏️ Great Drawing! ✏️',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You learned all the lines!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('→ ↓ ↙ ↘ ⌒ ⭕', style: TextStyle(fontSize: 30)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentLevel = 0;
                  _completedLevels = 0;
                  _userPath = [];
                  _levelComplete = false;
                  _accuracy = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Practice Again!',
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
    final lesson = _lessons[_currentLevel];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lesson.color.withOpacity(0.3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 30),
                          color: lesson.color,
                        ),
                        Expanded(
                          child: Text(
                            'Draw Lines',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: lesson.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Level progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_lessons.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: index < _completedLevels
                                ? Colors.green
                                : (index == _currentLevel
                                    ? lesson.color
                                    : Colors.grey.shade300),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _lessons[index].emoji,
                              style: TextStyle(
                                fontSize: index < _completedLevels || index == _currentLevel
                                    ? 20
                                    : 16,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Lesson info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: lesson.color, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          lesson.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: lesson.color,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          lesson.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Drawing canvas
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: lesson.color, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: lesson.color.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            return GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: (d) => _onPanEnd(d, size),
                              child: CustomPaint(
                                size: size,
                                painter: LineGuidePainter(
                                  lesson: lesson,
                                  userPath: _userPath,
                                  levelComplete: _levelComplete,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Accuracy display
                  if (_accuracy > 0)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _accuracy >= 60 ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _accuracy >= 60
                              ? 'Great! ${_accuracy.toInt()}%'
                              : 'Try again! ${_accuracy.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Clear button
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _userPath = [];
                          _accuracy = 0;
                        });
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
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
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.pink,
                    Colors.purple,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum LineType {
  horizontal,
  vertical,
  slantLeft,
  slantRight,
  semicircle,
  circle,
}

class LineLesson {
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final LineType lineType;

  LineLesson({
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.lineType,
  });
}

class LineGuidePainter extends CustomPainter {
  final LineLesson lesson;
  final List<Offset> userPath;
  final bool levelComplete;

  LineGuidePainter({
    required this.lesson,
    required this.userPath,
    required this.levelComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guide
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    switch (lesson.lineType) {
      case LineType.horizontal:
        canvas.drawLine(
          Offset(size.width * 0.1, center.dy),
          Offset(size.width * 0.9, center.dy),
          guidePaint,
        );
        break;
      case LineType.vertical:
        canvas.drawLine(
          Offset(center.dx, size.height * 0.1),
          Offset(center.dx, size.height * 0.9),
          guidePaint,
        );
        break;
      case LineType.slantLeft:
        canvas.drawLine(
          Offset(size.width * 0.8, size.height * 0.2),
          Offset(size.width * 0.2, size.height * 0.8),
          guidePaint,
        );
        break;
      case LineType.slantRight:
        canvas.drawLine(
          Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8),
          guidePaint,
        );
        break;
      case LineType.semicircle:
        final rect = Rect.fromCircle(center: center, radius: size.width / 3);
        canvas.drawArc(rect, pi, pi, false, guidePaint);
        break;
      case LineType.circle:
        canvas.drawCircle(center, size.width / 3, guidePaint);
        break;
    }

    // Draw arrows/indicators
    final arrowPaint = Paint()
      ..color = lesson.color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw start indicator
    switch (lesson.lineType) {
      case LineType.horizontal:
        canvas.drawCircle(Offset(size.width * 0.1, center.dy), 15, arrowPaint);
        break;
      case LineType.vertical:
        canvas.drawCircle(Offset(center.dx, size.height * 0.1), 15, arrowPaint);
        break;
      case LineType.slantLeft:
        canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 15, arrowPaint);
        break;
      case LineType.slantRight:
        canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 15, arrowPaint);
        break;
      case LineType.semicircle:
        canvas.drawCircle(Offset(center.dx - size.width / 3, center.dy), 15, arrowPaint);
        break;
      case LineType.circle:
        canvas.drawCircle(Offset(center.dx, center.dy - size.width / 3), 15, arrowPaint);
        break;
    }

    // Draw user path
    if (userPath.isNotEmpty) {
      final userPaint = Paint()
        ..color = levelComplete ? Colors.green : lesson.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(userPath.first.dx, userPath.first.dy);
      for (var point in userPath.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, userPaint);
    }

    // Draw success indicator
    if (levelComplete) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '✓',
          style: TextStyle(fontSize: 80, color: Colors.green),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LineGuidePainter oldDelegate) => true;
}
