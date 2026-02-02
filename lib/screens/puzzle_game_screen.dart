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

  // Puzzle categories with body parts
  final Map<String, List<PuzzleData>> _puzzleCategories = {
    'Animals': [
      PuzzleData(
        name: 'Lion',
        fullEmoji: '🦁',
        color: Colors.orange,
        parts: [
          PuzzlePart(id: 'head', emoji: '🦁', label: 'Head', position: const Offset(0.5, 0.15)),
          PuzzlePart(id: 'body', emoji: '🟠', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'legs', emoji: '🦵', label: 'Legs', position: const Offset(0.5, 0.72)),
          PuzzlePart(id: 'tail', emoji: '〰️', label: 'Tail', position: const Offset(0.85, 0.5)),
        ],
      ),
      PuzzleData(
        name: 'Elephant',
        fullEmoji: '🐘',
        color: Colors.blueGrey,
        parts: [
          PuzzlePart(id: 'head', emoji: '🐘', label: 'Head', position: const Offset(0.5, 0.15)),
          PuzzlePart(id: 'body', emoji: '🔘', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'legs', emoji: '🦶', label: 'Legs', position: const Offset(0.5, 0.75)),
          PuzzlePart(id: 'trunk', emoji: '🌀', label: 'Trunk', position: const Offset(0.2, 0.35)),
        ],
      ),
      PuzzleData(
        name: 'Dog',
        fullEmoji: '🐶',
        color: Colors.brown,
        parts: [
          PuzzlePart(id: 'head', emoji: '🐶', label: 'Head', position: const Offset(0.5, 0.15)),
          PuzzlePart(id: 'body', emoji: '🟤', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'legs', emoji: '🦴', label: 'Legs', position: const Offset(0.5, 0.75)),
          PuzzlePart(id: 'tail', emoji: '🐕', label: 'Tail', position: const Offset(0.85, 0.45)),
        ],
      ),
      PuzzleData(
        name: 'Cat',
        fullEmoji: '🐱',
        color: Colors.amber,
        parts: [
          PuzzlePart(id: 'head', emoji: '🐱', label: 'Head', position: const Offset(0.5, 0.15)),
          PuzzlePart(id: 'body', emoji: '🟡', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'legs', emoji: '🐾', label: 'Paws', position: const Offset(0.5, 0.75)),
          PuzzlePart(id: 'tail', emoji: '🐈', label: 'Tail', position: const Offset(0.85, 0.55)),
        ],
      ),
      PuzzleData(
        name: 'Rabbit',
        fullEmoji: '🐰',
        color: Colors.pink,
        parts: [
          PuzzlePart(id: 'head', emoji: '🐰', label: 'Head', position: const Offset(0.5, 0.15)),
          PuzzlePart(id: 'ears', emoji: '👂', label: 'Ears', position: const Offset(0.5, 0.0)),
          PuzzlePart(id: 'body', emoji: '🩷', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'tail', emoji: '⚪', label: 'Tail', position: const Offset(0.85, 0.5)),
        ],
      ),
    ],
    'Vehicles': [
      PuzzleData(
        name: 'Car',
        fullEmoji: '🚗',
        color: Colors.red,
        parts: [
          PuzzlePart(id: 'roof', emoji: '🔲', label: 'Roof', position: const Offset(0.5, 0.15)),
          PuzzlePart(id: 'body', emoji: '🚗', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'wheels', emoji: '⚫', label: 'Wheels', position: const Offset(0.5, 0.75)),
          PuzzlePart(id: 'lights', emoji: '💡', label: 'Lights', position: const Offset(0.15, 0.45)),
        ],
      ),
      PuzzleData(
        name: 'Airplane',
        fullEmoji: '✈️',
        color: Colors.blue,
        parts: [
          PuzzlePart(id: 'nose', emoji: '▶️', label: 'Nose', position: const Offset(0.15, 0.45)),
          PuzzlePart(id: 'body', emoji: '✈️', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'wings', emoji: '🪽', label: 'Wings', position: const Offset(0.5, 0.3)),
          PuzzlePart(id: 'tail', emoji: '🔺', label: 'Tail', position: const Offset(0.85, 0.35)),
        ],
      ),
      PuzzleData(
        name: 'Train',
        fullEmoji: '🚂',
        color: Colors.grey,
        parts: [
          PuzzlePart(id: 'chimney', emoji: '🏭', label: 'Chimney', position: const Offset(0.3, 0.1)),
          PuzzlePart(id: 'body', emoji: '🚂', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'wheels', emoji: '⚙️', label: 'Wheels', position: const Offset(0.5, 0.75)),
          PuzzlePart(id: 'front', emoji: '🔴', label: 'Front', position: const Offset(0.15, 0.45)),
        ],
      ),
      PuzzleData(
        name: 'Rocket',
        fullEmoji: '🚀',
        color: Colors.purple,
        parts: [
          PuzzlePart(id: 'tip', emoji: '🔺', label: 'Tip', position: const Offset(0.5, 0.1)),
          PuzzlePart(id: 'body', emoji: '🚀', label: 'Body', position: const Offset(0.5, 0.4)),
          PuzzlePart(id: 'fins', emoji: '📐', label: 'Fins', position: const Offset(0.5, 0.65)),
          PuzzlePart(id: 'fire', emoji: '🔥', label: 'Fire', position: const Offset(0.5, 0.85)),
        ],
      ),
      PuzzleData(
        name: 'Bus',
        fullEmoji: '🚌',
        color: Colors.yellow,
        parts: [
          PuzzlePart(id: 'roof', emoji: '🟨', label: 'Roof', position: const Offset(0.5, 0.15)),
          PuzzlePart(id: 'body', emoji: '🚌', label: 'Body', position: const Offset(0.5, 0.45)),
          PuzzlePart(id: 'wheels', emoji: '⚫', label: 'Wheels', position: const Offset(0.5, 0.75)),
          PuzzlePart(id: 'windows', emoji: '🪟', label: 'Windows', position: const Offset(0.5, 0.3)),
        ],
      ),
    ],
    'Fruits': [
      PuzzleData(
        name: 'Apple',
        fullEmoji: '🍎',
        color: Colors.red,
        parts: [
          PuzzlePart(id: 'stem', emoji: '🌿', label: 'Stem', position: const Offset(0.5, 0.1)),
          PuzzlePart(id: 'leaf', emoji: '🍃', label: 'Leaf', position: const Offset(0.65, 0.15)),
          PuzzlePart(id: 'body', emoji: '🍎', label: 'Apple', position: const Offset(0.5, 0.5)),
        ],
      ),
      PuzzleData(
        name: 'Banana',
        fullEmoji: '🍌',
        color: Colors.yellow,
        parts: [
          PuzzlePart(id: 'top', emoji: '🟫', label: 'Top', position: const Offset(0.3, 0.2)),
          PuzzlePart(id: 'body', emoji: '🍌', label: 'Banana', position: const Offset(0.5, 0.5)),
          PuzzlePart(id: 'bottom', emoji: '🟤', label: 'Bottom', position: const Offset(0.7, 0.75)),
        ],
      ),
      PuzzleData(
        name: 'Grapes',
        fullEmoji: '🍇',
        color: Colors.purple,
        parts: [
          PuzzlePart(id: 'stem', emoji: '🌿', label: 'Stem', position: const Offset(0.5, 0.1)),
          PuzzlePart(id: 'top', emoji: '🟣', label: 'Top', position: const Offset(0.5, 0.35)),
          PuzzlePart(id: 'body', emoji: '🍇', label: 'Grapes', position: const Offset(0.5, 0.6)),
        ],
      ),
      PuzzleData(
        name: 'Watermelon',
        fullEmoji: '🍉',
        color: Colors.green,
        parts: [
          PuzzlePart(id: 'rind', emoji: '🟢', label: 'Rind', position: const Offset(0.5, 0.25)),
          PuzzlePart(id: 'flesh', emoji: '🍉', label: 'Flesh', position: const Offset(0.5, 0.5)),
          PuzzlePart(id: 'seeds', emoji: '🖤', label: 'Seeds', position: const Offset(0.5, 0.7)),
        ],
      ),
      PuzzleData(
        name: 'Pineapple',
        fullEmoji: '🍍',
        color: Colors.amber,
        parts: [
          PuzzlePart(id: 'crown', emoji: '👑', label: 'Crown', position: const Offset(0.5, 0.1)),
          PuzzlePart(id: 'body', emoji: '🍍', label: 'Body', position: const Offset(0.5, 0.5)),
          PuzzlePart(id: 'base', emoji: '🟤', label: 'Base', position: const Offset(0.5, 0.8)),
        ],
      ),
    ],
  };

  final Map<String, IconData> _categoryIcons = {
    'Animals': Icons.pets,
    'Vehicles': Icons.directions_car,
    'Fruits': Icons.apple,
  };

  final Map<String, List<Color>> _categoryGradients = {
    'Animals': [Colors.orange.shade200, Colors.amber.shade100],
    'Vehicles': [Colors.blue.shade200, Colors.cyan.shade100],
    'Fruits': [Colors.pink.shade200, Colors.red.shade100],
  };

  String? _selectedCategory;
  int _currentPuzzleIndex = 0;
  int _score = 0;
  Map<String, bool> _placedParts = {}; // Track which parts are placed correctly
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPuzzleIndex = 0;
      _score = 0;
      _setupPuzzle();
    });
  }

  void _setupPuzzle() {
    _placedParts = {};
    _solved = false;
  }

  PuzzleData get _currentPuzzle => _puzzleCategories[_selectedCategory]![_currentPuzzleIndex];

  void _onPartPlaced(String partId) {
    if (_solved) return;

    setState(() {
      _placedParts[partId] = true;
    });

    // Check if puzzle is solved
    if (_placedParts.length == _currentPuzzle.parts.length) {
      _onPuzzleSolved();
    }
  }

  void _onPuzzleSolved() {
    setState(() {
      _solved = true;
      _score += 10;
    });
    _confettiController.play();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final puzzles = _puzzleCategories[_selectedCategory]!;
      if (_currentPuzzleIndex < puzzles.length - 1) {
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
    final puzzles = _puzzleCategories[_selectedCategory]!;
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
              'You built all ${puzzles.length} $_selectedCategory!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedCategory = null;
              });
            },
            child: const Text('Categories'),
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
    if (_selectedCategory == null) {
      return _buildCategorySelection();
    }
    return _buildPuzzleGame();
  }

  Widget _buildCategorySelection() {
    return Scaffold(
      body: Container(
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
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 30),
                    ),
                    const Expanded(
                      child: Text(
                        'Puzzle Pieces',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Puzzle emoji
              const Text(
                '🧩',
                style: TextStyle(fontSize: 80),
              ),

              const SizedBox(height: 20),

              Text(
                'Build the Picture!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Drag body parts to build animals,\nvehicles, and fruits!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.indigo.shade400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Category buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _puzzleCategories.keys.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildCategoryButton(category),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final gradients = _categoryGradients[category]!;
    final icon = _categoryIcons[category]!;
    final puzzles = _puzzleCategories[category]!;
    final emojis = puzzles.map((p) => p.fullEmoji).take(4).join(' ');

    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradients[0].withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    emojis,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleGame() {
    final puzzles = _puzzleCategories[_selectedCategory]!;
    final puzzle = _currentPuzzle;
    final gradients = _categoryGradients[_selectedCategory]!;

    // Get unplaced parts
    List<PuzzlePart> unplacedParts = puzzle.parts
        .where((part) => !_placedParts.containsKey(part.id))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradients,
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
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
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
                          '${_currentPuzzleIndex + 1}/${puzzles.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Title
                  Text(
                    'Build the ${puzzle.name}!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: puzzle.color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Goal: ',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      Text(
                        puzzle.fullEmoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Target puzzle area (where parts should be dropped)
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: puzzle.color.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: puzzle.parts.map((part) {
                            return _buildDropTarget(part, puzzle);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // Draggable parts area
                  Container(
                    height: 130,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: puzzle.color.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Drag the parts:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: unplacedParts.isEmpty
                                ? const Text(
                                    '✓ All parts placed!',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Wrap(
                                    spacing: 15,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: unplacedParts.map((part) {
                                      return _buildDraggablePart(part, puzzle);
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reset button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _setupPuzzle();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: puzzle.color,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Reset',
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
              colors: [
                puzzle.color,
                Colors.amber,
                Colors.white,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      puzzle.fullEmoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                    const Text(
                      'Great Job!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDraggablePart(PuzzlePart part, PuzzleData puzzle) {
    return Draggable<String>(
      data: part.id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: puzzle.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: puzzle.color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(part.emoji, style: const TextStyle(fontSize: 35)),
              Text(
                part.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 2),
        ),
      ),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: puzzle.color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: puzzle.color.withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(part.emoji, style: const TextStyle(fontSize: 28)),
            Text(
              part.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropTarget(PuzzlePart part, PuzzleData puzzle) {
    final isPlaced = _placedParts.containsKey(part.id);
    final size = 65.0;

    return Positioned(
      left: part.position.dx * 280 - size / 2,
      top: part.position.dy * 280 - size / 2,
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          if (details.data == part.id) {
            _onPartPlaced(part.id);
          }
        },
        onWillAcceptWithDetails: (details) => !_solved && details.data == part.id,
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;
          final isWrong = rejectedData.isNotEmpty;

          if (isPlaced) {
            // Show placed part
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(part.emoji, style: const TextStyle(fontSize: 28)),
                  const Text('✓', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            );
          }

          // Empty slot
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.green.withOpacity(0.3)
                  : isWrong
                      ? Colors.red.withOpacity(0.3)
                      : puzzle.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted
                    ? Colors.green
                    : isWrong
                        ? Colors.red
                        : puzzle.color.withOpacity(0.5),
                width: isHighlighted || isWrong ? 3 : 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Text(
                part.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: puzzle.color.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Data classes
class PuzzleData {
  final String name;
  final String fullEmoji;
  final Color color;
  final List<PuzzlePart> parts;

  PuzzleData({
    required this.name,
    required this.fullEmoji,
    required this.color,
    required this.parts,
  });
}

class PuzzlePart {
  final String id;
  final String emoji;
  final String label;
  final Offset position; // Normalized position (0-1) in the target area

  PuzzlePart({
    required this.id,
    required this.emoji,
    required this.label,
    required this.position,
  });
}
