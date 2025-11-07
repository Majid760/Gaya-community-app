import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/controller/cache_controller.dart';
import 'package:gaya/controller/crowns_controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/cache_service/cache_services.dart';
import 'package:gaya/shared/service/crown_service/crown_services.dart';
import 'package:gaya/shared/service/media_service/file_picking_service.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/view/comments/controller/post_with_comment_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../model/comment.model.dart';
import '../../../model/local/crown_payload.dart';
import '../../../model/replies.model.dart';
import '../../../services/notification/notification_api/notification_api.dart';
import '../../../utils/asset_images.dart';
import '../models/comment_custom_model.dart';
import '../services/comment_services.dart';

class CommentsController extends GetxController {
  static CommentsController to({required String? tag}) => Get.find(tag: tag);

  static bool isRegistered({required String? tag}) => Get.isRegistered<CommentsController>(tag: tag);

  Post post;

  CommentsController({required this.post});

  final CommentsServices service = CommentsServices();
  final Services _commonService = Services();
  final NotificationApiHitting _notificationApiHitting = NotificationApiHitting();
  final User? user = FirebaseAuth.instance.currentUser;
  EasyRefreshController refreshController = EasyRefreshController();
  final HelperFunc _helperFunc = HelperFunc();

  UserModel get myAppUser => UserModel.to;

  // done by mak
  File? commentsMedia;
  bool isVideo = false;

  // for pdf files
  TextEditingController documentTextField = TextEditingController();
  List<File> pdfFiles = [];
  Uint8List? pdfThumbnail;
  bool isPdf = false;

  /// this button is for AB testing we can handle to hide the
  /// visibility of post DM

  bool isPostDMEnabled = false;

  @override
  void onInit() {
    super.onInit();
    fetchComments();
    //Fetching from the Remote config
    isPostDMEnabled = GayaRemoteConfig.to.isPostDMEnabled;
  }

  @override
  void dispose() {
    //clear all comments in case (rare case) if cache left.
    allComments.clear();
    service.reset();
    super.dispose();
  }

  List<MultiCommentModel> allComments = [];

  /// returns true if comments fetched
  Future<bool> requestMoreComments() async {
    List<MultiCommentModel> comments = await service.loadPostsComments(post.postid ?? "");
    if (comments.isNotEmpty) {
      allComments.addAll(comments);
      allComments.distinctBy((element) => element.comment.id);
      update();
      return true;
    } else {
      return false;
    }
  }

  void fetchComments() async {
    PerformanceController.to.instance.startLoadCommentsTime();
    //clear all comments in case (rare case) if cache left.
    allComments.clear();
    setLoading(true);
    List<MultiCommentModel> comments = await service.loadPostsComments(post.postid ?? "");
    allComments = comments;
    PerformanceController.to.instance.stopLoadCommentsTime();
    setLoading(false);
  }

  bool documentUploadStatus = false;

  updateDocumentUploadStatus() {
    documentUploadStatus = true;
    update();
  }

  void postNewComment({
    required String newCommentId,
    required String myNewComment,
    List<Map<String, dynamic>>? mentionedUser,
    List<Map<String, dynamic>>? documentFiles,
  }) async {
    try {
      debugPrint("postNewComment $myNewComment");
      final isAnonymous = isPostedAnonymously;
      // final newCommentId = uuid.v1();

      /// score
      EngagementScoreController.to.instance.onComment(
        communityId: post.communityId ?? "",
        postId: post.postid ?? "",
      );

      /// if image/video attached, call [postNewCommentWithMedia]
      if (commentsMedia != null || pdfFiles.isNotEmpty) {
        return postNewCommentWithMedia(
          newCommentId: newCommentId,
          myNewComment: myNewComment,
          mentionedUsers: mentionedUser,
        );
      }

      // if photo is not attached, post comment directly

      /// empty comment not allowed
      if (myNewComment.isBlank == true) return;
      //make model for local.
      final newComment = CommentCustomModel(
        id: newCommentId,
        mentionedUsers: mentionedUser?.toList(),
        comment: myNewComment,
        user: UserModel.to,
        createdAt: DateTime.now(),
      );
      //add locally.
      if (service.hasMoreComments == false) {
        allComments.add(MultiCommentModel(comment: newComment, replies: []));
      }
      // allComments.insert(0, MultiCommentModel(comment: newComment, replies: []));
      update();
      UserModel? userData = await _commonService.getUserById(post.postedBy.uId, forcefullyServer: true);
      if (post.postedBy.uId != myAppUser.uId) {
        final notificationTitle =
            "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name}";
        final notificationBody = '${GayaStrings.new_comment.tr}  "$myNewComment"';
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent: notificationBody,
          messageTitle: notificationTitle,
          receiverFcm: userData?.fm_token ?? '',
        );
        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);
        _commonService.addNotification(
          posId: post.postid ?? '',
          isRead: false,
          body: notificationBody,
          receiverUserID: post.postedBy.uId ?? '',
          senderId: myAppUser.uId ?? '',
          title: notificationTitle,
          time: DateTime.now().toString(),
          type: "postCommented",
          userImage: isAnonymous
              ? myAppUser.gender == null
                  ? ImageAssetsUtils.anonymousUserNetworkUrl
                  : myAppUser.gender == 'male'
                      ? ImageAssetsUtils.anonymousBoyNetworkUrl
                      : myAppUser.gender == 'female'
                          ? ImageAssetsUtils.anonymousGirlNetworkUrl
                          : ImageAssetsUtils.anonymousUserNetworkUrl
              : myAppUser.profilePicture ?? "",
        );
      }

      //send to firebase
      CommentsModel commentsModel = CommentsModel(
        userId: myAppUser.uId,
        comment: newComment.comment,
        mentionedUsers: newComment.mentionedUsers,
        commentId: newComment.id,
        commentTime: newComment.createdAt,
      );
      _commonService.postComment(
        post.postid ?? "",
        commentsModel.commentId!,
        commentsModel.toMap(),
      );

      // logging new comment analytics event (comment on post)
      AnalyticsController.to.instance.logNewComment(
        communityId: post.communityId,
        commentId: newCommentId,
        postId: post.postid,
        userId: UserModel.to.uId ?? '',
      );
      notificationSendToMentioedUser(mentionedUser: mentionedUser);
    } catch (e) {
      MyLoggerServices.to.print(e.toString());
    }
  }

  void notificationSendToMentioedUser({List<Map<String, dynamic>>? mentionedUser}) {
    // mentioned user functionality
    List<String> mentionedUsersUids = [];
    if (mentionedUser != null && mentionedUser.isNotEmpty) {
      mentionedUser = mentionedUser.where((item) {
        return (item['isCommunity'] == null || item['isCommunity'] != true);
      }).toList();
      MyLoggerServices.to.print('notifired user ids:${mentionedUser.toString()}');
      mentionedUsersUids = mentionedUser.map<String>((user) {
        return user['senderUid'];
      }).toList();
    }
    if (mentionedUsersUids.isNotEmpty) {
      final PostWithCommentController postController = PostWithCommentController.to(tag: post.postid);
      postController.mentionedUsersOnPost(mentionedUsers: mentionedUsersUids.toSet().toList());
    }
  }

  //deletion of parent comment
  void deleteComment(String commentId) async {
    //delete locally.
    final comment = allComments.firstWhereOrNull((element) => element.comment.id == commentId);
    if (comment == null) return; //comment does not exist for some reason

    int totalCommentsCount = 1 + comment.replies.length;

    //update locally total comments count.
    // PostWithCommentController.to(tag: post.postid).updateTotalComments(totalCommentsCount);
    PostWithCommentController.to(tag: post.postid).updateTotalCommentsAndRemoveRecentCommentWhenDelete(totalCommentsCount, commentId);

    //removing locally
    allComments.removeWhere((element) => element.comment.id == commentId);
    //removing from db
    _commonService.deleteComment(
      postId: post.postid ?? "",
      commentId: commentId,
      totalCommentsCount: totalCommentsCount,
    );

    // Logging delete comment analytics event
    AnalyticsController.to.instance.deleteComment(
      commentId: commentId,
      postId: post.postid ?? "",
      communityId: post.community.communityId ?? '',
      userId: UserModel.to.uId ?? '',
    );

    update();
  }

  void deleteChildComment(String commentId, String childCommentId) async {
    //delete locally.
    final comment = allComments.firstWhereOrNull((element) => element.comment.id == commentId);
    if (comment == null || comment.replies.isEmpty) {
      return; //comment does not exist for some reason
    }

    int parentCommentIndex = allComments.indexOf(comment);
    if (parentCommentIndex == -1) return;

    //update locally total comments count.
    PostWithCommentController.to(tag: post.postid).updateTotalComments(1);

    //removing reply comment locally.
    allComments[parentCommentIndex].replies.removeWhere((reply) => reply.id == childCommentId);
    //removing comment from db
    _commonService.deleteChildComment(
      postId: post.postid ?? "",
      commentId: commentId,
      childCommentId: childCommentId,
    );

    // Logging delete comment reply analytics event
    AnalyticsController.to.instance.deleteCommentReply(
      commentId: commentId,
      replyCommentId: childCommentId,
      postId: post.postid ?? "",
      communityId: post.community.communityId ?? '',
      userId: UserModel.to.uId ?? '',
    );
    update();
  }

  void postNewReply({
    required String myNewComment,
    required int commentIndex,
    required Post postModel,
    List<Map<String, dynamic>>? mentionedUser,
  }) async {
    final bool isAnonymously = isPostedAnonymously;
    final newCommentId = uuid.v1();
    try {
      String parentCommentId = allComments[commentIndex].comment.id;
      final newReplyComment = CommentCustomModel(
        id: newCommentId,
        comment: myNewComment,
        user: UserModel.to,
        createdAt: DateTime.now(),
        mentionedUsers: mentionedUser,
      );

      /// score
      EngagementScoreController.to.instance
          .onComment(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: parentCommentId);

      // log new comment added analytics event
      AnalyticsController.to.instance.logNewCommentReply(
        communityId: post.communityId,
        commentId: parentCommentId,
        postId: postModel.postid,
        userId: UserModel.to.uId ?? '',
        commentReplyId: newCommentId,
      );

      if (commentsMedia != null || pdfFiles.isNotEmpty) {
        return postNewCommentReplyWithMedia(
            myNewComment: myNewComment,
            commentIndex: commentIndex,
            postModel: postModel,
            newCommentId: newCommentId,
            parentCommentId: parentCommentId,
            mentionedUsers: mentionedUser);
      }

      //add locally
      allComments[commentIndex].addReply(newReplyComment);
      update();
      //for firestore
      RepliesModel repliesModel = RepliesModel(
          userUid: newReplyComment.user.uId,
          replyId: newReplyComment.id,
          replyTime: newReplyComment.createdAt,
          reply: newReplyComment.comment,
          mentionedUsers: mentionedUser);
      _commonService.setReply(post.postid ?? "", parentCommentId, repliesModel.replyId!, repliesModel.toMap());
      UserModel? userData = await _commonService.getUserById(post.postedBy.uId, forcefullyServer: true);

      /// Send notification to post Author
      if (post.postedBy.uId != myAppUser.uId && post.postedBy.uId != allComments[commentIndex].comment.user.uId) {
        final notificationTitle = isAnonymously
            ? myAppUser.gender == null
                ? anonymousUser
                : myAppUser.gender == 'male'
                    ? anonymousBoy
                    : myAppUser.gender == 'female'
                        ? anonymousGirl
                        : anonymousUser
            : (myAppUser.name ?? "Gaya User");
        final notificationBody = '${GayaStrings.replied_to_your_post.tr} "$myNewComment"';
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent: '${GayaStrings.replied_to_your_post.tr} "$myNewComment"',
          messageTitle:
              "${isAnonymously ? newReplyComment.user.gender == null ? anonymousUser : newReplyComment.user.gender == 'male' ? anonymousBoy : newReplyComment.user.gender == 'female' ? anonymousGirl : anonymousUser : newReplyComment.user.name}",
          receiverFcm: userData?.fm_token ?? '',
        );
        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);
        _commonService.addNotification(
          posId: post.postid ?? '',
          isRead: false,
          body: notificationBody,
          title: notificationTitle,
          receiverUserID: post.postedBy.uId ?? '',
          senderId: myAppUser.uId ?? '',
          time: DateTime.now().toString(),
          type: "postCommented",
          userImage: isAnonymously
              ? myAppUser.gender == null
                  ? ImageAssetsUtils.anonymousUserNetworkUrl
                  : myAppUser.gender == 'male'
                      ? ImageAssetsUtils.anonymousBoyNetworkUrl
                      : myAppUser.gender == 'female'
                          ? ImageAssetsUtils.anonymousGirlNetworkUrl
                          : ImageAssetsUtils.anonymousUserNetworkUrl
              : myAppUser.profilePicture ?? "",
        );
      }

      /// Send Notification to comment author
      if (allComments[commentIndex].comment.user.uId != myAppUser.uId && allComments[commentIndex].comment.user.fm_token != null) {
        final notificationTitle = isAnonymously
            ? myAppUser.gender == null
                ? anonymousUser
                : myAppUser.gender == 'male'
                    ? anonymousBoy
                    : myAppUser.gender == 'female'
                        ? anonymousGirl
                        : anonymousUser
            : (myAppUser.name ?? "Gaya User");
        final notificationBody = '${GayaStrings.replied_to_your_comment.tr} "$myNewComment"';
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent: notificationBody,
          messageTitle: notificationTitle,
          receiverFcm: allComments[commentIndex].comment.user.fm_token ?? '',
        );
        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);
        log('new comment added successfully.');
        _commonService.addNotification(
          posId: post.postid ?? '',
          isRead: false,
          body: notificationBody,
          receiverUserID: allComments[commentIndex].comment.user.uId ?? '',
          senderId: myAppUser.uId ?? '',
          title: notificationTitle,
          time: DateTime.now().toString(),
          type: "postCommented",
          userImage: isAnonymously
              ? myAppUser.gender == null
                  ? ImageAssetsUtils.anonymousUserNetworkUrl
                  : myAppUser.gender == 'male'
                      ? ImageAssetsUtils.anonymousBoyNetworkUrl
                      : myAppUser.gender == 'female'
                          ? ImageAssetsUtils.anonymousGirlNetworkUrl
                          : ImageAssetsUtils.anonymousUserNetworkUrl
              : myAppUser.profilePicture ?? "",
        );
      }

      // mentioned user functionality
      notificationSendToMentioedUser(mentionedUser: mentionedUser);
    } catch (_) {}
  }

  // Like Reaction/vibe on parent Comment
  Future<void> likeReactionAComment(
      {required String commentId, required String communityId, String? reaction, bool isChecked = false}) async {
    try {
      int index = allComments.indexWhere((element) => element.comment.id == commentId);
      if (index == -1) return;

      ReactionModel reactionModel = ReactionModel(userId: UserModel.to.uId ?? '', reaction: reaction ?? 'Love');

      if (allComments[index].comment.commentReactionData == null) {
        allComments[index].comment.commentReactionData = PostReactionDataModel(
          like: reaction == 'Like' ? 1 : 0,
          inLove: reaction == 'Love' ? 1 : 0,
          sad: reaction == 'Sad' ? 1 : 0,
          angry: reaction == 'Angry' ? 1 : 0,
          surprized: reaction == 'Surprised' ? 1 : 0,
          funny: reaction == 'Funny' ? 1 : 0,
        );
        allComments[index].comment.reactionModel = reactionModel;
      } else {
        final commentModel = _helperFunc.getCommentModelOnReactionChange(reaction ?? 'Like', allComments[index].comment);
        allComments[index].comment.commentReactionData = commentModel?.commentReactionData;
        allComments[index].comment.reactionModel = reactionModel;
      }

      update();
      // logging like a post comment event
      AnalyticsController.to.instance.logLikeUnlikePostComment(
        eventType: 'like',
        commentId: commentId,
        postId: post.postid ?? "",
        communityId: communityId,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      /// score
      EngagementScoreController.to.instance.onLike(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: commentId);
      await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(post.postid)
          .collection('comments')
          .doc(commentId)
          .collection('reactions')
          .doc(myAppUser.uId)
          .set(reactionModel.toMap());
    } catch (_) {}
  }

  Future<void> unlikeReactionAComment({required String commentId, String? reaction, bool isChecked = false}) async {
    try {
      /// FIND A COMMENT
      int index = allComments.indexWhere((element) => element.comment.id == commentId);
      if (index == -1) return;
      final comment = allComments[index].comment;
      if (comment.commentReactionData != null) {
        final postReaction = PostReactionDataModel(
          like: reaction == 'Like' ? (comment.commentReactionData?.like ?? 0) - 1 : comment.commentReactionData?.like ?? 0,
          inLove: reaction == 'Love' ? (comment.commentReactionData?.inLove ?? 0) - 1 : comment.commentReactionData?.inLove ?? 0,
          sad: reaction == 'Sad' ? (comment.commentReactionData?.sad ?? 0) - 1 : comment.commentReactionData?.sad ?? 0,
          angry: reaction == 'Angry' ? (comment.commentReactionData?.angry ?? 0) - 1 : comment.commentReactionData?.angry ?? 0,
          surprized:
              reaction == 'Surprised' ? (comment.commentReactionData?.surprized ?? 0) - 1 : comment.commentReactionData?.surprized ?? 0,
          funny: reaction == 'Funny' ? (comment.commentReactionData?.funny ?? 0) - 1 : comment.commentReactionData?.funny ?? 0,
        );

        /// UPDATE COMMENT REACTION DATA
        allComments[index].comment.commentReactionData = postReaction;
      }

      /// SEND TO DB
      allComments[index].comment.reactionModel = null;
      update();
      EngagementScoreController.to.instance.onDislike(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: commentId);
      await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(post.postid)
          .collection('comments')
          .doc(commentId)
          .collection('reactions')
          .doc(myAppUser.uId)
          .delete();
      // logging unlike a post comment event
      AnalyticsController.to.instance.logLikeUnlikePostComment(
        eventType: 'unlike',
        commentId: commentId,
        postId: post.postid ?? "",
        communityId: post.communityId ?? "",
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
    } catch (_) {
      debugPrint("Error occured at unlikeReactionAComment() $_");
    }
  }

  /// Crown A Comment with Notification
  Future<void> crownAComment({
    required String commentId,
    UserModel? receiverUser,
    String? communityId,
  }) async {
    final isAnonymous = isPostedAnonymously;
    if (post.postid == null || receiverUser?.uId == null || myAppUser.uId == null || receiverUser?.uId == myAppUser.uId) return;
    int index = allComments.indexWhere((element) => element.comment.id == commentId);
    if (index == -1) return;
    final comment = allComments[index].comment;
    allComments[index].comment = allComments[index].comment.copyWithFlower();
    // update user daily crowns
    final tempCrownCount = myAppUser.userDailyCrowns;

    myAppUser.userDailyCrowns = (myAppUser.userDailyCrowns != null) ? myAppUser.userDailyCrowns! - 1 : myAppUser.userDailyCrowns;
    CacheController.to.updateUser(userModel);
    update();

    // log crown comment analytics event
    AnalyticsController.to.instance.logCrownPostComment(
      userId: UserModel.to.uId ?? '',
      communityId: communityId ?? '',
      commentId: commentId,
      postId: post.postid ?? '',
    );

    final isCrownedSuccesfully = await crownACommentCloudFunction(
      postId: post.postid!,
      commentId: commentId,
      receiverId: receiverUser!.uId!,
      currentUserId: myAppUser.uId!,
      communityId: communityId,
    );

    if (isCrownedSuccesfully) {
      _updateHomeWidgetTotalCount();
      if (receiverUser != null) {
        _commonService.increaseInfluencePointOnCrownReward(receiverUser.uId);
      }

      /// score
      EngagementScoreController.to.instance.onCrown(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: commentId);
      //send notification
      if (comment.user.uId != userModel.uId) {
        UserModel? userData = await _commonService.getUserById(comment.user.uId, forcefullyServer: true);

        //fcm
        final notificationTitle = GayaStrings.your_comment_was_crowned_checkout.tr;
        final notificationBody =
            "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name} ${GayaStrings.dash_has_crowned_comment.tr}";
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent: notificationBody,
          messageTitle: notificationTitle,
          receiverFcm: userData?.fm_token ?? '',
        );

        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

        //store notification
        _commonService.addNotification(
          posId: post.postid,
          isRead: false,
          body: notificationBody,
          receiverUserID: comment.user.uId!,
          senderId: UserModel.to.uId!,
          title: notificationTitle,
          time: DateTime.now().toString(),
          type: "postCrowned",
          userImage: isAnonymous
              ? myAppUser.gender == null
                  ? ImageAssetsUtils.anonymousUserNetworkUrl
                  : myAppUser.gender == 'male'
                      ? ImageAssetsUtils.anonymousBoyNetworkUrl
                      : myAppUser.gender == 'female'
                          ? ImageAssetsUtils.anonymousGirlNetworkUrl
                          : ImageAssetsUtils.anonymousUserNetworkUrl
              : UserModel.to.profilePicture ?? '',
        );
      }
    } else {
      // update user daily crowns
      myAppUser.userDailyCrowns = tempCrownCount;
      CacheController.to.updateUser(userModel);
      allComments[index].comment = allComments[index].comment.copyWithFlower(shouldUnCrown: true);
      update();
    }
  }

  _updateHomeWidgetTotalCount() {
    final CrownsController crownsController = Get.find();

    if (myAppUser.userDailyCrowns == 0) {
      crownsController.getCrownServerTimeStamp();
    } else {
      crownsController.updateCurrentUser();
    }
  }

  /// Crown A Comment Reply with Notification
  Future<void> crownAReplyComment({
    required String commentId,
    required String replyCommentId,
    UserModel? receiverUser,
    String? communityId,
  }) async {
    final isAnonymous = isPostedAnonymously;
    if (post.postid == null || receiverUser?.uId == null || myAppUser.uId == null || receiverUser?.uId == myAppUser.uId) return;
    // find parent comment Id index
    int index = allComments.indexWhere((element) => element.comment.id == commentId);
    if (index == -1) return;
    final replies = allComments[index].replies;
    // find reply comment index
    final replyCommentIndex = replies.indexWhere((element) => element.id == replyCommentId);
    allComments[index].replies[replyCommentIndex] = allComments[index].replies[replyCommentIndex].copyWithFlower();
    final reply = allComments[index].replies[replyCommentIndex];
    final tempCrownCount = myAppUser.userDailyCrowns;

    myAppUser.userDailyCrowns = (myAppUser.userDailyCrowns != null) ? myAppUser.userDailyCrowns! - 1 : myAppUser.userDailyCrowns;
    CacheController.to.updateUser(userModel);

    update();

    // log crown comment reply analytics event
    AnalyticsController.to.instance.logCrownPostCommentReply(
      commentId: commentId,
      commentReplyId: replyCommentId,
      postId: post.postid ?? '',
      userId: UserModel.to.uId ?? '',
      communityId: communityId ?? '',
    );

    final isCrownedSuccessfully = await crownAReplyCommentCloudFunction(
      postId: post.postid!,
      commentId: commentId,
      receiverId: receiverUser!.uId!,
      currentUserId: myAppUser.uId!,
      replyId: replyCommentId,
      communityId: communityId,
    );

    if (isCrownedSuccessfully) {
      if (receiverUser != null) {
        _commonService.increaseInfluencePointOnCrownReward(receiverUser.uId);
      }

      /// score
      EngagementScoreController.to.instance.onCrown(
        communityId: post.communityId ?? "",
        postId: post.postid ?? "",
        commentId: commentId,
        replyId: replyCommentId,
      );
      _updateHomeWidgetTotalCount();
      //send notification
      if (reply.user.uId != userModel.uId) {
        UserModel? userData = await _commonService.getUserById(reply.user.uId, forcefullyServer: true);
        final notificationTitle = GayaStrings.your_comment_was_crowned_checkout.tr;
        final notificationBody =
            "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name} ${GayaStrings.dash_has_crowned_comment.tr}";
        //fcm
        log('comment crowned: ${reply.user.uId}');
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent: notificationBody,
          messageTitle: notificationTitle,
          receiverFcm: userData?.fm_token ?? '',
        );

        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

        //store notification
        _commonService.addNotification(
          posId: post.postid,
          isRead: false,
          body:
              "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name} ${GayaStrings.dash_has_crowned_comment.tr}",
          receiverUserID: reply.user.uId!,
          senderId: UserModel.to.uId!,
          title: GayaStrings.your_comment_was_crowned_checkout.tr,
          time: DateTime.now().toString(),
          type: "postCrowned",
          userImage: isAnonymous
              ? myAppUser.gender == null
                  ? ImageAssetsUtils.anonymousUserNetworkUrl
                  : myAppUser.gender == 'male'
                      ? ImageAssetsUtils.anonymousBoyNetworkUrl
                      : myAppUser.gender == 'female'
                          ? ImageAssetsUtils.anonymousGirlNetworkUrl
                          : ImageAssetsUtils.anonymousUserNetworkUrl
              : UserModel.to.profilePicture ?? '',
        );
      }
    } else {
      // update user daily crowns
      myAppUser.userDailyCrowns = tempCrownCount;
      CacheController.to.updateUser(userModel);
      allComments[index].replies[replyCommentIndex] = allComments[index].replies[replyCommentIndex].copyWithFlower(shouldUnCrown: true);
      update();
    }
  }

  UserModel userModel = UserModel.to;
  CrownServices crownServices = CrownServices();

  /// this function is used to crown on comment on cloud
  Future<bool> crownACommentCloudFunction({
    required String postId,
    required String commentId,
    required String receiverId,
    required String currentUserId,
    String? communityId,
  }) async {
    final commentCrownPayload = CrownPayload(
      postId: postId,
      commentId: commentId,
      senderId: currentUserId,
      receiverId: receiverId,
    );

    return await crownServices.crownOnComment(payload: commentCrownPayload);
  }

  /// this function is used to crown on comment on cloud
  Future<bool> crownAReplyCommentCloudFunction({
    required String postId,
    required String commentId,
    required String receiverId,
    required String currentUserId,
    required String replyId,
    String? communityId,
  }) async {
    final commentCrownPayload = CrownPayload(
      postId: postId,
      commentId: commentId,
      senderId: currentUserId,
      receiverId: receiverId,
      replyId: replyId,
    );

    return await crownServices.crownOnCommentReply(payload: commentCrownPayload);
  }

/*
  // Future<void> likeACommentReply({
  //   required String commentId,
  //   required String replyId,
  //   required String? communityId,
  // }) async {
  //   // print("postId ${this.post.postid}");
  //   int index = allComments.indexWhere((element) => element.comment.id == commentId);
  //   if (index == -1) return;
  //   int replyIndex = allComments[index].replies.indexWhere((element) => element.id == replyId);
  //   if (replyIndex == -1) return;
  //   allComments[index].replies[replyIndex] = allComments[index].replies[replyIndex].copyWithLike();
  //   // print("likeACommentReply ${allComments[index].replies[replyIndex].totalLikes}");
  //   update();
  //   AnalyticsController.to.instance.logAddToLike(
  //     "likeACommentReply",
  //     "commentId: $commentId, replyId: $replyId",
  //     communityId: communityId,
  //   );
  //   LikeCommentModel likeCommentModel = LikeCommentModel(userUid: myAppUser.uId, likeCommentId: myAppUser.uId);
  //   /// score
  //   EngagementScoreController.to.instance
  //       .onLike(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: commentId, replyId: replyId);
  //   await FirebaseFirestore.instance
  //       .collection('communityposts')
  //       .doc(post.postid)
  //       .collection('comments')
  //       .doc(commentId)
  //       .collection('replies')
  //       .doc(replyId)
  //       .collection('likeOnComment')
  //       .doc(myAppUser.uId)
  //       .set(likeCommentModel.toMap());
  //   // print("likeACommentReply done");
  // }
  // Future<void> unlikeACommentReply({
  //   required String commentId,
  //   required String replyId,
  //   required String communityId,
  // }) async {
  //   int index = allComments.indexWhere((element) => element.comment.id == commentId);
  //   if (index == -1) return;
  //   int replyIndex = allComments[index].replies.indexWhere((element) => element.id == replyId);
  //   if (replyIndex == -1) return;
  //   allComments[index].replies[replyIndex] = allComments[index].replies[replyIndex].copyWithLike(shouldUnlike: true);
  //   update();
  //   AnalyticsController.to.instance.logAddToLike(
  //     "commentReply",
  //     "commentId: $commentId, replyId: $replyId",
  //     communityId: communityId,
  //   );
  //   /// score
  //   EngagementScoreController.to.instance
  //       .onDislike(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: commentId, replyId: replyId);
  //   await FirebaseFirestore.instance
  //       .collection('communityposts')
  //       .doc(post.postid)
  //       .collection('comments')
  //       .doc(commentId)
  //       .collection('replies')
  //       .doc(replyId)
  //       .collection('likeOnComment')
  //       .doc(myAppUser.uId)
  //       .delete();
  //   // print("unlike comment done");
  // }

*/
  // like reaction/vibe on child/reply comment
  Future<void> likeReactionACommentReply(
      {required String commentId, required String replyId, required String? communityId, String? reaction, bool isChecked = false}) async {
    // print("postId ${this.post.postid}");
    int index = allComments.indexWhere((element) => element.comment.id == commentId);
    if (index == -1) return;
    int replyIndex = allComments[index].replies.indexWhere((element) => element.id == replyId);
    if (replyIndex == -1) return;

    ReactionModel reactionModel = ReactionModel(userId: UserModel.to.uId ?? '', reaction: reaction ?? 'Like');

    if (allComments[index].replies[replyIndex].commentReactionData == null) {
      allComments[index].replies[replyIndex].commentReactionData = PostReactionDataModel(
        like: reaction == 'Like' ? 1 : 0,
        inLove: reaction == 'Love' ? 1 : 0,
        sad: reaction == 'Sad' ? 1 : 0,
        angry: reaction == 'Angry' ? 1 : 0,
        surprized: reaction == 'Surprised' ? 1 : 0,
        funny: reaction == 'Funny' ? 1 : 0,
      );
      allComments[index].replies[replyIndex].reactionModel = reactionModel;
    } else {
      final commentModel = _helperFunc.getCommentModelOnReactionChange(reaction ?? 'Like', allComments[index].replies[replyIndex]);
      allComments[index].replies[replyIndex].commentReactionData = commentModel?.commentReactionData;
      allComments[index].replies[replyIndex].reactionModel = reactionModel;
    }

    // allComments[index].replies[replyIndex] = allComments[index].replies[replyIndex].copyWithLike();
    // print("likeACommentReply ${allComments[index].replies[replyIndex].totalLikes}");
    update();
    // logging like a post comment reply event
    AnalyticsController.to.instance.logLikeUnlikePostCommentReply(
      eventType: 'like',
      commentId: commentId,
      postId: post.postid ?? "",
      repliedCommentId: replyId,
      communityId: communityId,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    // LikeCommentModel likeCommentModel = LikeCommentModel(userUid: myAppUser.uId, likeCommentId: myAppUser.uId);

    /// score
    EngagementScoreController.to.instance
        .onLike(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: commentId, replyId: replyId);

    await FirebaseFirestore.instance
        .collection('communityposts')
        .doc(post.postid)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId)
        .collection('reactions')
        .doc(myAppUser.uId)
        .set(reactionModel.toMap());
    // print("likeACommentReply done");
  }

  // unlike reaction/vibe on child/reply comment
  Future<void> unlikeReactionACommentReply(
      {required String commentId, required String replyId, required String communityId, String? reaction, bool isChecked = false}) async {
    try {
      int index = allComments.indexWhere((element) => element.comment.id == commentId);
      if (index == -1) return;
      int replyIndex = allComments[index].replies.indexWhere((element) => element.id == replyId);
      if (replyIndex == -1) return;

      if (allComments[index].replies[replyIndex].commentReactionData != null) {
        allComments[index].replies[replyIndex].commentReactionData = PostReactionDataModel(
          like: reaction == 'Like'
              ? (((allComments[index].replies[replyIndex].commentReactionData?.like == null ||
                          allComments[index].replies[replyIndex].commentReactionData?.like == 0)
                      ? 1
                      : allComments[index].replies[replyIndex].commentReactionData!.like) -
                  1)
              : allComments[index].replies[replyIndex].commentReactionData?.like ?? 0,
          inLove: reaction == 'Love'
              ? (((allComments[index].replies[replyIndex].commentReactionData?.inLove == null ||
                          allComments[index].replies[replyIndex].commentReactionData?.inLove == 0)
                      ? 1
                      : allComments[index].replies[replyIndex].commentReactionData!.inLove) -
                  1)
              : allComments[index].replies[replyIndex].commentReactionData?.inLove ?? 0,
          sad: reaction == 'Sad'
              ? (((allComments[index].replies[replyIndex].commentReactionData?.sad == null ||
                          allComments[index].replies[replyIndex].commentReactionData?.sad == 0)
                      ? 1
                      : allComments[index].replies[replyIndex].commentReactionData!.sad) -
                  1)
              : allComments[index].replies[replyIndex].commentReactionData?.sad ?? 0,
          angry: reaction == 'Angry'
              ? (((allComments[index].replies[replyIndex].commentReactionData?.angry == null ||
                          allComments[index].replies[replyIndex].commentReactionData?.angry == 0)
                      ? 1
                      : allComments[index].replies[replyIndex].commentReactionData!.angry) -
                  1)
              : allComments[index].replies[replyIndex].commentReactionData?.angry ?? 0,
          surprized: reaction == 'Surprised'
              ? (((allComments[index].replies[replyIndex].commentReactionData?.surprized == null ||
                          allComments[index].replies[replyIndex].commentReactionData?.surprized == 0)
                      ? 1
                      : allComments[index].replies[replyIndex].commentReactionData!.surprized) -
                  1)
              : allComments[index].replies[replyIndex].commentReactionData?.surprized ?? 0,
          funny: reaction == 'Funny'
              ? (((allComments[index].replies[replyIndex].commentReactionData?.funny == null ||
                          allComments[index].replies[replyIndex].commentReactionData?.funny == 0)
                      ? 1
                      : allComments[index].replies[replyIndex].commentReactionData!.funny) -
                  1)
              : allComments[index].replies[replyIndex].commentReactionData?.funny ?? 0,
        );
      }
      allComments[index].replies[replyIndex].reactionModel = null;

      // allComments[index].replies[replyIndex] = allComments[index].replies[replyIndex].copyWithLike(shouldUnlike: true);

      update();
      // AnalyticsController.to.instance.logAddToLike(
      //   "commentReply",
      //   "commentId: $commentId, replyId: $replyId",
      //   communityId: communityId,
      // );
      // logging like a post comment reply event
      AnalyticsController.to.instance.logLikeUnlikePostCommentReply(
        eventType: 'like',
        commentId: commentId,
        postId: post.postid ?? "",
        repliedCommentId: replyId,
        communityId: communityId,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      /// score
      EngagementScoreController.to.instance
          .onDislike(communityId: post.communityId ?? "", postId: post.postid ?? "", commentId: commentId, replyId: replyId);
      await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(post.postid)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .collection('reactions')
          .doc(myAppUser.uId)
          .delete();
    } catch (_) {}
    // print("unlike comment done");
  }

  bool get isPostedAnonymously {
    final _post = PostWithCommentController.to(tag: post.postid).post;
    return (_post.isPostedAnonymously == true && _post.postedBy.uId == myAppUser.uId);
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    update();
  }

  Future<void> postNewCommentWithMedia({
    required String newCommentId,
    required String myNewComment,
    List<Map<String, dynamic>>? mentionedUsers,
  }) async {
    CommentCustomModel newComment = CommentCustomModel(
        id: newCommentId,
        comment: myNewComment,
        user: UserModel.to,
        createdAt: DateTime.now(),
        videoFile: isVideo ? commentsMedia : null,
        photoFile: isVideo
            ? null
            : isPdf
                ? null
                : commentsMedia,
        mediaSource: commentsMedia != null ? MediaSource.local : MediaSource.idle,
        mentionedUsers: mentionedUsers,
        documentFile: pdfFiles.isNotEmpty ? pdfFiles.first : null,
        pdfFiles: []);

    if (isVideo) {
      String? thumbnailUrl;
      service.uploadVideo(file: commentsMedia!).then((url) async {
        if (url == null) return;

        /// once media is uploaded, update the comment with real url
        File? thumbnailFile = await service.getThumbnailFromVideoUrl(videoUrl: url);
        if (thumbnailFile != null) {
          thumbnailUrl = await service.uploadPhoto(file: thumbnailFile);
        }
        Map<String, dynamic>? videoData = {};
        videoData['thumbnailUrl'] = thumbnailUrl;
        videoData['videoUrl'] = url;
        _updateNewCommentLocally(videoData: videoData, commentId: newCommentId, isVideo: true, mentionedUsers: mentionedUsers);
        newComment.copyWith(videoUrl: videoData);
        sendCommentToFirebase(newComment: newComment, videoUrl: videoData);
      });
      // video thumbnail
    } else if (isPdf && pdfFiles.isNotEmpty) {
      String? thumbnailUrl;
      service.uploadDocument(file: pdfFiles.first).then((url) async {
        if (url == null) return;

        File? thumbnailFile = await generateThumbnailFile(url: pdfFiles.first.path);
        if (thumbnailFile != null) {
          // ignore: use_build_context_synchronously
          thumbnailUrl = await service.uploadDocumentThumbnail(file: thumbnailFile);
        }

        List<Map<String, dynamic>> documentFiles = [];
        if (thumbnailUrl != null) {
          documentFiles = [];
          documentFiles.add({
            'title': documentTextField.text.isEmpty ? '' : documentTextField.text.trim(),
            'fileUrl': url,
            'fileName': pdfFiles.first.path.split("/").last,
            'thumbnail': thumbnailUrl
          });
        }
        MyLoggerServices.to.print('allcommentslength is: ${allComments.length}');
        _updateNewCommentLocally(
            videoData: {},
            commentId: newCommentId,
            isVideo: false,
            isPdf: true,
            mentionedUsers: mentionedUsers,
            documentFiles: documentFiles);
        newComment = newComment.copyWith(pdfFiles: documentFiles, documentFile: null);
        sendCommentToFirebase(newComment: newComment, documentFiles: documentFiles);
        pdfFiles = [];
        documentFiles = [];
      });
    } else {
      service.uploadPhoto(file: commentsMedia!).then((url) {
        if (url == null) return;

        /// once media is uploaded, update the comment with real url
        _updateNewCommentLocally(videoData: {}, commentId: newCommentId, isVideo: false, photoUrl: url, mentionedUsers: mentionedUsers);
        sendCommentToFirebase(newComment: newComment, photoUrl: url);
      });
    }
    // allComments.insert(0, MultiCommentModel(comment: newComment, replies: []));
    if (service.hasMoreComments == false) {
      allComments.add(MultiCommentModel(comment: newComment, replies: []));
    }
    MyLoggerServices.to.print('allcommentslength is after: ${allComments.length}');

    notificationSendToMentioedUser(mentionedUser: mentionedUsers);
    commentsMedia = null;
    isPdf = false;
    pdfThumbnail = null;
    // pdfFiles = [];
    isVideo = false;
    setLoading(false);
  }

  Future<File?> generateThumbnailFile({required String url}) async {
    CacheServices cacheService = CacheServices();
    return await cacheService.generateThumbnailFile(url: url);
  }

  Future<void> generateLocalPdfThumbnail({required String url}) async {
    CacheServices cacheService = CacheServices();
    pdfThumbnail = await cacheService.generatelocalPdfThumbnail(url: url);
    setLoading(false);
  }

  Future<String> downloadAndCachePdf({required String url}) async {
    CacheServices cacheService = CacheServices();

    return await cacheService.downloadAndCachePdf(url: url);
  }

  _updateNewCommentLocally({
    required Map<String, dynamic> videoData,
    required String commentId,
    bool isVideo = false,
    bool isPdf = false,
    String? replyId,
    String? photoUrl,
    List<Map<String, dynamic>>? mentionedUsers,
    List<Map<String, dynamic>>? documentFiles,
  }) {
    /// if replyId is not null, then it is a reply
    if (replyId != null) {
      final commentIndex = allComments.indexWhere((element) => element.comment.id == commentId);
      if (commentIndex == -1) {
        return;
      }
      final replyIndex = allComments[commentIndex].replies.indexWhere((element) => element.id == replyId);
      if (replyIndex == -1) {
        //reply does not exist for some reason
        debugPrint("reply[commentIndex] comment doesnt exist....");
        return;
      }
      debugPrint("dataasdasd: $photoUrl");
      if (isVideo) {
        allComments[commentIndex].replies[replyIndex] = allComments[commentIndex]
            .replies[replyIndex]
            .copyWith(videoUrl: videoData, mediaSource: MediaSource.network, mentionedUsers: mentionedUsers);
      } else if (isPdf) {
        try {
          allComments[commentIndex].replies[replyIndex] = allComments[commentIndex]
              .replies[replyIndex]
              .copyWith(pdfFiles: documentFiles, mediaSource: MediaSource.network, mentionedUsers: mentionedUsers);
          debugPrint(
              "pdf files length in func: (_updateNewCommentLocally) : ${allComments[commentIndex].replies[replyIndex].pdfFiles?.length}");
        } catch (_) {
          debugPrint("_ $_");
        }
      } else {
        try {
          allComments[commentIndex].replies[replyIndex] = allComments[commentIndex]
              .replies[replyIndex]
              .copyWith(photoUrl: photoUrl, mediaSource: MediaSource.network, mentionedUsers: mentionedUsers);
          debugPrint("daadada : ${allComments[commentIndex].replies[replyIndex].photoUrl}");
        } catch (_) {
          debugPrint("_ $_");
        }
      }
      update();
      return;
    }

    /// if [replyId] is null, then it is a parent comment
    MyLoggerServices.to.print('commentId is: $commentId');
    final comment = allComments.firstWhereOrNull((element) => element.comment.id == commentId);
    if (comment == null) return; //comment does not exist for some reason
    if (isVideo) {
      comment.comment = comment.comment.copyWith(videoUrl: videoData, mediaSource: MediaSource.network);
    } else if (isPdf) {
      comment.comment = comment.comment.copyWith(pdfFiles: documentFiles, mediaSource: MediaSource.network);
    } else {
      comment.comment = comment.comment.copyWith(photoUrl: photoUrl, mediaSource: MediaSource.network);
    }
    update();
  }

  /// Post new comment [Firebase Firestore]
  Future<void> sendCommentToFirebase({
    required CommentCustomModel newComment,
    Map<String, dynamic>? videoUrl,
    String? photoUrl,
    List<Map<String, dynamic>>? documentFiles,
  }) async {
    final isAnonymous = isPostedAnonymously;
    UserModel? userData = await _commonService.getUserById(post.postedBy.uId, forcefullyServer: true);
    if (post.postedBy.uId != myAppUser.uId) {
      final notificationTitle = GayaStrings.new_comment.tr;
      final notificationBody =
          "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name} ${GayaStrings.dash_commented_on_your_post.tr}";
      final fcmPostModel = FcmCreatePostModel(
        postid: post.postid ?? '',
        communityId: post.communityId ?? '',
        messageContent:
            "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name} ${GayaStrings.dash_commented_on_your_post.tr}",
        messageTitle: GayaStrings.new_comment.tr,
        receiverFcm: userData?.fm_token ?? '',
      );
      _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);
      _commonService.addNotification(
        posId: post.postid ?? '',
        isRead: false,
        body: notificationBody,
        receiverUserID: post.postedBy.uId ?? '',
        senderId: myAppUser.uId ?? '',
        title: notificationTitle,
        time: DateTime.now().toString(),
        type: "postCommented",
        userImage: isAnonymous
            ? myAppUser.gender == null
                ? ImageAssetsUtils.anonymousUserNetworkUrl
                : myAppUser.gender == 'male'
                    ? ImageAssetsUtils.anonymousBoyNetworkUrl
                    : myAppUser.gender == 'female'
                        ? ImageAssetsUtils.anonymousGirlNetworkUrl
                        : ImageAssetsUtils.anonymousUserNetworkUrl
            : myAppUser.profilePicture ?? "",
      );
    }

    CommentsModel commentsModel = CommentsModel(
        userId: myAppUser.uId,
        photoUrl: photoUrl,
        videoUrl: videoUrl,
        comment: newComment.comment,
        commentId: newComment.id,
        mentionedUsers: newComment.mentionedUsers,
        commentTime: newComment.createdAt,
        pdfFiles: documentFiles);
    _commonService.postComment(post.postid ?? "", commentsModel.commentId!, commentsModel.toMap());
  }

  Future<void> sendCommentReplyToFirebase(
      {required CommentCustomModel newReplyComment,
      Map<String, dynamic>? videoUrl,
      String? photoUrl,
      required String parentCommentId,
      required int commentIndex,
      List<Map<String, dynamic>>? documentFiles}) async {
    final isAnonymously = isPostedAnonymously;
    //for firestore
    RepliesModel repliesModel = RepliesModel(
        userUid: newReplyComment.user.uId,
        replyId: newReplyComment.id,
        replyTime: newReplyComment.createdAt,
        photoUrl: photoUrl,
        videoUrl: videoUrl,
        mentionedUsers: newReplyComment.mentionedUsers,
        reply: newReplyComment.comment,
        pdfFiles: documentFiles);
    _commonService.setReply(
      post.postid ?? "",
      parentCommentId,
      repliesModel.replyId!,
      repliesModel.toMap(),
    );
    UserModel? userData = await _commonService.getUserById(post.postedBy.uId, forcefullyServer: true);

    /// Notify Author of post
    if (post.postedBy.uId != myAppUser.uId && post.postedBy.uId != allComments[commentIndex].comment.user.uId) {
      final notificationTitle = GayaStrings.new_comment.tr;
      final notificationBody =
          "${isAnonymously ? newReplyComment.user.gender == null ? anonymousUser : newReplyComment.user.gender == 'male' ? anonymousBoy : newReplyComment.user.gender == 'female' ? anonymousGirl : anonymousUser : newReplyComment.user.name} ${GayaStrings.replied_to_your_post.tr}";
      final fcmPostModel = FcmCreatePostModel(
        postid: post.postid ?? '',
        communityId: post.communityId ?? '',
        messageContent: notificationBody,
        messageTitle: notificationTitle,
        receiverFcm: userData?.fm_token ?? '',
      );
      _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

      _commonService.addNotification(
        posId: post.postid ?? '',
        isRead: false,
        body: notificationBody,
        receiverUserID: post.postedBy.uId ?? '',
        senderId: myAppUser.uId ?? '',
        title: notificationTitle,
        time: DateTime.now().toString(),
        type: "postCommented",
        userImage: isAnonymously
            ? myAppUser.gender == null
                ? ImageAssetsUtils.anonymousUserNetworkUrl
                : myAppUser.gender == 'male'
                    ? ImageAssetsUtils.anonymousBoyNetworkUrl
                    : myAppUser.gender == 'female'
                        ? ImageAssetsUtils.anonymousGirlNetworkUrl
                        : ImageAssetsUtils.anonymousUserNetworkUrl
            : myAppUser.profilePicture ?? "",
      );
    }

    ///Notify comment author
    if (allComments[commentIndex].comment.user.uId != myAppUser.uId && allComments[commentIndex].comment.user.fm_token != null) {
      final notificationTitle = isAnonymously
          ? myAppUser.gender == null
              ? anonymousUser
              : myAppUser.gender == 'male'
                  ? anonymousBoy
                  : myAppUser.gender == 'female'
                      ? anonymousGirl
                      : anonymousUser
          : (myAppUser.name ?? "Gaya User");
      final notificationBody = GayaStrings.replied_to_your_comment.tr;
      final fcmPostModel = FcmCreatePostModel(
        postid: post.postid ?? '',
        communityId: post.communityId ?? '',
        messageContent: notificationBody,
        messageTitle: notificationTitle,
        receiverFcm: allComments[commentIndex].comment.user.fm_token ?? '',
      );

      _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);
      log('new comment added successfully.');

      _commonService.addNotification(
        posId: post.postid ?? '',
        isRead: false,
        body: notificationBody,
        receiverUserID: allComments[commentIndex].comment.user.uId ?? '',
        senderId: myAppUser.uId ?? '',
        title: notificationTitle,
        time: DateTime.now().toString(),
        type: "postCommented",
        userImage: isAnonymously
            ? myAppUser.gender == null
                ? ImageAssetsUtils.anonymousUserNetworkUrl
                : myAppUser.gender == 'male'
                    ? ImageAssetsUtils.anonymousBoyNetworkUrl
                    : myAppUser.gender == 'female'
                        ? ImageAssetsUtils.anonymousGirlNetworkUrl
                        : ImageAssetsUtils.anonymousUserNetworkUrl
            : myAppUser.profilePicture ?? "",
      );
    }
  }

  Future<void> postNewCommentReplyWithMedia(
      {required String myNewComment,
      required int commentIndex,
      required Post postModel,
      required String newCommentId,
      required String parentCommentId,
      List<Map<String, dynamic>>? mentionedUsers}) async {
    CommentCustomModel newReplyComment = CommentCustomModel(
        id: newCommentId,
        comment: myNewComment,
        user: UserModel.to,
        createdAt: DateTime.now(),
        videoFile: isVideo ? commentsMedia : null,
        // photoFile: !isVideo ? commentsMedia : null,
        photoFile: isVideo
            ? null
            : isPdf
                ? null
                : commentsMedia,
        mediaSource: commentsMedia != null ? MediaSource.local : MediaSource.idle,
        mentionedUsers: mentionedUsers,
        documentFile: pdfFiles.isNotEmpty ? pdfFiles.first : null,
        pdfFiles: []);

    String? thumbnailUrl;
    Map<String, dynamic>? videoData = {};
    if (commentsMedia != null || pdfFiles.isNotEmpty) {
      if (isVideo) {
        service.uploadVideo(file: commentsMedia!).then((videoUrl) async {
          if (videoUrl != null) {
            File? thumbnailFile = await service.getThumbnailFromVideoUrl(videoUrl: videoUrl);
            if (thumbnailFile != null) {
              thumbnailUrl = await service.uploadVideo(file: thumbnailFile);
            }
            videoData['videoUrl'] = videoUrl;
            videoData['thumbnailUrl'] = thumbnailUrl;
            _updateNewCommentLocally(
                videoData: videoData,
                commentId: parentCommentId,
                isVideo: true,
                photoUrl: null,
                replyId: newCommentId,
                mentionedUsers: mentionedUsers);
            newReplyComment.copyWith(videoUrl: videoData, photoUrl: null);
            sendCommentReplyToFirebase(
                newReplyComment: newReplyComment, parentCommentId: parentCommentId, commentIndex: commentIndex, videoUrl: videoData);
            setLoading(false);
          }
        });
      } else if (isPdf && pdfFiles.isNotEmpty) {
        String? thumbnailUrl;
        service.uploadDocument(file: pdfFiles.first).then((url) async {
          if (url == null) return;

          File? thumbnailFile = await generateThumbnailFile(url: pdfFiles.first.path);
          if (thumbnailFile != null) {
            // ignore: use_build_context_synchronously
            thumbnailUrl = await service.uploadDocumentThumbnail(file: thumbnailFile);
          }

          List<Map<String, dynamic>> documentFiles = [];
          if (thumbnailUrl != null) {
            documentFiles = [];
            documentFiles.add({
              'title': documentTextField.text.isEmpty ? '' : documentTextField.text.trim(),
              'fileUrl': url,
              'fileName': pdfFiles.first.path.split("/").last,
              'thumbnail': thumbnailUrl
            });
          }
          MyLoggerServices.to.print('allcommentslength is: ${allComments.length}');
          newReplyComment = newReplyComment.copyWith(pdfFiles: documentFiles, documentFile: null);

          _updateNewCommentLocally(
              videoData: {},
              commentId: parentCommentId,
              isVideo: false,
              isPdf: true,
              photoUrl: url,
              replyId: newCommentId,
              mentionedUsers: mentionedUsers,
              documentFiles: documentFiles);

          sendCommentReplyToFirebase(
              newReplyComment: newReplyComment, parentCommentId: parentCommentId, commentIndex: commentIndex, documentFiles: documentFiles);

          // _updateNewCommentLocally(
          //     videoData: {},
          //     commentId: newCommentId,
          //     isVideo: false,
          //     isPdf: true,
          //     mentionedUsers: mentionedUsers,
          //     documentFiles: documentFiles);
          // newReplyComment = newReplyComment.copyWith(pdfFiles: documentFiles, documentFile: null);
          // sendCommentReplyToFirebase(newComment: newReplyComment, documentFiles: documentFiles);
          pdfFiles = [];
          documentFiles = [];
        });
      } else {
        service.uploadPhoto(file: commentsMedia!).then((url) {
          newReplyComment.copyWith(videoUrl: null, photoUrl: url);
          _updateNewCommentLocally(
              videoData: {},
              commentId: parentCommentId,
              isVideo: false,
              photoUrl: url,
              replyId: newCommentId,
              mentionedUsers: mentionedUsers);

          sendCommentReplyToFirebase(
              newReplyComment: newReplyComment, parentCommentId: parentCommentId, commentIndex: commentIndex, photoUrl: url);
        });
      }
    }
    allComments[commentIndex].addReply(newReplyComment);
    notificationSendToMentioedUser(mentionedUser: mentionedUsers);
    commentsMedia = null;
    isPdf = false;
    pdfThumbnail = null;
    setLoading(false);
  }

  // done by mak

  // by mak => picking image from gallerey with proper permission handling etc
  final MediaService _mediaService = MediaService();

  Future<void> pickPhoto({required BuildContext context, int imageQuality = 50}) async {
    try {
      isVideo = false;
      List<XFile>? file = await _mediaService.pickImageFromGallery(context: context, imageQuality: imageQuality);
      if (file != null && file.isNotEmpty) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        commentsMedia = File(file.last.path);
        List<File> files = await Routes.cropPhotoView(imageFile: <File>[commentsMedia!]);
        if (files.isNotEmpty) {
          commentsMedia = files.first;
        }
      }
      update();
    } on PlatformException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  // by mak => picking video from gallerey with proper permission handling etc
  Future<void> pickVideo({required BuildContext context, int imageQuality = 50}) async {
    try {
      isVideo = true;
      XFile? file = await _mediaService.pickVideoFromGallery(context: context);
      if (file != null) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'video',
          userId: UserModel.to.uId ?? '',
        );

        commentsMedia = File(file.path);
        commentsMedia = await Routes.cropVideoView(video: commentsMedia!);
      }
      update();
    } on PlatformException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  final MediaService filePickerService = MediaService();

  //GET THE Document FROM STORAGE
  Future getPdfDocument(BuildContext context) async {
    try {
      documentTextField.clear();
      pdfFiles = [];
      commentsMedia = null;

      isPdf = true;
      final File? document = await filePickerService.pickFile(context: context);
      if (document != null) {
        pdfFiles.add(document);
      } else {
        MyLoggerServices.to.print('No Document picked');
      }
      update();
      return document;
    } catch (e) {
      debugPrint('error during document picking!: ${e.toString()}');
      return null;
    }
  }

  void removeSelectedCommentsMedia() {
    try {
      documentTextField.clear();
      commentsMedia = null;
      pdfFiles = [];
      pdfThumbnail = null;
      isPdf = false;

      update();
    } catch (e) {
      log(e.toString());
    }
  }
}
