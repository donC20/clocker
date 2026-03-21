import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackgroundPainter extends CustomPainter {
  final double animationValue;
  final List<Star> _stars = [];

  SpaceBackgroundPainter({required this.animationValue}) {
    final random = Random(42); // Seed for consistency
    for (int i = 0; i < 150; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2,
        brightness: random.nextDouble(),
        speed: random.nextDouble() * 0.01 + 0.005,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    
    // 1. Draw Deep Space Gradient
    final Paint bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, -0.6),
        radius: 1.5,
        colors: [
          const Color(0xFF1A1A2E), // Deep navy
          const Color(0xFF16213E), // Slightly more blue
          const Color(0xFF0F3460), // Lighter blue
          const Color(0xFF000000), // Pure black
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Draw Subtle Nebulae
    _drawNebula(canvas, size, const Color(0x156C3483), Offset(size.width * 0.2, size.height * 0.3), 200);
    _drawNebula(canvas, size, const Color(0x102874A6), Offset(size.width * 0.8, size.height * 0.7), 250);

    // 3. Draw Stars
    for (var star in _stars) {
      final double x = (star.x * size.width + animationValue * star.speed * size.width) % size.width;
      final double y = star.y * size.height;
      final double alpha = (star.brightness * (0.5 + 0.5 * sin(animationValue * 5 + star.x * 100))).clamp(0.0, 1.0);
      
      final Paint starPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), star.size, starPaint);
      
      // Subtle glow for brighter stars
      if (star.size > 1.2) {
        canvas.drawCircle(Offset(x, y), star.size * 2, starPaint..color = Colors.white.withValues(alpha: alpha * 0.3));
      }
    }
  }

  void _drawNebula(Canvas canvas, Size size, Color color, Offset center, double radius) {
    final Paint nebulaPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(center, radius, nebulaPaint);
  }

  @override
  bool shouldRepaint(covariant SpaceBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class Star {
  final double x, y, size, brightness, speed;
  Star({required this.x, required this.y, required this.size, required this.brightness, required this.speed});
}
