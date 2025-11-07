import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/assets_icons.dart';
import '../../models/searched_community_item.dart';
import 'community_content_bio.dart';
import 'community_cover.dart';
import 'community_dp.dart';
import 'community_name.dart';
import 'join_or_leave_community_button.dart';

class CommunityContainerContent extends StatelessWidget {
  const CommunityContainerContent({
    super.key,
    required this.searchedCommunityItem,
    required this.isHorizontalTile,
    required this.onJoinOrLeaveCommunityTap,
    required this.onReadMoreButtonTap,
  });

  final SearchedCommunityItem searchedCommunityItem;
  final bool isHorizontalTile;
  final VoidCallback onJoinOrLeaveCommunityTap;
  final VoidCallback? onReadMoreButtonTap;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                         main column widget [Column]                        */
    /* -------------------------------------------------------------------------- */
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            /* ----------------------------- community cover ---------------------------- */
            CommunityCover(communityCover: searchedCommunityItem.communityCover),
            /* ------------------------------ community dp ------------------------------ */
            CommunityDp(communityDp: searchedCommunityItem.communityDp),
          ],
        ),
        SizedBox(height: 16.0.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Row(
            children: [
              /* ------------------------- community name and type ------------------------ */
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /* ----------------------------- community name ----------------------------- */
                      CommunityName(communityName: searchedCommunityItem.communityName),
                      SizedBox(width: 4.0.w),
                      /* --------------------------- lock / unlock icon --------------------------- */
                      searchedCommunityItem.communityType == 'Public' ? SvgIconWidget.unLock : SvgIconWidget.lock,
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.0.h),
              /* --------------------- join or leave community button --------------------- */
              JoinOrLeaveCommunityButton(
                communityJoiningStatus: searchedCommunityItem.communityJoiningStatus,
                onJoinOrLeaveCommunityTap: onJoinOrLeaveCommunityTap,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0.h),
        /* -------------------------- community content/bio ------------------------- */
        isHorizontalTile
            ? Expanded(
                child: CommunityContentBio(
                  communityBioContent: searchedCommunityItem.communityBioContent,
                  onReadMoreButtonTap: onReadMoreButtonTap,
                ),
              )
            : CommunityContentBio(communityBioContent: searchedCommunityItem.communityBioContent),
      ],
    );
  }
}
