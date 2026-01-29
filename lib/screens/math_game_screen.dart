import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late AnimationController _transitionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _transitionAnimation;
  final Random _random = Random();
  bool _isTransitioning = false;

  int _num1 = 0;
  int _num2 = 0;
  bool _isAddition = true;
  int _correctAnswer = 0;
  List<int> _options = [];
  int _score = 0;
  int _questionsAnswered = 0;
  final int _totalQuestions = 10;
  bool _answered = false;
  int? _selectedAnswer;
  bool _isWrong = false;
  int _attempts = 0;
  bool _isProcessing = false;

  final List<String> _emojis = ['🍎', '🌟', '🎈', '🍪', '🦋', '🌸', '🍬', '🎯'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

    // Transition animation (rotate and scale)
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _transitionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    _initTts();
    _generateQuestion();
  }

  bool _isSpeaking = false;

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
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
    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await _tts.speak(text);
      // Give enough time for short phrases to complete
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      // TTS error - ignore
    }
  }

  void _generateQuestion() {
    _answered = false;
    _selectedAnswer = null;
    _isWrong = false;
    _attempts = 0;
    _isProcessing = false;

    // Alternate between addition and subtraction
    _isAddition = _random.nextBool();

    if (_isAddition) {
      _num1 = _random.nextInt(9) + 1; // 1-9
      _num2 = _random.nextInt(9) + 1; // 1-9
      _correctAnswer = _num1 + _num2;
    } else {
      _num1 = _random.nextInt(9) + 2; // 2-10
      _num2 = _random.nextInt(_num1 - 1) + 1; // 1 to num1-1
      _correctAnswer = _num1 - _num2;
    }

    // Generate options
    _options = [_correctAnswer];
    while (_options.length < 4) {
      int wrongAnswer = _correctAnswer + _random.nextInt(5) - 2;
      if (wrongAnswer >= 0 && !_options.contains(wrongAnswer) && wrongAnswer != _correctAnswer) {
        _options.add(wrongAnswer);
      }
    }
    _options.shuffle();

    _speakQuestion();
  }

  void _speakQuestion() async {
    String question = _isAddition
        ? 'What is $_num1 plus $_num2?'
        : 'What is $_num1 minus $_num2?';
    await _speak(question);
  }

  void _checkAnswer(int answer) async {
    if (_answered || _isProcessing) return;

    if (answer == _correctAnswer) {
      // Correct answer
      setState(() {
        _answered = true;
        _selectedAnswer = answer;
        _isWrong = false;
      });
      _confettiController.play();
      await _speak('Correct! Great job!');
      setState(() {
        // Give bonus points for first attempt
        _score += _attempts == 0 ? 10 : 5;
        _questionsAnswered++;
      });
      _animationController.forward().then((_) => _animationController.reverse());

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (_questionsAnswered < _totalQuestions) {
            setState(() {
              _generateQuestion();
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
        _selectedAnswer = answer;
        _attempts++;
        _isProcessing = true;
      });

      // Shake animation
      _shakeController.forward();

      // Play wrong sound (don't await - let it play in background)
      try {
        _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
      } catch (e) {
        // Sound file might not exist
      }

      // Speak feedback
      await _speak('Oops! Try again!');

      // Reset after showing feedback to allow retry
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isWrong = false;
          _selectedAnswer = null;
          _isProcessing = false;
        });
      }
    }
  }

  void _showCompletionDialog() {
    int stars = _score >= 80 ? 3 : (_score >= 50 ? 2 : 1);
    String message = stars == 3
        ? 'Math Genius!'
        : (stars == 2 ? 'Great Work!' : 'Keep Practicing!');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.green.shade50,
        title: Column(
          children: [
            const Text('🧮', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text(message, style: TextStyle(color: Colors.green.shade700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score / ${_totalQuestions * 10}',
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
                _score = 0;
                _questionsAnswered = 0;
                _generateQuestion();
              });
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
    _transitionController.dispose();
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  Widget _buildVisualRepresentation() {
    String emoji = _emojis[_random.nextInt(_emojis.length)];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First number
        Wrap(
          children: List.generate(
            _num1,
            (_) => Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _isAddition ? '+' : '-',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _isAddition ? Colors.green : Colors.orange,
            ),
          ),
        ),
        // Second number
        Wrap(
          children: List.generate(
            _num2,
            (_) => Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green.shade200, Colors.teal.shade100],
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
                          '${_questionsAnswered + 1}/$_totalQuestions',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _questionsAnswered / _totalQuestions,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
                        minHeight: 10,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Visual representation
                        _buildVisualRepresentation(),

                        const SizedBox(height: 30),

                        // Question
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_num1',
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    _isAddition ? '+' : '-',
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      color: _isAddition ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$_num2',
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade600,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '=',
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  '?',
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Wrong answer feedback message
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

                        // Answer options with shake animation
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                _isWrong ? sin(_shakeAnimation.value * pi * 4) * 10 : 0,
                                0,
                              ),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: _options.map((option) {
                                  bool isSelected = _selectedAnswer == option;
                                  bool isCorrect = option == _correctAnswer;
                                  Color bgColor = Colors.blue.shade400;

                                  if (_answered && isCorrect) {
                                    bgColor = Colors.green;
                                  } else if (_isWrong && isSelected) {
                                    bgColor = Colors.red;
                                  }

                                  return GestureDetector(
                                    onTap: () => _checkAnswer(option),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: bgColor.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$option',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Speak button
                        ElevatedButton.icon(
                          onPressed: _speakQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.volume_up, color: Colors.white),
                          label: const Text(
                            'Hear Question',
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
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.pink,
              ],
            ),
          ),
        ],
      ),
    );
  }
}