import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MazeGameScreen extends StatefulWidget {
  const MazeGameScreen({super.key});

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends State<MazeGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  int _currentLevel = 0;
  List<Offset> _path = [];
  bool _isDrawing = false;
  bool _levelComplete = false;
  int _completedLevels = 0;

  final List<String> _encouragements = [
    'Great job!',
    'Well done!',
    'Awesome!',
    'You did it!',
    'Fantastic!',
    'Super!',
    'Amazing!',
    'Wonderful!',
  ];

  final List<MazeLevel> _levels = [
    MazeLevel(
      startEmoji: '🐰',
      endEmoji: '🥕',
      startPos: const Offset(0.1, 0.5),
      endPos: const Offset(0.9, 0.5),
      pathColor: Colors.orange,
      bgColor: Colors.green.shade100,
    ),
    MazeLevel(
      startEmoji: '🐝',
      endEmoji: '🌸',
      startPos: const Offset(0.1, 0.2),
      endPos: const Offset(0.9, 0.8),
      pathColor: Colors.amber,
      bgColor: Colors.yellow.shade100,
    ),
    MazeLevel(
      startEmoji: '🚗',
      endEmoji: '🏠',
      startPos: const Offset(0.1, 0.8),
      endPos: const Offset(0.9, 0.2),
      pathColor: Colors.blue,
      bgColor: Colors.blue.shade50,
    ),
    MazeLevel(
      startEmoji: '🐶',
      endEmoji: '🦴',
      startPos: const Offset(0.5, 0.1),
      endPos: const Offset(0.5, 0.9),
      pathColor: Colors.brown,
      bgColor: Colors.brown.shade50,
    ),
    MazeLevel(
      startEmoji: '🚀',
      endEmoji: '⭐',
      startPos: const Offset(0.2, 0.9),
      endPos: const Offset(0.8, 0.1),
      pathColor: Colors.purple,
      bgColor: Colors.purple.shade50,
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

  void _onPanStart(DragStartDetails details, Size size) {
    final level = _levels[_currentLevel];
    final startPoint = Offset(
      level.startPos.dx * size.width,
      level.startPos.dy * size.height,
    );

    final touchPoint = details.localPosition;
    final distance = (touchPoint - startPoint).distance;

    if (distance < 50) {
      setState(() {
        _isDrawing = true;
        _path = [details.localPosition];
        _levelComplete = false;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!_isDrawing) return;

    setState(() {
      _path.add(details.localPosition);
    });

    // Check if reached end
    final level = _levels[_currentLevel];
    final endPoint = Offset(
      level.endPos.dx * size.width,
      level.endPos.dy * size.height,
    );

    final distance = (details.localPosition - endPoint).distance;
    if (distance < 40) {
      _completeLevel();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_levelComplete) {
      setState(() {
        _isDrawing = false;
        _path = [];
      });
    }
  }

  void _completeLevel() async {
    if (_levelComplete) return; // Prevent multiple calls

    setState(() {
      _isDrawing = false;
      _levelComplete = true;
      _completedLevels++;
    });

    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      // Sound file may not exist, continue anyway
    }
    _confettiController.play();

    // Speak encouragement
    _speak(_getRandomEncouragement());

    await Future.delayed(const Duration(seconds: 2));

    if (_currentLevel < _levels.length - 1) {
      setState(() {
        _currentLevel++;
        _path = [];
        _levelComplete = false;
      });
    } else {
      _speak('You completed all mazes! You are a star!');
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.purple.shade100,
        title: const Text(
          '🎉 Fantastic! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You completed all mazes!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('🌟🌟🌟🌟🌟', style: TextStyle(fontSize: 35)),
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
                  _path = [];
                  _levelComplete = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Play Again!',
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
    final level = _levels[_currentLevel];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [level.bgColor, Colors.white],
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
                          color: Colors.purple,
                        ),
                        Expanded(
                          child: Text(
                            'Maze Fun',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Level indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_levels.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: index < _completedLevels
                                ? Colors.green
                                : (index == _currentLevel
                                    ? Colors.purple
                                    : Colors.grey.shade300),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: index < _completedLevels
                                ? const Icon(Icons.check, color: Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: index == _currentLevel
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Instructions
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(level.startEmoji, style: const TextStyle(fontSize: 30)),
                        const Icon(Icons.arrow_forward, size: 30, color: Colors.purple),
                        Text(level.endEmoji, style: const TextStyle(fontSize: 30)),
                        const SizedBox(width: 10),
                        const Text(
                          'Draw a path!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Maze area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: level.pathColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: level.pathColor.withOpacity(0.3),
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
                              onPanStart: (d) => _onPanStart(d, size),
                              onPanUpdate: (d) => _onPanUpdate(d, size),
                              onPanEnd: _onPanEnd,
                              child: CustomPaint(
                                size: size,
                                painter: MazePainter(
                                  level: level,
                                  path: _path,
                                  levelComplete: _levelComplete,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Reset button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _path = [];
                          _levelComplete = false;
                        });
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
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

class MazeLevel {
  final String startEmoji;
  final String endEmoji;
  final Offset startPos;
  final Offset endPos;
  final Color pathColor;
  final Color bgColor;

  MazeLevel({
    required this.startEmoji,
    required this.endEmoji,
    required this.startPos,
    required this.endPos,
    required this.pathColor,
    required this.bgColor,
  });
}

class MazePainter extends CustomPainter {
  final MazeLevel level;
  final List<Offset> path;
  final bool levelComplete;

  MazePainter({
    required this.level,
    required this.path,
    required this.levelComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background pattern
    final bgPaint = Paint()
      ..color = level.bgColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw dotted guide line
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final startPoint = Offset(
      level.startPos.dx * size.width,
      level.startPos.dy * size.height,
    );
    final endPoint = Offset(
      level.endPos.dx * size.width,
      level.endPos.dy * size.height,
    );

    // Draw dashed line
    const dashLength = 10.0;
    const dashGap = 8.0;
    final totalDistance = (endPoint - startPoint).distance;
    final direction = (endPoint - startPoint) / totalDistance;

    double currentDistance = 0;
    while (currentDistance < totalDistance) {
      final dashStart = startPoint + direction * currentDistance;
      final dashEnd = startPoint + direction * (currentDistance + dashLength).clamp(0, totalDistance);
      canvas.drawLine(dashStart, dashEnd, guidePaint);
      currentDistance += dashLength + dashGap;
    }

    // Draw user's path
    if (path.isNotEmpty) {
      final pathPaint = Paint()
        ..color = levelComplete ? Colors.green : level.pathColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final pathPath = Path();
      pathPath.moveTo(path.first.dx, path.first.dy);
      for (var point in path.skip(1)) {
        pathPath.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(pathPath, pathPaint);
    }

    // Draw start circle
    final startCirclePaint = Paint()
      ..color = Colors.green.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPoint, 35, startCirclePaint);

    // Draw end circle
    final endCirclePaint = Paint()
      ..color = levelComplete ? Colors.green : Colors.red.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 35, endCirclePaint);

    // Draw emojis
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: level.startEmoji,
      style: const TextStyle(fontSize: 40),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      startPoint - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    textPainter.text = TextSpan(
      text: level.endEmoji,
      style: const TextStyle(fontSize: 40),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      endPoint - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Draw success checkmark
    if (levelComplete) {
      textPainter.text = const TextSpan(
        text: '✅',
        style: TextStyle(fontSize: 50),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MazePainter oldDelegate) => true;
}
