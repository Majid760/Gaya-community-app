import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinkContainer extends StatelessWidget {
  const PinkContainer({super.key});
  final Color pinkColor = const Color(0xFFFF67C6);
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
                pinkColor,
                const Color.fromARGB(70, 232, 224, 0),
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
