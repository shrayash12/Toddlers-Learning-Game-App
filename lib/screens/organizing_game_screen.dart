import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class OrganizingGameScreen extends StatefulWidget {
  const OrganizingGameScreen({super.key});

  @override
  State<OrganizingGameScreen> createState() => _OrganizingGameScreenState();
}

class _OrganizingGameScreenState extends State<OrganizingGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _currentLevel = 0;
  List<SortItem> _items = [];
  String? _draggedItem;
  int _correctPlacements = 0;
  bool _levelComplete = false;
  int _completedLevels = 0;

  final List<SortingChallenge> _challenges = [
    SortingChallenge(
      title: 'Fruits & Vegetables',
      instruction: 'Sort into the correct basket!',
      categories: [
        SortCategory('🧺', 'Fruits', Colors.red, ['🍎', '🍊', '🍌', '🍇']),
        SortCategory('🧺', 'Vegetables', Colors.green, ['🥕', '🥦', '🌽', '🥬']),
      ],
    ),
    SortingChallenge(
      title: 'Toys & Books',
      instruction: 'Put them in the right place!',
      categories: [
        SortCategory('📦', 'Toys', Colors.orange, ['🧸', '🎮', '🚗', '⚽']),
        SortCategory('📚', 'Books', Colors.blue, ['📕', '📗', '📘', '📙']),
      ],
    ),
    SortingChallenge(
      title: 'Animals',
      instruction: 'Where do they live?',
      categories: [
        SortCategory('🏠', 'Farm', Colors.amber, ['🐄', '🐷', '🐔', '🐴']),
        SortCategory('🌲', 'Forest', Colors.green, ['🦊', '🐻', '🦌', '🐰']),
      ],
    ),
    SortingChallenge(
      title: 'Big & Small',
      instruction: 'Sort by size!',
      categories: [
        SortCategory('⬆️', 'Big', Colors.purple, ['🐘', '🦒', '🐋', '🦕']),
        SortCategory('⬇️', 'Small', Colors.pink, ['🐁', '🐜', '🐛', '🦋']),
      ],
    ),
    SortingChallenge(
      title: 'Clothes',
      instruction: 'Organize your closet!',
      categories: [
        SortCategory('👕', 'Tops', Colors.blue, ['👔', '👚', '🎽', '👘']),
        SortCategory('👖', 'Bottoms', Colors.indigo, ['👖', '🩳', '👗', '🩱']),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _setupLevel();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _setupLevel() {
    final challenge = _challenges[_currentLevel];
    _items = [];

    for (var category in challenge.categories) {
      for (var emoji in category.items) {
        _items.add(SortItem(
          emoji: emoji,
          correctCategory: category.name,
          isPlaced: false,
        ));
      }
    }

    _items.shuffle(_random);
    _correctPlacements = 0;
    _levelComplete = false;
    setState(() {});
  }

  void _onItemDropped(String emoji, String categoryName) async {
    final itemIndex = _items.indexWhere((i) => i.emoji == emoji && !i.isPlaced);
    if (itemIndex == -1) return;

    final item = _items[itemIndex];

    if (item.correctCategory == categoryName) {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      setState(() {
        _items[itemIndex].isPlaced = true;
        _correctPlacements++;
      });

      if (_correctPlacements == _items.length) {
        _completeLevel();
      }
    } else {
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    }
  }

  void _completeLevel() async {
    setState(() {
      _levelComplete = true;
      _completedLevels++;
    });

    _confettiController.play();

    await Future.delayed(const Duration(seconds: 2));

    if (_currentLevel < _challenges.length - 1) {
      setState(() {
        _currentLevel++;
      });
      _setupLevel();
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
        backgroundColor: Colors.green.shade100,
        title: const Text(
          '🏆 Super Organizer! 🏆',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You sorted everything perfectly!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('📦✨🧹', style: TextStyle(fontSize: 40)),
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
                });
                _setupLevel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
    final challenge = _challenges[_currentLevel];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              challenge.categories[0].color.withOpacity(0.2),
              challenge.categories[1].color.withOpacity(0.2),
            ],
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
                            'Organizing Fun',
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

                  // Level progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_challenges.length, (index) {
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
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
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

                  // Challenge info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          challenge.instruction,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Items to sort
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Drag items to sort:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: _items
                              .where((item) => !item.isPlaced)
                              .map((item) {
                            return Draggable<String>(
                              data: item.emoji,
                              onDragStarted: () {
                                setState(() {
                                  _draggedItem = item.emoji;
                                });
                              },
                              onDragEnd: (_) {
                                setState(() {
                                  _draggedItem = null;
                                });
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: Text(
                                  item.emoji,
                                  style: const TextStyle(fontSize: 50),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: Text(
                                  item.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_items.every((item) => item.isPlaced))
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              '✨ All sorted! ✨',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Drop zones (categories)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: challenge.categories.map((category) {
                          final placedItems = _items
                              .where((i) => i.isPlaced && i.correctCategory == category.name)
                              .toList();

                          return Expanded(
                            child: DragTarget<String>(
                              onWillAcceptWithDetails: (_) => true,
                              onAcceptWithDetails: (details) {
                                _onItemDropped(details.data, category.name);
                              },
                              builder: (context, candidateData, rejectedData) {
                                final isHovering = candidateData.isNotEmpty;

                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isHovering
                                        ? category.color.withOpacity(0.3)
                                        : category.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isHovering
                                          ? category.color
                                          : category.color.withOpacity(0.5),
                                      width: isHovering ? 4 : 3,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        category.icon,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: category.color,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 5,
                                            runSpacing: 5,
                                            alignment: WrapAlignment.center,
                                            children: placedItems
                                                .map((item) => Text(
                                                      item.emoji,
                                                      style: const TextStyle(fontSize: 35),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${placedItems.length}/${category.items.length}',
                                        style: TextStyle(
                                          color: category.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Reset button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: ElevatedButton.icon(
                      onPressed: _setupLevel,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Start Over',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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

class SortItem {
  final String emoji;
  final String correctCategory;
  bool isPlaced;

  SortItem({
    required this.emoji,
    required this.correctCategory,
    this.isPlaced = false,
  });
}

class SortCategory {
  final String icon;
  final String name;
  final Color color;
  final List<String> items;

  SortCategory(this.icon, this.name, this.color, this.items);
}

class SortingChallenge {
  final String title;
  final String instruction;
  final List<SortCategory> categories;

  SortingChallenge({
    required this.title,
    required this.instruction,
    required this.categories,
  });
}
