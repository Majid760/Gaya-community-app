import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/colorful_animation/color_animated_bg.dart';
import '../../../../utils/asset_video.dart';
import '../../../../widgets/create_recipe_widgets/picked.video.widget.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
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
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: AnimatedBuilder(
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
                          return Transform.rotate(angle: -(_animationController.value * 2.0 * pi), child: child);
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
          ),
          Opacity(opacity: 0.3, child: SvgIconWidget.newWelcomeCircle()),
        ],
      ),
    );
  }
}

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
                const Color.fromARGB(75, 124, 36, 255),
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
                lightBlue.withAlpha(200),
                const Color.fromARGB(50, 0, 232, 244),
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
                const Color.fromARGB(50, 232, 224, 0),
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
                const Color.fromARGB(50, 232, 224, 0),
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
                const Color.fromARGB(50, 0, 255, 174),
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

//// OnboardingV2 (with video)

class OnboardingV2 extends StatelessWidget {
  const OnboardingV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoAssetPlayer(
      assetPath: VideoAssetsUtils.primaryAnimationBg,
      onLoading: ColorfulStaticPrimaryBackground(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height + 25,
      ),
    );
  }
}
