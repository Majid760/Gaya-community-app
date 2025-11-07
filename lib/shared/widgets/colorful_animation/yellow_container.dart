import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YellowContainer extends StatelessWidget {
  const YellowContainer({super.key});
  final Color yellowColor = const Color(0xFFE8DF00);
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
                yellowColor,
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
