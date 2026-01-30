import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class ConnectDotsGameScreen extends StatefulWidget {
  const ConnectDotsGameScreen({super.key});

  @override
  State<ConnectDotsGameScreen> createState() => _ConnectDotsGameScreenState();
}

class _ConnectDotsGameScreenState extends State<ConnectDotsGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  int _currentLevel = 0;
  List<int> _connectedDots = [];
  bool _levelComplete = false;
  int _completedLevels = 0;
  bool _isDragging = false;
  Offset? _currentDragPosition;

  final List<DotPuzzle> _puzzles = [
    // Star
    DotPuzzle(
      name: 'Star',
      emoji: '⭐',
      color: Colors.amber,
      dots: [
        DotPoint(0.5, 0.1, 1),  // top
        DotPoint(0.35, 0.4, 2), // left upper
        DotPoint(0.1, 0.4, 3),  // far left
        DotPoint(0.3, 0.6, 4),  // left lower
        DotPoint(0.2, 0.9, 5),  // bottom left
        DotPoint(0.5, 0.75, 6), // bottom center
        DotPoint(0.8, 0.9, 7),  // bottom right
        DotPoint(0.7, 0.6, 8),  // right lower
        DotPoint(0.9, 0.4, 9),  // far right
        DotPoint(0.65, 0.4, 10),// right upper
      ],
    ),
    // House
    DotPuzzle(
      name: 'House',
      emoji: '🏠',
      color: Colors.brown,
      dots: [
        DotPoint(0.5, 0.1, 1),  // roof top
        DotPoint(0.2, 0.4, 2),  // roof left
        DotPoint(0.2, 0.9, 3),  // bottom left
        DotPoint(0.8, 0.9, 4),  // bottom right
        DotPoint(0.8, 0.4, 5),  // roof right
      ],
    ),
    // Heart
    DotPuzzle(
      name: 'Heart',
      emoji: '❤️',
      color: Colors.red,
      dots: [
        DotPoint(0.5, 0.3, 1),  // top center
        DotPoint(0.3, 0.2, 2),  // left hump
        DotPoint(0.15, 0.35, 3),// left side
        DotPoint(0.25, 0.55, 4),// left lower
        DotPoint(0.5, 0.85, 5), // bottom point
        DotPoint(0.75, 0.55, 6),// right lower
        DotPoint(0.85, 0.35, 7),// right side
        DotPoint(0.7, 0.2, 8),  // right hump
      ],
    ),
    // Fish
    DotPuzzle(
      name: 'Fish',
      emoji: '🐟',
      color: Colors.blue,
      dots: [
        DotPoint(0.15, 0.5, 1),  // tail left
        DotPoint(0.3, 0.35, 2),  // tail top
        DotPoint(0.3, 0.65, 3),  // tail bottom
        DotPoint(0.5, 0.3, 4),   // body top
        DotPoint(0.75, 0.5, 5),  // nose
        DotPoint(0.5, 0.7, 6),   // body bottom
      ],
    ),
    // Tree
    DotPuzzle(
      name: 'Tree',
      emoji: '🌲',
      color: Colors.green,
      dots: [
        DotPoint(0.5, 0.05, 1),  // top
        DotPoint(0.25, 0.35, 2), // left 1
        DotPoint(0.35, 0.35, 3), // inner left 1
        DotPoint(0.2, 0.55, 4),  // left 2
        DotPoint(0.35, 0.55, 5), // inner left 2
        DotPoint(0.15, 0.75, 6), // left 3
        DotPoint(0.4, 0.75, 7),  // trunk left
        DotPoint(0.4, 0.95, 8),  // trunk bottom left
        DotPoint(0.6, 0.95, 9),  // trunk bottom right
        DotPoint(0.6, 0.75, 10), // trunk right
        DotPoint(0.85, 0.75, 11),// right 3
        DotPoint(0.65, 0.55, 12),// inner right 2
        DotPoint(0.8, 0.55, 13), // right 2
        DotPoint(0.65, 0.35, 14),// inner right 1
        DotPoint(0.75, 0.35, 15),// right 1
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details, Size size) {
    if (_levelComplete) return;

    final puzzle = _puzzles[_currentLevel];
    final expectedNext = _connectedDots.length + 1;

    // Check if starting near the next expected dot (or dot 1 if starting fresh)
    for (var dot in puzzle.dots) {
      if (dot.number == expectedNext) {
        final dotPos = Offset(dot.x * size.width, dot.y * size.height);
        final distance = (details.localPosition - dotPos).distance;

        if (distance < 40) {
          setState(() {
            _isDragging = true;
            _currentDragPosition = details.localPosition;
            _connectedDots.add(dot.number);
          });

          try {
            _audioPlayer.play(AssetSource('sounds/pop.mp3'));
          } catch (e) {
            // Sound file may not exist
          }

          // Check if this completes the puzzle
          if (_connectedDots.length == puzzle.dots.length) {
            _completeLevel();
          }
          break;
        }
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!_isDragging || _levelComplete) return;

    setState(() {
      _currentDragPosition = details.localPosition;
    });

    final puzzle = _puzzles[_currentLevel];
    final expectedNext = _connectedDots.length + 1;

    // Check if dragging over the next expected dot
    for (var dot in puzzle.dots) {
      if (dot.number == expectedNext) {
        final dotPos = Offset(dot.x * size.width, dot.y * size.height);
        final distance = (details.localPosition - dotPos).distance;

        if (distance < 35) {
          setState(() {
            _connectedDots.add(dot.number);
          });

          try {
            _audioPlayer.play(AssetSource('sounds/pop.mp3'));
          } catch (e) {
            // Sound file may not exist
          }

          // Check if this completes the puzzle
          if (_connectedDots.length == puzzle.dots.length) {
            _completeLevel();
          }
          break;
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _currentDragPosition = null;
    });
  }

  void _completeLevel() async {
    if (_levelComplete) return; // Prevent multiple calls

    setState(() {
      _levelComplete = true;
      _completedLevels++;
    });

    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      // Sound file may not exist
    }
    _confettiController.play();

    await Future.delayed(const Duration(seconds: 2));

    if (_currentLevel < _puzzles.length - 1) {
      setState(() {
        _currentLevel++;
        _connectedDots = [];
        _levelComplete = false;
      });
    } else {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.blue.shade100,
        title: const Text(
          '🎨 Amazing Artist! 🎨',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You connected all the dots!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('⭐🏠❤️🐟🌲', style: TextStyle(fontSize: 30)),
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
                  _connectedDots = [];
                  _levelComplete = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
    final puzzle = _puzzles[_currentLevel];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [puzzle.color.withOpacity(0.3), Colors.white],
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
                          color: puzzle.color,
                        ),
                        Expanded(
                          child: Text(
                            'Connect the Dots',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: puzzle.color,
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
                      children: List.generate(_puzzles.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _puzzles[index].emoji,
                            style: TextStyle(
                              fontSize: index < _completedLevels ? 30 : 25,
                              color: index < _completedLevels
                                  ? null
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Current puzzle info
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
                        Text(
                          'Draw a ${puzzle.name}! ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(puzzle.emoji, style: const TextStyle(fontSize: 30)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Dot canvas
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: puzzle.color, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: puzzle.color.withOpacity(0.3),
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
                              child: Stack(
                                children: [
                                  // Lines painter
                                  CustomPaint(
                                    size: size,
                                    painter: DotLinePainter(
                                      puzzle: puzzle,
                                      connectedDots: _connectedDots,
                                      levelComplete: _levelComplete,
                                      currentDragPosition: _currentDragPosition,
                                      isDragging: _isDragging,
                                    ),
                                  ),
                                  // Dots
                                  ...puzzle.dots.map((dot) {
                                    final isConnected = _connectedDots.contains(dot.number);
                                    final isNext = dot.number == _connectedDots.length + 1;

                                    return Positioned(
                                      left: dot.x * size.width - 25,
                                      top: dot.y * size.height - 25,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isConnected
                                              ? puzzle.color
                                              : (isNext
                                                  ? puzzle.color.withOpacity(0.5)
                                                  : Colors.grey.shade300),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isNext
                                                ? puzzle.color
                                                : Colors.grey,
                                            width: isNext ? 3 : 2,
                                          ),
                                          boxShadow: isNext
                                              ? [
                                                  BoxShadow(
                                                    color: puzzle.color.withOpacity(0.5),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${dot.number}',
                                            style: TextStyle(
                                              color: isConnected
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  // Show emoji when complete
                                  if (_levelComplete)
                                    Center(
                                      child: Text(
                                        puzzle.emoji,
                                        style: const TextStyle(fontSize: 80),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Progress text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Connect: ${_connectedDots.length} / ${puzzle.dots.length}',
                      style: TextStyle(
                        fontSize: 18,
                        color: puzzle.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Reset button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _connectedDots = [];
                          _levelComplete = false;
                        });
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Start Over',
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

class DotPoint {
  final double x;
  final double y;
  final int number;

  DotPoint(this.x, this.y, this.number);
}

class DotPuzzle {
  final String name;
  final String emoji;
  final Color color;
  final List<DotPoint> dots;

  DotPuzzle({
    required this.name,
    required this.emoji,
    required this.color,
    required this.dots,
  });
}

class DotLinePainter extends CustomPainter {
  final DotPuzzle puzzle;
  final List<int> connectedDots;
  final bool levelComplete;
  final Offset? currentDragPosition;
  final bool isDragging;

  DotLinePainter({
    required this.puzzle,
    required this.connectedDots,
    required this.levelComplete,
    this.currentDragPosition,
    this.isDragging = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = levelComplete ? puzzle.color : puzzle.color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = levelComplete ? 6 : 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (connectedDots.isEmpty) return;

    final path = Path();

    for (int i = 0; i < connectedDots.length; i++) {
      final dotNum = connectedDots[i];
      final dot = puzzle.dots.firstWhere((d) => d.number == dotNum);
      final point = Offset(dot.x * size.width, dot.y * size.height);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    // Draw line to current drag position
    if (isDragging && currentDragPosition != null && !levelComplete) {
      path.lineTo(currentDragPosition!.dx, currentDragPosition!.dy);
    }

    // Close the shape when complete
    if (levelComplete && connectedDots.length == puzzle.dots.length) {
      final firstDot = puzzle.dots.firstWhere((d) => d.number == 1);
      path.lineTo(firstDot.x * size.width, firstDot.y * size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DotLinePainter oldDelegate) => true;
}
