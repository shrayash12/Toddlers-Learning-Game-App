import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class OrganizingGameScreen extends StatefulWidget {
  const OrganizingGameScreen({super.key});

  @override
  State<OrganizingGameScreen> createState() => _OrganizingGameScreenState();
}

class _OrganizingGameScreenState extends State<OrganizingGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  final Random _random = Random();

  int _currentLevel = 0;
  List<SortItem> _items = [];
  String? _draggedItem;
  int _correctPlacements = 0;
  bool _levelComplete = false;
  int _completedLevels = 0;

  final List<String> _correctPhrases = [
    'Correct!',
    'Great job!',
    'Well done!',
    'Perfect!',
    'Awesome!',
    'Good!',
  ];

  final List<String> _wrongPhrases = [
    'Try again!',
    'Oops! Wrong basket!',
    'Not quite!',
    'Try the other one!',
  ];

  // Get spoken name for emoji
  String _getEmojiName(String emoji) {
    switch (emoji) {
      // Level 1 - Fruits
      case '🍎': return 'Apple';
      case '🍊': return 'Orange';
      case '🍌': return 'Banana';
      case '🍇': return 'Grapes';
      // Level 1 - Vegetables
      case '🥕': return 'Carrot';
      case '🥦': return 'Broccoli';
      case '🌽': return 'Corn';
      case '🥬': return 'Lettuce';
      // Level 2 - Toys
      case '🧸': return 'Teddy Bear';
      case '🎮': return 'Game Controller';
      case '🚗': return 'Red Car';
      case '⚽': return 'Soccer Ball';
      // Level 2 - Books
      case '📕': return 'Red Book';
      case '📗': return 'Green Book';
      case '📘': return 'Blue Book';
      case '📙': return 'Orange Book';
      // Level 3 - Farm Animals
      case '🐄': return 'Cow';
      case '🐷': return 'Pig';
      case '🐔': return 'Chicken';
      case '🐴': return 'Horse';
      // Level 3 - Forest Animals
      case '🦊': return 'Fox';
      case '🐻': return 'Bear';
      case '🦌': return 'Deer';
      case '🐰': return 'Rabbit';
      // Level 4 - Big Animals
      case '🐘': return 'Elephant';
      case '🦒': return 'Giraffe';
      case '🐋': return 'Whale';
      case '🦕': return 'Dinosaur';
      // Level 4 - Small Animals
      case '🐁': return 'Mouse';
      case '🐜': return 'Ant';
      case '🐛': return 'Caterpillar';
      case '🦋': return 'Butterfly';
      // Level 5 - Tops
      case '👔': return 'Shirt';
      case '👚': return 'Blouse';
      case '🎽': return 'Tank Top';
      case '👘': return 'Kimono';
      // Level 5 - Bottoms
      case '👖': return 'Pants';
      case '🩳': return 'Shorts';
      case '👗': return 'Dress';
      case '🩱': return 'Swimsuit';
      default: return 'Item';
    }
  }

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
    _initTts();
    _setupLevel();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.1);
    await _flutterTts.awaitSpeakCompletion(false);
  }

  void _speak(String text) async {
    await _flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 50));
    _flutterTts.speak(text);
  }

  void _speakItemName(String emoji) async {
    final name = _getEmojiName(emoji);
    await _flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 50));
    _flutterTts.speak(name);
  }

  String _getRandomCorrectPhrase() {
    return _correctPhrases[_random.nextInt(_correctPhrases.length)];
  }

  String _getRandomWrongPhrase() {
    return _wrongPhrases[_random.nextInt(_wrongPhrases.length)];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
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

    // Re-initialize TTS for new level
    _flutterTts.stop();

    setState(() {});
  }

  void _onItemDropped(String emoji, String categoryName) {
    final itemIndex = _items.indexWhere((i) => i.emoji == emoji && !i.isPlaced);
    if (itemIndex == -1) return;

    final item = _items[itemIndex];

    if (item.correctCategory == categoryName) {
      // Correct placement
      setState(() {
        _items[itemIndex].isPlaced = true;
        _correctPlacements++;
      });

      // Speak random correct phrase
      _speak(_getRandomCorrectPhrase());

      if (_correctPlacements == _items.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _completeLevel();
        });
      }
    } else {
      // Wrong placement - speak random wrong phrase
      _speak(_getRandomWrongPhrase());
    }
  }

  void _completeLevel() async {
    setState(() {
      _levelComplete = true;
      _completedLevels++;
    });

    _confettiController.play();

    // Speak level complete
    _speak('Amazing! All sorted!');

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_currentLevel < _challenges.length - 1) {
      setState(() {
        _currentLevel++;
      });
      _setupLevel();
      // Speak next challenge
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _speak('Now sort ${_challenges[_currentLevel].title}!');
        }
      });
    } else {
      _speak('You are a super organizer!');
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
                            return GestureDetector(
                              onTapDown: (_) {
                                // Speak the item name when touched
                                _speakItemName(item.emoji);
                              },
                              child: Draggable<String>(
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

                  // Drop zones (categories) - BASKETS
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: challenge.categories.map((category) {
                          final placedItems = _items
                              .where((i) => i.isPlaced && i.correctCategory == category.name)
                              .toList();

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: DragTarget<String>(
                                onWillAccept: (data) {
                                  return data != null;
                                },
                                onAccept: (data) {
                                  _onItemDropped(data, category.name);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  final isHovering = candidateData.isNotEmpty;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isHovering
                                          ? category.color.withOpacity(0.5)
                                          : category.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: category.color,
                                        width: isHovering ? 5 : 3,
                                      ),
                                      boxShadow: isHovering
                                          ? [
                                              BoxShadow(
                                                color: category.color.withOpacity(0.5),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          category.icon,
                                          style: const TextStyle(fontSize: 50),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: category.color,
                                          ),
                                        ),
                                        if (isHovering)
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: const Text(
                                              '⬇️ DROP HERE ⬇️',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 5,
                                          runSpacing: 5,
                                          alignment: WrapAlignment.center,
                                          children: placedItems
                                              .map((item) => Text(
                                                    item.emoji,
                                                    style: const TextStyle(fontSize: 30),
                                                  ))
                                              .toList(),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                          margin: const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            '${placedItems.length}/${category.items.length}',
                                            style: TextStyle(
                                              color: category.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
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
