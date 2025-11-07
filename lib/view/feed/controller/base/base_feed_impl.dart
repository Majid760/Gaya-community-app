import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../model/community.model.dart';
import '../../../../model/create.post.model.dart';
import '../../../../model/user.model.dart';
import '../../../../services/services.dart';
import '../../../search/controllers/search_controller.dart';
import '../for_you_controller.dart';

///This class will be used to update post everywhere in the app - no matter how we interact with it, it will search
///for the post and update it
///Filed [metadata] is use for debugging only
class FeedControllerUtils {
  static final Services _commonService = Services();

  static likePost(String? postId, {UserModel? receiverUser, String? metadata}) {
    Post? post;
    debugPrint('likePost $metadata');

    // like or unlike post if the GayaSearchController is registered
    if (Get.isRegistered<GayaSearchController>()) {
      debugPrint('likePost GayaSearchController');
      Post? post = Get.find<GayaSearchController>().likeOrUnlikePost(postId, receiverUser: receiverUser);

      // if post is not null we already liked it and stored it on remote db
      if (post != null) {
        // updating post status locally everywhere
        return updatePostLocally(post, metadata: metadata);
      }
    }

    if (Get.isRegistered<ForYouFeedController>()) {
      debugPrint('likePost ForYouFeedController');
      final forYouFeedController = Get.find<ForYouFeedController>();
      post = forYouFeedController.likePost(postId, receiverUser: receiverUser);
      if (post != null) {
        return updatePostLocally(post);
      }
    }
  }

  static likeReactionOnPost(String? postId, {UserModel? receiverUser, String? metadata, String? reaction, bool isChecked = false}) {
    Post? post;
    debugPrint('likePost $metadata');

    // like or unlike post if the SearchController is registered
    if (Get.isRegistered<GayaSearchController>()) {
      debugPrint('likePost SearchController');
      Post? post = Get.find<GayaSearchController>()
          .likeOrUnlikeReactionOnPost(postId, receiverUser: receiverUser, reaction: reaction, isChecked: isChecked);

      // if post is not null we already liked it and stored it on remote db
      if (post != null) {
        // updating post status locally everywhere
        return updatePostLocally(post, metadata: metadata);
      }
    }

    if (Get.isRegistered<ForYouFeedController>()) {
      debugPrint('likePost ForYouFeedController');
      final forYouFeedController = Get.find<ForYouFeedController>();
      post = forYouFeedController.likeReactionOnPost(postId, receiverUser: receiverUser, reaction: reaction, isChecked: isChecked);
      if (post != null) {
        return updatePostLocally(post);
      }
    }
  }

  static crownPost(String? postId, {UserModel? receiverUser}) async {
    Post? post;

    if (Get.isRegistered<GayaSearchController>()) {
      Post? post = await GayaSearchController.to.crownPost(
        postId,
        receiverUser: receiverUser,
      );

      if (post != null) {
        /// post already crowned need to updated locally everywhere
        return updatePostLocally(post);
      }
    }

    if (Get.isRegistered<ForYouFeedController>()) {
      final forYouFeedController = Get.find<ForYouFeedController>();
      post = await forYouFeedController.crownPost(postId, receiverUser: receiverUser);

      /// Operation already done so just need to update locally
      if (post != null) {
        return updatePostLocally(post);
      }
    }
    /*   if (Get.isRegistered<FeedPostsController>()) {
      final homePageController = Get.find<FeedPostsController>();
      homePageController.crownPost(postId, receiverUser: receiverUser);
    }*/
  }

  static updatePostTopics({required Post post}) {
    if (Get.isRegistered<ForYouFeedController>()) {
      final forYouFeedController = Get.find<ForYouFeedController>();
      forYouFeedController.updatePostTopics(post: post);
    }
    /*  if (Get.isRegistered<FeedPostsController>()) {
      final homePageController = Get.find<FeedPostsController>();
      homePageController.updatePostTopics(post: post);
    }*/

    /// Instead of doing db, we are doing it here
    _commonService.updatePostTopics(post);
  }

  static updateAllOfTheCommunitieslocally(Community community) {
    if (Get.isRegistered<ForYouFeedController>()) {
      final forYouFeedController = Get.find<ForYouFeedController>();
      forYouFeedController.updateAllOfTheCommunitieslocally(community);
    }
    /*if (Get.isRegistered<FeedPostsController>()) {
      final homePageController = Get.find<FeedPostsController>();
      homePageController.updateAllOfTheCommunitieslocally(community);
    }*/
  }

  static addAPostLocally(Post post) {
    if (Get.isRegistered<ForYouFeedController>()) {
      final forYouFeedController = Get.find<ForYouFeedController>();
      forYouFeedController.addAPostLocally(post);
    }
    /* if (Get.isRegistered<FeedPostsController>()) {
      final homePageController = Get.find<FeedPostsController>();
      homePageController.addAPostLocally(post);
    }*/
  }

  /// [onlyOrganicFeed] is used to update only organic feed, [metadata] is use for debugging only
  static updatePostLocally(Post post, {bool shouldDelete = false, String? metadata}) {
    debugPrint('updatePostLocally metadata: $metadata');
    /*  if (onlyOrganicFeed) {
      if (Get.isRegistered<FeedPostsController>()) {
        debugPrint('updatePostLocally FeedPostsController');
        final homePageController = Get.find<FeedPostsController>();
        homePageController.updatePostLocally(post, shouldDelete: shouldDelete);
      }
      return;
    }
*/

    if (Get.isRegistered<ForYouFeedController>()) {
      debugPrint('ForYouFeedController was registered');
      final forYouFeedController = Get.find<ForYouFeedController>();
      forYouFeedController.updatePostLocally(post, shouldDelete: shouldDelete);
    }

    /*   if (Get.isRegistered<FeedPostsController>()) {
      debugPrint('updatePostLocally FeedPostsController');
      final homePageController = Get.find<FeedPostsController>();
      homePageController.updatePostLocally(post, shouldDelete: shouldDelete);
    }*/

    if (Get.isRegistered<GayaSearchController>()) {
      debugPrint('updatePostLocally GayaSearchController');
      GayaSearchController.to.updatePostLocally(
        post,
        shouldDelete: shouldDelete,
      );
    }
  }

  static onHideCommunity({required String communityId}) {
    if (Get.isRegistered<ForYouFeedController>()) {
      final forYouFeedController = Get.find<ForYouFeedController>();
      forYouFeedController.onHideCommunity(communityId: communityId);
    }
    /*  if (Get.isRegistered<FeedPostsController>()) {
      final homePageController = Get.find<FeedPostsController>();
      homePageController.onHideCommunity(communityId: communityId);
    }*/
  }

  static resetController() {
    if (Get.isRegistered<ForYouFeedController>()) {
      final forYouFeedController = Get.find<ForYouFeedController>();
      forYouFeedController.resetController();
    }
    /*  if (Get.isRegistered<FeedPostsController>()) {
      final homePageController = Get.find<FeedPostsController>();
      homePageController.resetController();
    }*/
  }
}
