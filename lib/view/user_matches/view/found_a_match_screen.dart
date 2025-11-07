import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/view/user_matches/view/match_screen.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/colorful_animation/color_animated_bg.dart';
import '../../../utils/assets_icons.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';
import '../widgets/conversation_widget.dart';
import '../widgets/matched_data_widget.dart';

class FoundAMatchView extends StatelessWidget {
  static const String rootPath = "/found-a-match";
  static const String path = "${MatchView.rootPath}/found-a-match";

  const FoundAMatchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizedBox gap = SizedBox(height: MySpaces.gap5.h);
    SizedBox gap2 = SizedBox(height: MySpaces.gap10.h);
    SizedBox gap3 = SizedBox(height: MySpaces.gap20.h);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.center,

        children: [
          const ColorfulStaticPrimaryBackground(),
          Positioned.fill(
            top: 10.r,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MySpaces.gap10.h,
                    ),
                    Text(
                      GayaStrings.you_have_a_match.tr,
                      style: GayaTypography.h2.copyWith(color: AppColors.white),
                    ),
                    gap,
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
                    gap,
                    Text(
                      "Omer Harel",
                      textAlign: TextAlign.center,
                      style: GayaTypography.h4.copyWith(letterSpacing: 0.3, color: AppColors.white),
                    ),
                    gap2,
                    Text(
                      GayaStrings.what_you_have_common.tr,
                      textAlign: TextAlign.center,
                      style: GayaTypography.h4.copyWith(letterSpacing: 0.3, color: AppColors.white),
                    ),
                    gap,
                    const MatchedDataRow(),
                    gap3,
                    ConversationWidget()
                  ],
                ),
              ),
            ),
          ),

          ///cross icon
          Positioned(
            top: 40.r,
            left: 10.r,
            right: 20.r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: SvgIconWidget.xCloseOutline(color: AppColors.white),
                  onPressed: () {
                    Get.back();
                  },
                ),
                Row(
                  children: [
                    SvgIconWidget.shuffleOutline(),
                    SizedBox(
                      width: MySpaces.gap2.w,
                    ),
                    Text(
                      GayaStrings.shuffle.tr,
                      style: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
