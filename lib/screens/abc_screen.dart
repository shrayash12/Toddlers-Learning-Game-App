import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AbcScreen extends StatefulWidget {
  const AbcScreen({super.key});

  @override
  State<AbcScreen> createState() => _AbcScreenState();
}

class _AbcScreenState extends State<AbcScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  final List<Map<String, dynamic>> _letters = [
    {'letter': 'A', 'word': 'Apple', 'emoji': '🍎', 'color': Colors.red},
    {'letter': 'B', 'word': 'Ball', 'emoji': '⚽', 'color': Colors.blue},
    {'letter': 'C', 'word': 'Cat', 'emoji': '🐱', 'color': Colors.orange},
    {'letter': 'D', 'word': 'Dog', 'emoji': '🐕', 'color': Colors.brown},
    {'letter': 'E', 'word': 'Elephant', 'emoji': '🐘', 'color': Colors.grey},
    {'letter': 'F', 'word': 'Fish', 'emoji': '🐟', 'color': Colors.cyan},
    {'letter': 'G', 'word': 'Grapes', 'emoji': '🍇', 'color': Colors.purple},
    {'letter': 'H', 'word': 'House', 'emoji': '🏠', 'color': Colors.teal},
    {'letter': 'I', 'word': 'Ice Cream', 'emoji': '🍦', 'color': Colors.pink},
    {'letter': 'J', 'word': 'Juice', 'emoji': '🧃', 'color': Colors.amber},
    {'letter': 'K', 'word': 'Kite', 'emoji': '🪁', 'color': Colors.indigo},
    {'letter': 'L', 'word': 'Lion', 'emoji': '🦁', 'color': Colors.yellow},
    {'letter': 'M', 'word': 'Moon', 'emoji': '🌙', 'color': Colors.blueGrey},
    {'letter': 'N', 'word': 'Nose', 'emoji': '👃', 'color': Colors.lime},
    {'letter': 'O', 'word': 'Orange', 'emoji': '🍊', 'color': Colors.deepOrange},
    {'letter': 'P', 'word': 'Penguin', 'emoji': '🐧', 'color': Colors.black87},
    {'letter': 'Q', 'word': 'Queen', 'emoji': '👸', 'color': Colors.deepPurple},
    {'letter': 'R', 'word': 'Rainbow', 'emoji': '🌈', 'color': Colors.redAccent},
    {'letter': 'S', 'word': 'Sun', 'emoji': '☀️', 'color': Colors.amber},
    {'letter': 'T', 'word': 'Tree', 'emoji': '🌳', 'color': Colors.green},
    {'letter': 'U', 'word': 'Umbrella', 'emoji': '☂️', 'color': Colors.lightBlue},
    {'letter': 'V', 'word': 'Violin', 'emoji': '🎻', 'color': Colors.brown},
    {'letter': 'W', 'word': 'Watermelon', 'emoji': '🍉', 'color': Colors.greenAccent},
    {'letter': 'X', 'word': 'Xylophone', 'emoji': '🎵', 'color': Colors.pinkAccent},
    {'letter': 'Y', 'word': 'Yarn', 'emoji': '🧶', 'color': Colors.red},
    {'letter': 'Z', 'word': 'Zebra', 'emoji': '🦓', 'color': Colors.black54},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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

    // Speak the first letter
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakLetter();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakLetter() async {
    final letter = _letters[_currentIndex];
    final text = "${letter['letter']}. ${letter['letter']} for ${letter['word']}";
    await _flutterTts.speak(text);
  }

  void _nextLetter() {
    _flutterTts.stop();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    setState(() {
      _currentIndex = (_currentIndex + 1) % _letters.length;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _speakLetter();
    });
  }

  void _previousLetter() {
    _flutterTts.stop();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    setState(() {
      _currentIndex = (_currentIndex - 1 + _letters.length) % _letters.length;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _speakLetter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final letter = _letters[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (letter['color'] as Color).withOpacity(0.3),
              (letter['color'] as Color).withOpacity(0.1),
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
                      color: letter['color'] as Color,
                    ),
                    const Spacer(),
                    Text(
                      'ABC Letters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: letter['color'] as Color,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isSpeaking ? Icons.volume_up : Icons.volume_off,
                      color: letter['color'] as Color,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _speakLetter,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _previousLetter();
                    } else {
                      _nextLetter();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (letter['color'] as Color).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            letter['letter'] as String,
                            style: TextStyle(
                              fontSize: 150,
                              fontWeight: FontWeight.bold,
                              color: letter['color'] as Color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        letter['emoji'] as String,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${letter['letter']} for ${letter['word']}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: letter['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 15),
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _previousLetter,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: letter['color'] as Color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: (letter['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${_letters.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: letter['color'] as Color,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _nextLetter,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: letter['color'] as Color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
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
}
