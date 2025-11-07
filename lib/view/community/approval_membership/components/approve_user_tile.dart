import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:get/get.dart';

import '../../../../components/button.component.dart';
import '../../../../components/profile_image_widget.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../../utils/theme/app_typography.dart';
import '../services/membership_approval_services.dart';

class ApproveUserTile extends StatelessWidget {
  final UserMembershipModel user;
  final DateTime? joinedAt;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onViewForm;

  const ApproveUserTile(
      {Key? key, required this.user, required this.joinedAt, required this.onAccept, required this.onReject, required this.onViewForm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultWidth = MediaQuery.sizeOf(context).width * 0.3;
    final user = this.user.user;
    final membership = this.user.communityMembership;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Routes.viewProfile(uid: user.uId, model: user),
              child: user.profilePicture == ''
                  ? CircleAvatar(
                      radius: 24.r,
                      backgroundColor: kBaseGrey,
                      child: Image.asset(Assets.assets.images.userDefault, cacheHeight: 48),
                    )
                  : CircleAvatar(radius: 24.r, backgroundColor: kBaseGrey, child: ProfileImageWidget(url: user.profilePicture)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: MySpaces.gap3).r,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Routes.viewProfile(uid: user.uId, model: user),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name ?? "", style: GayaTypography.subtitleMedium),
                              Text(user.dobAndGender(), style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary)),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            joinedAt?.toNow() ?? "",
                            style: GayaTypography.caption.copyWith(color: AppColors.secondary, fontSize: 12.64.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MySpaces.gap2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GayaButton(
                            onPressed: onAccept,
                            width: defaultWidth,
                            height: 30.h,
                            textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
                            title: GayaStrings.approve_txt.tr,
                            primaryColor: kprimaryColor,
                            borderColor: kTransparentColor),
                        SizedBox(width: MySpaces.gap3.w),
                        GayaButton(
                            onPressed: onReject,
                            width: defaultWidth,
                            height: 30.h,
                            title: GayaStrings.decline_txt.tr,
                            primaryColor: kBaseGrey,
                            textStyle: GayaTypography.subtitleMedium,
                            borderColor: kTransparentColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: MySpaces.gap2.h),
        if (membership.questionnaires?.isNotEmpty ?? false)
          GestureDetector(
            onTap: () => onViewForm(),
            child: Container(
                height: 40.h,
                padding: EdgeInsets.only(left: MySpaces.gap3.w),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(5.r)),
                child: Row(
                  children: [
                    Text(
                      "View Form",
                      style: GayaTypography.subtitleMedium.copyWith(color: AppColors.black, fontSize: 14.sp),
                      textAlign: TextAlign.left,
                    ),
                    const Spacer(),
                    Padding(
                        padding: const EdgeInsets.only(right: MySpaces.gap3).r,
                        child: SvgPicture.asset("Assets/icons/right_arrow.svg", height: 15.r)),
                  ],
                )),
          ),
      ],
    );
  }
}
