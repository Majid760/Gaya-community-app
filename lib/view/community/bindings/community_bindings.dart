import 'package:gaya/model/community.model.dart';
import 'package:gaya/view/community/community_invites/controllers/community_invites_controller.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:gaya/view/community/controllers/community_feed_controller.dart';
import 'package:gaya/view/community/controllers/community_profile_controller.dart';
import 'package:gaya/view/community/events/controller/event_controller.dart';
import 'package:get/get.dart';

import '../../../shared/controller/mentioned_user_controller.dart';

class CommunityViewBindings extends Bindings {
  String communityId;
  Community? community;
  String? hashTagTopic;

  CommunityViewBindings({required this.communityId, this.community});

  @override
  void dependencies() {
    Get.lazyPut(() => EditCommunityController(community: community), tag: communityId);
    Get.lazyPut(() => CommunityFeedController(communityId: communityId, community: community, hashTagTopic: hashTagTopic),
        tag: communityId);
    Get.lazyPut(() => CommunityProfileController(communityId: communityId, communityModel: community), tag: communityId);
    Get.lazyPut(() => MentionedUserController(), fenix: true);
    Get.lazyPut(() => EventController(communityId: communityId), tag: communityId, fenix: true);
  }
}

class CommunityInvitesBindings extends Bindings {
  String communityId;

  CommunityInvitesBindings({required this.communityId});

  @override
  void dependencies() {
    Get.lazyPut(() => CommunityInvitesController(communityId: communityId));
  }
}

// class CommunityPendingPostsAndUsersBindings extends Bindings {
//   Community community;
//
//   CommunityPendingPostsAndUsersBindings({required this.community});
//
//   @override
//   void dependencies() {
//     Get.lazyPut(
//         () => CommunityPendingPostsAndUsersController(community: community),
//         tag: community.communityId);
//   }
// }
