import 'package:flutter/material.dart';
import 'dart:math' as math;
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
import 'hide_seek_game_screen.dart';
import 'maze_game_screen.dart';
import 'connect_dots_game_screen.dart';
import 'find_difference_game_screen.dart';
import 'draw_lines_game_screen.dart';
import 'potty_training_game_screen.dart';
import 'organizing_game_screen.dart';
import 'coloring_game_screen.dart';
import '../services/premium_service.dart';
import '../services/razorpay_service.dart';
import '../widgets/screen_lock_wrapper.dart';
import '../widgets/play_timer_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PremiumService _premiumService = PremiumService();
  final RazorpayService _razorpayService = RazorpayService();
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _wiggleController;
  late AnimationController _starController;

  // Check if user has premium from either service
  bool get _isPremium => _premiumService.isPremium || _razorpayService.isPremium;

  @override
  void initState() {
    super.initState();
    _premiumService.addListener(_onPremiumChange);
    _razorpayService.addListener(_onPremiumChange);

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation for premium badge
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Wiggle animation for icons
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Star rotation
    _starController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _premiumService.removeListener(_onPremiumChange);
    _razorpayService.removeListener(_onPremiumChange);
    _floatController.dispose();
    _pulseController.dispose();
    _wiggleController.dispose();
    _starController.dispose();
    super.dispose();
  }

  void _onPremiumChange() {
    setState(() {});
  }

  void _navigateToPremiumGame(BuildContext context, Widget screen) {
    if (_isPremium) {
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
                    const SizedBox(height: 10),
                    // Screen Lock Toggle and Play Timer at top
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          PlayTimerDisplay(),
                          ScreenLockToggle(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Animated title
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.05),
                          child: Text(
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
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    // Animated baby faces
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Boy face - bouncing up
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                math.sin(_floatController.value * math.pi * 2) * 5,
                                -8 * math.sin(_floatController.value * math.pi),
                              ),
                              child: Transform.rotate(
                                angle: math.sin(_floatController.value * math.pi * 2) * 0.1,
                                child: const Text('👦🏻', style: TextStyle(fontSize: 40)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Girl face - bouncing delayed
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                -10 * math.sin((_floatController.value + 0.33) * math.pi),
                              ),
                              child: Transform.scale(
                                scale: 1.0 + math.sin((_floatController.value + 0.33) * math.pi) * 0.1,
                                child: const Text('👧🏻', style: TextStyle(fontSize: 44)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Another child face - bouncing different phase
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                math.sin((_floatController.value + 0.66) * math.pi * 2) * -5,
                                -8 * math.sin((_floatController.value + 0.66) * math.pi),
                              ),
                              child: Transform.rotate(
                                angle: math.sin((_floatController.value + 0.66) * math.pi * 2) * -0.1,
                                child: const Text('🧒🏻', style: TextStyle(fontSize: 40)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Choose an activity text with sparkles
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: _pulseController.value * math.pi * 0.2,
                              child: Text(
                                '✨',
                                style: TextStyle(
                                  fontSize: 18 + (_pulseController.value * 4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Choose an activity!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.pink.shade400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: -_pulseController.value * math.pi * 0.2,
                              child: Text(
                                '✨',
                                style: TextStyle(
                                  fontSize: 18 + (_pulseController.value * 4),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
                      _AnimatedIcon(
                        icon: Icons.games,
                        color: Colors.pink.shade600,
                        controller: _wiggleController,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Free Games',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade600,
                        ),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(3 * math.sin(_floatController.value * math.pi), 0),
                            child: const Text('🆓', style: TextStyle(fontSize: 20)),
                          );
                        },
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
                    _AnimatedActivityCard(
                      title: 'ABC',
                      subtitle: 'Learn Letters',
                      icon: Icons.abc,
                      color: Colors.red.shade300,
                      delay: 0,
                      floatController: _floatController,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AbcScreen()),
                      ),
                    ),
                    _AnimatedActivityCard(
                      title: '123',
                      subtitle: 'Count Numbers',
                      icon: Icons.numbers,
                      color: Colors.blue.shade300,
                      delay: 1,
                      floatController: _floatController,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NumbersScreen()),
                      ),
                    ),
                    _AnimatedActivityCard(
                      title: 'Colors',
                      subtitle: 'Colors & Shapes',
                      icon: Icons.palette,
                      color: Colors.green.shade300,
                      delay: 2,
                      floatController: _floatController,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ColorsShapesScreen()),
                      ),
                    ),
                    _AnimatedActivityCard(
                      title: 'Animals',
                      subtitle: 'Animal Sounds',
                      icon: Icons.pets,
                      color: Colors.orange.shade300,
                      delay: 3,
                      floatController: _floatController,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnimalsScreen()),
                      ),
                    ),
                    _AnimatedActivityCard(
                      title: 'Quiz',
                      subtitle: 'Matching Game',
                      icon: Icons.quiz,
                      color: Colors.purple.shade300,
                      delay: 4,
                      floatController: _floatController,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MatchingGameScreen()),
                      ),
                    ),
                    _AnimatedActivityCard(
                      title: 'Memory',
                      subtitle: 'Card Game',
                      icon: Icons.grid_view_rounded,
                      color: Colors.teal.shade300,
                      delay: 5,
                      floatController: _floatController,
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
                      AnimatedBuilder(
                        animation: _starController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _starController.value * 2 * math.pi,
                            child: Icon(Icons.star, color: Colors.amber.shade700),
                          );
                        },
                      ),
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
                      if (!_isPremium)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.1),
                              child: GestureDetector(
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
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: _pulseController.value * 3,
                                      ),
                                    ],
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
                            );
                          },
                        ),
                      if (_isPremium)
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

              // Learning Category
              SliverToBoxAdapter(
                child: _CategoryHeader(
                  emoji: '📚',
                  title: 'Learning',
                  color: Colors.blue,
                  floatController: _floatController,
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
                    _AnimatedPremiumCard(
                      title: 'Spelling',
                      subtitle: 'Learn to Spell',
                      icon: Icons.spellcheck,
                      color: Colors.purple.shade400,
                      isPremium: _isPremium,
                      delay: 0,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const SpellingGameScreen()),
                    ),
                    _AnimatedPremiumCard(
                      title: 'Math',
                      subtitle: 'Add & Subtract',
                      icon: Icons.calculate,
                      color: Colors.green.shade500,
                      isPremium: _isPremium,
                      delay: 1,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const MathGameScreen()),
                    ),
                    _AnimatedPremiumCard(
                      title: 'Phonics',
                      subtitle: 'Letter Sounds',
                      icon: Icons.record_voice_over,
                      color: Colors.teal.shade400,
                      isPremium: _isPremium,
                      delay: 2,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const PhonicsGameScreen()),
                    ),
                    _AnimatedPremiumCard(
                      title: 'Organize',
                      subtitle: 'Sort & Clean',
                      icon: Icons.category,
                      color: Colors.orange.shade500,
                      isPremium: _isPremium,
                      delay: 3,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const OrganizingGameScreen()),
                    ),
                  ]),
                ),
              ),

              // Brain Games Category
              SliverToBoxAdapter(
                child: _CategoryHeader(
                  emoji: '🧠',
                  title: 'Brain Games',
                  color: Colors.purple,
                  floatController: _floatController,
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
                    _AnimatedPremiumCard(
                      title: 'Puzzles',
                      subtitle: 'Solve Puzzles',
                      icon: Icons.extension,
                      color: Colors.indigo.shade400,
                      isPremium: _isPremium,
                      delay: 4,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PuzzleGameScreen())), // TODO: Add premium check back later
                    ),
                    _AnimatedPremiumCard(
                      title: 'Maze',
                      subtitle: 'Find the Path',
                      icon: Icons.route,
                      color: Colors.deepPurple.shade400,
                      isPremium: _isPremium,
                      delay: 5,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const MazeGameScreen()),
                    ),
                    _AnimatedPremiumCard(
                      title: 'Hide & Seek',
                      subtitle: 'Find Animals',
                      icon: Icons.visibility,
                      color: Colors.pink.shade400,
                      isPremium: _isPremium,
                      delay: 6,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const HideSeekGameScreen()),
                    ),
                    _AnimatedPremiumCard(
                      title: 'Differences',
                      subtitle: 'Spot Changes',
                      icon: Icons.compare,
                      color: Colors.blueGrey.shade400,
                      isPremium: _isPremium,
                      delay: 7,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const FindDifferenceGameScreen()),
                    ),
                  ]),
                ),
              ),

              // Creative Category
              SliverToBoxAdapter(
                child: _CategoryHeader(
                  emoji: '🎨',
                  title: 'Creative',
                  color: Colors.pink,
                  floatController: _floatController,
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
                    _AnimatedPremiumCard(
                      title: 'Connect Dots',
                      subtitle: 'Draw Shapes',
                      icon: Icons.timeline,
                      color: Colors.amber.shade600,
                      isPremium: _isPremium,
                      delay: 8,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const ConnectDotsGameScreen()),
                    ),
                    _AnimatedPremiumCard(
                      title: 'Draw Lines',
                      subtitle: 'Trace & Learn',
                      icon: Icons.gesture,
                      color: Colors.cyan.shade500,
                      isPremium: _isPremium,
                      delay: 9,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const DrawLinesGameScreen()),
                    ),
                    _AnimatedPremiumCard(
                      title: 'Coloring',
                      subtitle: 'Color Sketches',
                      icon: Icons.brush,
                      color: Colors.pink.shade400,
                      isPremium: _isPremium,
                      delay: 10,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const ColoringGameScreen()),
                    ),
                  ]),
                ),
              ),

              // Life Skills Category
              SliverToBoxAdapter(
                child: _CategoryHeader(
                  emoji: '🌟',
                  title: 'Life Skills',
                  color: Colors.green,
                  floatController: _floatController,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _AnimatedPremiumCard(
                      title: 'Potty Time',
                      subtitle: 'Fun Training',
                      icon: Icons.child_care,
                      color: Colors.lime.shade600,
                      isPremium: _isPremium,
                      delay: 10,
                      floatController: _floatController,
                      pulseController: _pulseController,
                      onTap: () => _navigateToPremiumGame(context, const PottyTrainingGameScreen()),
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

class _AnimatedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final AnimationController controller;

  const _AnimatedIcon({
    required this.icon,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(controller.value * math.pi * 2) * 0.1,
          child: Icon(icon, color: color),
        );
      },
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final AnimationController floatController;

  const _CategoryHeader({
    required this.emoji,
    required this.title,
    required this.color,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(floatController.value * math.pi) * 3),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedActivityCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int delay;
  final AnimationController floatController;
  final VoidCallback onTap;

  const _AnimatedActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.delay,
    required this.floatController,
    required this.onTap,
  });

  @override
  State<_AnimatedActivityCard> createState() => _AnimatedActivityCardState();
}

class _AnimatedActivityCardState extends State<_AnimatedActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Each card has a different phase offset for the floating animation
    final phaseOffset = widget.delay * 0.3;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.reverse();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.forward();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.floatController, _scaleController]),
        builder: (context, child) {
          final floatValue = math.sin((widget.floatController.value + phaseOffset) * math.pi);
          return Transform.translate(
            offset: Offset(0, floatValue * 4),
            child: Transform.scale(
              scale: _scaleController.value,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(_isPressed ? 0.3 : 0.5),
                      blurRadius: _isPressed ? 5 : 10,
                      offset: Offset(0, _isPressed ? 2 : 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouncing icon
                    Transform.rotate(
                      angle: math.sin((widget.floatController.value * 2 + phaseOffset) * math.pi) * 0.1,
                      child: Icon(
                        widget.icon,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedPremiumCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPremium;
  final int delay;
  final AnimationController floatController;
  final AnimationController pulseController;
  final VoidCallback onTap;

  const _AnimatedPremiumCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isPremium,
    required this.delay,
    required this.floatController,
    required this.pulseController,
    required this.onTap,
  });

  @override
  State<_AnimatedPremiumCard> createState() => _AnimatedPremiumCardState();
}

class _AnimatedPremiumCardState extends State<_AnimatedPremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phaseOffset = widget.delay * 0.3;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.reverse();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.forward();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.floatController, _scaleController]),
        builder: (context, child) {
          final floatValue = math.sin((widget.floatController.value + phaseOffset) * math.pi);
          return Transform.translate(
            offset: Offset(0, floatValue * 4),
            child: Transform.scale(
              scale: _scaleController.value,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isPremium ? widget.color : widget.color,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(_isPressed ? 0.3 : 0.5),
                      blurRadius: _isPressed ? 5 : 10,
                      offset: Offset(0, _isPressed ? 2 : 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: math.sin((widget.floatController.value * 2 + phaseOffset) * math.pi) * 0.1,
                            child: Icon(
                              widget.icon,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lock badge for non-premium users
                    if (!widget.isPremium)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
