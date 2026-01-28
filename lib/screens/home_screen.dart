import 'package:flutter/material.dart';
import 'abc_screen.dart';
import 'numbers_screen.dart';
import 'colors_shapes_screen.dart';
import 'animals_screen.dart';
import 'matching_game_screen.dart';
import 'memory_game_screen.dart';
import 'premium_screen.dart';
import 'spelling_game_screen.dart';
import 'math_game_screen.dart';
import 'puzzle_game_screen.dart';
import 'phonics_game_screen.dart';
import '../services/premium_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PremiumService _premiumService = PremiumService();

  @override
  void initState() {
    super.initState();
    _premiumService.addListener(_onPremiumChange);
  }

  @override
  void dispose() {
    _premiumService.removeListener(_onPremiumChange);
    super.dispose();
  }

  void _onPremiumChange() {
    setState(() {});
  }

  void _navigateToPremiumGame(BuildContext context, Widget screen) {
    if (_premiumService.isPremium) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0EC), Color(0xFFFFF9C4)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Baby Learning Games',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700,
                        shadows: [
                          Shadow(
                            color: Colors.pink.shade200,
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose an activity!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.pink.shade400,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Free Games Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.games, color: Colors.pink.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Free Games',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _ActivityCard(
                      title: 'ABC',
                      subtitle: 'Learn Letters',
                      icon: Icons.abc,
                      color: Colors.red.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AbcScreen()),
                      ),
                    ),
                    _ActivityCard(
                      title: '123',
                      subtitle: 'Count Numbers',
                      icon: Icons.numbers,
                      color: Colors.blue.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NumbersScreen()),
                      ),
                    ),
                    _ActivityCard(
                      title: 'Colors',
                      subtitle: 'Colors & Shapes',
                      icon: Icons.palette,
                      color: Colors.green.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ColorsShapesScreen()),
                      ),
                    ),
                    _ActivityCard(
                      title: 'Animals',
                      subtitle: 'Animal Sounds',
                      icon: Icons.pets,
                      color: Colors.orange.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnimalsScreen()),
                      ),
                    ),
                    _ActivityCard(
                      title: 'Quiz',
                      subtitle: 'Matching Game',
                      icon: Icons.quiz,
                      color: Colors.purple.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MatchingGameScreen()),
                      ),
                    ),
                    _ActivityCard(
                      title: 'Memory',
                      subtitle: 'Card Game',
                      icon: Icons.grid_view_rounded,
                      color: Colors.teal.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MemoryGameScreen()),
                      ),
                    ),
                  ]),
                ),
              ),

              // Premium Games Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Premium Games',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const Spacer(),
                      if (!_premiumService.isPremium)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PremiumScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock_open, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Unlock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_premiumService.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Unlocked',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _PremiumActivityCard(
                      title: 'Spelling',
                      subtitle: 'Learn to Spell',
                      icon: Icons.spellcheck,
                      color: Colors.purple.shade400,
                      isPremium: _premiumService.isPremium,
                      onTap: () => _navigateToPremiumGame(context, const SpellingGameScreen()),
                    ),
                    _PremiumActivityCard(
                      title: 'Math',
                      subtitle: 'Add & Subtract',
                      icon: Icons.calculate,
                      color: Colors.green.shade400,
                      isPremium: _premiumService.isPremium,
                      onTap: () => _navigateToPremiumGame(context, const MathGameScreen()),
                    ),
                    _PremiumActivityCard(
                      title: 'Puzzles',
                      subtitle: 'Solve Puzzles',
                      icon: Icons.extension,
                      color: Colors.indigo.shade400,
                      isPremium: _premiumService.isPremium,
                      onTap: () => _navigateToPremiumGame(context, const PuzzleGameScreen()),
                    ),
                    _PremiumActivityCard(
                      title: 'Phonics',
                      subtitle: 'Letter Sounds',
                      icon: Icons.record_voice_over,
                      color: Colors.teal.shade400,
                      isPremium: _premiumService.isPremium,
                      onTap: () => _navigateToPremiumGame(context, const PhonicsGameScreen()),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPremium;
  final VoidCallback onTap;

  const _PremiumActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isPremium ? color : color.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isPremium ? 0.5 : 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: Colors.white.withOpacity(isPremium ? 1 : 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(isPremium ? 1 : 0.7),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(isPremium ? 0.9 : 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          if (isPremium)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
