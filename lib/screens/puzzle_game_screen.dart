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

  static const double _aspectRatio = 1.5;

  final Map<String, List<PuzzleData>> _puzzleCategories = {
    'Animals': [
      PuzzleData(name: 'Lion', color: Colors.orange, parts: [
        PuzzlePart(id: 'head', label: 'Head', sliceStart: 0.0, sliceEnd: 0.35),
        PuzzlePart(id: 'body', label: 'Body', sliceStart: 0.35, sliceEnd: 0.60),
        PuzzlePart(id: 'legs', label: 'Legs', sliceStart: 0.60, sliceEnd: 0.82),
        PuzzlePart(id: 'paws', label: 'Paws', sliceStart: 0.82, sliceEnd: 1.0),
      ]),
      PuzzleData(name: 'Elephant', color: Colors.blueGrey, parts: [
        PuzzlePart(id: 'head', label: 'Head', sliceStart: 0.0, sliceEnd: 0.38),
        PuzzlePart(id: 'body', label: 'Body', sliceStart: 0.38, sliceEnd: 0.62),
        PuzzlePart(id: 'legs', label: 'Legs', sliceStart: 0.62, sliceEnd: 0.85),
        PuzzlePart(id: 'paws', label: 'Feet', sliceStart: 0.85, sliceEnd: 1.0),
      ]),
      PuzzleData(name: 'Cat', color: Colors.amber, parts: [
        PuzzlePart(id: 'head', label: 'Head', sliceStart: 0.0, sliceEnd: 0.36),
        PuzzlePart(id: 'body', label: 'Body', sliceStart: 0.36, sliceEnd: 0.60),
        PuzzlePart(id: 'legs', label: 'Legs', sliceStart: 0.60, sliceEnd: 0.82),
        PuzzlePart(id: 'paws', label: 'Paws', sliceStart: 0.82, sliceEnd: 1.0),
      ]),
    ],
    'Vehicles': [
      PuzzleData(name: 'Car', color: Colors.red, parts: [
        PuzzlePart(id: 'top', label: 'Roof', sliceStart: 0.0, sliceEnd: 0.35),
        PuzzlePart(id: 'body', label: 'Body', sliceStart: 0.35, sliceEnd: 0.62),
        PuzzlePart(id: 'wheels', label: 'Wheels', sliceStart: 0.62, sliceEnd: 0.85),
        PuzzlePart(id: 'road', label: 'Road', sliceStart: 0.85, sliceEnd: 1.0),
      ]),
      PuzzleData(name: 'Rocket', color: Colors.deepPurple, parts: [
        PuzzlePart(id: 'nose', label: 'Nose', sliceStart: 0.0, sliceEnd: 0.28),
        PuzzlePart(id: 'body', label: 'Body', sliceStart: 0.28, sliceEnd: 0.58),
        PuzzlePart(id: 'fins', label: 'Fins', sliceStart: 0.58, sliceEnd: 0.80),
        PuzzlePart(id: 'fire', label: 'Fire', sliceStart: 0.80, sliceEnd: 1.0),
      ]),
      PuzzleData(name: 'Train', color: Colors.green, parts: [
        PuzzlePart(id: 'chimney', label: 'Chimney', sliceStart: 0.0, sliceEnd: 0.30),
        PuzzlePart(id: 'cabin', label: 'Cabin', sliceStart: 0.30, sliceEnd: 0.55),
        PuzzlePart(id: 'body', label: 'Body', sliceStart: 0.55, sliceEnd: 0.80),
        PuzzlePart(id: 'wheels', label: 'Wheels', sliceStart: 0.80, sliceEnd: 1.0),
      ]),
    ],
    'Fruits': [
      PuzzleData(name: 'Apple', color: Colors.red, parts: [
        PuzzlePart(id: 'stem', label: 'Stem', sliceStart: 0.0, sliceEnd: 0.30),
        PuzzlePart(id: 'top', label: 'Top', sliceStart: 0.30, sliceEnd: 0.60),
        PuzzlePart(id: 'bottom', label: 'Bottom', sliceStart: 0.60, sliceEnd: 1.0),
      ]),
      PuzzleData(name: 'Watermelon', color: Colors.green, parts: [
        PuzzlePart(
            id: 'rind', label: 'Rind', sliceStart: 0.0, sliceEnd: 0.35),
        PuzzlePart(
            id: 'flesh', label: 'Red Part', sliceStart: 0.35, sliceEnd: 0.70),
        PuzzlePart(
            id: 'seeds', label: 'Seeds', sliceStart: 0.70, sliceEnd: 1.0),
      ]),
      PuzzleData(name: 'Pineapple', color: Colors.amber, parts: [
        PuzzlePart(
            id: 'crown', label: 'Crown', sliceStart: 0.0, sliceEnd: 0.35),
        PuzzlePart(
            id: 'body', label: 'Body', sliceStart: 0.35, sliceEnd: 0.70),
        PuzzlePart(
            id: 'base', label: 'Base', sliceStart: 0.70, sliceEnd: 1.0),
      ]),
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
  Map<int, String> _slotPlacements = {};
  List<String> _shuffledPartIds = [];
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  PuzzleData get _currentPuzzle =>
      _puzzleCategories[_selectedCategory!]![_currentPuzzleIndex];

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPuzzleIndex = 0;
      _score = 0;
      _setupPuzzle();
    });
  }

  void _setupPuzzle() {
    final puzzle = _currentPuzzle;
    _slotPlacements = {};
    _shuffledPartIds = puzzle.parts.map((p) => p.id).toList()..shuffle();
    _solved = false;
  }

  bool _isPartPlaced(String partId) => _slotPlacements.containsValue(partId);

  void _onPartDroppedOnSlot(String partId, int slotIndex) {
    if (_solved) return;
    setState(() {
      _slotPlacements.removeWhere((_, v) => v == partId);
      _slotPlacements.remove(slotIndex);
      _slotPlacements[slotIndex] = partId;
    });
    _checkSolved();
  }

  void _checkSolved() {
    final puzzle = _currentPuzzle;
    if (_slotPlacements.length != puzzle.parts.length) return;
    for (int i = 0; i < puzzle.parts.length; i++) {
      if (_slotPlacements[i] != puzzle.parts[i].id) return;
    }
    _onPuzzleSolved();
  }

  void _onPuzzleSolved() {
    setState(() {
      _solved = true;
      _score += 10;
    });
    _confettiController.play();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final puzzles = _puzzleCategories[_selectedCategory!]!;
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
    final puzzles = _puzzleCategories[_selectedCategory!]!;
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
            Text('You built all ${puzzles.length} $_selectedCategory!',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Score: $_score',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (_) =>
                      const Icon(Icons.star, color: Colors.amber, size: 40)),
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
              setState(() => _selectedCategory = null);
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

  // ─── Build ───
  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) return _buildCategorySelection();
    return _buildPuzzleGame();
  }

  // ─── Category Selection ───
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 30)),
                    const Expanded(
                      child: Text('Puzzle Pieces',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Text('✂️', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 10),
              Text('Cut & Glue!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700)),
              const SizedBox(height: 5),
              Text('Match the parts to build the picture!',
                  style:
                      TextStyle(fontSize: 14, color: Colors.indigo.shade400)),
              const SizedBox(height: 25),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _puzzleCategories.keys
                        .map((cat) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildCategoryButton(cat)))
                        .toList(),
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

    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradients,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: gradients[0].withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(category,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ─── Puzzle Game ───
  Widget _buildPuzzleGame() {
    final puzzle = _currentPuzzle;
    final puzzles = _puzzleCategories[_selectedCategory!]!;
    final unplacedPartIds =
        _shuffledPartIds.where((id) => !_isPartPlaced(id)).toList();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.amber.shade50, Colors.orange.shade50],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () =>
                                setState(() => _selectedCategory = null),
                            icon: const Icon(Icons.arrow_back, size: 26)),
                        Text('Build: ${puzzle.name}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: puzzle.color)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text('$_score',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                            '${_currentPuzzleIndex + 1}/${puzzles.length}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // Main area: Reference + Build Zone
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Reference image
                          _buildReferenceCard(puzzle),
                          const SizedBox(width: 10),
                          // Build zone
                          Expanded(child: _buildBuildZone(puzzle)),
                        ],
                      ),
                    ),
                  ),

                  // Pieces tray
                  _buildPiecesTray(puzzle, unplacedPartIds),

                  // Reset
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _setupPuzzle()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: puzzle.color,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.refresh,
                          color: Colors.white, size: 18),
                      label: const Text('Reset',
                          style:
                              TextStyle(fontSize: 14, color: Colors.white)),
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
              colors: [puzzle.color, Colors.amber, Colors.white, Colors.pink],
            ),
          ),

          // Solved overlay
          if (_solved)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.green.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 50)),
                    Text('Great Job!',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Reference Card ───
  Widget _buildReferenceCard(PuzzleData puzzle) {
    return Container(
      width: 85,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: puzzle.color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Reference',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: puzzle.color)),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            height: 70 * _aspectRatio,
            child: CustomPaint(
              size: Size(70, 70 * _aspectRatio),
              painter: PuzzlePainter(puzzle.name),
            ),
          ),
          const SizedBox(height: 4),
          Text(puzzle.name,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: puzzle.color)),
        ],
      ),
    );
  }

  // ─── Build Zone ───
  Widget _buildBuildZone(PuzzleData puzzle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: puzzle.color.withValues(alpha: 0.3), width: 2),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text('✂️ Glue Parts Here',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: puzzle.color)),
          const SizedBox(height: 6),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                final maxW = constraints.maxWidth;
                final buildWidth =
                    min(maxW * 0.85, maxH / _aspectRatio).toDouble();
                final buildHeight = buildWidth * _aspectRatio;

                return Center(
                  child: SizedBox(
                    width: buildWidth,
                    height: buildHeight,
                    child: Column(
                      children: List.generate(puzzle.parts.length, (i) {
                        final part = puzzle.parts[i];
                        final sliceH =
                            (part.sliceEnd - part.sliceStart) * buildHeight;
                        return SizedBox(
                          height: sliceH,
                          child: _buildDropSlot(i, puzzle, buildWidth, sliceH),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Drop Slot ───
  Widget _buildDropSlot(
      int slotIndex, PuzzleData puzzle, double width, double height) {
    final expectedPart = puzzle.parts[slotIndex];
    final placedPartId = _slotPlacements[slotIndex];
    final isCorrect = placedPartId == expectedPart.id;

    return DragTarget<String>(
      onAcceptWithDetails: (details) =>
          _onPartDroppedOnSlot(details.data, slotIndex),
      onWillAcceptWithDetails: (_) => !_solved,
      builder: (context, candidates, rejected) {
        final isHovered = candidates.isNotEmpty;

        if (placedPartId != null) {
          final placedPart =
              puzzle.parts.firstWhere((p) => p.id == placedPartId);
          return Draggable<String>(
            data: placedPartId,
            onDragStarted: () =>
                setState(() => _slotPlacements.remove(slotIndex)),
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: puzzle.color.withValues(alpha: 0.4),
                        blurRadius: 12)
                  ],
                ),
                child:
                    _buildSliceWidget(puzzle.name, placedPart, width * 0.9),
              ),
            ),
            childWhenDragging: _buildEmptySlotBox(
                width, height, puzzle.color, isHovered, slotIndex,
                label: expectedPart.label),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.orange,
                  width: isCorrect ? 2 : 2,
                ),
              ),
              child: _buildSliceWidget(puzzle.name, placedPart, width),
            ),
          );
        }

        return _buildEmptySlotBox(
            width, height, puzzle.color, isHovered, slotIndex,
            label: expectedPart.label);
      },
    );
  }

  Widget _buildEmptySlotBox(double width, double height, Color color,
      bool isHovered, int index,
      {String? label}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isHovered
            ? color.withValues(alpha: 0.15)
            : Colors.grey.shade100,
        border: Border.all(
          color: isHovered ? color : Colors.grey.shade300,
          width: isHovered ? 2.5 : 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${index + 1}',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold)),
            if (label != null)
              Text(label,
                  style:
                      TextStyle(fontSize: 9, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  // ─── Slice Widget ───
  Widget _buildSliceWidget(String puzzleName, PuzzlePart part, double width) {
    final fullHeight = width * _aspectRatio;
    final sliceHeight = (part.sliceEnd - part.sliceStart) * fullHeight;

    return SizedBox(
      width: width,
      height: sliceHeight,
      child: CustomPaint(
        size: Size(width, sliceHeight),
        painter: PuzzleSlicePainter(
          puzzleName: puzzleName,
          sliceStart: part.sliceStart,
          sliceEnd: part.sliceEnd,
        ),
      ),
    );
  }

  // ─── Pieces Tray ───
  Widget _buildPiecesTray(PuzzleData puzzle, List<String> unplacedPartIds) {
    return Container(
      height: 105,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: puzzle.color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text('✂️ Cut-out Pieces',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: puzzle.color)),
          const SizedBox(height: 4),
          Expanded(
            child: unplacedPartIds.isEmpty
                ? Center(
                    child: Text(
                    _solved ? '✓ Complete!' : 'Check the order...',
                    style: TextStyle(
                        color: _solved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ))
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: unplacedPartIds.map((id) {
                      final part =
                          puzzle.parts.firstWhere((p) => p.id == id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildDraggablePiece(puzzle, part),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Draggable Piece ───
  Widget _buildDraggablePiece(PuzzleData puzzle, PuzzlePart part) {
    return Draggable<String>(
      data: part.id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: puzzle.color.withValues(alpha: 0.4), blurRadius: 10)
            ],
          ),
          child: _buildSliceWidget(puzzle.name, part, 80),
        ),
      ),
      childWhenDragging: Container(
        width: 68,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
      child: Container(
        width: 68,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: puzzle.color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: puzzle.color.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 28,
              child: FittedBox(
                fit: BoxFit.contain,
                child: _buildSliceWidget(puzzle.name, part, 60),
              ),
            ),
            const SizedBox(height: 2),
            Text(part.label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: puzzle.color)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PUZZLE PAINTER - Draws complete puzzle images
// ═══════════════════════════════════════════════════════════════
class PuzzlePainter extends CustomPainter {
  final String name;
  PuzzlePainter(this.name);

  @override
  void paint(Canvas canvas, Size size) {
    paintPuzzle(canvas, size, name);
  }

  static void paintPuzzle(Canvas canvas, Size size, String name) {
    switch (name) {
      case 'Lion':
        _paintLion(canvas, size);
        break;
      case 'Elephant':
        _paintElephant(canvas, size);
        break;
      case 'Cat':
        _paintCat(canvas, size);
        break;
      case 'Car':
        _paintCar(canvas, size);
        break;
      case 'Rocket':
        _paintRocket(canvas, size);
        break;
      case 'Train':
        _paintTrain(canvas, size);
        break;
      case 'Apple':
        _paintApple(canvas, size);
        break;
      case 'Watermelon':
        _paintWatermelon(canvas, size);
        break;
      case 'Pineapple':
        _paintPineapple(canvas, size);
        break;
    }
  }

  // ─── LION ───
  static void _paintLion(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Sky
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h * 0.82), Paint()..color = const Color(0xFFFFF8DC));
    // Ground
    canvas.drawRect(
        Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = const Color(0xFF90D070));

    // Body
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.5, h * 0.50),
                width: w * 0.48,
                height: h * 0.18),
            Radius.circular(w * 0.1)),
        Paint()..color = const Color(0xFFDEB887));

    // Tail
    final tailP = Paint()
      ..color = const Color(0xFFDEB887)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    final tp = Path()
      ..moveTo(w * 0.74, h * 0.48)
      ..quadraticBezierTo(w * 0.90, h * 0.38, w * 0.85, h * 0.50);
    canvas.drawPath(tp, tailP);
    canvas.drawCircle(
        Offset(w * 0.85, h * 0.50), w * 0.04, Paint()..color = const Color(0xFFC88020));

    // Legs
    final legP = Paint()..color = const Color(0xFFDEB887);
    for (var x in [0.30, 0.40, 0.56, 0.66]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(w * x, h * 0.57, w * 0.08, h * 0.22),
              Radius.circular(w * 0.03)),
          legP);
    }
    // Paw pads
    for (var x in [0.30, 0.40, 0.56, 0.66]) {
      canvas.drawCircle(Offset(w * (x + 0.04), h * 0.79), w * 0.035,
          Paint()..color = const Color(0xFFC89060));
    }

    // Mane
    final maneP = Paint()..color = const Color(0xFFE89020);
    for (int i = 0; i < 12; i++) {
      final a = i * pi * 2 / 12 - pi / 2;
      canvas.drawCircle(
          Offset(w * 0.48 + cos(a) * w * 0.19,
              h * 0.24 + sin(a) * w * 0.19),
          w * 0.09, maneP);
    }
    canvas.drawCircle(Offset(w * 0.48, h * 0.24), w * 0.20, maneP);
    // Face
    canvas.drawCircle(
        Offset(w * 0.48, h * 0.24), w * 0.15, Paint()..color = const Color(0xFFF5DEB3));
    // Eyes
    final eyeP = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(w * 0.41, h * 0.22), w * 0.025, eyeP);
    canvas.drawCircle(Offset(w * 0.55, h * 0.22), w * 0.025, eyeP);
    canvas.drawCircle(
        Offset(w * 0.415, h * 0.215), w * 0.008, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(w * 0.555, h * 0.215), w * 0.008, Paint()..color = Colors.white);
    // Nose
    final noseP = Path()
      ..moveTo(w * 0.46, h * 0.26)
      ..lineTo(w * 0.50, h * 0.26)
      ..lineTo(w * 0.48, h * 0.28)
      ..close();
    canvas.drawPath(noseP, Paint()..color = const Color(0xFF8B4513));
    // Mouth
    final mP = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008;
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(w * 0.46, h * 0.29),
            width: w * 0.05,
            height: w * 0.04),
        0, pi, false, mP);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.29),
            width: w * 0.05,
            height: w * 0.04),
        0, pi, false, mP);
  }

  // ─── ELEPHANT ───
  static void _paintElephant(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h * 0.82), Paint()..color = const Color(0xFFE8F4FD));
    canvas.drawRect(
        Rect.fromLTWH(0, h * 0.80, w, h * 0.20), Paint()..color = const Color(0xFF90D070));

    // Body
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.50, h * 0.50),
                width: w * 0.55,
                height: h * 0.20),
            Radius.circular(w * 0.12)),
        Paint()..color = const Color(0xFF9DB2BF));

    // Legs
    final legP = Paint()..color = const Color(0xFF8DA4B0);
    for (var x in [0.28, 0.38, 0.56, 0.66]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(w * x, h * 0.57, w * 0.10, h * 0.24),
              Radius.circular(w * 0.04)),
          legP);
    }
    // Toenails
    for (var x in [0.28, 0.38, 0.56, 0.66]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(w * x, h * 0.78, w * 0.10, h * 0.03),
              Radius.circular(w * 0.02)),
          Paint()..color = const Color(0xFF7A9099));
    }

    // Tail
    final tailP = Paint()
      ..color = const Color(0xFF8DA4B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.77, h * 0.48), Offset(w * 0.85, h * 0.55), tailP);

    // Head
    canvas.drawCircle(
        Offset(w * 0.48, h * 0.26), w * 0.20, Paint()..color = const Color(0xFF9DB2BF));
    // Ears
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.26, h * 0.24),
            width: w * 0.18,
            height: h * 0.14),
        Paint()..color = const Color(0xFF8DA4B0));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.26, h * 0.24),
            width: w * 0.12,
            height: h * 0.09),
        Paint()..color = const Color(0xFFBBA8B0));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.70, h * 0.24),
            width: w * 0.18,
            height: h * 0.14),
        Paint()..color = const Color(0xFF8DA4B0));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.70, h * 0.24),
            width: w * 0.12,
            height: h * 0.09),
        Paint()..color = const Color(0xFFBBA8B0));
    // Trunk
    final trunkP = Paint()
      ..color = const Color(0xFF9DB2BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    final trunkPath = Path()
      ..moveTo(w * 0.48, h * 0.32)
      ..quadraticBezierTo(w * 0.45, h * 0.42, w * 0.52, h * 0.44);
    canvas.drawPath(trunkPath, trunkP);
    // Eyes
    canvas.drawCircle(
        Offset(w * 0.40, h * 0.23), w * 0.025, Paint()..color = Colors.black);
    canvas.drawCircle(
        Offset(w * 0.56, h * 0.23), w * 0.025, Paint()..color = Colors.black);
    canvas.drawCircle(
        Offset(w * 0.405, h * 0.225), w * 0.008, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(w * 0.565, h * 0.225), w * 0.008, Paint()..color = Colors.white);
    // Tusks
    canvas.drawLine(Offset(w * 0.40, h * 0.30), Offset(w * 0.38, h * 0.36),
        Paint()
          ..color = const Color(0xFFFFFDD0)
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(w * 0.56, h * 0.30), Offset(w * 0.58, h * 0.36),
        Paint()
          ..color = const Color(0xFFFFFDD0)
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round);
  }

  // ─── CAT ───
  static void _paintCat(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h * 0.82), Paint()..color = const Color(0xFFFFF0E8));
    canvas.drawRect(
        Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = const Color(0xFF90D070));

    // Tail (behind body)
    final tailP = Paint()
      ..color = const Color(0xFFE8A040)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    final tp = Path()
      ..moveTo(w * 0.72, h * 0.48)
      ..quadraticBezierTo(w * 0.92, h * 0.30, w * 0.82, h * 0.42);
    canvas.drawPath(tp, tailP);

    // Body
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.50),
            width: w * 0.45,
            height: h * 0.18),
        Paint()..color = const Color(0xFFE8A040));
    // Stripes
    final stripeP = Paint()
      ..color = const Color(0xFFCC8020)
      ..strokeWidth = w * 0.012;
    for (var dx in [0.42, 0.48, 0.54]) {
      canvas.drawLine(Offset(w * dx, h * 0.43), Offset(w * dx, h * 0.57), stripeP);
    }

    // Legs
    final legP = Paint()..color = const Color(0xFFE8A040);
    for (var x in [0.32, 0.40, 0.56, 0.64]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(w * x, h * 0.57, w * 0.07, h * 0.22),
              Radius.circular(w * 0.025)),
          legP);
    }
    // Paws
    for (var x in [0.32, 0.40, 0.56, 0.64]) {
      canvas.drawCircle(Offset(w * (x + 0.035), h * 0.79), w * 0.03,
          Paint()..color = const Color(0xFFF5DEB3));
    }

    // Head
    canvas.drawCircle(
        Offset(w * 0.48, h * 0.24), w * 0.17, Paint()..color = const Color(0xFFE8A040));
    // Ears
    final earPath = Path()
      ..moveTo(w * 0.32, h * 0.18)
      ..lineTo(w * 0.36, h * 0.08)
      ..lineTo(w * 0.42, h * 0.16)
      ..close();
    canvas.drawPath(earPath, Paint()..color = const Color(0xFFE8A040));
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.34, h * 0.16)
          ..lineTo(w * 0.37, h * 0.10)
          ..lineTo(w * 0.41, h * 0.15)
          ..close(),
        Paint()..color = const Color(0xFFFFB0C0));
    final earPath2 = Path()
      ..moveTo(w * 0.54, h * 0.18)
      ..lineTo(w * 0.60, h * 0.08)
      ..lineTo(w * 0.64, h * 0.16)
      ..close();
    canvas.drawPath(earPath2, Paint()..color = const Color(0xFFE8A040));
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.55, h * 0.16)
          ..lineTo(w * 0.60, h * 0.10)
          ..lineTo(w * 0.63, h * 0.15)
          ..close(),
        Paint()..color = const Color(0xFFFFB0C0));
    // Eyes
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.41, h * 0.22),
            width: w * 0.06,
            height: w * 0.07),
        Paint()..color = const Color(0xFF40C040));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.55, h * 0.22),
            width: w * 0.06,
            height: w * 0.07),
        Paint()..color = const Color(0xFF40C040));
    canvas.drawCircle(
        Offset(w * 0.41, h * 0.22), w * 0.015, Paint()..color = Colors.black);
    canvas.drawCircle(
        Offset(w * 0.55, h * 0.22), w * 0.015, Paint()..color = Colors.black);
    // Nose
    final np = Path()
      ..moveTo(w * 0.46, h * 0.27)
      ..lineTo(w * 0.50, h * 0.27)
      ..lineTo(w * 0.48, h * 0.29)
      ..close();
    canvas.drawPath(np, Paint()..color = const Color(0xFFFF8080));
    // Whiskers
    final whP = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = w * 0.005;
    canvas.drawLine(Offset(w * 0.36, h * 0.28), Offset(w * 0.20, h * 0.26), whP);
    canvas.drawLine(Offset(w * 0.36, h * 0.29), Offset(w * 0.20, h * 0.30), whP);
    canvas.drawLine(Offset(w * 0.60, h * 0.28), Offset(w * 0.76, h * 0.26), whP);
    canvas.drawLine(Offset(w * 0.60, h * 0.29), Offset(w * 0.76, h * 0.30), whP);
  }

  // ─── CAR ───
  static void _paintCar(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.60),
        Paint()..color = const Color(0xFFADD8E6));
    // Sun
    canvas.drawCircle(
        Offset(w * 0.80, h * 0.12), w * 0.08, Paint()..color = const Color(0xFFFFD700));
    // Road
    canvas.drawRect(Rect.fromLTWH(0, h * 0.60, w, h * 0.25),
        Paint()..color = const Color(0xFF606060));
    // Road line
    canvas.drawLine(Offset(0, h * 0.72), Offset(w, h * 0.72),
        Paint()
          ..color = Colors.yellow
          ..strokeWidth = w * 0.012);
    // Ground
    canvas.drawRect(Rect.fromLTWH(0, h * 0.85, w, h * 0.15),
        Paint()..color = const Color(0xFF90D070));

    // Car body
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.12, h * 0.45, w * 0.76, h * 0.18),
            Radius.circular(w * 0.04)),
        Paint()..color = const Color(0xFFE02020));
    // Roof
    final roofPath = Path()
      ..moveTo(w * 0.25, h * 0.45)
      ..lineTo(w * 0.32, h * 0.30)
      ..lineTo(w * 0.68, h * 0.30)
      ..lineTo(w * 0.75, h * 0.45)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFFD01818));
    // Windows
    final winPath = Path()
      ..moveTo(w * 0.34, h * 0.32)
      ..lineTo(w * 0.37, h * 0.32)
      ..lineTo(w * 0.37, h * 0.44)
      ..lineTo(w * 0.28, h * 0.44)
      ..close();
    canvas.drawPath(winPath, Paint()..color = const Color(0xFF87CEEB));
    final winPath2 = Path()
      ..moveTo(w * 0.40, h * 0.32)
      ..lineTo(w * 0.60, h * 0.32)
      ..lineTo(w * 0.60, h * 0.44)
      ..lineTo(w * 0.40, h * 0.44)
      ..close();
    canvas.drawPath(winPath2, Paint()..color = const Color(0xFF87CEEB));
    final winPath3 = Path()
      ..moveTo(w * 0.63, h * 0.32)
      ..lineTo(w * 0.66, h * 0.32)
      ..lineTo(w * 0.72, h * 0.44)
      ..lineTo(w * 0.63, h * 0.44)
      ..close();
    canvas.drawPath(winPath3, Paint()..color = const Color(0xFF87CEEB));

    // Headlights
    canvas.drawCircle(
        Offset(w * 0.14, h * 0.52), w * 0.03, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(
        Offset(w * 0.86, h * 0.52), w * 0.03, Paint()..color = const Color(0xFFFF4040));

    // Bumpers
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.10, h * 0.60, w * 0.80, h * 0.03),
            Radius.circular(w * 0.01)),
        Paint()..color = const Color(0xFFC0C0C0));

    // Wheels
    canvas.drawCircle(
        Offset(w * 0.28, h * 0.66), w * 0.09, Paint()..color = const Color(0xFF303030));
    canvas.drawCircle(
        Offset(w * 0.28, h * 0.66), w * 0.05, Paint()..color = const Color(0xFFC0C0C0));
    canvas.drawCircle(
        Offset(w * 0.72, h * 0.66), w * 0.09, Paint()..color = const Color(0xFF303030));
    canvas.drawCircle(
        Offset(w * 0.72, h * 0.66), w * 0.05, Paint()..color = const Color(0xFFC0C0C0));
  }

  // ─── ROCKET ───
  static void _paintRocket(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Space background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF1A1A3E));
    // Stars
    final starP = Paint()..color = Colors.white;
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(
          Offset(rng.nextDouble() * w, rng.nextDouble() * h),
          w * 0.008,
          starP);
    }

    // Flames
    final flameP = Paint()..color = const Color(0xFFFF6600);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.88),
            width: w * 0.18,
            height: h * 0.14),
        flameP);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.86),
            width: w * 0.12,
            height: h * 0.10),
        Paint()..color = const Color(0xFFFFAA00));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.84),
            width: w * 0.06,
            height: h * 0.06),
        Paint()..color = const Color(0xFFFFDD44));

    // Fins
    final finPath = Path()
      ..moveTo(w * 0.30, h * 0.72)
      ..lineTo(w * 0.18, h * 0.80)
      ..lineTo(w * 0.30, h * 0.78)
      ..close();
    canvas.drawPath(finPath, Paint()..color = const Color(0xFFE02020));
    final finPath2 = Path()
      ..moveTo(w * 0.70, h * 0.72)
      ..lineTo(w * 0.82, h * 0.80)
      ..lineTo(w * 0.70, h * 0.78)
      ..close();
    canvas.drawPath(finPath2, Paint()..color = const Color(0xFFE02020));

    // Body
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.30, h * 0.25, w * 0.40, h * 0.52),
            Radius.circular(w * 0.05)),
        Paint()..color = const Color(0xFFF0F0F0));
    // Stripe
    canvas.drawRect(Rect.fromLTWH(w * 0.30, h * 0.50, w * 0.40, h * 0.05),
        Paint()..color = const Color(0xFFE02020));
    // Porthole
    canvas.drawCircle(
        Offset(w * 0.50, h * 0.40), w * 0.08, Paint()..color = const Color(0xFF4488CC));
    canvas.drawCircle(
        Offset(w * 0.50, h * 0.40),
        w * 0.08,
        Paint()
          ..color = const Color(0xFFCCCCCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.015);
    // Highlight
    canvas.drawCircle(
        Offset(w * 0.47, h * 0.37), w * 0.02, Paint()..color = Colors.white);

    // Nose cone
    final nosePath = Path()
      ..moveTo(w * 0.50, h * 0.08)
      ..lineTo(w * 0.30, h * 0.28)
      ..lineTo(w * 0.70, h * 0.28)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFE02020));
  }

  // ─── TRAIN ───
  static void _paintTrain(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.65),
        Paint()..color = const Color(0xFFADD8E6));
    // Clouds
    canvas.drawCircle(
        Offset(w * 0.20, h * 0.10), w * 0.08, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(w * 0.28, h * 0.08), w * 0.06, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(w * 0.75, h * 0.15), w * 0.07, Paint()..color = Colors.white);
    // Track
    canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w, h * 0.04),
        Paint()..color = const Color(0xFF808080));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.88, w, h * 0.02),
        Paint()..color = const Color(0xFF606060));
    // Ground
    canvas.drawRect(Rect.fromLTWH(0, h * 0.90, w, h * 0.10),
        Paint()..color = const Color(0xFF90D070));
    // Ties
    for (var dx = 0.0; dx < 1.0; dx += 0.12) {
      canvas.drawRect(Rect.fromLTWH(w * dx, h * 0.80, w * 0.04, h * 0.10),
          Paint()..color = const Color(0xFF8B6914));
    }

    // Chimney
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.10, h * 0.20),
            Radius.circular(w * 0.02)),
        Paint()..color = const Color(0xFF404040));
    // Chimney top
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.19, h * 0.16, w * 0.16, h * 0.04),
            Radius.circular(w * 0.02)),
        Paint()..color = const Color(0xFF505050));
    // Smoke
    canvas.drawCircle(Offset(w * 0.27, h * 0.12), w * 0.05,
        Paint()..color = const Color(0xFFD0D0D0));
    canvas.drawCircle(Offset(w * 0.32, h * 0.07), w * 0.04,
        Paint()..color = const Color(0xFFE0E0E0));

    // Cabin
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.55, h * 0.30, w * 0.30, h * 0.30),
            Radius.circular(w * 0.03)),
        Paint()..color = const Color(0xFF2E8B57));
    // Cabin window
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.60, h * 0.34, w * 0.20, h * 0.14),
            Radius.circular(w * 0.02)),
        Paint()..color = const Color(0xFF87CEEB));
    // Cabin roof
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.53, h * 0.27, w * 0.34, h * 0.05),
            Radius.circular(w * 0.02)),
        Paint()..color = const Color(0xFF1E6B37));

    // Boiler body
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.10, h * 0.38, w * 0.50, h * 0.22),
            Radius.circular(w * 0.08)),
        Paint()..color = const Color(0xFF2E8B57));
    // Front circle
    canvas.drawCircle(
        Offset(w * 0.14, h * 0.49), w * 0.09, Paint()..color = const Color(0xFF1E6B37));
    canvas.drawCircle(
        Offset(w * 0.14, h * 0.49), w * 0.05, Paint()..color = const Color(0xFFCCCCCC));
    // Cow catcher
    final cowPath = Path()
      ..moveTo(w * 0.05, h * 0.62)
      ..lineTo(w * 0.12, h * 0.58)
      ..lineTo(w * 0.12, h * 0.62)
      ..close();
    canvas.drawPath(cowPath, Paint()..color = const Color(0xFFCCCCCC));

    // Wheels
    canvas.drawCircle(
        Offset(w * 0.25, h * 0.68), w * 0.09, Paint()..color = const Color(0xFF404040));
    canvas.drawCircle(
        Offset(w * 0.25, h * 0.68), w * 0.04, Paint()..color = const Color(0xFFCCCCCC));
    canvas.drawCircle(
        Offset(w * 0.45, h * 0.68), w * 0.09, Paint()..color = const Color(0xFF404040));
    canvas.drawCircle(
        Offset(w * 0.45, h * 0.68), w * 0.04, Paint()..color = const Color(0xFFCCCCCC));
    canvas.drawCircle(
        Offset(w * 0.70, h * 0.68), w * 0.07, Paint()..color = const Color(0xFF404040));
    canvas.drawCircle(
        Offset(w * 0.70, h * 0.68), w * 0.03, Paint()..color = const Color(0xFFCCCCCC));
  }

  // ─── APPLE ───
  static void _paintApple(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFFF8E8));

    // Shadow
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.88),
            width: w * 0.50,
            height: h * 0.06),
        Paint()..color = const Color(0xFFE0D8C8));

    // Apple body
    canvas.drawCircle(
        Offset(w * 0.50, h * 0.58), w * 0.32, Paint()..color = const Color(0xFFE02020));
    // Left bump
    canvas.drawCircle(
        Offset(w * 0.38, h * 0.48), w * 0.18, Paint()..color = const Color(0xFFE02020));
    // Right bump
    canvas.drawCircle(
        Offset(w * 0.62, h * 0.48), w * 0.18, Paint()..color = const Color(0xFFE02020));
    // Top dip
    canvas.drawCircle(
        Offset(w * 0.50, h * 0.40), w * 0.06, Paint()..color = const Color(0xFFFFF8E8));
    // Highlight
    canvas.drawCircle(
        Offset(w * 0.38, h * 0.52), w * 0.08, Paint()..color = const Color(0xFFFF5050));

    // Stem
    canvas.drawLine(Offset(w * 0.50, h * 0.38), Offset(w * 0.52, h * 0.22),
        Paint()
          ..color = const Color(0xFF8B4513)
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round);

    // Leaf
    final leafPath = Path()
      ..moveTo(w * 0.52, h * 0.24)
      ..quadraticBezierTo(w * 0.68, h * 0.14, w * 0.70, h * 0.22)
      ..quadraticBezierTo(w * 0.64, h * 0.22, w * 0.52, h * 0.24);
    canvas.drawPath(leafPath, Paint()..color = const Color(0xFF40A040));
    // Leaf vein
    canvas.drawLine(Offset(w * 0.52, h * 0.24), Offset(w * 0.66, h * 0.19),
        Paint()
          ..color = const Color(0xFF308030)
          ..strokeWidth = w * 0.006);
  }

  // ─── WATERMELON ───
  static void _paintWatermelon(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFF5FFF0));

    // Shadow
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.90),
            width: w * 0.60,
            height: h * 0.06),
        Paint()..color = const Color(0xFFD8E8D0));

    // Outer rind (green)
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.50, h * 0.50),
                width: w * 0.75,
                height: h * 0.55),
            Radius.circular(w * 0.15)),
        Paint()..color = const Color(0xFF2E8B20));
    // Dark stripes
    final stripeP = Paint()
      ..color = const Color(0xFF1E6B10)
      ..strokeWidth = w * 0.025;
    for (var dx in [0.35, 0.45, 0.55, 0.65]) {
      canvas.drawLine(
          Offset(w * dx, h * 0.26), Offset(w * dx, h * 0.74), stripeP);
    }

    // White rind layer
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.50, h * 0.50),
                width: w * 0.65,
                height: h * 0.45),
            Radius.circular(w * 0.12)),
        Paint()..color = const Color(0xFFE8FFE0));

    // Red flesh
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.50, h * 0.50),
                width: w * 0.58,
                height: h * 0.38),
            Radius.circular(w * 0.10)),
        Paint()..color = const Color(0xFFE02030));

    // Seeds
    final seedP = Paint()..color = const Color(0xFF303030);
    for (var pos in [
      [0.38, 0.42],
      [0.55, 0.45],
      [0.45, 0.55],
      [0.60, 0.52],
      [0.40, 0.50],
      [0.52, 0.60],
      [0.58, 0.40],
    ]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * pos[0], h * pos[1]),
              width: w * 0.03,
              height: w * 0.05),
          seedP);
    }
  }

  // ─── PINEAPPLE ───
  static void _paintPineapple(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFFFAE8));

    // Shadow
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.92),
            width: w * 0.40,
            height: h * 0.04),
        Paint()..color = const Color(0xFFE8E0C8));

    // Crown leaves
    final leafP = Paint()..color = const Color(0xFF2E8B20);
    for (var i = -3; i <= 3; i++) {
      final angle = i * 0.25;
      final leafPath = Path()
        ..moveTo(w * 0.50 + sin(angle) * w * 0.02, h * 0.35)
        ..quadraticBezierTo(
            w * 0.50 + sin(angle) * w * 0.15,
            h * 0.10 + i.abs() * h * 0.03,
            w * 0.50 + sin(angle) * w * 0.12,
            h * 0.05 + i.abs() * h * 0.04);
      canvas.drawPath(
          leafPath,
          Paint()
            ..color = const Color(0xFF2E8B20)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.04
            ..strokeCap = StrokeCap.round);
    }
    // Center leaf
    canvas.drawLine(Offset(w * 0.50, h * 0.35), Offset(w * 0.50, h * 0.06),
        Paint()
          ..color = const Color(0xFF3AA030)
          ..strokeWidth = w * 0.04
          ..strokeCap = StrokeCap.round);

    // Body
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.50, h * 0.60),
                width: w * 0.50,
                height: h * 0.45),
            Radius.circular(w * 0.10)),
        Paint()..color = const Color(0xFFDAA520));

    // Diamond pattern
    final diamondP = Paint()
      ..color = const Color(0xFFC08810)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008;
    for (var dy = 0.42; dy < 0.80; dy += 0.07) {
      for (var dx = 0.30; dx < 0.72; dx += 0.10) {
        canvas.drawLine(
            Offset(w * dx, h * dy), Offset(w * (dx + 0.05), h * (dy + 0.035)), diamondP);
        canvas.drawLine(Offset(w * (dx + 0.10), h * dy),
            Offset(w * (dx + 0.05), h * (dy + 0.035)), diamondP);
        canvas.drawLine(Offset(w * (dx + 0.05), h * (dy + 0.035)),
            Offset(w * dx, h * (dy + 0.07)), diamondP);
        canvas.drawLine(Offset(w * (dx + 0.05), h * (dy + 0.035)),
            Offset(w * (dx + 0.10), h * (dy + 0.07)), diamondP);
      }
    }

    // Highlight
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.34, h * 0.42, w * 0.08, h * 0.28),
            Radius.circular(w * 0.03)),
        Paint()..color = const Color(0xFFE8C030).withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) =>
      oldDelegate.name != name;
}

// ═══════════════════════════════════════════════════════════════
// PUZZLE SLICE PAINTER - Shows a vertical slice of the full image
// ═══════════════════════════════════════════════════════════════
class PuzzleSlicePainter extends CustomPainter {
  final String puzzleName;
  final double sliceStart;
  final double sliceEnd;

  PuzzleSlicePainter({
    required this.puzzleName,
    required this.sliceStart,
    required this.sliceEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullHeight = size.width * _PuzzleGameScreenState._aspectRatio;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.translate(0, -sliceStart * fullHeight);
    PuzzlePainter.paintPuzzle(canvas, Size(size.width, fullHeight), puzzleName);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PuzzleSlicePainter oldDelegate) =>
      oldDelegate.puzzleName != puzzleName ||
      oldDelegate.sliceStart != sliceStart ||
      oldDelegate.sliceEnd != sliceEnd;
}

// ═══════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════
class PuzzleData {
  final String name;
  final Color color;
  final List<PuzzlePart> parts;

  PuzzleData({required this.name, required this.color, required this.parts});
}

class PuzzlePart {
  final String id;
  final String label;
  final double sliceStart;
  final double sliceEnd;

  PuzzlePart({
    required this.id,
    required this.label,
    required this.sliceStart,
    required this.sliceEnd,
  });
}
