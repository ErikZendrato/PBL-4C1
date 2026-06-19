import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.heroTag = "app-logo"});

  final double size;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _LogoPainter(),
          child: Align(
            alignment: const Alignment(0.48, -0.08),
            child: Text(
              "TI",
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final circle = Paint()..color = const Color(0xFF312B96);

    canvas.drawCircle(center, radius, circle);

    final stripePaint = Paint()
      ..color = const Color(0xFF75D5F0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.17;

    for (var i = 0; i < 3; i++) {
      final top = size.height * (0.24 + (i * 0.2));
      final path = Path()
        ..moveTo(size.width * 0.2, top + size.height * 0.2)
        ..quadraticBezierTo(size.width * 0.34, top, size.width * 0.58, top);

      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
