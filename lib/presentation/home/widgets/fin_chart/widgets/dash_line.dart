import 'package:flutter/material.dart';

class DashLine extends StatelessWidget {
  const DashLine({
    super.key,
    required this.color,
    this.direction = Axis.horizontal,
    this.thickness = 1,
    this.length,
  });

  final Axis direction;
  final double thickness;
  final Color color;
  final double? length;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _DashLinePainter(
            direction: direction,
            thickness: thickness,
            color: color,
          ),
        );
      },
    );
  }
}

class _DashLinePainter extends CustomPainter {
  final Axis direction;
  final double thickness;
  final Color color;

  _DashLinePainter({
    required this.direction,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    if (direction == Axis.horizontal) {
      final y = size.height / 2;
      for (double x = 0; x < size.width; x += 6) {
        canvas.drawLine(Offset(x, y), Offset(x + 2, y), paint);
      }
    } else {
      final x = size.width / 2;
      for (double y = 0; y < size.height; y += 6) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
