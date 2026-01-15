import 'package:flutter/material.dart';
import 'abc_screen.dart';
import 'numbers_screen.dart';
import 'colors_shapes_screen.dart';
import 'animals_screen.dart';
import 'matching_game_screen.dart';
import 'memory_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
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
