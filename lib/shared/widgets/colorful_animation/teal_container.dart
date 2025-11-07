import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TealContainer extends StatelessWidget {
  const TealContainer({super.key});
  final Color tealColor = const Color(0xFF00FFAF);
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
                tealColor,
                const Color.fromARGB(70, 0, 255, 174),
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
