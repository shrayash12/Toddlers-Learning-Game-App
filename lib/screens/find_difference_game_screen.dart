import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class FindDifferenceGameScreen extends StatefulWidget {
  const FindDifferenceGameScreen({super.key});

  @override
  State<FindDifferenceGameScreen> createState() => _FindDifferenceGameScreenState();
}

class _FindDifferenceGameScreenState extends State<FindDifferenceGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  int _currentLevel = 0;
  Set<int> _foundDifferences = {};
  bool _levelComplete = false;
  int _completedLevels = 0;

  final List<DifferencePuzzle> _puzzles = [
    DifferencePuzzle(
      theme: 'Garden',
      bgColor: Colors.green.shade100,
      baseItems: [
        PuzzleItem('🌻', 0.2, 0.2),
        PuzzleItem('🌻', 0.5, 0.2),
        PuzzleItem('🌻', 0.8, 0.2),
        PuzzleItem('🌳', 0.2, 0.5),
        PuzzleItem('🦋', 0.5, 0.5),
        PuzzleItem('🌳', 0.8, 0.5),
        PuzzleItem('🌷', 0.3, 0.8),
        PuzzleItem('🐝', 0.6, 0.8),
      ],
      differences: [
        Difference(1, '🌸', 0.5, 0.2), // sunflower -> cherry blossom
        Difference(4, '🐛', 0.5, 0.5), // butterfly -> caterpillar
        Difference(7, '🐞', 0.6, 0.8), // bee -> ladybug
      ],
    ),
    DifferencePuzzle(
      theme: 'Farm',
      bgColor: Colors.amber.shade100,
      baseItems: [
        PuzzleItem('🐄', 0.2, 0.2),
        PuzzleItem('🐷', 0.5, 0.2),
        PuzzleItem('🐔', 0.8, 0.2),
        PuzzleItem('🏠', 0.2, 0.5),
        PuzzleItem('🚜', 0.5, 0.5),
        PuzzleItem('🌾', 0.8, 0.5),
        PuzzleItem('🐴', 0.3, 0.8),
        PuzzleItem('🐑', 0.7, 0.8),
      ],
      differences: [
        Difference(1, '🐖', 0.5, 0.2), // pig -> different pig
        Difference(5, '🌽', 0.8, 0.5), // wheat -> corn
        Difference(6, '🦙', 0.3, 0.8), // horse -> llama
      ],
    ),
    DifferencePuzzle(
      theme: 'Ocean',
      bgColor: Colors.blue.shade100,
      baseItems: [
        PuzzleItem('🐠', 0.2, 0.2),
        PuzzleItem('🐡', 0.5, 0.2),
        PuzzleItem('🦀', 0.8, 0.2),
        PuzzleItem('🐙', 0.2, 0.5),
        PuzzleItem('🐚', 0.5, 0.5),
        PuzzleItem('🦑', 0.8, 0.5),
        PuzzleItem('🐬', 0.3, 0.8),
        PuzzleItem('🐢', 0.7, 0.8),
      ],
      differences: [
        Difference(0, '🐟', 0.2, 0.2), // tropical fish -> fish
        Difference(3, '🦐', 0.2, 0.5), // octopus -> shrimp
        Difference(7, '🦭', 0.7, 0.8), // turtle -> seal
      ],
    ),
    DifferencePuzzle(
      theme: 'Space',
      bgColor: Colors.indigo.shade100,
      baseItems: [
        PuzzleItem('🌟', 0.2, 0.2),
        PuzzleItem('🌙', 0.5, 0.2),
        PuzzleItem('⭐', 0.8, 0.2),
        PuzzleItem('🚀', 0.2, 0.5),
        PuzzleItem('🌍', 0.5, 0.5),
        PuzzleItem('👽', 0.8, 0.5),
        PuzzleItem('🛸', 0.3, 0.8),
        PuzzleItem('☄️', 0.7, 0.8),
      ],
      differences: [
        Difference(1, '🌕', 0.5, 0.2), // crescent -> full moon
        Difference(4, '🪐', 0.5, 0.5), // earth -> saturn
        Difference(6, '🛰️', 0.3, 0.8), // ufo -> satellite
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

  void _onDifferenceTapped(int diffIndex) async {
    if (_foundDifferences.contains(diffIndex) || _levelComplete) return;

    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));

    setState(() {
      _foundDifferences.add(diffIndex);
    });

    final puzzle = _puzzles[_currentLevel];
    if (_foundDifferences.length == puzzle.differences.length) {
      _completeLevel();
    }
  }

  void _onWrongTap() async {
    await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
  }

  void _completeLevel() async {
    setState(() {
      _levelComplete = true;
      _completedLevels++;
    });

    _confettiController.play();

    await Future.delayed(const Duration(seconds: 2));

    if (_currentLevel < _puzzles.length - 1) {
      setState(() {
        _currentLevel++;
        _foundDifferences = {};
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
        backgroundColor: Colors.purple.shade100,
        title: const Text(
          '👀 Eagle Eyes! 👀',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You found all the differences!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('🏆🌟🏆', style: TextStyle(fontSize: 40)),
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
                  _foundDifferences = {};
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

  Widget _buildPuzzleImage(DifferencePuzzle puzzle, bool isRight) {
    return Container(
      decoration: BoxDecoration(
        color: puzzle.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.brown, width: 3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              // Base items
              ...puzzle.baseItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                // Check if this item has a difference
                final diffIndex = puzzle.differences.indexWhere((d) => d.baseIndex == index);
                final hasDiff = diffIndex >= 0;
                final isFound = _foundDifferences.contains(diffIndex);

                if (isRight && hasDiff) {
                  final diff = puzzle.differences[diffIndex];
                  return Positioned(
                    left: diff.x * size.width - 25,
                    top: diff.y * size.height - 25,
                    child: GestureDetector(
                      onTap: () => _onDifferenceTapped(diffIndex),
                      child: Stack(
                        children: [
                          Text(diff.emoji, style: const TextStyle(fontSize: 40)),
                          if (isFound)
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.green, width: 3),
                              ),
                              child: const Center(
                                child: Icon(Icons.check, color: Colors.green, size: 30),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return Positioned(
                  left: item.x * size.width - 25,
                  top: item.y * size.height - 25,
                  child: GestureDetector(
                    onTap: _onWrongTap,
                    child: Text(item.emoji, style: const TextStyle(fontSize: 40)),
                  ),
                );
              }),
            ],
          );
        },
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
            colors: [puzzle.bgColor, Colors.white],
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
                          color: Colors.brown,
                        ),
                        Expanded(
                          child: Text(
                            'Find Differences',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Theme and progress
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${puzzle.theme} Scene',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Found: ${_foundDifferences.length} / ${puzzle.differences.length}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 10),
                            ...List.generate(puzzle.differences.length, (i) {
                              return Icon(
                                _foundDifferences.contains(i)
                                    ? Icons.circle
                                    : Icons.circle_outlined,
                                color: _foundDifferences.contains(i)
                                    ? Colors.green
                                    : Colors.grey,
                                size: 20,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Instructions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Tap the differences in the RIGHT picture!',
                      style: TextStyle(fontSize: 14, color: Colors.brown),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Two pictures side by side
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Left picture (original)
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Original',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _buildPuzzleImage(puzzle, false),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Right picture (with differences)
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Different',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _buildPuzzleImage(puzzle, true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Level progress
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_puzzles.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: index < _completedLevels
                                ? Colors.green
                                : (index == _currentLevel
                                    ? Colors.orange
                                    : Colors.grey.shade300),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: index < _completedLevels
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
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

class PuzzleItem {
  final String emoji;
  final double x;
  final double y;

  PuzzleItem(this.emoji, this.x, this.y);
}

class Difference {
  final int baseIndex;
  final String emoji;
  final double x;
  final double y;

  Difference(this.baseIndex, this.emoji, this.x, this.y);
}

class DifferencePuzzle {
  final String theme;
  final Color bgColor;
  final List<PuzzleItem> baseItems;
  final List<Difference> differences;

  DifferencePuzzle({
    required this.theme,
    required this.bgColor,
    required this.baseItems,
    required this.differences,
  });
}
