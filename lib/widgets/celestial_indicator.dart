import 'package:flutter/material.dart';

enum CelestialType { sun, moon }

class CelestialIndicator extends StatelessWidget {
  final CelestialType type;
  final double size;

  const CelestialIndicator({super.key, required this.type, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CelestialPainter(type: type),
    );
  }
}

class CelestialPainter extends CustomPainter {
  final CelestialType type;

  CelestialPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = size.width / 2;

    if (type == CelestialType.sun) {
      _drawSun(canvas, center, radius);
    } else {
      _drawMoon(canvas, center, radius);
    }
  }

  void _drawSun(Canvas canvas, Offset center, double radius) {
    // 1. Solar Core
    final Paint corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.yellow.shade400,
          Colors.orange.shade700,
          Colors.deepOrange.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, corePaint);

    // 2. Solar Glow
    final Paint glowPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, radius * 1.2, glowPaint);
  }

  void _drawMoon(Canvas canvas, Offset center, double radius) {
    // 1. Moon Body
    final Paint moonBodyPaint = Paint()
      ..color = const Color(0xFFEAECEE);
    
    // 2. Crescent Shadow (to make it look like it's in space)
    final Path moonPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    
    canvas.save();
    canvas.clipPath(moonPath);
    
    // Draw the moon base
    canvas.drawCircle(center, radius, moonBodyPaint);
    
    // Draw craters (subtle accents)
    final Paint craterPaint = Paint()..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawCircle(center + Offset(radius * 0.3, -radius * 0.2), radius * 0.2, craterPaint);
    canvas.drawCircle(center + Offset(-radius * 0.4, radius * 0.4), radius * 0.15, craterPaint);

    // Draw space shadow (shadow half of the moon)
    final Paint shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.6),
          Colors.black.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.5, 0.7],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, shadowPaint);
    canvas.restore();

    // 3. Subtle Bloom
    final Paint bloomPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawCircle(center, radius, bloomPaint);
  }

  @override
  bool shouldRepaint(covariant CelestialPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
