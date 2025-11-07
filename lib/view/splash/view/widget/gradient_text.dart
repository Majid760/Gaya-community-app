import 'package:flutter/material.dart';
import 'package:gaya/bindings/initializing_dependencies.dart';

class GradientText extends StatelessWidget {
  GradientText(
    this.text, {super.key,
    this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final defaultGradient = LinearGradient(colors: [const Color(0XFF7A24FF).withOpacity(0.9), const Color(0XFF37D8F5).withOpacity(0.9)]);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient != null
          ? gradient!.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            )
          : defaultGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
      child: Text(text,
          textAlign: LocalizationController.to.isHebrew ? TextAlign.right : TextAlign.left, textDirection: LocalizationController.to.isHebrew ? TextDirection.rtl : TextDirection.ltr, style: style),
    );
  }
}
