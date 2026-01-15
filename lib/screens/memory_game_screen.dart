import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late ConfettiController _confettiController;

  final List<String> _emojis = ['🐕', '🐱', '🐸', '🦁', '🐘', '🐷', '🐰', '🐻'];
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;

  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isProcessing = false;
  int _moves = 0;
  int _matchedPairs = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initGame();
  }

  void _initGame() {
    _cards = [..._emojis, ..._emojis];
    _cards.shuffle();
    _flipped = List.generate(_cards.length, (_) => false);
    _matched = List.generate(_cards.length, (_) => false);
    _firstCardIndex = null;
    _secondCardIndex = null;
    _isProcessing = false;
    _moves = 0;
    _matchedPairs = 0;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (_isProcessing || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;

      if (_firstCardIndex == null) {
        _firstCardIndex = index;
      } else {
        _secondCardIndex = index;
        _moves++;
        _isProcessing = true;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        if (_cards[_firstCardIndex!] == _cards[_secondCardIndex!]) {
          _matched[_firstCardIndex!] = true;
          _matched[_secondCardIndex!] = true;
          _matchedPairs++;

          if (_matchedPairs == _emojis.length) {
            _confettiController.play();
            _showGameComplete();
          }
        } else {
          _flipped[_firstCardIndex!] = false;
          _flipped[_secondCardIndex!] = false;
        }

        _firstCardIndex = null;
        _secondCardIndex = null;
        _isProcessing = false;
      });
    });
  }

  void _showGameComplete() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '🎉 You Won!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Completed in $_moves moves!',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _getStars(),
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 10),
              Text(
                _getRating(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _initGame();
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
    });
  }

  String _getStars() {
    if (_moves <= 10) return '⭐⭐⭐';
    if (_moves <= 15) return '⭐⭐';
    if (_moves <= 20) return '⭐';
    return '🌟';
  }

  String _getRating() {
    if (_moves <= 10) return 'Perfect Memory!';
    if (_moves <= 15) return 'Great Job!';
    if (_moves <= 20) return 'Good Work!';
    return 'Keep Practicing!';
  }

  void _resetGame() {
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE1BEE7), Color(0xFFF3E5F5)],
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
                          color: Colors.purple,
                        ),
                        const Spacer(),
                        Text(
                          'Memory Game',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _resetGame,
                          icon: const Icon(Icons.refresh_rounded, size: 30),
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Moves', '$_moves', Icons.touch_app),
                        _buildStatCard('Pairs', '$_matchedPairs/${_emojis.length}', Icons.check_circle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) => _buildCard(index),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Find all matching pairs!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple.shade400,
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
              numberOfParticles: 30,
              gravity: 0.1,
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
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = _flipped[index];
    final isMatched = _matched[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isMatched
              ? Colors.green.shade100
              : isFlipped
                  ? Colors.white
                  : Colors.purple.shade300,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMatched
                ? Colors.green
                : isFlipped
                    ? Colors.purple.shade200
                    : Colors.purple.shade400,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isFlipped || isMatched ? 1.0 : 0.0,
            child: Text(
              _cards[index],
              style: const TextStyle(fontSize: 35),
            ),
          ),
        ),
      ),
    );
  }
}
