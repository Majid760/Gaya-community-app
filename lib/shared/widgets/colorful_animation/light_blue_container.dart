import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LightBlueContainer extends StatelessWidget {
  const LightBlueContainer({super.key});
  final Color lightBlue = const Color(0xFF00E7F4);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: Get.width + 200,
          height: Get.width + 50,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, 0.0), // near the top right
              stops: const [0.95, 1.0],
              colors: [
                lightBlue,
                const Color.fromARGB(70, 0, 232, 244),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 88.5, sigmaY: 88.5),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
