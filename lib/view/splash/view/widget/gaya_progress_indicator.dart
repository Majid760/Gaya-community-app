import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class FindingCommunitiesLoadingSplashScreen extends StatefulWidget {
  const FindingCommunitiesLoadingSplashScreen({super.key});

  @override
  FindingCommunitiesLoadingSplashScreenState createState() => FindingCommunitiesLoadingSplashScreenState();
}

class FindingCommunitiesLoadingSplashScreenState extends State<FindingCommunitiesLoadingSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(seconds: 10), // Duration of the animation
        vsync: this);
    // Tween to define the range of values to animate
    final progressTween = Tween<double>(begin: 0.0, end: 1.0);
    // Animate the progress value using the tween and animation controller
    _animationController.drive(progressTween).addListener(() {
      setState(() {
        _progressValue = _animationController.value;
      });
    });
    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).r,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 300,
              child: Text("${GayaStrings.finding_perfect_community.tr}...",
                  textAlign: TextAlign.center,
                  style: GayaTypography.h1.copyWith(fontSize: 28.sp, fontWeight: FontWeight.w600, height: 1.2, color: AppColors.white))),
          SizedBox(height: 25.h),
          Container(
              width: 300.0,
              height: 13.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(11).r),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(11).r,
                  child: LinearProgressIndicator(
                      value: _progressValue,
                      minHeight: 13.h,
                      backgroundColor: AppColors.white.withOpacity(0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))),
          SizedBox(height: 82.h),
        ],
      ),
    );
  }
}
