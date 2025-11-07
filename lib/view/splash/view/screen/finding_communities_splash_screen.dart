import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/topic.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/splash/view/screen/splash_animated_background_screen.dart';
import 'package:gaya/view/splash/view/widget/gaya_progress_indicator.dart';
import 'package:get/get.dart';

import '../../controller/interest_search_controller.dart';

class FindingSplashScreen extends StatefulWidget {
  const FindingSplashScreen({Key? key}) : super(key: key);

  @override
  State<FindingSplashScreen> createState() => _FindingSplashScreenState();
}

class _FindingSplashScreenState extends State<FindingSplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () => Routes.switchView());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Positioned.fill(child: Image.asset(IconsAssetsPathUtils.splashWelcomePng, fit: BoxFit.cover)),
        const Positioned(top: -25, left: 0, right: 0, bottom: 0, child: OnboardingV2()),
        Positioned.fill(
            bottom: 200,
            child: GetBuilder<InterestController>(
                init: Get.find<InterestController>(),
                builder: (controller) {
                  return SequentialContainerScreen(selectedInterest: controller.selectedInterests);
                })),
        Positioned(
            bottom: 10,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20).r, child: const FindingCommunitiesLoadingSplashScreen()))
      ]),
    );
  }
}

class SequentialContainerScreen extends StatefulWidget {
  const SequentialContainerScreen({super.key, required this.selectedInterest});
  final List<TopicsModel> selectedInterest;
  @override
  SequentialContainerScreenState createState() => SequentialContainerScreenState();
}

class SequentialContainerScreenState extends State<SequentialContainerScreen> with SingleTickerProviderStateMixin {
  List<ContainerData> _containerList = [];
  late ContainerData selectedContainer;
  Widget? selectedWidget;
  bool toggle = false;

  @override
  void initState() {
    super.initState();
    selectedContainer = ContainerData.none();
    init();
  }

  void init() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _containerList = List<ContainerData>.generate(
        widget.selectedInterest.length,
        (index) => ContainerData(left: getRandomPosition(), top: getRandomPosition() + 30, opacity: 1.0),
      );
      setSelectedContainer();
    });
  }

  Future<void> setSelectedContainer() async {
    for (int index = 0; index < _containerList.length; index++) {
      /// if widget is not mounted then break the loop
      if (!mounted) break;
      setState(() {
        selectedContainer = _containerList[index];
        selectedWidget = Bounce(
            duration: const Duration(seconds: 2),
            onPressed: () {},
            child: ZoomAnimation(
              child:
                  SelectedInterestWidget(imagePath: widget.selectedInterest[index].url ?? "", title: widget.selectedInterest[index].title),
            ));
      });
      await Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          toggle = !toggle;
        });
      });
    }
  }

  double getRandomPosition() {
    final random = Random();
    return random.nextDouble() * 170;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: selectedContainer?.left,
          top: selectedContainer?.top,
          child: SizedBox(
            height: 200,
            width: 200,
            child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500), opacity: toggle ? selectedContainer?.opacity ?? 0 : 0, child: selectedWidget),
          ),
        ),
      ],
    );
  }
}

class ContainerData {
  final double left;
  final double top;
  double opacity;

  factory ContainerData.none() => ContainerData(left: 0, top: 0, opacity: 0.0);
  ContainerData({
    required this.left,
    required this.top,
    required this.opacity,
  });
}

class ZoomAnimation extends StatefulWidget {
  const ZoomAnimation({super.key, required this.child});

  final Widget child;
  @override
  ZoomAnimationState createState() => ZoomAnimationState();
}

class ZoomAnimationState extends State<ZoomAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );
    _animationController.repeat(reverse: false, min: 1);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: GestureDetector(
              onTap: () {
                if (_animationController.isAnimating) {
                  _animationController.stop();
                } else {
                  _animationController.repeat(reverse: false);
                }
              },
              child: widget.child),
        );
      },
    );
  }
}

// smoke

class SelectedInterestWidget extends StatelessWidget {
  const SelectedInterestWidget({Key? key, required this.imagePath, required this.title, this.height, this.width}) : super(key: key);
  final String imagePath;
  final String title;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: height ?? 100,
        width: width ?? 100,
        // duration: const Duration(milliseconds: 300),
        foregroundDecoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 6, color: AppColors.white)),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 6, color: AppColors.white)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(imageUrl: imagePath, height: 103.h, width: 103.h, memCacheHeight: 103, memCacheWidth: 103)),
      ),
      const SizedBox(height: 8),
      Text(title,
          style: GayaTypography.body2.copyWith(fontWeight: FontWeight.w700, fontSize: 17.sp, color: AppColors.white, height: 1.2),
          textAlign: TextAlign.center,
          maxLines: 2),
    ]);
  }
}

// tested here

class Bounce extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Duration duration;
  // This will get the data from the pages
  // Makes sure child won't be passed as null
  const Bounce({super.key, required this.child, required this.duration, required this.onPressed});

  @override
  BounceState createState() => BounceState();
}

class BounceState extends State<Bounce> with SingleTickerProviderStateMixin {
  late double _scale;

  // This controller is responsible for the animation
  late AnimationController _animate;

  //Getting the VoidCallack onPressed passed by the user
  VoidCallback get onPressed => widget.onPressed;

  // This is a user defined duration, which will be responsible for
  // what kind of bounce he/she wants
  Duration get userDuration => widget.duration;

  @override
  void initState() {
    //defining the controller
    _animate = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200), //This is an inital controller duration
        lowerBound: 0.0,
        upperBound: 0.1)
      ..addListener(() {
        setState(() {});
      }); // Can do something in the listener, but not required
    super.initState();
  }

  @override
  void dispose() {
    // To dispose the contorller when not required
    _animate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animate.value;
    return GestureDetector(
        onTap: _onTap,
        child: Transform.scale(
          scale: _scale,
          child: widget.child,
        ));
  }

  //This is where the animation works out for us
  // Both the animation happens in the same method,
  // but in a duration of time, and our callback is called here as well
  void _onTap() {
    //Firing the animation right away
    _animate.forward();
    //Now reversing the animation after the user defined duration
    Future.delayed(userDuration, () {
      _animate.reverse();
      //Calling the callback
      onPressed();
    });
  }
}