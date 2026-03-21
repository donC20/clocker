import 'dart:math';
import 'package:flutter/material.dart';

class AnalogClockPainter extends CustomPainter {
  final DateTime dateTime;
  final Color color;

  AnalogClockPainter({required this.dateTime, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = min(centerX, centerY);

    final Paint dialPaint = Paint()
      ..color = Colors.white.withValues(alpha: 40 / 255.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw dial circle
    canvas.drawCircle(center, radius, dialPaint);

    // Draw ticks
    final Paint tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 60; i++) {
      final double angle = i * 6 * pi / 180;
      final bool isHour = i % 5 == 0;
      final double tickLen = isHour ? 8 : 4;
      
      tickPaint.color = isHour ? color.withValues(alpha: 255 / 255.0) : Colors.white.withValues(alpha: 60 / 255.0);
      tickPaint.strokeWidth = isHour ? 2.0 : 1.0;

      final Offset p1 = Offset(
        centerX + (radius - 2) * cos(angle),
        centerY + (radius - 2) * sin(angle),
      );
      final Offset p2 = Offset(
        centerX + (radius - 2 - tickLen) * cos(angle),
        centerY + (radius - 2 - tickLen) * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Hour hand
    final double hourAngle = (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180 - pi / 2;
    _drawHand(canvas, center, radius * 0.5, hourAngle, color, 4.0);

    // Minute hand
    final double minuteAngle = (dateTime.minute + dateTime.second / 60) * 6 * pi / 180 - pi / 2;
    _drawHand(canvas, center, radius * 0.7, minuteAngle, color, 3.0);

    // Second hand
    final double secondAngle = (dateTime.second + dateTime.millisecond / 1000) * 6 * pi / 180 - pi / 2;
    _drawHand(canvas, center, radius * 0.85, secondAngle, color.withValues(alpha: 150 / 255.0), 1.5, isSecond: true);

    // Center dot
    canvas.drawCircle(center, 3, Paint()..color = color);
    canvas.drawCircle(center, 1.5, Paint()..color = Colors.white);
  }

  void _drawHand(Canvas canvas, Offset center, double length, double angle, Color color, double width, {bool isSecond = false}) {
    final Paint handPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    if (!isSecond) {
      // Add glow for hour/minute hands
      handPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawLine(
        center,
        Offset(center.dx + length * cos(angle), center.dy + length * sin(angle)),
        handPaint,
      );
      handPaint.maskFilter = null;
    }

    canvas.drawLine(
      center,
      Offset(center.dx + length * cos(angle), center.dy + length * sin(angle)),
      handPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime || oldDelegate.color != color;
  }
}
