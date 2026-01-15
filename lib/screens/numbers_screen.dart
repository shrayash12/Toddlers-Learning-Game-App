import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen>
    with SingleTickerProviderStateMixin {
  int _currentNumber = 1;
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  final List<Map<String, dynamic>> _numberData = [
    {'number': 1, 'word': 'One', 'emoji': '⭐', 'color': Colors.red},
    {'number': 2, 'word': 'Two', 'emoji': '🌟', 'color': Colors.orange},
    {'number': 3, 'word': 'Three', 'emoji': '🎈', 'color': Colors.yellow},
    {'number': 4, 'word': 'Four', 'emoji': '🍀', 'color': Colors.green},
    {'number': 5, 'word': 'Five', 'emoji': '✋', 'color': Colors.teal},
    {'number': 6, 'word': 'Six', 'emoji': '🎲', 'color': Colors.blue},
    {'number': 7, 'word': 'Seven', 'emoji': '🌈', 'color': Colors.indigo},
    {'number': 8, 'word': 'Eight', 'emoji': '🐙', 'color': Colors.purple},
    {'number': 9, 'word': 'Nine', 'emoji': '🎱', 'color': Colors.pink},
    {'number': 10, 'word': 'Ten', 'emoji': '🔟', 'color': Colors.brown},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.1);

    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });

    // Speak the first number
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakNumber();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakNumber() async {
    final data = _numberData[_currentNumber - 1];
    final text = "${data['number']}. ${data['word']}";
    await _flutterTts.speak(text);
  }

  void _nextNumber() {
    _flutterTts.stop();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    setState(() {
      _currentNumber = (_currentNumber % 10) + 1;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _speakNumber();
    });
  }

  void _previousNumber() {
    _flutterTts.stop();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    setState(() {
      _currentNumber = _currentNumber == 1 ? 10 : _currentNumber - 1;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _speakNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _numberData[_currentNumber - 1];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (data['color'] as Color).withOpacity(0.2),
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
                      onPressed: () {
                        _flutterTts.stop();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 30),
                      color: data['color'] as Color,
                    ),
                    const Spacer(),
                    Text(
                      'Count Numbers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: data['color'] as Color,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isSpeaking ? Icons.volume_up : Icons.volume_off,
                      color: data['color'] as Color,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _speakNumber,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _previousNumber();
                    } else {
                      _nextNumber();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: (data['color'] as Color).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            '${data['number']}',
                            style: TextStyle(
                              fontSize: 160,
                              fontWeight: FontWeight.bold,
                              color: data['color'] as Color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['word'] as String,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: data['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isSpeaking)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Speaking...',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          data['number'] as int,
                          (index) => Text(
                            data['emoji'] as String,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(
                      icon: Icons.remove,
                      onPressed: _previousNumber,
                      color: data['color'] as Color,
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: (data['color'] as Color).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_currentNumber',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: data['color'] as Color,
                        ),
                      ),
                    ),
                    _buildNavButton(
                      icon: Icons.add,
                      onPressed: _nextNumber,
                      color: data['color'] as Color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, size: 40, color: Colors.white),
      ),
    );
  }
}
