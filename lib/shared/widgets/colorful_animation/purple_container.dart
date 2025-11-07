import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurpleContainer extends StatelessWidget {
  final Color brandPurple = const Color(0xFF7A24FF);
  const PurpleContainer({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: Get.width + 300,
          height: Get.width + 200,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, 0.0), // near the top right
              stops: const [0.95, 1.0],
              colors: [
                brandPurple,
                const Color.fromARGB(70, 124, 36, 255),
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
