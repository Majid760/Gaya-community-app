import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/methods.dart';
import 'package:get/get.dart';

import '../../utils/const.dart';
import '../../utils/theme/app_spaces.dart';
import '../../utils/theme/app_typography.dart';
import '../../view/Auth/controller/require.sigin.register.dart';

class CommunityWidget extends StatelessWidget {
  const CommunityWidget({
    Key? key,
    required this.communityId,
    this.linearGradient,
    required this.opacity,
    required this.communityName,
    required this.numberOfMemebers,
    this.numberOfNewPosts,
    this.onLongTap,
    required this.image,
    required this.onTap,
    this.isPinned = false,
    this.badge,
    this.isGridView = false,
  }) : super(key: key);

  final String communityId;
  final VoidCallback onTap;
  final VoidCallback? onLongTap;
  final Shader? linearGradient;
  final double opacity;
  final String communityName, numberOfMemebers, image;
  final String? numberOfNewPosts;
  final Widget? badge;
  final bool isPinned;
  final bool isGridView;

  @override
  Widget build(BuildContext context) {
    final isRTL = Methods.isRTL(communityName);
    final isAdmin = AppConfigurationController.to.isAdminOrModerator(communityId: communityId, isAdminOnly: true);
    // final isJoinedCommunity = forcefullyLongPress || AppConfigurationController.to.getJoinedCommunitiesIds().contains(communityId);
    return Padding(
      padding: isGridView ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 20).r,
      child: GestureDetector(
        onTap: FirebaseAuth.instance.currentUser == null
            ? () {
                Get.to(const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
              }
            : onTap,
        onLongPress: FirebaseAuth.instance.currentUser == null
            ? () {
                Get.to(const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
              }
            : onLongTap,
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            // margin:isGridView?null: const EdgeInsets.only(left: distance_20).r,
            width: isGridView ? null : 154.w,
            height: isGridView ? null : 112.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius_8).r,
              color: kTransparentColor,
            ),
            child: CachedNetworkImage(
              memCacheHeight: 30,
              memCacheWidth: 30,
              maxHeightDiskCache: 240,
              maxWidthDiskCache: 240,
              imageUrl: image,
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius_8.r),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                );
              },
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200)),
            ),
          ),
          Container(
            // margin: isGridView?null: const EdgeInsets.only(left: distance_20).r,
            width: isGridView ? null : 154.w,
            height: isGridView ? null : 112.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius_8),
              color: Colors.white,
              gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                kBlackColor.withOpacity(0.0),
                kBlackColor.withOpacity(opacity),
              ], stops: const [
                0.0,
                1.0
              ]),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: distance_20, right: distance_20).r,
              alignment: Alignment.bottomCenter,
              width: isGridView ? null : 154.w,
              height: isGridView ? null : 112.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '',
                      style: CustomTypography.community.copyWith(fontSize: 12.sp, color: kWhiteColor),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.bottom,
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5), child: SvgIconWidget.usersOutline(width: 15.r, color: kWhiteColor)),
                        ),
                        TextSpan(
                          text: numberOfMemebers.toString(),
                          style: CustomTypography.community.copyWith(fontSize: 12.sp, color: kWhiteColor),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      communityName.tr,
                      style: CustomTypography.community.copyWith(fontSize: 14.sp, color: kWhiteColor),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                  SizedBox(height: MySpaces.gap3.h)
                ],
              ),
            ),
          ),
          badge ?? const SizedBox.shrink(),
          // show admin logo
          if (isAdmin) Positioned(right: 5, top: 5, child: SvgIcons.adminWhite(height: 24.r, width: 24.r)),
          // show pin logo
          // if (isPinned) Positioned(left: 5, top: 5, child: SvgIconWidget.pinOutlinee(height: 16.r, width: 16.r, color: kWhiteColor)),

          // if (isPinned) Positioned(left: 5, top: 5, child: SvgIcons.pinOutline(height: 16.r, width: 16.r, color: kWhiteColor)),
        ]),
      ),
    );
  }
}
