import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorsShapesScreen extends StatefulWidget {
  const ColorsShapesScreen({super.key});

  @override
  State<ColorsShapesScreen> createState() => _ColorsShapesScreenState();
}

class _ColorsShapesScreenState extends State<ColorsShapesScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _rotationController;

  final List<Map<String, dynamic>> _items = [
    {'name': 'Red Circle', 'color': Colors.red, 'shape': 'circle'},
    {'name': 'Blue Square', 'color': Colors.blue, 'shape': 'square'},
    {'name': 'Yellow Triangle', 'color': Colors.yellow, 'shape': 'triangle'},
    {'name': 'Green Rectangle', 'color': Colors.green, 'shape': 'rectangle'},
    {'name': 'Orange Star', 'color': Colors.orange, 'shape': 'star'},
    {'name': 'Purple Diamond', 'color': Colors.purple, 'shape': 'diamond'},
    {'name': 'Pink Heart', 'color': Colors.pink, 'shape': 'heart'},
    {'name': 'Cyan Oval', 'color': Colors.cyan, 'shape': 'oval'},
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _items.length;
    });
  }

  void _previous() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _items.length) % _items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (item['color'] as Color).withOpacity(0.15),
              Colors.white,
              (item['color'] as Color).withOpacity(0.1),
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
                      color: item['color'] as Color,
                    ),
                    const Spacer(),
                    Text(
                      'Colors & Shapes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: item['color'] as Color,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _next,
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
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * math.pi * 0.1,
                            child: child,
                          );
                        },
                        child: _buildShape(
                          item['shape'] as String,
                          item['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        item['name'] as String,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: item['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to see next!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
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
                      color: item['color'] as Color,
                    ),
                    _buildIndicator(item['color'] as Color),
                    _buildNavButton(
                      icon: Icons.arrow_forward,
                      onPressed: _next,
                      color: item['color'] as Color,
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

  Widget _buildShape(String shape, Color color) {
    const double size = 180;

    switch (shape) {
      case 'circle':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        );
      case 'square':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        );
      case 'triangle':
        return CustomPaint(
          size: const Size(size, size),
          painter: TrianglePainter(color: color),
        );
      case 'rectangle':
        return Container(
          width: size * 1.5,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        );
      case 'star':
        return CustomPaint(
          size: const Size(size, size),
          painter: StarPainter(color: color),
        );
      case 'diamond':
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        );
      case 'heart':
        return CustomPaint(
          size: const Size(size, size),
          painter: HeartPainter(color: color),
        );
      case 'oval':
        return Container(
          width: size * 1.3,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
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

  Widget _buildIndicator(Color activeColor) {
    return Row(
      children: List.generate(_items.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentIndex ? 20 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? activeColor
                : activeColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path.shift(const Offset(5, 10)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = _createStarPath(size);

    canvas.drawPath(path.shift(const Offset(5, 10)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  Path _createStarPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;

      if (i == 0) {
        path.moveTo(
          centerX + outerRadius * math.cos(outerAngle),
          centerY + outerRadius * math.sin(outerAngle),
        );
      } else {
        path.lineTo(
          centerX + outerRadius * math.cos(outerAngle),
          centerY + outerRadius * math.sin(outerAngle),
        );
      }

      path.lineTo(
        centerX + innerRadius * math.cos(innerAngle),
        centerY + innerRadius * math.sin(innerAngle),
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = _createHeartPath(size);

    canvas.drawPath(path.shift(const Offset(5, 10)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  Path _createHeartPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.35);
    path.cubicTo(
      width * 0.2, height * 0.1,
      -width * 0.25, height * 0.6,
      width / 2, height,
    );
    path.moveTo(width / 2, height * 0.35);
    path.cubicTo(
      width * 0.8, height * 0.1,
      width * 1.25, height * 0.6,
      width / 2, height,
    );

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
