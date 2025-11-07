import 'package:flutter/material.dart';

class BlackVignette extends StatelessWidget {
  const BlackVignette({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OvalVignettePainter(),
      child: Container(),
    );
  }
}

class OvalVignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    var gradient = RadialGradient(
      center: const Alignment(0.0, 0.0), // near the top right
      radius: 1.2,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.8),
      ],
      stops: const [0.3, 1.0],
    );

    var paint = Paint();
    paint.shader = gradient.createShader(rect, textDirection: TextDirection.ltr);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
