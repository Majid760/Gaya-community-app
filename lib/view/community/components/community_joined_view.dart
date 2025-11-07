import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../../../utils/language/translation.dart';

class JoiningApprovalScreen extends StatelessWidget {
  final Community community;

  const JoiningApprovalScreen({Key? key, required this.community}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50).r,
              child: Column(
                children: [
                  const Spacer(),
                  SvgIconWidget.usersRightOutline(color: AppColors.primary, height: 124.h),
                  SizedBox(height: MySpaces.gap6.h),
                  Text(GayaStrings.entry_request_sent.tr, style: GayaTypography.h1),
                  SizedBox(height: MySpaces.gap3.h),
                  Text(
                    "${GayaStrings.your_request_to_enter.tr} ${community.communityName} ${GayaStrings.was_sent_to_community_manager.tr}",
                    style: GayaTypography.body2.copyWith(color: AppColors.secondary, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20).r,
            child: GayaButton(
                title: GayaStrings.continue_txt.tr,
                onPressed: () => Navigator.pop(context),
                borderColor: AppColors.transparrent,
                height: 50,
                primaryColor: AppColors.primary,
                textStyle: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 14.sp),
                width: MediaQuery.sizeOf(context).width),
          ),
          SizedBox(height: MySpaces.gap6.h),
        ],
      ),
    );
  }
}
