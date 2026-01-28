import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> _puzzles = [
    {'emoji': '🐶', 'name': 'Dog', 'color': Colors.brown},
    {'emoji': '🐱', 'name': 'Cat', 'color': Colors.orange},
    {'emoji': '🦁', 'name': 'Lion', 'color': Colors.amber},
    {'emoji': '🐘', 'name': 'Elephant', 'color': Colors.grey},
    {'emoji': '🌸', 'name': 'Flower', 'color': Colors.pink},
    {'emoji': '🌈', 'name': 'Rainbow', 'color': Colors.purple},
    {'emoji': '🚗', 'name': 'Car', 'color': Colors.red},
    {'emoji': '🏠', 'name': 'House', 'color': Colors.blue},
  ];

  int _currentPuzzleIndex = 0;
  int _score = 0;
  List<int> _tileOrder = [];
  int? _selectedTile;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _setupPuzzle();
  }

  void _setupPuzzle() {
    _tileOrder = List.generate(9, (i) => i);
    // Shuffle but ensure it's solvable
    do {
      _tileOrder.shuffle();
    } while (_isSolved() || !_isSolvable());
    _solved = false;
    _selectedTile = null;
  }

  bool _isSolvable() {
    int inversions = 0;
    for (int i = 0; i < _tileOrder.length - 1; i++) {
      for (int j = i + 1; j < _tileOrder.length; j++) {
        if (_tileOrder[i] > _tileOrder[j]) {
          inversions++;
        }
      }
    }
    return inversions % 2 == 0;
  }

  bool _isSolved() {
    for (int i = 0; i < _tileOrder.length; i++) {
      if (_tileOrder[i] != i) return false;
    }
    return true;
  }

  void _swapTiles(int index) {
    if (_solved) return;

    if (_selectedTile == null) {
      setState(() {
        _selectedTile = index;
      });
    } else {
      // Check if adjacent
      int row1 = _selectedTile! ~/ 3;
      int col1 = _selectedTile! % 3;
      int row2 = index ~/ 3;
      int col2 = index % 3;

      bool isAdjacent = (row1 == row2 && (col1 - col2).abs() == 1) ||
          (col1 == col2 && (row1 - row2).abs() == 1);

      if (isAdjacent) {
        setState(() {
          int temp = _tileOrder[_selectedTile!];
          _tileOrder[_selectedTile!] = _tileOrder[index];
          _tileOrder[index] = temp;
          _selectedTile = null;
        });

        if (_isSolved()) {
          _onPuzzleSolved();
        }
      } else {
        setState(() {
          _selectedTile = index;
        });
      }
    }
  }

  void _onPuzzleSolved() {
    setState(() {
      _solved = true;
      _score += 10;
    });
    _confettiController.play();

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentPuzzleIndex < _puzzles.length - 1) {
        setState(() {
          _currentPuzzleIndex++;
          _setupPuzzle();
        });
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.indigo.shade50,
        title: const Column(
          children: [
            Text('🧩', style: TextStyle(fontSize: 50)),
            SizedBox(height: 10),
            Text('Puzzle Master!', style: TextStyle(color: Colors.indigo)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You completed all ${_puzzles.length} puzzles!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => const Icon(Icons.star, color: Colors.amber, size: 40),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentPuzzleIndex = 0;
                _score = 0;
                _setupPuzzle();
              });
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzles[_currentPuzzleIndex];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade200, Colors.purple.shade100],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 30),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_currentPuzzleIndex + 1}/${_puzzles.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Title
                  Text(
                    'Arrange the ${puzzle['name']}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap two adjacent tiles to swap them',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.indigo.shade400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reference image
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Goal:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          puzzle['emoji'] as String,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Puzzle grid
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade200,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            int tileNumber = _tileOrder[index];
                            bool isSelected = _selectedTile == index;

                            return GestureDetector(
                              onTap: () => _swapTiles(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: _solved
                                      ? Colors.green.shade100
                                      : (isSelected
                                          ? Colors.amber.shade200
                                          : (puzzle['color'] as Color).withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.amber
                                        : (puzzle['color'] as Color).withOpacity(0.5),
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${tileNumber + 1}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: puzzle['color'] as Color,
                                    ),
                                  ),
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
                          _setupPuzzle();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Shuffle',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.indigo,
                Colors.purple,
                Colors.blue,
                Colors.pink,
              ],
            ),
          ),

          // Solved overlay
          if (_solved)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✓ Solved!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}