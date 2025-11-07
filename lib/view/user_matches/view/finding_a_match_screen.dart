import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/view/user_matches/view/match_screen.dart';
import 'package:get/get.dart';

import '../../../routing/getx_route_methods.dart';
import '../../../shared/widgets/colorful_animation/color_animated_bg.dart';
import '../../../utils/assets_icons.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';

class FindingAMatchView extends StatefulWidget {
  static const String rootPath = '/finding-a-match';
  static const String path = "${MatchView.rootPath}$rootPath";

  const FindingAMatchView({Key? key}) : super(key: key);

  @override
  State<FindingAMatchView> createState() => _FindingAMatchViewState();
}

class _FindingAMatchViewState extends State<FindingAMatchView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigateToMatchedView();
  }

  void navigateToMatchedView() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
      Routes.gotoMatchedView();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const ColorfulStaticPrimaryBackground(),
          Positioned(
            top: 300.r,
            child: Column(
              children: [
                Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.r),
                    color: AppColors.white,
                    image: const DecorationImage(
                      image: AssetImage('Assets/images/anonymous_user.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.h,
                ),
                Text(
                  "Omer Harel",
                  textAlign: TextAlign.center,
                  style: GayaTypography.h4.copyWith(letterSpacing: 0.3, color: AppColors.white),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 130.r,
            child: Column(
              children: [
                Text(
                  GayaStrings.finding_string.tr,
                  textAlign: TextAlign.center,
                  style: GayaTypography.h4.copyWith(letterSpacing: 0.3, color: AppColors.white),
                ),
                SizedBox(
                  height: 15.h,
                ),
                SvgIconWidget.loadingOutline(color: AppColors.white),
              ],
            ),
          ),

          ///cross icon
          Positioned(
            top: 40.r,
            left: 10.r,
            child: IconButton(
              icon: SvgIconWidget.xCloseOutline(color: AppColors.white),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
