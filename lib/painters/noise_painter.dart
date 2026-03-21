import 'dart:math';
import 'package:flutter/material.dart';

class NoisePainter extends CustomPainter {
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03);
    for (int i = 0; i < 5000; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
          1,
          1,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
