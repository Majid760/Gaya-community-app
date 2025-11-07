import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/community_container/community_container.dart';
import '../../../controller/communities.controller.dart';
import '../../../model/community.model.dart';
import '../../../model/community_item/raw_community_item.dart';
import '../../../utils/enum.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/methods.dart';
import '../../../utils/theme/app_typography.dart';
import '../controller/for_you_controller.dart';

/// Suggested Communities Section for [ForYouFeedView]
class SuggestedCommunitiesSection extends StatelessWidget {
  const SuggestedCommunitiesSection({
    Key? key,
    required this.suggestedCommunities,
  }) : super(key: key);

  ///
  /// STATE VARIABLES
  ///

  /// List of suggested communities
  final List<Community> suggestedCommunities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ///
        /// Suggested Communities text
        ///
        Padding(
          padding: EdgeInsets.only(left: 20.0.r, right: 20.0.r, top: 14.0.h, bottom: 12.0.h),
          child: Text(
            GayaStrings.communities_suggestions.tr,
            style: GayaTypography.h4,
          ),
        ),

        ///
        /// Suggested Communities list view (horizontal)
        ///
        SizedBox(
          height: _communityContainerHeight,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.0.r),
            shrinkWrap: true,
            primary: false,
            scrollDirection: Axis.horizontal,
            itemCount: suggestedCommunities.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.0.w),
            itemBuilder: (context, index) {
              // getting community instance at specific index
              Community community = suggestedCommunities[index];

              return SizedBox(
                width: 1.0.sw - 62.0.w,
                child: GetBuilder<ForYouFeedController>(
                  id: community.communityId,
                  builder: (controller) {
                    // checking whether [community] is already joined
                    bool isCommunityJoined = controller.checkIsCommunityJoined(community.communityId ?? '');
                    // checking whether [community] request is in pending
                    bool isCommunityRequestSent = controller.checkIsCommunityJoinRequestSent(community.communityId ?? '');

                    return CommunityContainer(
                      communityItem: RawCommunityItem(
                        communityId: community.communityId ?? '',
                        communityCover: community.coverPicture ?? '',
                        communityDp: community.CommunityPic ?? '',
                        communityName: community.communityName ?? '',
                        communityType: community.communityType ?? '',
                        communityBioContent: community.communityDescription ?? '',
                        communityJoiningStatus: isCommunityJoined
                            ? CommunityJoiningStatus.joined
                            : isCommunityRequestSent
                                ? CommunityJoiningStatus.waitingForApproval
                                : CommunityJoiningStatus.notJoined,
                      ),
                      isHorizontalTile: true,
                      onCommunityContainerTap: () => joinOrOpenCommunity(context, community),
                      onJoinOrLeaveCommunityTap: !isCommunityRequestSent && !isCommunityJoined
                          ? () => joinOrOpenCommunity(context, community)
                          : () {
                              // opening leave community dialog
                              Methods.showLeaveCommunityAlert(
                                communityModel: community,
                                context: context,
                                onLeave: () {},
                              );
                            },
                    );
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.0.h)
      ],
    );
  }

  /// Returns height of community container
  double get _communityContainerHeight => 100.0.h + 16.0.h + 8.0.h + 16.sp + 8.0 + 16.0.h + 14.22.sp + 8.0.h + 16.0.w + 12.64.sp + 12.64.sp;

  /// Call to join or open community
  void joinOrOpenCommunity(BuildContext context, Community community) {
    context.read<CommunitiesController>().isReadMore = false;
    Methods.showModalSheetToJoinCommunity(communityId: community.communityId, ctx: context);
  }
}
