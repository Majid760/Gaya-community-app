import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../gen/assets.gen.dart';
import '../utils/textstyles.dart';

class ReportDialogue extends StatelessWidget {
  const ReportDialogue({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20).r + const EdgeInsets.only(bottom: 16).r,
      title: SvgPicture.asset(Assets.assets.icons.problem, fit: BoxFit.scaleDown),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          Text(
            GayaStrings.reporting_thank.tr,
            style: GayaTypography.titleMedium.copyWith(height: 1.5),
          ),
          Text(
            GayaStrings.appreciate_feedback.tr,
            style: CustomTypography.postCaptionStyle.copyWith(height: 1.57, color: AppColors.secondary),
          ),
          const SizedBox(height: 20),
          GayaButton(
            primaryColor: AppColors.primary,
            title: GayaStrings.continue_txt.tr,
            textStyle: CustomTypography.body4StyleWhite,
            borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
            height: 40.h,
            width: double.infinity,
            onPressed: () {
              // Logging report a problem analytics event
              AnalyticsController.to.instance.logReportAProblem(
                userId: UserModel.to.uId ?? '',
                reportMessage: '',
              );

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
