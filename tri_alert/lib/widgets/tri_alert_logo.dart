import 'package:flutter/material.dart';

/// Reproduces the TriAlert triangular logo with blue glow layers
class TriAlertLogo extends StatelessWidget {
  final double size;
  const TriAlertLogo({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Capa exterior glow difuso
          CustomPaint(
            size: Size(size, size * 0.87),
            painter: _TrianglePainter(
              color: const Color(0xFF0D47A1).withOpacity(0.25),
              strokeWidth: 18,
            ),
          ),
          // Capa media azul brillante
          CustomPaint(
            size: Size(size * 0.82, size * 0.82 * 0.87),
            painter: _TrianglePainter(
              color: const Color(0xFF1976D2),
              strokeWidth: 10,
              glowColor: const Color(0xFF42A5F5),
            ),
          ),
          // Capa interior azul cyan
          CustomPaint(
            size: Size(size * 0.64, size * 0.64 * 0.87),
            painter: _TrianglePainter(
              color: const Color(0xFF29B6F6),
              strokeWidth: 6,
              glowColor: const Color(0xFF81D4FA),
            ),
          ),
          // Signo de exclamación rojo en el centro
          Positioned(
            bottom: size * 0.12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.07,
                  height: size * 0.26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.7),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size * 0.03),
                Container(
                  width: size * 0.07,
                  height: size * 0.07,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.7),
                        blurRadius: 8,
                        spreadRadius: 1,
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

class _TrianglePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Color? glowColor;

  _TrianglePainter({
    required this.color,
    required this.strokeWidth,
    this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path, glowPaint);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
