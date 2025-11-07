import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controller/communities.controller.dart';
import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../model/community.model.dart';
import '../../../../model/create.post.model.dart';
import '../../../../model/user.model.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../utils/enum.dart';
import '../../../../utils/methods.dart';
import '../../../../utils/textstyles.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../Auth/controller/require.sigin.register.dart';
import '../../../feed/components/post_tile.dart';
import '../../controllers/search_controller.dart';
import '../../models/friendship_status.dart';
import '../../models/searched_community_item.dart';
import '../../models/searched_person_item.dart';
import '../community_container/community_container.dart';
import '../people_container/people_container.dart';

class TopSearchSection extends StatelessWidget {
  const TopSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GayaSearchController>(
      builder: (searchController) {
        return ListView(
          children: [
            SizedBox(height: 16.0.h),
            /* ---------------------------- communities title --------------------------- */

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: Text(
                GayaStrings.communities_txt.tr,
                style: CustomTypography.body2StyleWeightBlack,
              ),
            ),
            SizedBox(height: 16.0.h),
            /* -------------------------- top communities list -------------------------- */
            if (searchController.isLoading)
              SizedBox(
                height: _communityContainerHeight,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 16.0.w),
                  shrinkWrap: true,
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: 16.0.w),
                      width: 1.0.sw - 200.0.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0.r),
                        color: AppColors.black5,
                      ),
                    );
                  },
                ),
              )
            else
              searchController.communities.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            GayaStrings.no_community_found.tr,
                            style: CustomTypography.body2StyleWeightBlack.copyWith(
                              color: AppColors.secondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: _communityContainerHeight,
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: 16.0.w),
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        itemCount: searchController.communities.length,
                        itemBuilder: (context, index) {
                          // getting community instance at specific index
                          Community community = searchController.communities[index];

                          return Padding(
                            padding: EdgeInsets.only(right: 16.0.w),
                            child: SizedBox(
                              width: 1.0.sw - 32.0.w,
                              child: GetBuilder<GayaSearchController>(
                                id: community.communityId,
                                builder: (controller) {
                                  // checking whether [community] is already joined
                                  bool isCommunityJoined = controller.checkIsCommunityJoined(community.communityId ?? '');
                                  // checking whether [community] request is in pending
                                  bool isCommunityRequestSent = controller.checkIsCommunityJoinRequestSent(community.communityId ?? '');

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
                                    isHorizontalTile: true,
                                    onCommunityContainerTap: () => joinOrOpenCommunity(
                                      context,
                                      community,
                                      index,
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
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            SizedBox(height: 16.0.h),
            /* ------------------------------ people title ------------------------------ */

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: Text(
                GayaStrings.people.tr,
                style: CustomTypography.body2StyleWeightBlack,
              ),
            ),
            SizedBox(height: 16.0.h),
            /* ----------------------------- top people list ---------------------------- */
            if (searchController.isLoading)
              ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                shrinkWrap: true,
                primary: false,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Container(
                    height: 120.0.h,
                    margin: EdgeInsets.only(bottom: 16.0.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0.r),
                      color: AppColors.black5,
                    ),
                  );
                },
              )
            else
              searchController.people.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            GayaStrings.no_user_found.tr,
                            style: CustomTypography.body2StyleWeightBlack.copyWith(
                              color: AppColors.secondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      shrinkWrap: true,
                      primary: false,
                      itemCount: searchController.people.length,
                      itemBuilder: (context, index) {
                        // getting user instance at specific index
                        UserModel user = searchController.people[index];

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.0.w),
                          child: GetBuilder<GayaSearchController>(
                            id: user.uId,
                            builder: (controller) {
                              // getting FriendshipStatusModel if me and user is already friend
                              FriendshipStatusModel? friendshipStatusModel = controller.isUserFriend(user.uId ?? '');

                              return PeopleContainer(
                                searchedPersonItem: SearchedPersonItem(
                                  username: user.name ?? '',
                                  profileImage: user.profilePicture ?? '',
                                  about: user.bio ?? '',
                                  friendshipStatus: friendshipStatusModel?.friendshipStatus ?? FriendshipStatus.addFriend,
                                ),
                                onPeopleContainerTap: () {
                                  if (FirebaseAuth.instance.currentUser == null) {
                                    Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                                    return;
                                  }
                                  searchController.addToRecentSearch(user.name ?? '');
                                  Routes.viewProfile(uid: user.uId, model: user, shouldReplace: false);

                                  // Logging user clicked search result analytics event
                                  AnalyticsController.to.instance.logUserClickedSearchResult(
                                    userId: UserModel.to.uId ?? '',
                                    clickedResultIndex: index.toString(),
                                    searchedText: GayaSearchController.to.searchTextEditingController.text,
                                    clickedResultText: user.name ?? '',
                                    itemType: 'user',
                                  );
                                },
                                onPeopleContainerButtonTap: () => searchController.onPeopleContainerButtonTapCallback(
                                  friendshipStatusModel: friendshipStatusModel,
                                  context: context,
                                  user: user,
                                ),
                                showLoader: searchController.isLoading,
                              );
                            },
                          ),
                        );
                      },
                    ),

            /* ------------------------------- posts title ------------------------------ */

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: Text(
                GayaStrings.posts.tr,
                style: CustomTypography.body2StyleWeightBlack,
              ),
            ),
            SizedBox(height: 16.0.h),
            /* ----------------------------- top posts list ----------------------------- */
            if (searchController.isLoading)
              ListView.builder(
                // padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                shrinkWrap: true,
                primary: false,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    height: 160.0.h,
                    margin: EdgeInsets.only(
                      left: 16.0.w,
                      right: 16.0.w,
                      bottom: 16.0.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0.r),
                      color: AppColors.black5,
                    ),
                  );
                },
              )
            else
              searchController.posts.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 16.0.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            GayaStrings.no_post_found.tr,
                            style: CustomTypography.body2StyleWeightBlack.copyWith(
                              color: AppColors.secondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      // padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      shrinkWrap: true,
                      primary: false,
                      itemCount: searchController.posts.length,
                      itemBuilder: (context, index) {
                        return GetBuilder<GayaSearchController>(
                          id: searchController.posts[index].postid,
                          builder: (controller) {
                            // getting post instance at specific index
                            Post post = controller.posts[index];
                            return PostTile(
                              postModel: post,
                              inSearchScreen: true,
                              index: index,
                            );
                          },
                        );
                      },
                    ),
          ],
        );
      },
    );
  }

  double get _communityContainerHeight => 100.0.h + 16.0.h + 8.0.h + 16.sp + 8.0 + 16.0.h + 14.22.sp + 8.0.h + 16.0.w + 12.64.sp + 12.64.sp;

  /// call to join or open community
  void joinOrOpenCommunity(
    BuildContext context,
    Community community,
    int index,
  ) {
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
}
