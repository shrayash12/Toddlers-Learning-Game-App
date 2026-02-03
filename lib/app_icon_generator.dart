import 'package:flutter/material.dart';

/// Run this file standalone to preview/screenshot the app icon
void main() {
  runApp(const AppIconPreview());
}

class AppIconPreview extends StatelessWidget {
  const AppIconPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1024x1024 preview
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                  child: AppIconWidget(),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Baby Learning Games',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 50),
              // Smaller icon preview
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconPreview(80, 18),
                  const SizedBox(width: 20),
                  _buildIconPreview(60, 14),
                  const SizedBox(width: 20),
                  _buildIconPreview(40, 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconPreview(double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: const AppIconWidget(),
      ),
    );
  }
}

class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE991D1), // Pink
            Color(0xFFB384E8), // Purple
            Color(0xFF9B8BE8), // Light purple
            Color(0xFF8B9EF0), // Blue-purple
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Center circle glow
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Paint palette - top left
          const Positioned(
            top: 25,
            left: 25,
            child: Text(
              '🎨',
              style: TextStyle(fontSize: 32),
            ),
          ),

          // Rainbow - bottom left
          const Positioned(
            bottom: 25,
            left: 25,
            child: Text(
              '🌈',
              style: TextStyle(fontSize: 32),
            ),
          ),

          // Teddy bear - bottom right
          const Positioned(
            bottom: 25,
            right: 25,
            child: Text(
              '🧸',
              style: TextStyle(fontSize: 32),
            ),
          ),

          // ABC and 123 text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ABC with star
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AB',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Text(
                          'C',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Star on C
                        const Positioned(
                          top: -8,
                          right: -12,
                          child: Text(
                            '⭐',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // 123
                const Text(
                  '123',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
