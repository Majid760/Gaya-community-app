import 'package:flutter/material.dart';

class GradientTextWidget extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;

  const GradientTextWidget(
    this.text, {
    Key? key,
    required this.gradient,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
    );
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
