import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controller/homepage.controller.dart';
import '../../../model/community.model.dart';
import '../../../routing/getx_route_methods.dart';
import '../../../utils/assets_icons.dart';
import '../../../utils/enum.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/theme/app_typography.dart';
import '../../share/controllers/instagram_story_share_controller.dart';
import '../../share/models/community_insta_share.dart';
import '../controllers/community_profile_controller.dart';
import 'leading_trailing_subtitle_button.dart';

/// No posts widget is displayed when there are no posts in the community.
class NoPostsWidget extends StatelessWidget {
  /// Creates a no posts widget.
  const NoPostsWidget({
    Key? key,
    required this.community,
    required this.postCreationFrom,
  }) : super(key: key);

  /* -------------------------------------------------------------------------- */
  /*                               STATE VARIABLES                              */
  /* -------------------------------------------------------------------------- */
  final Community community;
  final PostCreationFrom postCreationFrom;

  /* -------------------------------------------------------------------------- */
  /*                               LIFECYCLE API'S                              */
  /* -------------------------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                                 Main Column                                */
    /* -------------------------------------------------------------------------- */
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* ------------------------ Welcome to community text ----------------------- */
        Text(
          '${GayaStrings.welcome_to_.tr}${community.communityName}',
          style: GayaTypography.h2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.0.h),
        /* ----------------------- Let's get you started text ----------------------- */
        Text(
          GayaStrings.lets_get_you_started.tr,
          style: GayaTypography.text,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12.0.h),
        /* -------------------------- Invite friends button ------------------------- */
        LeadingTrailingSubtitleButton(
          leadingIcon: IconsAssetsPathUtils.inviteFriend,
          title: GayaStrings.invite_friends.tr,
          subTitle: GayaStrings.share_the_community_with_your_friends.tr,
          onTap: () => _onInviteFriendsButtonTap(context),
        ),
        SizedBox(height: 8.0.h),
        /* --------------------------- Write a post button -------------------------- */
        LeadingTrailingSubtitleButton(
          leadingIcon: IconsAssetsPathUtils.editOutline,
          title: GayaStrings.write_a_post.tr,
          subTitle: GayaStrings.start_a_discussion_by_writing_the_first_post.tr,
          onTap: _onWriteAPostButtonTap,
        ),
      ],
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                 OTHER API'S                                */
  /* -------------------------------------------------------------------------- */
  /// Callback call when invite friends button is tapped.
  void _onInviteFriendsButtonTap(BuildContext context) async {
    if (community.communityType == 'Secret') {
      Routes.openInvitePermission(
        communityId: community.communityId ?? '',
      );
    } else {
      if (FirebaseAuth.instance.currentUser?.uid == null) return;

      final HomePageController homePageController = context.read<HomePageController>();
      homePageController.searchFriendsController.clear();
      homePageController.searchFriends.clear();
      homePageController.sentMessageUserIds.clear();
      homePageController.isSend = false;

      // creating instance of CommunityInstaShare for share
      CommunityInstaShare communityInstaShare = CommunityInstaShare(
        communityName: community.communityName ?? '',
        communityDp: community.CommunityPic,
        communityCover: community.coverPicture,
        communityInfo: community.communityDescription,
        communityMembers: community.communityMembers,
        communityType: community.communityType,
        community: community,
      );
      // setting instaShare instance to communityInstaShare to share community
      InstagramStoryShareController.instance.instaShare = communityInstaShare;

      // Navigating to invite friends screen.
      Routes.goToInviteFriendsScreen(community: getCommunityModel);

      // Getting all the friends of the user.
      await context.read<HomePageController>().yourFriends();
    }
  }

  /// Callback call when write a post button is tapped.
  void _onWriteAPostButtonTap() {
    // Checking whether the community id is null.
    if (community.communityId == null) return;

    // Assigning existing community model to newCommunityModel
    Community newCommunityModel = community;

    // Checking whether the post creation is from community
    if (postCreationFrom == PostCreationFrom.Community) {
      newCommunityModel = getCommunityModel;
    }

    // Navigating to create post screen.
    Routes.createPost(community: newCommunityModel, from: postCreationFrom);
    // Vibrating the device on tap.
    HapticFeedback.mediumImpact();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   GETTERS                                  */
  /* -------------------------------------------------------------------------- */
  /// Fetches the community from either CommunityProfileController || Widget.communityModel
  /// reason: when getting from post, the community might be outdated, so communityProfileController is
  /// always updated with the latest community
  Community get getCommunityModel {
    Community communityModel = community;
    bool isRegistered = CommunityProfileController.isRegistered(tag: community.communityId);
    if (isRegistered && CommunityProfileController.to(tag: community.communityId).communityModel != null) {
      communityModel = CommunityProfileController.to(tag: community.communityId).communityModel!;
    }
    return communityModel;
  }
}
