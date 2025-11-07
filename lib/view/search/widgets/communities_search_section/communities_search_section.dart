import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controller/communities.controller.dart';
import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../model/community.model.dart';
import '../../../../model/user.model.dart';
import '../../../../utils/enum.dart';
import '../../../../utils/methods.dart';
import '../../../../utils/refresh_builder_utils.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../controllers/search_controller.dart';
import '../../models/searched_community_item.dart';
import '../community_container/community_container.dart';
import '../status_text.dart';

class CommunitiesSearchSection extends StatelessWidget {
  const CommunitiesSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GayaSearchController>(
      builder: (searchController) {
        return EasyRefresh.builder(
          controller: searchController.refreshController,
          footer: RefreshBuilderUtils.footer,
          simultaneously: true,
          onLoad: searchController.communities.isEmpty
              ? null
              : () async {
                  await searchController.loadMoreData();
                },
          childBuilder: (context, physics) {
            return searchController.isLoading
                ? ListView.builder(
                    padding: EdgeInsets.only(
                      top: 16.0.w,
                      left: 16.0.w,
                      right: 16.0.w,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        height: _communityContainerHeight,
                        margin: EdgeInsets.only(bottom: 16.0.w),
                        width: 1.0.sw - 64.0.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0.r),
                          color: AppColors.black5,
                        ),
                      );
                    },
                  )
                : searchController.isTabBarViewTabBuildFirstTime
                    ? StatusText(statusText: GayaStrings.search_communities.tr)
                    : searchController.communities.isEmpty
                        ? StatusText(statusText: GayaStrings.no_community_found.tr)
                        : CustomScrollView(
                            physics: physics,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: searchController.communities.length,
                                  (context, index) {
                                    // getting community instance at specific index
                                    Community community = searchController.communities[index];

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 16.0.w,
                                        right: 16.0.w,
                                        left: 16.0.w,
                                        top: index == 0 ? 16.0.w : 0.0,
                                      ),
                                      child: GetBuilder<GayaSearchController>(
                                        id: community.communityId,
                                        builder: (controller) {
                                          // checking whether [community] is already joined
                                          bool isCommunityJoined = searchController.checkIsCommunityJoined(community.communityId ?? '');
                                          bool isCommunityRequestSent =
                                              searchController.checkIsCommunityJoinRequestSent(community.communityId ?? '');

                                          return CommunityContainer(
                                            searchedCommunityItem: SearchedCommunityItem(
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
                                            onJoinOrLeaveCommunityTap: !isCommunityRequestSent && !isCommunityJoined
                                                ? () => joinOrOpenCommunity(
                                                      context,
                                                      community,
                                                      index,
                                                    )
                                                : () {
                                                    // opening leave community dialog
                                                    Methods.showLeaveCommunityAlert(
                                                      communityModel: community,
                                                      context: context,
                                                      onLeave: () {},
                                                    );
                                                  },
                                            onCommunityContainerTap: () => joinOrOpenCommunity(
                                              context,
                                              community,
                                              index,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const FooterLocator.sliver(),
                            ],
                          );
          },
        );
      },
    );
  }

  /// call to join or open community
  void joinOrOpenCommunity(BuildContext context, Community community, int index) {
    context.read<CommunitiesController>().isReadMore = false;
    Methods.showModalSheetToJoinCommunity(communityId: community.communityId, ctx: context);

    // Logging user clicked search result analytics event
    AnalyticsController.to.instance.logUserClickedSearchResult(
      userId: UserModel.to.uId ?? '',
      clickedResultIndex: index.toString(),
      searchedText: GayaSearchController.to.searchTextEditingController.text,
      clickedResultText: community.communityName ?? '',
      itemType: 'community',
    );
  }

  double get _communityContainerHeight => 100.0.h + 16.0.h + 8.0.h + 16.sp + 8.0 + 16.0.h + 14.22.sp + 8.0.h + 16.0.w + 12.64.sp + 12.64.sp;
}
