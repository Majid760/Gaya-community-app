import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:get/get.dart';

import '../controller/firebase_analytics_controller.dart';
import '../model/user.model.dart';

class CommunitySettingScreen extends StatelessWidget {
  final String communityId;
  const CommunitySettingScreen({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.community_settings.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18.5).r,
        children: [
          CommunitySettingItem(
            title: GayaStrings.edit_community.tr,
            subtitle: GayaStrings.edit_community_details.tr,
            onTap: () => Routes.editCommunityView(communityId: communityId),
          ),
          CommunitySettingItem(
            title: GayaStrings.community_moderator.tr,
            subtitle: GayaStrings.moderator_manage_community.tr,
            onTap: () => Routes.communityModeratorView(
              communityId: communityId,
            ),
          ),
          // community analytics tile
          CommunitySettingItem(
              title: GayaStrings.analytics.tr,
              subtitle: GayaStrings.analytics_description.tr,
              onTap: () {
                // Logging special feature usage analytics event
                AnalyticsController.to.instance.logSpecialFeatureUsage(
                  userId: UserModel.to.uId ?? '',
                  featureName: 'community_analytics',
                );

                Routes.communityAnalyticsView(
                  communityId: communityId,
                );
              }),
          CommunitySettingItem(
            title: GayaStrings.manage_topic.tr,
            subtitle: GayaStrings.arrange_community_knowledge.tr,
            onTap: () => Routes.manageCommunityTopicsView(communityId: communityId),
          ),

          CommunitySettingItem(
            title: GayaStrings.community_calendar.tr,
            subtitle: GayaStrings.manage_community_calendar.tr,
            onTap: () {
              // Logging special feature usage analytics event
              AnalyticsController.to.instance.logSpecialFeatureUsage(
                userId: UserModel.to.uId ?? '',
                featureName: 'community_calendar',
              );

              Routes.communityCalendarView(communityId: communityId, isEditable: true);
            },
          ),
          CommunitySettingItem(
            title: GayaStrings.approval_settings.tr,
            subtitle: GayaStrings.manage_post_user_approval.tr,
            onTap: () {
              Navigator.pop(context);
              if (EditCommunityController.to(tag: communityId).createCommunityModel == null) return;
              Methods.showCommunityAutoPostApprovalModalSheet(
                community: EditCommunityController.to(tag: communityId).createCommunityModel!,
                context: context,
              );
            },
          ),
        ],
      ),
    );
  }
}

class CommunitySettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function? onTap;
  final bool haveIcon;
  final EdgeInsets? padding;
  const CommunitySettingItem({Key? key, required this.title, required this.subtitle, this.onTap, this.padding, this.haveIcon = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding ?? const EdgeInsets.fromLTRB(20, 0, 20, 14).r,
      onTap: onTap == null ? null : () => onTap!(),
      title: Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GayaTypography.titleMedium.copyWith(height: 1.1)),
            if (haveIcon) SvgPicture.asset("Assets/icons/right_arrow.svg", height: 20.r),
          ],
        ),
      ),
      subtitle: Text(subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GayaTypography.subtitleRegular.copyWith(height: 1.4, color: AppColors.secondary)),
    );
  }
}
