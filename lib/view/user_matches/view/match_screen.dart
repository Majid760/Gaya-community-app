import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/colorful_animation/color_animated_bg.dart';
import '../../../utils/theme/app_colors.dart';
import '../widgets/start_match_widget.dart';

class MatchView extends StatelessWidget {
  static const String rootPath = "/match";

  const MatchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizedBox gap = SizedBox(
      height: MySpaces.gap4.h,
    );
    return Scaffold(
      body: Stack(
        children: [
          const ColorfulStaticPrimaryBackground(),
          Positioned(
            top: 225.r,
            left: 34.r,
            right: 34.r,
            child: Column(
              children: [
                StartMatchingWidget(
                    message: "${GayaStrings.hi.tr}, Omer Harel ${GayaStrings.welcome_to.tr} Gaya ${GayaStrings.matches.tr}"),
                gap,
                SvgIconWidget.loadingOutline(color: AppColors.white),
                gap,
                StartMatchingWidget(message: "${GayaStrings.matches_string.tr} Gaya!"),
                gap,
                SvgIconWidget.loadingOutline(color: AppColors.white),
                SizedBox(height: MySpaces.gap12.h),
                GestureDetector(
                  onTap: () => Routes.gotoMeetSomeOneView(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 12).r,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      GayaStrings.got_it.tr,
                      style: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 40.r,
            left: 10.r,
            child: IconButton(
              icon: SvgIconWidget.xCloseOutline(color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
