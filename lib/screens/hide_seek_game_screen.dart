import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class HideSeekGameScreen extends StatefulWidget {
  const HideSeekGameScreen({super.key});

  @override
  State<HideSeekGameScreen> createState() => _HideSeekGameScreenState();
}

class _HideSeekGameScreenState extends State<HideSeekGameScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  final Random _random = Random();

  List<HidingSpot> _hidingSpots = [];
  String _currentAnimal = '';
  String _currentAnimalEmoji = '';
  int _foundCount = 0;
  int _totalToFind = 5;
  bool _showHint = false;
  int _hiddenSpotIndex = -1;

  final List<Map<String, String>> _animals = [
    {'name': 'Cat', 'emoji': '🐱'},
    {'name': 'Dog', 'emoji': '🐶'},
    {'name': 'Rabbit', 'emoji': '🐰'},
    {'name': 'Bear', 'emoji': '🐻'},
    {'name': 'Monkey', 'emoji': '🐵'},
    {'name': 'Panda', 'emoji': '🐼'},
    {'name': 'Fox', 'emoji': '🦊'},
    {'name': 'Lion', 'emoji': '🦁'},
  ];

  final List<Map<String, dynamic>> _spots = [
    {'emoji': '🌳', 'name': 'Tree', 'color': Colors.green},
    {'emoji': '🏠', 'name': 'House', 'color': Colors.brown},
    {'emoji': '📦', 'name': 'Box', 'color': Colors.orange},
    {'emoji': '🪨', 'name': 'Rock', 'color': Colors.grey},
    {'emoji': '🌺', 'name': 'Flower', 'color': Colors.pink},
    {'emoji': '☁️', 'name': 'Cloud', 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _startNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    final animal = _animals[_random.nextInt(_animals.length)];
    _currentAnimal = animal['name']!;
    _currentAnimalEmoji = animal['emoji']!;

    // Create hiding spots
    _hidingSpots = [];
    List<int> usedSpots = [];
    for (int i = 0; i < 4; i++) {
      int spotIndex;
      do {
        spotIndex = _random.nextInt(_spots.length);
      } while (usedSpots.contains(spotIndex));
      usedSpots.add(spotIndex);

      _hidingSpots.add(HidingSpot(
        emoji: _spots[spotIndex]['emoji'],
        name: _spots[spotIndex]['name'],
        color: _spots[spotIndex]['color'],
        isRevealed: false,
      ));
    }

    _hiddenSpotIndex = _random.nextInt(_hidingSpots.length);
    _showHint = false;
    setState(() {});
  }

  void _onSpotTapped(int index) async {
    if (_hidingSpots[index].isRevealed) return;

    setState(() {
      _hidingSpots[index].isRevealed = true;
    });

    if (index == _hiddenSpotIndex) {
      // Found the animal!
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      _confettiController.play();
      _foundCount++;

      if (_foundCount >= _totalToFind) {
        _showWinDialog();
      } else {
        await Future.delayed(const Duration(milliseconds: 1500));
        _startNewRound();
      }
    } else {
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.amber.shade100,
        title: const Text(
          '🎉 Amazing! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You found all the animals!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '⭐⭐⭐',
              style: TextStyle(fontSize: 40),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _foundCount = 0;
                });
                _startNewRound();
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
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
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Text(
                            'Hide & Seek',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalToFind, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _foundCount ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 35,
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Find prompt
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Find the $_currentAnimal! ',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currentAnimalEmoji,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Hiding spots grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                        ),
                        itemCount: _hidingSpots.length,
                        itemBuilder: (context, index) {
                          final spot = _hidingSpots[index];
                          return GestureDetector(
                            onTap: () => _onSpotTapped(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: spot.isRevealed
                                    ? (index == _hiddenSpotIndex
                                        ? Colors.green.shade200
                                        : Colors.red.shade100)
                                    : spot.color.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: spot.color,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: spot.color.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    spot.emoji,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                  if (spot.isRevealed && index == _hiddenSpotIndex)
                                    Text(
                                      _currentAnimalEmoji,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  if (spot.isRevealed && index != _hiddenSpotIndex)
                                    const Text(
                                      '❌',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Hint button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showHint = true;
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _showHint = false;
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.lightbulb, color: Colors.white),
                      label: const Text(
                        'Hint',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
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

              // Hint indicator
              if (_showHint && _hiddenSpotIndex >= 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Look behind the ${_hidingSpots[_hiddenSpotIndex].name}! ${_hidingSpots[_hiddenSpotIndex].emoji}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
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

class HidingSpot {
  final String emoji;
  final String name;
  final Color color;
  bool isRevealed;

  HidingSpot({
    required this.emoji,
    required this.name,
    required this.color,
    this.isRevealed = false,
  });
}
