import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/const.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../Auth/controller/require.sigin.register.dart';
import '../../models/searched_community_item.dart';
import 'community_container_content.dart';

class CommunityContainer extends StatelessWidget {
  const CommunityContainer({
    super.key,
    required this.searchedCommunityItem,
    this.isHorizontalTile = false,
    required this.onCommunityContainerTap,
    required this.onJoinOrLeaveCommunityTap,
  });

  final SearchedCommunityItem searchedCommunityItem;
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
          ? () => Get.to(const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog)
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
          searchedCommunityItem: searchedCommunityItem,
          onJoinOrLeaveCommunityTap: onJoinOrLeaveCommunityTap,
          isHorizontalTile: isHorizontalTile,
          onReadMoreButtonTap: isHorizontalTile
              ? FirebaseAuth.instance.currentUser == null
                  ? () => Get.to(const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog)
                  : onCommunityContainerTap
              : null,
        ),
      ),
    );
  }
}
