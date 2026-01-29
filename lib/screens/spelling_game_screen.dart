import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class SpellingGameScreen extends StatefulWidget {
  const SpellingGameScreen({super.key});

  @override
  State<SpellingGameScreen> createState() => _SpellingGameScreenState();
}

class _SpellingGameScreenState extends State<SpellingGameScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _ttsReady = false;
  bool _isSpeaking = false;
  bool _isWrong = false;

  final List<Map<String, dynamic>> _words = [
    {'word': 'CAT', 'emoji': '🐱', 'hint': 'A furry pet that says meow'},
    {'word': 'DOG', 'emoji': '🐕', 'hint': 'A loyal pet that says woof'},
    {'word': 'SUN', 'emoji': '☀️', 'hint': 'It shines bright in the sky'},
    {'word': 'BALL', 'emoji': '⚽', 'hint': 'You can kick or throw it'},
    {'word': 'FISH', 'emoji': '🐟', 'hint': 'It swims in the water'},
    {'word': 'BIRD', 'emoji': '🐦', 'hint': 'It has wings and can fly'},
    {'word': 'TREE', 'emoji': '🌳', 'hint': 'It has leaves and branches'},
    {'word': 'STAR', 'emoji': '⭐', 'hint': 'It twinkles at night in the sky'},
    {'word': 'MOON', 'emoji': '🌙', 'hint': 'You see it at night, it glows'},
    {'word': 'BEAR', 'emoji': '🐻', 'hint': 'A big furry animal in the forest'},
  ];

  int _currentWordIndex = 0;
  List<String> _selectedLetters = [];
  List<String> _availableLetters = [];
  int _score = 0;
  bool _showHint = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);

    _tts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    setState(() {
      _ttsReady = true;
    });

    _setupWord();
  }

  Future<void> _speak(String text) async {
    if (!_ttsReady || _isSpeaking) return;

    setState(() {
      _isSpeaking = true;
    });

    await _tts.stop();
    await Future.delayed(const Duration(milliseconds: 100));
    await _tts.speak(text);
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
    _isCorrect = false;

    // Announce the word after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _speakWordIntro();
      }
    });
  }

  Future<void> _speakWordIntro() async {
    final word = _words[_currentWordIndex]['word'] as String;
    final emoji = _words[_currentWordIndex]['emoji'] as String;
    await _speak('Can you spell $word? Look at the picture and spell the word!');
  }

  Future<void> _speakHint() async {
    final hint = _words[_currentWordIndex]['hint'] as String;
    await _speak('Here is a hint: $hint');
  }

  void _selectLetter(int index) async {
    if (_isCorrect) return;
    if (_selectedLetters.length >= (_words[_currentWordIndex]['word'] as String).length) {
      return;
    }

    final letter = _availableLetters[index];

    setState(() {
      _selectedLetters.add(letter);
      _availableLetters.removeAt(index);
    });

    // Speak the letter
    await _tts.stop();
    await _tts.speak(letter);

    _checkWord();
  }

  void _removeLetter(int index) async {
    if (_isCorrect) return;

    final letter = _selectedLetters[index];

    setState(() {
      _availableLetters.add(letter);
      _selectedLetters.removeAt(index);
    });
  }

  void _checkWord() async {
    final word = _words[_currentWordIndex]['word'] as String;
    if (_selectedLetters.length == word.length) {
      final spelled = _selectedLetters.join('');
      if (spelled == word) {
        setState(() {
          _isCorrect = true;
          _score += 10;
        });

        _confettiController.play();

        await Future.delayed(const Duration(milliseconds: 500));
        await _speak('Wonderful! You spelled $word correctly! Great job!');

        await Future.delayed(const Duration(seconds: 3));

        if (mounted) {
          if (_currentWordIndex < _words.length - 1) {
            setState(() {
              _currentWordIndex++;
            });
            _setupWord();
          } else {
            _showCompletionDialog();
          }
        }
      } else {
        await _speak('Oops! That is not right. Try again!');

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          setState(() {
            _availableLetters.addAll(_selectedLetters);
            _selectedLetters = [];
            _availableLetters.shuffle();
          });
        }
      }
    }
  }

  void _showCompletionDialog() {
    _speak('Amazing! You completed all the words! You are a spelling star!');

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
              });
              _setupWord();
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${_currentWordIndex + 1}/${_words.length}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Word display
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),

                          // Emoji with animation
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Text(
                                  currentWord['emoji'] as String,
                                  style: const TextStyle(fontSize: 80),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          // Hint button with voice
                          GestureDetector(
                            onTap: () {
                              setState(() => _showHint = !_showHint);
                              if (_showHint) {
                                _speakHint();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 30),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _showHint
                                    ? Colors.amber.shade100
                                    : Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                                    color: Colors.amber.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      _showHint
                                          ? currentWord['hint'] as String
                                          : 'Tap for Hint! 💡',
                                      style: TextStyle(
                                        color: Colors.purple.shade700,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (_showHint) ...[
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: _speakHint,
                                      child: Icon(
                                        Icons.volume_up,
                                        color: Colors.purple.shade400,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Spelling slots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              (currentWord['word'] as String).length,
                              (index) => GestureDetector(
                                onTap: index < _selectedLetters.length && !_isCorrect
                                  ? () => _removeLetter(index)
                                  : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 55,
                                  height: 65,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: _isCorrect
                                        ? Colors.green.shade100
                                        : (index < _selectedLetters.length
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isCorrect
                                          ? Colors.green
                                          : Colors.purple.shade300,
                                      width: 3,
                                    ),
                                    boxShadow: index < _selectedLetters.length
                                        ? [
                                            BoxShadow(
                                              color: (_isCorrect
                                                  ? Colors.green
                                                  : Colors.purple).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      index < _selectedLetters.length
                                        ? _selectedLetters[index]
                                        : '',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: _isCorrect
                                            ? Colors.green.shade700
                                            : Colors.purple.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (_isCorrect)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('✓ ', style: TextStyle(fontSize: 24, color: Colors.green)),
                                  Text(
                                    'Correct!',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const Text(' 🎉', style: TextStyle(fontSize: 24)),
                                ],
                              ),
                            ),

                          const SizedBox(height: 35),

                          // Available letters
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(
                                _availableLetters.length,
                                (index) => GestureDetector(
                                  onTap: !_isCorrect ? () => _selectLetter(index) : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.orange.shade400,
                                          Colors.orange.shade600,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.shade300,
                                          blurRadius: 6,
                                          offset: const Offset(0, 4),
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
                          ),

                          const SizedBox(height: 25),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Hear Word button
                              ElevatedButton.icon(
                                onPressed: () => _speak('The word is ${currentWord['word']}. Can you spell it?'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                icon: const Icon(Icons.volume_up, color: Colors.white),
                                label: const Text(
                                  'Hear Word',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Spell it out button
                              ElevatedButton.icon(
                                onPressed: () {
                                  final word = currentWord['word'] as String;
                                  final spelled = word.split('').join(', ');
                                  _speak('$word is spelled: $spelled');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                icon: const Icon(Icons.abc, color: Colors.white),
                                label: const Text(
                                  'Spell It',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
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
