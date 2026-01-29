import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class PhonicsGameScreen extends StatefulWidget {
  const PhonicsGameScreen({super.key});

  @override
  State<PhonicsGameScreen> createState() => _PhonicsGameScreenState();
}

class _PhonicsGameScreenState extends State<PhonicsGameScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;

  final List<Map<String, dynamic>> _phonics = [
    {
      'letter': 'A',
      'sound': 'ah',
      'words': ['Apple', 'Ant', 'Alligator'],
      'emojis': ['🍎', '🐜', '🐊'],
      'color': Colors.red,
    },
    {
      'letter': 'B',
      'sound': 'buh',
      'words': ['Ball', 'Bear', 'Banana'],
      'emojis': ['⚽', '🐻', '🍌'],
      'color': Colors.blue,
    },
    {
      'letter': 'C',
      'sound': 'kuh',
      'words': ['Cat', 'Car', 'Cookie'],
      'emojis': ['🐱', '🚗', '🍪'],
      'color': Colors.orange,
    },
    {
      'letter': 'D',
      'sound': 'duh',
      'words': ['Dog', 'Duck', 'Drum'],
      'emojis': ['🐕', '🦆', '🥁'],
      'color': Colors.brown,
    },
    {
      'letter': 'E',
      'sound': 'eh',
      'words': ['Egg', 'Elephant', 'Eagle'],
      'emojis': ['🥚', '🐘', '🦅'],
      'color': Colors.purple,
    },
    {
      'letter': 'F',
      'sound': 'fuh',
      'words': ['Fish', 'Frog', 'Flower'],
      'emojis': ['🐟', '🐸', '🌸'],
      'color': Colors.cyan,
    },
    {
      'letter': 'G',
      'sound': 'guh',
      'words': ['Goat', 'Grapes', 'Guitar'],
      'emojis': ['🐐', '🍇', '🎸'],
      'color': Colors.green,
    },
    {
      'letter': 'H',
      'sound': 'huh',
      'words': ['House', 'Horse', 'Hat'],
      'emojis': ['🏠', '🐴', '🎩'],
      'color': Colors.indigo,
    },
    {
      'letter': 'I',
      'sound': 'ih',
      'words': ['Ice cream', 'Igloo', 'Island'],
      'emojis': ['🍦', '🏔️', '🏝️'],
      'color': Colors.lightBlue,
    },
    {
      'letter': 'J',
      'sound': 'juh',
      'words': ['Jam', 'Jellyfish', 'Jump'],
      'emojis': ['🍓', '🪼', '🦘'],
      'color': Colors.pink,
    },
  ];

  int _currentIndex = 0;
  int _score = 0;
  String? _correctWord;
  List<Map<String, String>> _options = [];
  bool _answered = false;
  String? _selectedWord;
  bool _isWrong = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeController);
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
    _initTts();
    _setupQuestion();
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.35);
    await _tts.setPitch(1.1);
    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() {
      _isSpeaking = true;
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await _tts.speak(text);
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      // TTS error
    }
  }

  void _setupQuestion() {
    final current = _phonics[_currentIndex];
    final words = current['words'] as List<String>;
    final emojis = current['emojis'] as List<String>;

    // Pick ONE correct answer from current letter
    int correctIndex = Random().nextInt(words.length);
    _correctWord = words[correctIndex];

    // Create options with only ONE correct answer
    _options = [];
    _options.add({'word': words[correctIndex], 'emoji': emojis[correctIndex]});

    // Add 3 wrong options from other letters
    List<int> usedIndices = [_currentIndex];
    while (_options.length < 4) {
      int wrongIndex = Random().nextInt(_phonics.length);
      if (!usedIndices.contains(wrongIndex)) {
        usedIndices.add(wrongIndex);
        final wrongPhonic = _phonics[wrongIndex];
        int wrongWordIndex = Random().nextInt((wrongPhonic['words'] as List).length);
        _options.add({
          'word': (wrongPhonic['words'] as List<String>)[wrongWordIndex],
          'emoji': (wrongPhonic['emojis'] as List<String>)[wrongWordIndex],
        });
      }
    }

    _options.shuffle();
    _answered = false;
    _selectedWord = null;
    _isWrong = false;
    _isProcessing = false;
  }

  void _playSound() {
    final current = _phonics[_currentIndex];
    _tts.speak('${current['letter']} says ${current['sound']}');
    _animationController.forward().then((_) => _animationController.reverse());
  }

  void _playWord(String word) {
    _tts.speak(word);
  }

  void _checkAnswer(String word) async {
    if (_answered || _isProcessing) return;

    if (word == _correctWord) {
      // Correct answer
      setState(() {
        _answered = true;
        _selectedWord = word;
        _isWrong = false;
      });
      _confettiController.play();
      await _speak('Correct! $word starts with ${_phonics[_currentIndex]['letter']}');
      setState(() {
        _score += 10;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (_currentIndex < _phonics.length - 1) {
            setState(() {
              _currentIndex++;
              _setupQuestion();
            });
          } else {
            _showCompletionDialog();
          }
        }
      });
    } else {
      // Wrong answer - give another chance
      setState(() {
        _isWrong = true;
        _selectedWord = word;
        _isProcessing = true;
      });

      // Shake animation
      _shakeController.forward();

      // Play wrong sound
      try {
        _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
      } catch (e) {
        // Sound file might not exist
      }

      // Speak feedback
      await _speak('Oops! Try again!');

      // Reset to allow retry
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isWrong = false;
          _selectedWord = null;
          _isProcessing = false;
        });
      }
    }
  }

  void _showCompletionDialog() {
    int stars = _score >= 80 ? 3 : (_score >= 50 ? 2 : 1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.teal.shade50,
        title: Column(
          children: [
            const Text('🔤', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text(
              'Phonics Pro!',
              style: TextStyle(color: Colors.teal.shade700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score / ${_phonics.length * 10}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  Icons.star,
                  color: i < stars ? Colors.amber : Colors.grey.shade300,
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
                _currentIndex = 0;
                _score = 0;
                _setupQuestion();
              });
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    _shakeController.dispose();
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _phonics[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.teal.shade200, Colors.cyan.shade100],
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
                          '${_currentIndex + 1}/${_phonics.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Letter display
                          AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _bounceAnimation.value),
                                child: child,
                              );
                            },
                            child: GestureDetector(
                              onTap: _playSound,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: current['color'] as Color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (current['color'] as Color).withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    current['letter'] as String,
                                    style: const TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Sound info
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.shade100,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.volume_up, color: current['color'] as Color),
                                const SizedBox(width: 10),
                                Text(
                                  '"${current['letter']}" says "${current['sound']}"',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: current['color'] as Color,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Question
                          Text(
                            'Which word starts with "${current['letter']}"?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Wrong answer feedback
                          if (_isWrong)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('❌', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Oops! Try Again!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Options with shake animation
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  _isWrong ? sin(_shakeAnimation.value * pi * 4) * 10 : 0,
                                  0,
                                ),
                                child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: _options.map((option) {
                              bool isSelected = _selectedWord == option['word'];
                              bool isCorrect = option['word'] == _correctWord;
                              Color bgColor = Colors.white;

                              if (_answered && isCorrect) {
                                bgColor = Colors.green.shade100;
                              } else if (_isWrong && isSelected) {
                                bgColor = Colors.red.shade100;
                              }

                              return GestureDetector(
                                onTap: () => _checkAnswer(option['word']!),
                                onLongPress: () => _playWord(option['word']!),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 150,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: (_answered && isCorrect)
                                          ? Colors.green
                                          : (_isWrong && isSelected)
                                              ? Colors.red
                                              : Colors.teal.shade200,
                                      width: (isSelected && (_answered || _isWrong)) ? 3 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal.shade100,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        option['emoji']!,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        option['word']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // Play sound button
                          ElevatedButton.icon(
                            onPressed: _playSound,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: current['color'] as Color,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.record_voice_over, color: Colors.white),
                            label: const Text(
                              'Hear the Sound',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Long press any word to hear it!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
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
              numberOfParticles: 40,
              gravity: 0.1,
              colors: const [
                Colors.teal,
                Colors.cyan,
                Colors.green,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}