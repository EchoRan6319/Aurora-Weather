import 'package:flutter/material.dart';

/// Aurora-style app icon: glowing sun partially behind iridescent cloud
/// on a deep gradient background.
class AppIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? sunColor;
  final Color? cloudColor;

  const AppIcon({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.sunColor,
    this.cloudColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF0D3B66),
              Color(0xFF1A5C5C),
            ],
          ),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _AppIconPainter(
            sunColor: sunColor ?? const Color(0xFFFFB300),
            cloudColor: cloudColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  final Color sunColor;
  final Color cloudColor;

  _AppIconPainter({required this.sunColor, required this.cloudColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 108;
    canvas.scale(scale, scale);

    // Draw aurora bands (subtle background arcs)
    _drawAuroraBands(canvas);

    // Icon body offset
    canvas.translate(25, 30);

    // Draw sun glow
    _drawSunGlow(canvas);

    // Draw sun
    _drawSun(canvas, 5, 5);

    // Draw cloud with shimmer
    _drawCloud(canvas, 10, 12);
  }

  void _drawAuroraBands(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    paint.color = const Color(0xFF00E5FF).withValues(alpha: 0.15);
    canvas.save();
    canvas.translate(54, 54);
    canvas.rotate(-15 * 3.14159 / 180);
    canvas.drawOval(const Rect.fromLTRB(-50, -40, 50, 40), paint);
    canvas.restore();

    paint.color = const Color(0xFF7C4DFF).withValues(alpha: 0.12);
    canvas.save();
    canvas.translate(54, 54);
    canvas.rotate(-25 * 3.14159 / 180);
    canvas.drawOval(const Rect.fromLTRB(-45, -35, 45, 35), paint);
    canvas.restore();
  }

  void _drawSunGlow(Canvas canvas) {
    final paint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Color(0x66FFAB00),
          Color(0x00FF6D00),
        ],
      ).createShader(const Rect.fromLTWH(-1, -1, 38, 38));
    canvas.drawCircle(const Offset(17, 17), 18, paint);
  }

  void _drawSun(Canvas canvas, double offsetX, double offsetY) {
    canvas.save();
    canvas.translate(offsetX, offsetY);

    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFAB00).withValues(alpha: 0.9)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rays = [
      const Offset(15, 4),
      const Offset(15, 6),
      const Offset(15, 26),
      const Offset(15, 30),
      const Offset(4, 15),
      const Offset(6, 15),
      const Offset(26, 15),
      const Offset(30, 15),
      const Offset(6.5, 6.5),
      const Offset(9.5, 9.5),
      const Offset(22.5, 22.5),
      const Offset(25.5, 25.5),
      const Offset(6.5, 25.5),
      const Offset(9.5, 22.5),
      const Offset(22.5, 9.5),
      const Offset(25.5, 6.5),
    ];

    for (int i = 0; i < rays.length; i += 2) {
      canvas.drawLine(rays[i], rays[i + 1], rayPaint);
    }

    // Sun center - gradient fill
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [
          Color(0xFFFFE082),
          Color(0xFFFFB300),
          Color(0xFFFF6D00),
        ],
      ).createShader(const Rect.fromLTWH(7.5, 7.5, 19, 19));
    canvas.drawCircle(const Offset(17, 17), 9.5, sunPaint);

    canvas.restore();
  }

  void _drawCloud(Canvas canvas, double offsetX, double offsetY) {
    canvas.save();
    canvas.translate(offsetX, offsetY);

    // Cloud body - iridescent translucent
    final cloudPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xE6FFFFFF),
          Color(0xD9E0F7FA),
          Color(0xBFB2EBF2),
        ],
      ).createShader(const Rect.fromLTWH(0, 10, 42, 23));
    cloudPaint.style = PaintingStyle.fill;

    final cloudPath = Path();
    cloudPath.moveTo(36, 22);
    cloudPath.cubicTo(36, 17, 32, 13, 27, 13);
    cloudPath.cubicTo(26.5, 13, 26, 13.1, 25.5, 13.2);
    cloudPath.cubicTo(24, 8.7, 19.7, 5.5, 14.7, 5.5);
    cloudPath.cubicTo(8.3, 5.5, 3.2, 10.7, 3.2, 17);
    cloudPath.cubicTo(3.2, 17.4, 3.2, 17.8, 3.3, 18.2);
    cloudPath.cubicTo(1.9, 18.9, 0, 21.3, 0, 24);
    cloudPath.cubicTo(0, 27.3, 2.7, 30, 6, 30);
    cloudPath.lineTo(36, 30);
    cloudPath.cubicTo(39.3, 30, 42, 27.3, 42, 24);
    cloudPath.cubicTo(42, 20.7, 39.3, 22, 36, 22);
    cloudPath.close();

    canvas.drawPath(cloudPath, cloudPaint);

    // Cloud shimmer overlay
    final shimmerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x8080DEEA),
          Color(0x4DE1F5FE),
          Color(0x99B3E5FC),
        ],
      ).createShader(const Rect.fromLTWH(0, 10, 42, 23));
    shimmerPaint.style = PaintingStyle.fill;
    canvas.drawPath(cloudPath, shimmerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
