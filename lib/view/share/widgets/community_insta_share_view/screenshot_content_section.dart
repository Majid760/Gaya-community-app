import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../utils/assets_icons.dart';
import '../../controllers/instagram_story_share_controller.dart';
import '../../models/community_insta_share.dart';
import 'community_dp.dart';
import 'community_info_bio.dart';
import 'community_members.dart';
import 'community_name.dart';
import 'community_type.dart';
import 'cover_image.dart';
import 'gradient_link_arrows_container.dart';

class ScreenshotContentSection extends StatelessWidget {
  const ScreenshotContentSection({
    super.key,
    required this.communityInstaShare,
  });

  final CommunityInstaShare communityInstaShare;

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: InstagramStoryShareController.instance.screenshotController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(33.0.r),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    /* ------------------------------- cover image ------------------------------ */
                    CoverImage(coverImage: communityInstaShare.communityCover),
                    Padding(
                      padding: EdgeInsets.only(
                        right: 16.0.w,
                        bottom: 16.0.w,
                        left: 16.0.w + 64.r,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* ----------------------------- community name ----------------------------- */
                          CommunityName(communityName: communityInstaShare.communityName),
                          /* ----------------------- COMMUNITY TYPE AND MEMBERS ----------------------- */
                          Row(
                            children: [
                              communityInstaShare.communityType == "Private"
                                  ? SvgIconWidget.lockOutline1(height: 16.h, width: 16.w)
                                  : SvgIconWidget.lockUnlockedOutline(height: 16.h, width: 16.w),
                              const SizedBox(width: 10),
                              /* ----------------------------- community type ----------------------------- */
                              CommunityType(communityType: communityInstaShare.communityType),
                              /* ---------------------------- vertical divider ---------------------------- */
                              const VerticalDivider(),
                              /* ---------------------------- community members --------------------------- */
                              CommunityMembers(communityMembers: communityInstaShare.communityMembers),
                            ],
                          ),
                        ],
                      ),
                    ),
                    /* ---------------------- community info / description ---------------------- */
                    CommunityInfoBio(communityInfo: communityInstaShare.communityInfo),
                    SizedBox(height: 16.0.h),
                    /* --------------------------- gradient container --------------------------- */
                    const GradientLinkArrowsContainer(),
                  ],
                ),
                /* ------------------------------ profile image ----------------------------- */
                CommunityDp(communityDp: communityInstaShare.communityDp),
              ],
            ),
          ),
          SizedBox(height: 16.0.h),
          /* -------------------------------- gaya logo ------------------------------- */
          Image.asset(
            'Assets/images/gaya_logo_with_text.png',
            height: 26.0.w,
          ),
        ],
      ),
    );
  }
}
