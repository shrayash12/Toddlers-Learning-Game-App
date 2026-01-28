import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class SpellingGameScreen extends StatefulWidget {
  const SpellingGameScreen({super.key});

  @override
  State<SpellingGameScreen> createState() => _SpellingGameScreenState();
}

class _SpellingGameScreenState extends State<SpellingGameScreen> {
  final FlutterTts _tts = FlutterTts();
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> _words = [
    {'word': 'CAT', 'emoji': '🐱', 'hint': 'A furry pet that meows'},
    {'word': 'DOG', 'emoji': '🐕', 'hint': 'A loyal pet that barks'},
    {'word': 'SUN', 'emoji': '☀️', 'hint': 'It shines in the sky'},
    {'word': 'BALL', 'emoji': '⚽', 'hint': 'You can kick or throw it'},
    {'word': 'FISH', 'emoji': '🐟', 'hint': 'It swims in water'},
    {'word': 'BIRD', 'emoji': '🐦', 'hint': 'It has wings and can fly'},
    {'word': 'TREE', 'emoji': '🌳', 'hint': 'It has leaves and branches'},
    {'word': 'STAR', 'emoji': '⭐', 'hint': 'It twinkles at night'},
    {'word': 'MOON', 'emoji': '🌙', 'hint': 'You see it at night'},
    {'word': 'BEAR', 'emoji': '🐻', 'hint': 'A big furry animal'},
  ];

  int _currentWordIndex = 0;
  List<String> _selectedLetters = [];
  List<String> _availableLetters = [];
  int _score = 0;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initTts();
    _setupWord();
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
  }

  void _setupWord() {
    final word = _words[_currentWordIndex]['word'] as String;
    _selectedLetters = [];
    _availableLetters = word.split('')..shuffle();
    // Add some extra random letters for difficulty
    final extraLetters = ['A', 'E', 'I', 'O', 'U', 'S', 'T', 'N', 'R'];
    extraLetters.shuffle();
    _availableLetters.addAll(extraLetters.take(3));
    _availableLetters.shuffle();
    _showHint = false;
  }

  void _selectLetter(int index) {
    if (_selectedLetters.length >= (_words[_currentWordIndex]['word'] as String).length) {
      return;
    }

    setState(() {
      _selectedLetters.add(_availableLetters[index]);
      _availableLetters.removeAt(index);
    });

    _checkWord();
  }

  void _removeLetter(int index) {
    setState(() {
      _availableLetters.add(_selectedLetters[index]);
      _selectedLetters.removeAt(index);
    });
  }

  void _checkWord() {
    final word = _words[_currentWordIndex]['word'] as String;
    if (_selectedLetters.length == word.length) {
      final spelled = _selectedLetters.join('');
      if (spelled == word) {
        _confettiController.play();
        _tts.speak('Great job! You spelled $word correctly!');
        setState(() {
          _score += 10;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (_currentWordIndex < _words.length - 1) {
            setState(() {
              _currentWordIndex++;
              _setupWord();
            });
          } else {
            _showCompletionDialog();
          }
        });
      } else {
        _tts.speak('Try again!');
        // Shake animation would go here
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _availableLetters.addAll(_selectedLetters);
            _selectedLetters = [];
            _availableLetters.shuffle();
          });
        });
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.purple.shade50,
        title: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text(
              'Amazing Speller!',
              style: TextStyle(color: Colors.purple.shade700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You scored $_score points!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  Icons.star,
                  color: _score >= (i + 1) * 30 ? Colors.amber : Colors.grey.shade300,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentWordIndex = 0;
                _score = 0;
                _setupWord();
              });
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _words[_currentWordIndex];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade200, Colors.blue.shade100],
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
                          '${_currentWordIndex + 1}/${_words.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Word display
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji
                        Text(
                          currentWord['emoji'] as String,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 10),

                        // Hint button
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _showHint = !_showHint);
                            if (_showHint) {
                              _tts.speak(currentWord['hint'] as String);
                            }
                          },
                          icon: Icon(
                            _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                            color: Colors.amber,
                          ),
                          label: Text(
                            _showHint ? currentWord['hint'] as String : 'Show Hint',
                            style: TextStyle(color: Colors.purple.shade700),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Spelling slots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            (currentWord['word'] as String).length,
                            (index) => GestureDetector(
                              onTap: index < _selectedLetters.length
                                ? () => _removeLetter(index)
                                : null,
                              child: Container(
                                width: 50,
                                height: 60,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: index < _selectedLetters.length
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.purple.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    index < _selectedLetters.length
                                      ? _selectedLetters[index]
                                      : '',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Available letters
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            _availableLetters.length,
                            (index) => GestureDetector(
                              onTap: () => _selectLetter(index),
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade400,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.shade200,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _availableLetters[index],
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Speak button
                        ElevatedButton.icon(
                          onPressed: () => _tts.speak('Spell ${currentWord['word']}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.volume_up, color: Colors.white),
                          label: const Text(
                            'Hear Word',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
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
                Colors.purple,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}