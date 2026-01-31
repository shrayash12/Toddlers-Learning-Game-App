import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

class PottyTrainingGameScreen extends StatefulWidget {
  const PottyTrainingGameScreen({super.key});

  @override
  State<PottyTrainingGameScreen> createState() => _PottyTrainingGameScreenState();
}

class _PottyTrainingGameScreenState extends State<PottyTrainingGameScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  int _currentStep = 0;
  int _starsEarned = 0;
  bool _showCelebration = false;
  bool _stepComplete = false;

  final List<String> _encouragements = [
    'Great job!',
    'Well done!',
    'Awesome!',
    'You did it!',
    'Fantastic!',
    'Super!',
    'Amazing!',
    'Wonderful!',
    'Good job!',
    'Excellent!',
  ];

  final List<PottyStep> _steps = [
    PottyStep(
      title: 'Feel the Need',
      instruction: 'When you feel it, tap your tummy!',
      emoji: '🤔',
      actionEmoji: '👆',
      targetEmoji: '😊',
      color: Colors.blue,
      celebration: 'Good job noticing!',
    ),
    PottyStep(
      title: 'Go to Bathroom',
      instruction: 'Walk to the potty! Tap the door!',
      emoji: '🚶',
      actionEmoji: '🚪',
      targetEmoji: '🚽',
      color: Colors.green,
      celebration: 'You found it!',
    ),
    PottyStep(
      title: 'Sit on Potty',
      instruction: 'Sit down carefully! Tap the potty!',
      emoji: '🚽',
      actionEmoji: '👇',
      targetEmoji: '😌',
      color: Colors.purple,
      celebration: 'Perfect sitting!',
    ),
    PottyStep(
      title: 'Do Your Business',
      instruction: 'Wait patiently... Tap when ready!',
      emoji: '⏳',
      actionEmoji: '✨',
      targetEmoji: '😊',
      color: Colors.amber,
      celebration: 'Well done!',
    ),
    PottyStep(
      title: 'Wipe Clean',
      instruction: 'Wipe yourself clean! Tap the paper!',
      emoji: '🧻',
      actionEmoji: '👋',
      targetEmoji: '✨',
      color: Colors.pink,
      celebration: 'So clean!',
    ),
    PottyStep(
      title: 'Flush',
      instruction: 'Flush the toilet! Tap the button!',
      emoji: '🔘',
      actionEmoji: '💧',
      targetEmoji: '🌊',
      color: Colors.cyan,
      celebration: 'Whoooosh!',
    ),
    PottyStep(
      title: 'Wash Hands',
      instruction: 'Wash your hands with soap! Tap the soap!',
      emoji: '🧼',
      actionEmoji: '🙌',
      targetEmoji: '🫧',
      color: Colors.teal,
      celebration: 'Squeaky clean!',
    ),
    PottyStep(
      title: 'All Done!',
      instruction: 'You did it! Give yourself a high five!',
      emoji: '🙌',
      actionEmoji: '⭐',
      targetEmoji: '🌟',
      color: Colors.orange,
      celebration: 'You are amazing!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _bounceController.repeat(reverse: true);
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
    // Speak the first instruction after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _speakInstruction();
      }
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  void _speakInstruction() {
    final step = _steps[_currentStep];
    _speak('${step.title}. ${step.instruction}');
  }

  String _getRandomEncouragement() {
    return _encouragements[Random().nextInt(_encouragements.length)];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onStepTapped() async {
    if (_stepComplete) return;

    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      // Sound file may not exist
    }

    if (!mounted) return;

    setState(() {
      _stepComplete = true;
      _starsEarned++;
      _showCelebration = true;
    });

    _confettiController.play();

    // Speak celebration
    final step = _steps[_currentStep];
    _speak('${_getRandomEncouragement()} ${step.celebration}');

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _stepComplete = false;
        _showCelebration = false;
      });
      // Speak next instruction
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _speakInstruction();
        }
      });
    } else {
      _speak('You are a super star! You learned all the potty steps!');
      _showFinalCelebration();
    }
  }

  void _showFinalCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.yellow.shade100,
        title: Column(
          children: [
            const Text(
              '🎉 Super Star! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _starsEarned,
                (_) => const Text('⭐', style: TextStyle(fontSize: 25)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You learned all the potty steps!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              '🚽✨🧼🙌',
              style: TextStyle(fontSize: 35),
            ),
            const SizedBox(height: 15),
            const Text(
              'Remember: Using the potty makes you a BIG kid!',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentStep = 0;
                  _starsEarned = 0;
                  _stepComplete = false;
                  _showCelebration = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Practice Again!',
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
    final step = _steps[_currentStep];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [step.color.withOpacity(0.3), Colors.white],
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
                          color: step.color,
                        ),
                        Expanded(
                          child: Text(
                            'Potty Time!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: step.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_starsEarned, (_) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⭐', style: TextStyle(fontSize: 20)),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentStep + 1) / _steps.length,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(step.color),
                            minHeight: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Step ${_currentStep + 1} of ${_steps.length}',
                          style: TextStyle(color: step.color),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Step title
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: step.color,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Instruction
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      step.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),

                  const Spacer(),

                  // Main action area
                  GestureDetector(
                    onTap: _onStepTapped,
                    child: AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _stepComplete ? 1.0 : _bounceAnimation.value,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: _stepComplete
                                  ? Colors.green.shade100
                                  : step.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _stepComplete ? Colors.green : step.color,
                                width: 5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: step.color.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _stepComplete ? step.targetEmoji : step.emoji,
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action indicator
                  if (!_stepComplete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tap! ',
                          style: TextStyle(
                            fontSize: 20,
                            color: step.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          step.actionEmoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ],
                    ),

                  // Celebration message
                  if (_showCelebration)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        step.celebration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Step indicators
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_steps.length, (index) {
                        final isComplete = index < _currentStep ||
                            (index == _currentStep && _stepComplete);
                        final isCurrent = index == _currentStep;

                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isComplete
                                ? Colors.green
                                : (isCurrent
                                    ? step.color
                                    : Colors.grey.shade300),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isComplete
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : Text(
                                    _steps[index].emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                          ),
                        );
                      }),
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
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.1,
                  colors: const [
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
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

class PottyStep {
  final String title;
  final String instruction;
  final String emoji;
  final String actionEmoji;
  final String targetEmoji;
  final Color color;
  final String celebration;

  PottyStep({
    required this.title,
    required this.instruction,
    required this.emoji,
    required this.actionEmoji,
    required this.targetEmoji,
    required this.color,
    required this.celebration,
  });
}
