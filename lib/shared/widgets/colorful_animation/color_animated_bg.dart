import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'light_blue_container.dart';
import 'pink_container.dart';
import 'purple_container.dart';
import 'teal_container.dart';
import 'yellow_container.dart';

class ColorfulStaticPrimaryBackground extends StatelessWidget {
  final double? height;
  final double? width;

  const ColorfulStaticPrimaryBackground({super.key,  this.height,  this.width});

  @override
  Widget build(BuildContext context) {
    return Image.asset('Assets/images/static_primary_linearbackground.png', fit: BoxFit.cover, height: height, width: width);
  }
}

class ColorfulAnimatedBackground extends StatefulWidget {
  const ColorfulAnimatedBackground({super.key});

  @override
  State<ColorfulAnimatedBackground> createState() => _ColorfulAnimatedBackgroundState();
}

class _ColorfulAnimatedBackgroundState extends State<ColorfulAnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -(_animationController.value * 2.0 * pi),
                child: child,
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -((Get.width + 150) / 2),
                  top: -((Get.width + 150) * 0.3),
                  child: Transform.rotate(
                    angle: 2.09,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -(_animationController.value * 2.0 * pi),
                          child: child,
                        );
                      },
                      child: const LightBlueContainer(),
                    ),
                  ),
                ),
                Positioned(
                  left: -((Get.width + 150) * 0.6),
                  top: -((Get.width + 150) * 0.3),
                  child: Transform.rotate(
                    angle: 2.09,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -(_animationController.value * 2.0 * pi),
                          child: child,
                        );
                      },
                      child: const YellowContainer(),
                    ),
                  ),
                ),
                Positioned(
                  left: -((Get.width + 150) * 0.6),
                  bottom: -((Get.width + 150) * 0.3),
                  child: Transform.rotate(
                    angle: 2.09,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -(_animationController.value * 2.0 * pi),
                          child: child,
                        );
                      },
                      child: const PinkContainer(),
                    ),
                  ),
                ),
                Positioned(
                  right: -((Get.width + 150) * 0.6),
                  bottom: -((Get.width + 150) * 0.3),
                  child: Transform.rotate(
                    angle: 1.39,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -(_animationController.value * 2.0 * pi),
                          child: child,
                        );
                      },
                      child: const TealContainer(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2.0 * pi,
                        child: child,
                      );
                    },
                    child: const PurpleContainer(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
