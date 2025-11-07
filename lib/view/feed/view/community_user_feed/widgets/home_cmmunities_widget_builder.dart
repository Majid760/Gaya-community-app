import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../model/community.model.dart';
import '../controller/home_feed_user_communities_controller.dart';
import '../view/community_user_feed_view.dart';
import 'user_community_widget.dart';

class MyCommunitiesFeedWidget extends StatelessWidget {
  final bool isHomeFeed;
  final Community community;

  const MyCommunitiesFeedWidget({Key? key, required this.community, required this.isHomeFeed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8).r,
      child: HomeCommunityWidget(
        communityId: community.communityId!,
        badge: const SizedBox.shrink(),
        onTap: () {
          HomeFeedUserCommunities.to.updateSelectedCommunity(community);
          if (isHomeFeed) {
            Get.to(() => CommunityUserFeedView(communityModel: community));
          }
          HomeFeedUserCommunities.to.updateCommunityLastVisitTimeForUser(community);
          if (community.totalUnseenPosts == 0) return;
          int totalUnseenPosts = community.totalUnseenPosts!;
          totalUnseenPosts = 0;
          HomeFeedUserCommunities.to.updateCount(community.copyWith(totalUnseenPosts: totalUnseenPosts));
          // SeenUnseenPostServices.instance.setLastVisit(community.communityId!);
        },
        communityName: community.communityName.toString(),
        numberOfMemebers: "0",
        numberOfNewPosts: community.totalUnseenPosts,
        opacity: 0.81,
        image: community.CommunityPic.toString(),
        isHomeFeed: isHomeFeed,
        community: community,
      ),
    );
  }
}

/*
class MyHomeCommunitiesWidget extends StatefulWidget {
  final bool isHomeFeed;
  final UserCommunities communitiesModel;
  final List<DocumentReference<Object?>> pinnedCommunities;

  const MyHomeCommunitiesWidget({Key? key, required this.communitiesModel, required this.pinnedCommunities, required this.isHomeFeed})
      : super(key: key);

  @override
  State<MyHomeCommunitiesWidget> createState() => _MyHomeCommunitiesWidgetState();
}

class _MyHomeCommunitiesWidgetState extends State<MyHomeCommunitiesWidget> {
  // @override
  // bool get wantKeepAlive => true;

  Community? community;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    Services.to.getCommunityDetailsModel(widget.communitiesModel.communityId ?? "", shouldHavePostCount: true).then((value) {
      isLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {
            community = value;
          });
        }
      });
    });
  }

  updateSeenPostCount() {
    if (community == null || community!.totalUnseenPosts == 0) return;
    int totalUnseenPosts = community!.totalUnseenPosts!;
    totalUnseenPosts = 0;

    community = community!.copyWith(totalUnseenPosts: totalUnseenPosts);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    if (!isLoaded) return const ShowHomeCommunityShimmer();
    if (community == null) return const SizedBox.shrink();

    final totalMembersCount = community?.communityMembers ?? 0;
    return Padding(
      padding: const EdgeInsets.only(right: 8).r,
      child: HomeCommunityWidget(
        communityId: community!.communityId!,
        badge: const SizedBox.shrink(),
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            updateSeenPostCount();
          });
        },
        communityName: community!.communityName.toString(),
        numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
        numberOfNewPosts: community!.totalUnseenPosts,
        // numberOfNewPosts: service.numberOfPost.toString(),
        opacity: 0.81,
        image: community!.CommunityPic.toString(),
        isHomeFeed: widget.isHomeFeed,
        community: community!,
      ),
    );
  }
}
*/
