import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late ConfettiController _confettiController;
  int _score = 0;
  int _currentRound = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Which animal says "Woof"?',
      'answer': '🐕',
      'options': ['🐕', '🐱', '🐄', '🐸'],
      'color': Colors.brown,
    },
    {
      'question': 'What color is the sun?',
      'answer': '🟡',
      'options': ['🔴', '🟡', '🔵', '🟢'],
      'color': Colors.amber,
    },
    {
      'question': 'Which fruit is red?',
      'answer': '🍎',
      'options': ['🍌', '🍊', '🍎', '🍇'],
      'color': Colors.red,
    },
    {
      'question': 'How many legs does a dog have?',
      'answer': '4',
      'options': ['2', '4', '6', '8'],
      'color': Colors.blue,
    },
    {
      'question': 'Which shape has 3 sides?',
      'answer': '🔺',
      'options': ['⬜', '🔺', '⭐', '💎'],
      'color': Colors.green,
    },
    {
      'question': 'What do cows give us?',
      'answer': '🥛',
      'options': ['🥚', '🥛', '🍯', '🧀'],
      'color': Colors.grey,
    },
    {
      'question': 'Which animal can fly?',
      'answer': '🐦',
      'options': ['🐕', '🐱', '🐦', '🐟'],
      'color': Colors.cyan,
    },
    {
      'question': 'What letter does "Apple" start with?',
      'answer': 'A',
      'options': ['B', 'A', 'C', 'D'],
      'color': Colors.red,
    },
    {
      'question': 'Which is bigger?',
      'answer': '🐘',
      'options': ['🐁', '🐱', '🐕', '🐘'],
      'color': Colors.purple,
    },
    {
      'question': 'What comes after 5?',
      'answer': '6',
      'options': ['4', '5', '6', '7'],
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _shuffleQuestions();
  }

  void _shuffleQuestions() {
    _questions.shuffle();
    for (var q in _questions) {
      (q['options'] as List).shuffle();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAnswer(String answer) {
    final correct = _questions[_currentRound]['answer'] as String;
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _isCorrect = answer == correct;
      if (_isCorrect) {
        _score++;
        _confettiController.play();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showResult = false;
          _selectedAnswer = null;
          if (_currentRound < _questions.length - 1) {
            _currentRound++;
          } else {
            _showGameComplete();
          }
        });
      }
    });
  }

  void _showGameComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _score >= 7 ? '🎉 Amazing!' : _score >= 5 ? '👍 Good Job!' : '💪 Keep Trying!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You got $_score out of ${_questions.length}!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _getStars(),
              style: const TextStyle(fontSize: 40),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _currentRound = 0;
                _shuffleQuestions();
              });
            },
            child: const Text('Play Again', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Home', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  String _getStars() {
    if (_score >= 9) return '⭐⭐⭐';
    if (_score >= 7) return '⭐⭐';
    if (_score >= 5) return '⭐';
    return '🌟';
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _currentRound = 0;
      _shuffleQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentRound];
    final color = question['color'] as Color;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.2),
                  Colors.white,
                ],
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
                          icon: const Icon(Icons.arrow_back_rounded, size: 30),
                          color: color,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 5),
                              Text(
                                '$_score',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _resetGame,
                          icon: const Icon(Icons.refresh_rounded, size: 30),
                          color: color,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      value: (_currentRound + 1) / _questions.length,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Question ${_currentRound + 1} of ${_questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              question['question'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Wrap(
                            spacing: 15,
                            runSpacing: 15,
                            alignment: WrapAlignment.center,
                            children: (question['options'] as List)
                                .map((option) => _buildOptionButton(
                                      option as String,
                                      color,
                                      question['answer'] as String,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.pink,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, Color color, String correctAnswer) {
    Color backgroundColor = Colors.white;
    Color borderColor = color.withOpacity(0.5);

    if (_showResult && _selectedAnswer == option) {
      if (_isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
      } else {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
      }
    }

    if (_showResult && option == correctAnswer && !_isCorrect) {
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green;
    }

    return GestureDetector(
      onTap: _showResult ? null : () => _checkAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            option,
            style: const TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }
}
