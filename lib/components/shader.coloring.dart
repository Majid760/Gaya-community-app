import 'package:flutter/material.dart';

class RadiantGradientMask extends StatelessWidget {
  const RadiantGradientMask({super.key,
    required this.child,
    required this.colors1,
    required this.colors2,
  });
  final Widget child;
  final Color colors1;
  final Color colors2;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => RadialGradient(
        stops: const [0.2, 0.97],
        center: Alignment.topLeft,
        radius: 1.0,
        colors: [colors1, colors2],
        tileMode: TileMode.clamp,
      ).createShader(bounds),
      child: child,
    );
  }
}
