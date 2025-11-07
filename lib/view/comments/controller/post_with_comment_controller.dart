import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaya/controller/cache_controller.dart';
import 'package:gaya/controller/crowns_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/shared/service/crown_service/crown_services.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/comments/controller/comments_controller.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/community/controllers/community_feed_controller.dart';
import 'package:gaya/view/community/controllers/community_profile_controller.dart';
import 'package:gaya/view/feed/controller/post_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

import '../../../model/local/crown_payload.dart';
import '../../../model/user.model.dart';
import '../../../services/notification/notification_api/notification_api.dart';
import '../../../services/services.dart';
import '../../../utils/asset_images.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/strings.dart';
import '../../feed/controller/base/base_feed_impl.dart';
import '../../feed/controller/for_you_controller.dart';

class PostWithCommentController extends GetxController {
  Post post;

  static PostWithCommentController to({required String? tag}) => Get.find<PostWithCommentController>(tag: tag);

  PostWithCommentController({required this.post});

  bool isMemberOfCommunity = true;
  final User? _user = FirebaseAuth.instance.currentUser;
  final Services _commonService = Services();
  final NotificationApiHitting _notificationApiHitting = NotificationApiHitting();

  bool get shouldFocusKeyboard => _shouldFocusKeyboard;

  UserModel get myAppUser => UserModel.to;

  String get communityId => post.communityId ?? "-1";

  bool get isCommunityIdPresent => communityId != "-1" && communityId.isBlank == false && communityId.length > 4;

  /// returns true if community is public
  bool get isCommunityPublic => post.isCommunityPublic;

  @override
  void onInit() {
    super.onInit();
    fetchPost();
  }

  _assignPostToCommentsController() {
    bool isReg = CommentsController.isRegistered(tag: post.postid);
    if (isReg) {
      CommentsController.to(tag: post.postid).post = post;
      MyLoggerServices.to.print('Assigned Post Successfully');
    }
  }

  ///Invokes when Community is already loaded from controller. so why not load from
  ///controller instead of pciking from post
  _assignCommunityToPost() {
    if (post.community.communityId.isBlank == true) return;
    bool isReg = CommunityProfileController.isRegistered(tag: post.communityId ?? "");
    if (isReg) {
      final _alreadyFetchedCommunity = CommunityProfileController.to(tag: post.communityId ?? "").communityModel;
      if (_alreadyFetchedCommunity == null || _alreadyFetchedCommunity.communityName.isBlank == true) return;
      post.community = _alreadyFetchedCommunity;
      MyLoggerServices.to.print('Assigned Community Successfully');
    }
  }

  void fetchPost({bool forcefullyRefresh = false}) async {
    //TODO:Make sure to remove once implement pull to refresh on whole post.
    /// case where we have the post model (all fields available)
    /// so no need to fetch again from db.
    // if (!post.isPostIdOnly && !forcefullyRefresh) {
    //   return;
    // }

    setLoading(true);

    PerformanceController.to.instance.startLoadPostTime();

    final _post = _commonService.getPostDetailsSnapshot(post.postid ?? "");
    final _isMem = isCommunityIdPresent ? _commonService.isMemberOfCommunity(communityId) : null;

    final __post = _post;
    final __isMem = _isMem != null ? _isMem : null;

    final (loadedPost, isMember) = (await __post, await __isMem);

    if (loadedPost != null) {
      post = loadedPost;

      /// Assign post to comment controller:
      /// Workaround: If coming from just postId, then assign post to comment controller
      _assignPostToCommentsController();

      _assignCommunityToPost();

      /// check if user is member of community,
      /// [isMember] is fetch concurrently with post, it can
      /// be null if [communityId] was not present at that time
      isMemberOfCommunity = isMember ?? await _commonService.isMemberOfCommunity(communityId);

      setLoading(false);
    }

    /*   final loadedPost = await _commonService.getPostDetailsSnapshot(post.postid ?? "");
    PerformanceController.to.instance.stopLoadPostTime();
    if (loadedPost != null) {
      post = loadedPost;

      /// Assign post to comment controller:
      /// Workaround: If coming from just postId, then assign post to comment controller
      _assignPostToCommentsController();

      /// check if user is member of community
      isMemberOfCommunity = await _commonService.isMemberOfCommunity(communityId);
    }*/

    setLoading(false);
  }

  Future<void> updatePostTopicsFirebase(Post post) async {
    await _commonService.updatePostTopics(post);
    _updateHomeFeedPost();
  }

  Future<void> likePost() async {
    if (_user == null) return;
    post.likedBy?.insert(0, _user?.uid ?? "");
    _commonService.likeOnPost(post.postid ?? "", communityId);
    update();
    _updateHomeFeedPost();
    if (post.postedBy.uId != UserModel.to.uId) {
      UserModel? userData = await _commonService.getUserById(post.postedBy.uId, forcefullyServer: true);
      if (userData?.uId == null) return;
      //fcm
      final fcmPostModel = FcmCreatePostModel(
        postid: post.postid ?? '',
        communityId: post.communityId ?? '',
        messageContent: "${myAppUser.name} ${GayaStrings.dash_reacted_your_post.tr}",
        messageTitle: GayaStrings.post_is_vibed_notification.tr,
        receiverFcm: userData?.fm_token ?? '',
      );

      _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

      if (UserModel.to.uId != null && post.postedBy.uId != null) {
        //store notification
        _commonService.addNotification(
            posId: post.postid,
            isRead: false,
            body: "${myAppUser.name} ${GayaStrings.dash_reacted_your_post.tr}",
            title: GayaStrings.post_is_vibed_notification.tr,
            receiverUserID: post.postedBy.uId!,
            senderId: UserModel.to.uId!,
            time: DateTime.now().toString(),
            type: "postLiked",
            userImage: UserModel.to.profilePicture ?? "");
      }

      ///score
      EngagementScoreController.to.instance.onLike(communityId: post.communityId ?? "", postId: post.postid ?? "");
    }
  }

  final _likeReactionDebounce = Debouncer(delay: const Duration(milliseconds: 500));

  Future<void> likeReactionOnPost({String? reaction, bool isChecked = false}) async {
    if (_user == null) return;

    ReactionModel reactionModel = ReactionModel(userId: UserModel.to.uId ?? '', reaction: reaction ?? 'Love');
    // post?.reactionModel = reactionModel;

    if (post.postReactionData == null) {
      post.postReactionData = PostReactionDataModel(
        like: reaction == 'Like' ? 1 : 0,
        inLove: reaction == 'Love' ? 1 : 0,
        sad: reaction == 'Sad' ? 1 : 0,
        angry: reaction == 'Angry' ? 1 : 0,
        surprized: reaction == 'Surprised' ? 1 : 0,
        funny: reaction == 'Funny' ? 1 : 0,
      );
      post.reactionModel = reactionModel;
    } else {
      final postModel = HelperFunc().getPostModelOnReactionChange(reaction ?? 'Love', post);
      post.postReactionData = postModel?.postReactionData;
      post.reactionModel = reactionModel;
    }

    //db operation
    _likeReactionDebounce(() async {
      await _commonService.likeReactionOnPost(post.postid ?? "", post.communityId ?? "", reactionModel);
      if (post.postedBy.uId != UserModel.to.uId) {
        UserModel? userData = await _commonService.getUserById(post.postedBy.uId, forcefullyServer: true);
        if (userData?.uId == null) return;

        String reactionData = Methods.getEmojiByType(reaction);

        //fcm
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent: "${myAppUser.name} ${GayaStrings.vibed_with.tr} '$reactionData' ${GayaStrings.to_your_post.tr}",
          messageTitle: GayaStrings.post_is_vibed_notification.tr,
          receiverFcm: userData?.fm_token ?? '',
        );

        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

        if (UserModel.to.uId != null && post.postedBy.uId != null) {
          //store notification
          _commonService.addNotification(
              posId: post.postid,
              isRead: false,
              // body: "${myAppUser.name} ${GayaStrings.dash_reacted_your_post.tr}",
              body: "${myAppUser.name} ${GayaStrings.vibed_with.tr} '$reactionData' ${GayaStrings.to_your_post.tr}",
              title: GayaStrings.post_is_vibed_notification.tr,
              receiverUserID: post.postedBy.uId!,
              senderId: UserModel.to.uId!,
              time: DateTime.now().toString(),
              type: reactionModel.reaction,
              // "postLiked",
              userImage: UserModel.to.profilePicture ?? "");
        }

        ///score
        EngagementScoreController.to.instance.onLike(communityId: post.communityId ?? "", postId: post.postid ?? "");
      }
    });
    // _commonService.likeReactionOnPost(post.postid ?? "", post.communityId ?? "", reactionModel);

    update();
    _updateHomeFeedPost();
  }

  bool isPostedAnonymously(Post postModel) {
    return (postModel.isPostedAnonymously == true && postModel.postedBy.uId == myAppUser.uId);
  }

  // mentioned users in comments
  Future<void> mentionedUsersOnPost({List<String> mentionedUsers = const []}) async {
    try {
      bool isAnonymous = isPostedAnonymously(post);
      if (_user == null) return;
      // if (post.postedBy.uId != UserModel.to.uId) {
      // UserModel? postUserData = await _commonService.getUserById(post.postedBy.uId);
      List<UserModel> notifyUsers = [];
      for (var user in mentionedUsers) {
        UserModel? userData = await _commonService.getUserById(user, forcefullyServer: true);
        if (userData != null) {
          notifyUsers.add(userData);
        }
      }
      //fcm
      for (var notifyUser in notifyUsers) {
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent:
              "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name} ${GayaStrings.dash_has_mentioned_you.tr}.",
          messageTitle: GayaStrings.your_mentioned_in_comment_checkout.tr,
          receiverFcm: notifyUser.fm_token ?? '',
        );
        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

        //store notification
        _commonService.addNotification(
          posId: post.postid,
          isRead: false,
          body:
              "${isAnonymous ? myAppUser.gender == null ? anonymousUser : myAppUser.gender == 'male' ? anonymousBoy : myAppUser.gender == 'female' ? anonymousGirl : anonymousUser : myAppUser.name} ${GayaStrings.dash_has_mentioned_you.tr}.",
          receiverUserID: notifyUser.uId!,
          senderId: UserModel.to.uId!,
          title: GayaStrings.your_mentioned_in_comment_checkout.tr,
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
      // }
    } catch (e) {
      MyLoggerServices.to.print('error thrown during notification sending!');
    }
  }

  UserModel userModel = UserModel.to;
  CrownServices crownServices = CrownServices();

  Future<PostReaction> crownPost(String? postId, {UserModel? receiverUser}) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return operationPerformed;
    //checking if the post is already flowered by the user
    bool? isCrowned = post.crownsBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");
    if (isCrowned == true) {
      print('Post already crowned');
    } else if (isCrowned == false) {
      // Invoke to log crown post event
      AnalyticsController.to.instance.logCrownPost(
        communityId: post.communityId ?? '',
        postId: post.postid ?? '',
        userId: UserModel.to.uId ?? '',
      );

      post.crownsBy ??= [];
      //locally
      post.crownsBy?.add(currentUserId);
      post.postedBy = post.postedBy.updateCrown(shouldIncreament: true);
      // cache author update
      CacheController.to.updateUser(post.postedBy);
      final tempCrown = userModel.userDailyCrowns;

      userModel.userDailyCrowns = (userModel.userDailyCrowns != null) ? userModel.userDailyCrowns! - 1 : userModel.userDailyCrowns;
      // cache update
      CacheController.to.updateUser(userModel);
      update();
      //db operation
      bool isSuccess = await crownAPostCloudFunction(postId, receiverUser?.uId ?? '', currentUserId);
      if (isSuccess == false) {
        post.crownsBy?.remove(currentUserId);
        post.postedBy.updateCrown(shouldIncreament: false);
        // cache author update
        CacheController.to.updateUser(post.postedBy);
        userModel.userDailyCrowns = tempCrown;
        // userModel.userDailyCrowns = (userModel.userDailyCrowns != null) ? userModel.userDailyCrowns! + 1 : userModel.userDailyCrowns;
        // cache update
        CacheController.to.updateUser(userModel);
      } else {
        if (receiverUser != null) {
          _commonService.increaseInfluencePointOnCrownReward(receiverUser.uId);
        }
        EngagementScoreController.to.instance.onCrown(postId: postId, communityId: post.communityId ?? '');
        final CrownsController crownsController = Get.find();
        if (userModel.userDailyCrowns == 0) {
          crownsController.getCrownServerTimeStamp();
        } else {
          crownsController.updateCurrentUser();
        }
      }
      //send notification
      if (post.postedBy.uId != userModel.uId) {
        UserModel? userData = await _commonService.getUserById(post.postedBy.uId, forcefullyServer: true);
        //fcm
        final fcmPostModel = FcmCreatePostModel(
          postid: post.postid ?? '',
          communityId: post.communityId ?? '',
          messageContent: "${myAppUser.name} ${GayaStrings.crowned_post.tr}",
          messageTitle: GayaStrings.newcrown.tr,
          receiverFcm: userData?.fm_token ?? '',
        );

        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);
        //store notification
        _commonService.addNotification(
            posId: post.postid,
            isRead: false,
            body: "${myAppUser.name} ${GayaStrings.crowned_post.tr}",
            receiverUserID: post.postedBy.uId!,
            senderId: UserModel.to.uId!,
            title: GayaStrings.newcrown.tr,
            time: DateTime.now().toString(),
            type: "postCrowned",
            userImage: UserModel.to.profilePicture ?? "");
      }
      operationPerformed = PostReaction.crown;
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }
    _updateHomeFeedPost();
    update();

    return operationPerformed;
  }

  /// this function is used to crown a post on cloud
  Future<bool> crownAPostCloudFunction(String postId, String receiverId, String currentUserId) async {
    final payload = CrownPayload(postId: postId, senderId: currentUserId, receiverId: receiverId);
    return await crownServices.crownOnPost(payload: payload);
  }

  void unlikePost() {
    if (_user == null) return;
    post.likedBy?.remove(_user?.uid ?? "");
    FirebaseFirestore.instance.collection('communityposts').doc(post.postid).update({
      'likedBy': FieldValue.arrayRemove([UserModel.to.uId]),
    });
    EngagementScoreController.to.instance.onDislike(communityId: post.communityId ?? "", postId: post.postid ?? "");
    update();
    _updateHomeFeedPost();
  }

  void unlikeReactionOnPost({String? reaction, bool isChecked = false}) {
    if (_user == null) return;

    if (post.postReactionData != null) {
      post.postReactionData = PostReactionDataModel(
        like: reaction == 'Like'
            ? (((post.postReactionData?.like == null || post.postReactionData?.like == 0) ? 1 : post.postReactionData!.like) - 1)
            : post.postReactionData?.like ?? 0,
        inLove: reaction == 'Love'
            ? (((post.postReactionData?.inLove == null || post.postReactionData?.inLove == 0) ? 1 : post.postReactionData!.inLove) - 1)
            : post.postReactionData?.inLove ?? 0,
        sad: reaction == 'Sad'
            ? (((post.postReactionData?.sad == null || post.postReactionData?.sad == 0) ? 1 : post.postReactionData!.sad) - 1)
            : post.postReactionData?.sad ?? 0,
        angry: reaction == 'Angry'
            ? (((post.postReactionData?.angry == null || post.postReactionData?.angry == 0) ? 1 : post.postReactionData!.angry) - 1)
            : post.postReactionData?.angry ?? 0,
        surprized: reaction == 'Surprised'
            ? (((post.postReactionData?.surprized == null || post.postReactionData?.surprized == 0)
                    ? 1
                    : post.postReactionData!.surprized) -
                1)
            : post.postReactionData?.surprized ?? 0,
        funny: reaction == 'Funny'
            ? (((post.postReactionData?.funny == null || post.postReactionData?.funny == 0) ? 1 : post.postReactionData!.funny) - 1)
            : post.postReactionData?.funny ?? 0,
      );
    }
    post.reactionModel = null;

    EngagementScoreController.to.instance.onDislike(communityId: post.communityId ?? "", postId: post.postid ?? "");

    _commonService.unLikeReactionOnPost(post.postid ?? "", post.communityId ?? "");

    update();
    _updateHomeFeedPost();
  }

  void incrementCommentCount() {
    if (_user == null) return;
    post.totalCommentsCount ??= "0";
    int totalCommentCount = int.tryParse(post.totalCommentsCount ?? "0") ?? 0;
    post.totalCommentsCount = (totalCommentCount + 1).toString();
    update();
    _updateHomeFeedPost();
  }

  // increment post comments count and save new comment to post latest comments list
  void incrementCommentCountAndUpdateRecentCommentsList(
    String newCommentId,
    String myNewComment,
    int commentTypeByIntegere,
    List<Map<String, dynamic>>? mentionedUser,
  ) {
    // 1 for simple text or @mentions or links, 2 for image, 3 for video and 4 for documents
    // final newCommentId = uuid.v1();
    //make model for local.
    final newComment = CommentCustomModel(
      id: newCommentId,
      mentionedUsers: mentionedUser?.toList(),
      comment: (commentTypeByIntegere == 1)
          ? myNewComment
          : (commentTypeByIntegere == 2)
              ? 'Photo'
              : (commentTypeByIntegere == 3)
                  ? 'video'
                  : (commentTypeByIntegere == 4)
                      ? 'Document'
                      : myNewComment,
      user: UserModel.to,
      createdAt: DateTime.now(),
    );
    //add locally.
    if (post.recentComments == null) {
      post.recentComments = [];
      post.recentComments?.add(newComment);
    } else if (post.recentComments!.length < 5) {
      if (post.recentComments == null) return;
      post.recentComments?.insert(0, newComment);
    } else {
      if (post.recentComments == null) return;
      post.recentComments?.insert(0, newComment);
      post.recentComments?.removeRange(5, post.recentComments!.length);
    }
    if (_user == null) return;
    post.totalCommentsCount ??= "0";
    int totalCommentCount = int.tryParse(post.totalCommentsCount ?? "0") ?? 0;
    post.totalCommentsCount = (totalCommentCount + 1).toString();
    update();
    _updateCommunityFeedPost();
    _updateHomeFeedPost();
  }

  void _updateHomeFeedPost() {
    try {
      //update post at home feed
      FeedControllerUtils.updatePostLocally(post, metadata: runtimeType.toString());
    } catch (_) {
      MyLoggerServices.to.print("error at updating postwithcontroller to homefed");
    }
  }

  //update post at community feed
  void _updateCommunityFeedPost() {
    try {
      if (Get.isRegistered<CommunityFeedController>(tag: communityId)) {
        CommunityFeedController(
          communityId: post.communityId ?? "",
          community: post.community,
        );

        final communityFeedController = Get.find<CommunityFeedController>(tag: communityId);
        communityFeedController.updatePostLocally(post);
      }
    } catch (_) {
      MyLoggerServices.to.print("error at updating CommunityFeedController to community feed");
    }
  }

  //update posts comment (locally)
  void updateTotalComments(int deletedCommentCount) {
    try {
      int totalComments = int.parse(post.totalCommentsCount ?? "");
      int updatedCommentCount = totalComments - deletedCommentCount;
      if (updatedCommentCount > 0) {
        post.totalCommentsCount = updatedCommentCount.toString();
      }
    } catch (_) {
    } finally {
      update();
    }
  }

  //update posts comment (locally)
  void updateTotalCommentsAndRemoveRecentCommentWhenDelete(int deletedCommentCount, String commentId) {
    try {
      int totalComments = int.parse(post.totalCommentsCount ?? "");
      int updatedCommentCount = totalComments - deletedCommentCount;
      if (updatedCommentCount > 0) {
        post.totalCommentsCount = updatedCommentCount.toString();
      }
      if (post.recentComments != null || post.recentComments?.isEmpty == false) {
        int index = post.recentComments!.indexWhere((element) => element?.id == commentId);
        if (index != -1) {
          post.recentComments?.removeAt(index);
          _updateCommunityFeedPost();
          _updateHomeFeedPost();
        }
      }
    } catch (_) {
      print(_.toString());
    } finally {
      update();
    }
  }

  /// delete posts from all feeds (community, forYou, myCommunities )
  void deletePostFromFeeds({required Post post}) {
    try {
      /// delete, first check is registered
      if (CommunityFeedController.isRegistered(tag: post.communityId)) {
        CommunityFeedController.to(tag: post.communityId).deletePostLocally(post);
      }

      /// delete from [Home] feed
      ForYouFeedController.to.updatePostLocally(post, shouldDelete: true);
    } catch (_, s) {
      CrashlyticsController.to.instance.recordError(_, stackTrace: s, reason: 'deletePostFromFeeds at $runtimeType');
    }
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    update();
  }

  addRemovePostTopic(String topic) {
    if (post.postTopicList == null) {
      post.postTopicList = [topic];
    } else {
      if (post.postTopicList!.contains(topic)) {
        post.postTopicList!.remove(topic);
      } else {
        post.postTopicList!.add(topic);
      }
    }
    update();
  }

  updatePostTopics(context, Post post) async {
    await _commonService.updatePostTopics(post);
    update();
  }

  /// TO handle focus of keyboard, workaround for:
  /// when use type something in NoCommentView, and then we were shifting to comment view,
  /// then keyboard was close - Open which was not looking good.
  /// so we are handling it here. Letting this true in case of NoCommentView (init)
  bool _shouldFocusKeyboard = true;

  set shouldFocusKeyboard(bool value) => _shouldFocusKeyboard = value;
}
