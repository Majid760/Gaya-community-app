import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/const.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../model/community_item/community_item.dart';
import '../../view/Auth/controller/require.sigin.register.dart';
import 'community_container_content.dart';

class CommunityContainer extends StatelessWidget {
  const CommunityContainer({
    super.key,
    required this.communityItem,
    this.isHorizontalTile = false,
    required this.onCommunityContainerTap,
    required this.onJoinOrLeaveCommunityTap,
  });

  final CommunityItem communityItem;
  final bool isHorizontalTile;
  final VoidCallback onCommunityContainerTap;
  final VoidCallback onJoinOrLeaveCommunityTap;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                      main container widget [Container]                     */
    /* -------------------------------------------------------------------------- */
    return GestureDetector(
      onTap: FirebaseAuth.instance.currentUser == null
          ? () => Get.to(
                const RequireSignRegisterView(userNotSigin: true),
                transition: Transition.cupertinoDialog,
              )
          : onCommunityContainerTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            width: 1.0.w,
            color: kSecondaryLightColor,
          ),
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        /* ----------------------- community container content ---------------------- */
        child: CommunityContainerContent(
          communityItem: communityItem,
          onJoinOrLeaveCommunityTap: onJoinOrLeaveCommunityTap,
          isHorizontalTile: isHorizontalTile,
          onReadMoreButtonTap: isHorizontalTile
              ? FirebaseAuth.instance.currentUser == null
                  ? () => Get.to(
                        const RequireSignRegisterView(userNotSigin: true),
                        transition: Transition.cupertinoDialog,
                      )
                  : onCommunityContainerTap
              : null,
        ),
      ),
    );
  }
}
