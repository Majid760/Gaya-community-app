import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:gaya/model/community.model.dart';
import 'package:gaya/shared/controller/mentioned_user_controller.dart';
import 'package:gaya/view/comments/controller/comments_controller.dart';
import 'package:gaya/view/comments/controller/post_with_comment_controller.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:get/get.dart';

import '../../../model/create.post.model.dart';

class CommentBindings extends Bindings {
  CommentBindings();

  @override
  void dependencies() {
    ///named rouyting
    final Post post = Get.arguments["post"] as Post;
    final Community community = Get.arguments["community"] as Community;
    final postId = post.postid;
    Get.put(EditCommunityController(community: community), tag: community.communityId);
    Get.lazyPut(() => PostWithCommentController(post: post), tag: postId ?? "");
    Get.lazyPut(() => CommentsController(post: post), tag: postId ?? "");
    Get.lazyPut(() => MentionedUserController(), fenix: true);
  }

  static void deleteControllers(String? postId) {
    try {
      Get.delete<PostWithCommentController>(tag: postId);
      Get.delete<CommentsController>(tag: postId);
    } catch (_) {}
  }

  static void initControllers(Post post) {
    try {
      Get.lazyPut(() => PostWithCommentController(post: post), tag: post.postid);
      Get.lazyPut(() => CommentsController(post: post), tag: post.postid);
    } catch (_) {
      debugPrint("initControllers error $_");
    }
  }
}
