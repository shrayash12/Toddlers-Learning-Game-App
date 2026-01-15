import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showSound = false;
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _animals = [
    {
      'name': 'Dog',
      'emoji': '🐕',
      'sound': 'Woof! Woof!',
      'audioUrl': 'https://www.soundjay.com/animals/dog-barking-01.mp3',
      'color': Colors.brown,
      'fact': 'Dogs are loyal friends!'
    },
    {
      'name': 'Cat',
      'emoji': '🐱',
      'sound': 'Meow! Meow!',
      'audioUrl': 'https://www.soundjay.com/animals/cat-meow-01.mp3',
      'color': Colors.orange,
      'fact': 'Cats love to sleep!'
    },
    {
      'name': 'Cow',
      'emoji': '🐄',
      'sound': 'Moo! Moo!',
      'audioUrl': 'https://www.soundjay.com/animals/cow-moo-01.mp3',
      'color': Colors.black87,
      'fact': 'Cows give us milk!'
    },
    {
      'name': 'Duck',
      'emoji': '🦆',
      'sound': 'Quack! Quack!',
      'audioUrl': 'https://www.soundjay.com/animals/duck-quack-01.mp3',
      'color': Colors.amber,
      'fact': 'Ducks love water!'
    },
    {
      'name': 'Lion',
      'emoji': '🦁',
      'sound': 'Roar! Roar!',
      'audioUrl': 'https://www.soundjay.com/animals/lion-roar-01.mp3',
      'color': Colors.yellow,
      'fact': 'Lions are the king of jungle!'
    },
    {
      'name': 'Elephant',
      'emoji': '🐘',
      'sound': 'Trumpet!',
      'audioUrl': 'https://www.soundjay.com/animals/elephant-01.mp3',
      'color': Colors.grey,
      'fact': 'Elephants have big ears!'
    },
    {
      'name': 'Pig',
      'emoji': '🐷',
      'sound': 'Oink! Oink!',
      'audioUrl': 'https://www.soundjay.com/animals/pig-oink-01.mp3',
      'color': Colors.pink,
      'fact': 'Pigs are very smart!'
    },
    {
      'name': 'Horse',
      'emoji': '🐴',
      'sound': 'Neigh! Neigh!',
      'audioUrl': 'https://www.soundjay.com/animals/horse-neigh-01.mp3',
      'color': Colors.brown,
      'fact': 'Horses can run fast!'
    },
    {
      'name': 'Sheep',
      'emoji': '🐑',
      'sound': 'Baa! Baa!',
      'audioUrl': 'https://www.soundjay.com/animals/sheep-baa-01.mp3',
      'color': Colors.grey,
      'fact': 'Sheep give us wool!'
    },
    {
      'name': 'Chicken',
      'emoji': '🐔',
      'sound': 'Cluck! Cluck!',
      'audioUrl': 'https://www.soundjay.com/animals/chicken-01.mp3',
      'color': Colors.red,
      'fact': 'Chickens lay eggs!'
    },
    {
      'name': 'Frog',
      'emoji': '🐸',
      'sound': 'Ribbit! Ribbit!',
      'audioUrl': 'https://www.soundjay.com/animals/frog-croaking-01.mp3',
      'color': Colors.green,
      'fact': 'Frogs can jump high!'
    },
    {
      'name': 'Bird',
      'emoji': '🐦',
      'sound': 'Tweet! Tweet!',
      'audioUrl': 'https://www.soundjay.com/animals/bird-chirping-01.mp3',
      'color': Colors.blue,
      'fact': 'Birds can fly in the sky!'
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    final animal = _animals[_currentIndex];

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _showSound = true;
    });

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(animal['audioUrl'] as String));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSound = false;
        });
      }
    });
  }

  void _next() {
    _audioPlayer.stop();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _animals.length;
      _showSound = false;
      _isPlaying = false;
    });
  }

  void _previous() {
    _audioPlayer.stop();
    setState(() {
      _currentIndex = (_currentIndex - 1 + _animals.length) % _animals.length;
      _showSound = false;
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final animal = _animals[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (animal['color'] as Color).withOpacity(0.2),
              Colors.white,
              (animal['color'] as Color).withOpacity(0.1),
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
                        _audioPlayer.stop();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 30),
                      color: animal['color'] as Color,
                    ),
                    const Spacer(),
                    Text(
                      'Animal Sounds',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: animal['color'] as Color,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isPlaying ? Icons.volume_up : Icons.volume_off,
                      color: animal['color'] as Color,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _previous();
                    } else {
                      _next();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _playSound,
                        child: AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation.value, 0),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: (animal['color'] as Color).withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (animal['color'] as Color).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  animal['emoji'] as String,
                                  style: const TextStyle(fontSize: 120),
                                ),
                                if (_isPlaying)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.graphic_eq, size: 30, color: Colors.green),
                                        SizedBox(width: 5),
                                        Icon(Icons.graphic_eq, size: 30, color: Colors.green),
                                        SizedBox(width: 5),
                                        Icon(Icons.graphic_eq, size: 30, color: Colors.green),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        animal['name'] as String,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: animal['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _showSound ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: animal['color'] as Color,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.volume_up, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                animal['sound'] as String,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          animal['fact'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Tap animal to hear real sound!',
                              style: TextStyle(
                                fontSize: 14,
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
                    _buildNavButton(
                      icon: Icons.arrow_back,
                      onPressed: _previous,
                      color: animal['color'] as Color,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: (animal['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${_animals.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: animal['color'] as Color,
                        ),
                      ),
                    ),
                    _buildNavButton(
                      icon: Icons.arrow_forward,
                      onPressed: _next,
                      color: animal['color'] as Color,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, size: 30, color: Colors.white),
      ),
    );
  }
}
