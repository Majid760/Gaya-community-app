import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/assets_icons.dart';
import '../../model/community_item/community_item.dart';
import '../../view/search/widgets/community_container/join_or_leave_community_button.dart';
import 'community_content_bio.dart';
import 'community_cover.dart';
import 'community_dp.dart';
import 'community_name.dart';

class CommunityContainerContent extends StatelessWidget {
  const CommunityContainerContent({
    super.key,
    required this.communityItem,
    required this.isHorizontalTile,
    required this.onJoinOrLeaveCommunityTap,
    required this.onReadMoreButtonTap,
  });

  final CommunityItem communityItem;
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
            CommunityCover(communityCover: communityItem.communityCover),
            /* ------------------------------ community dp ------------------------------ */
            CommunityDp(communityDp: communityItem.communityDp),
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
                      CommunityName(communityName: communityItem.communityName),
                      SizedBox(width: 4.0.w),
                      /* --------------------------- lock / unlock icon --------------------------- */
                      communityItem.communityType == 'Public' ? SvgIconWidget.unLock : SvgIconWidget.lock,
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.0.h),
              /* --------------------- join or leave community button --------------------- */
              JoinOrLeaveCommunityButton(
                communityJoiningStatus: communityItem.communityJoiningStatus,
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
                  communityBioContent: communityItem.communityBioContent,
                  onReadMoreButtonTap: onReadMoreButtonTap,
                ),
              )
            : CommunityContentBio(communityBioContent: communityItem.communityBioContent),
      ],
    );
  }
}
