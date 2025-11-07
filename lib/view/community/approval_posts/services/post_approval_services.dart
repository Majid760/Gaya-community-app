import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/notification/notification_api/notification_api.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:get/get.dart';

import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../model/create.post.model.dart';
import '../../../../services/services.dart';
import '../../../../utils/strings.dart';

class PostApprovalServices with ApprovalImpl, PaginationImpl {
  final String communityId;

  PostApprovalServices({required this.communityId});

  /// Get posts from the database
  Future<List<Post>> requestMoreData() async => await _requestPosts(communityId);

  /// resets pagination
  void reset() => _reset();
}

/// Database Crud operations for approval
mixin class ApprovalImpl {
  final _commonServices = Services.to;
  final _notificationApiHitting = NotificationApiHitting();

  /// Approve post - returns true if successfully approved.
  ///* title = Community name (if null, then [postIsApproved] will be used)
  ///* userId = Receiver (Post Author)
  ///* PostId and CommunityId is for navigation
  Future<bool> approvePost(
      {required String userId, required String postId, required String communityId, required String communityName}) async {
    try {
      /// Check if post id is null
      if (postId.isBlank == true) {
        throw Exception("PostId is null");
      }

      /// Update post
      try {
        await FirebaseFirestore.instance.collection("communityposts").doc(postId).update({
          "approve": true,
          "approvedAt": DateTime.now(),
        });
      } catch (_) {
        await FirebaseFirestore.instance.collection("communityposts").doc(postId).update({"approve": true});
      }

      /// Send notification
      _sendNotification(
          userId: userId,
          title: GayaStrings.post_approved_success.tr,
          postId: postId,
          communityId: communityId,
          communityName: communityName);
      return true;
    } catch (_) {
      CrashlyticsController.to.instance.recordError(_, reason: 'ApprovalImplementation.approvePost()');
    }
    return false;
  }

  /// Reject post - returns true if successfully rejected.
  /// * title = Community name (if null, then [postIsRejected] will be used)
  /// * userId = Receiver (Post Author)
  /// * PostId and CommunityId is for navigation
  Future<bool> rejectPost(
      {required String userId, required String postId, required String communityId, required String communityName}) async {
    try {
      /// Check if post id is null
      if (postId.isBlank == true) {
        throw Exception("PostId is null");
      }
      FirebaseFirestore.instance.collection("communityposts").doc(postId).delete();

      /// Send notification
      _sendNotification(
          userId: userId,
          title: GayaStrings.post_reject_success.tr,
          postId: postId,
          communityId: communityId,
          communityName: communityName,
          isRejected: true);
      return true;
    } catch (_) {
      CrashlyticsController.to.instance.recordError(_, reason: 'ApprovalImplementation.rejectPost()');
    }
    return false;
  }

  void _sendNotification(
      {required String userId,
      required String title,
      required String postId,
      required String communityId,
      bool isRejected = false,
      required String communityName}) async {
    {
      UserModel? receiverUser = await _commonServices.getUserById(userId, forcefullyServer: true);
      final fcmPostModel = FcmCreatePostModel(
        postid: postId,
        messageContent: isRejected
            ? "${GayaStrings.post_reject_initial.tr} $communityName ${GayaStrings.post_reject_end.tr}"
            : GayaStrings.post_approved_checkout.tr,
        messageTitle: title,
        receiverFcm: receiverUser?.fm_token ?? '',
        communityId: communityId,
      );

      _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

      /// Send notification to the user if [isFCMOnly] is false
      if (receiverUser != null) {
        UserModel adminData = UserModel.to;

        await _commonServices.addNotification(
            isRead: false,
            communityId: fcmPostModel.communityId,
            body: isRejected
                ? "${GayaStrings.post_reject_initial.tr} $communityName ${GayaStrings.post_reject_end.tr}"
                : GayaStrings.post_approved_checkout.tr,
            receiverUserID: receiverUser.uId ?? '',
            senderId: adminData.uId ?? "",
            title: fcmPostModel.messageTitle,
            time: DateTime.now().toString(),
            type: isRejected ? "communityPostRejected" : "communityPostApproved",
            userImage: adminData.profilePicture ?? "");
      }
    }
  }
}

/// Pagination operations
mixin class PaginationImpl {
  int postLimitSize = 15;
  DocumentSnapshot? _lastDocument;
  bool _hasMorePosts = true;
  final _commonServices = Services.to;

  void _reset() {
    _lastDocument = null;
    _hasMorePosts = true;
  }

  Future<List<Post>> _requestPosts(String communityId) async {
    List<Post> newPosts = [];
    try {
      var pagePostsQuery = FirebaseFirestore.instance
          .collection("communityposts")
          .where('communityId', isEqualTo: communityId)
          .where("approve", isEqualTo: false)
          .orderBy('createdOn', descending: true)
          .limit(postLimitSize);

      // #5: If we have a document start the query after it
      if (_lastDocument != null) {
        pagePostsQuery = pagePostsQuery.startAfterDocument(_lastDocument!);
      }

      if (_hasMorePosts == false) {
        return [];
      }

      List<Post> posts = [];
      final postsSnapshot = await pagePostsQuery.get();
      MyLoggerServices.to.print("approvalPosts data length: ${postsSnapshot.docs.length}");
      if (postsSnapshot.docs.isNotEmpty) {
        _lastDocument = postsSnapshot.docs.last;
      } else {
        _hasMorePosts = false;
        return _requestPosts(communityId);
      }

      var localPosts = await parse(postsSnapshot);
      for (var element in localPosts) {
        posts.add(element);
      }

      newPosts = posts;
      MyLoggerServices.to.print("newPosts length servies d: ${newPosts.length}");

      // #14: Determine if there's more posts to request
      _hasMorePosts = posts.length == postLimitSize;
    } catch (_) {
      CrashlyticsController.to.instance.recordError(_, reason: 'PostApproveServices._requestPosts()');
    }
    return newPosts;
  }

  Future<List<Post>> parse(QuerySnapshot<Map<String, dynamic>> postsSnapshot) async {
    List<Post> posts = [];
    final rawPosts = postsSnapshot.docs;
    for (var rawPost in rawPosts) {
      try {
        final Post post = Post.fromMap(rawPost.data());

        final reactionModel = await _commonServices.getUserReactionOnPost(post.postid ?? '');
        post.reactionModel = reactionModel;

        List<CommentCustomModel> comments = await _commonServices.loadPostRecentCommentsFromPostMap(post.postedBy, map: rawPost.data());
        post.recentComments = comments;

        // List<MultiCommentModel> comments = await _commonServices.loadPostsComments(post.postid ?? "");
        // post.recentComments = comments;

        posts.add(post);
      } catch (_) {
        CrashlyticsController.to.instance.recordError(_, reason: 'PostApproveServices.parse() ${rawPost.id}');
      }
    }
    return posts;
  }
}
