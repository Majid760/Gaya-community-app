import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/controller/crowns_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/services/notification/notification_api/notification_api.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:gaya/view/community/controllers/community_profile_controller.dart';
import 'package:gaya/view/feed/services/local/posts/seen_unseen_post_services.dart';
import 'package:gaya/view/feed/view/community_user_feed/controller/home_feed_user_communities_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:helpers/helpers.dart';

import '../../../controller/cache_controller.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../model/create.post.model.dart';
import '../../../model/user.model.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/logger.dart';
import '../../feed/controller/base/base_feed_impl.dart';
import '../../feed/controller/post_controller.dart';
import '../../feed/services/base/post_db_operations.dart';
import '../../feed/services/base/post_notification_operations.dart';
import '../services/communityFeedServices.dart';

class CommunityFeedController extends GetxController with PostDbOperationsImpl, PostNotificationImpl {
  final String communityId;
  Community? community;
  final String? hashTagTopic;

  /// tells us if this controller is for home feed comunity or inside a community view feed
  ///  1 old+new post category vise
  ///  2 not fetching pinned post
  bool shouldHaveSeenPost;

  CommunityFeedController({required this.communityId, this.community, this.hashTagTopic, this.shouldHaveSeenPost = false});

  static CommunityFeedController to({required String? tag}) => Get.find(tag: tag);

  static bool isRegistered({required String? tag}) => Get.isRegistered<CommunityFeedController>(tag: tag);

  List<Post> _posts = [];
  List<Post> _pinnedPosts = [];

  late CommunityFeedServices postServices;
  late Services _commonService;
  UserModel userModel = UserModel.to;

  List<Post> get posts => _posts.distinctBy((e) => e.postid ?? "").toList();

  bool get isFeedEmpty => _posts.isEmpty;
  bool isFirstTime = false;
  bool isLoading = false;
  String? selectedTopic;

  /// Seen and unseen post on home feed community.
  List<Post> oldPosts = [];
  List<Post> newPostsList = [];

  @override
  onInit() {
    super.onInit();

    /// stop scrolling when community feed posts are loading.
    _pauseScrolling();

    postServices = CommunityFeedServices(communityId: communityId);
    _commonService = Services();

    requestMoreData(fromInit: true, topic: hashTagTopic).then((_) {
      /// Set loading to false for Circle Community Loading
      /// to avoid, widget deactivated error.
      _resumeScrolling();
    });
    updateCommunityLastVisitTimeForUser(communityId);
  }

  bool setState(bool value) {
    isLoading = value;
    update();
    return isLoading;
  }

  void updateCommunityModel(Community communityModel) {
    community = communityModel;
    update();
  }

  /// select topic and fetch the post.
  void setSelectedTopic(String? topic) {
    if (selectedTopic == topic) return;
    selectedTopic = topic;
    //fetch posts according to selected topic.
    resetController();
  }

  // update community last visit time of a user
  void updateCommunityLastVisitTimeForUser(String communityId) {
    _commonService.updateCommunityLastVisitTimeForUser(communityId);
  }

  /// manage topics of post.
  /// firebase update + home feed update if exists in viewport.
  Future<void> updatePostTopicsFirebase(Post post) async {
    await _commonService.updatePostTopics(post);
    _updateHomeFeedPost(post);
  }

  //call when new post is posted
  void addAPostLocally(Post post) {
    _posts.insert(0, post);
    update();
  }

//delete post from home feed + community feed
  void deletePostLocally(Post post) {
    _posts.removeWhere((element) => element.postid == post.postid);

    /// remove from old and new post list.
    if (oldPosts.isNotEmpty || newPostsList.isNotEmpty) {
      oldPosts.removeWhere((element) => element.postid == post.postid);
    }

    _updateHomeFeedPost(post, shouldDelete: true);
    update();
  }

  //call when any post is updated somewhere else.
  void updatePostLocally(Post post) {
    final index = _posts.indexWhere((element) => element.postid == post.postid);
    if (index != -1) {
      final shouldUpdate = _shouldUpdateAllPostAuthorCrowns(newPost: post, oldPost: _posts[index]);
      if (shouldUpdate) {
        _updateAllOfThePostAuthorsCrownslocally(post);
      }

      /// incase if there is no communtiy new newPost [post] will be null
      /// so keep copy of old post community
      if (post.community.communityName == null) {
        /// make copy of old community
        Community _community = _posts[index].community;

        /// assign post
        _posts[index] = post;

        /// assign old community again
        _posts[index].community = _community;
      } else {
        _posts[index] = post;
      }
    }
    updateNewOldPostLocally(post);
    update();
  }

  void updateNewOldPostLocally(Post post) {
    if (oldPosts.isNotEmpty || newPostsList.isNotEmpty) {
      final index = oldPosts.indexWhere((element) => element.postid == post.postid);
      if (index != -1) {
        oldPosts[index] = post;
      }
      final index2 = newPostsList.indexWhere((element) => element.postid == post.postid);
      if (index2 != -1) {
        newPostsList[index2] = post;
      }
    }
  }

  PostReaction likePost(String? postId, {UserModel? receiverUser}) {
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return operationPerformed;

    var post = _posts.firstWhereOrNull((element) => element.postid == postId);
    //checking if the post is already flowered by the user
    bool? isLiked = post?.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");

    if (isLiked == true) {
      EngagementScoreController.to.instance.onDislike(communityId: communityId, postId: postId);
      post?.likedBy?.remove(FirebaseAuth.instance.currentUser?.uid ?? "");
      unlikeAPost(postId, communityId);
      operationPerformed = PostReaction.unlike;
    } else if (isLiked == false) {
      //locally
      post?.likedBy?.add(FirebaseAuth.instance.currentUser?.uid ?? "");
      //db operation
      likeAPost(postId, communityId);
      //score
      EngagementScoreController.to.instance.onLike(communityId: communityId, postId: postId);
      //send notification
      if (receiverUser != null) {
        debugPrint("likePost receiver user: ${receiverUser.fm_token}");
        sendLikeNotification(postId: postId, user: receiverUser, communityId: communityId, type: 'postLiked');
      }
      operationPerformed = PostReaction.like;
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }
    update();
    _updateHomeFeedPost(post);
    return operationPerformed;
  }

  final _likeReactionDebounce = Debouncer(delay: const Duration(milliseconds: 500));
  final _helper = HelperFunc();

  PostReaction likeReactionOnPost(String? postId, {UserModel? receiverUser, String? reaction, bool isChecked = false}) {
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return operationPerformed;
    var post = _posts.firstWhereOrNull((element) => element.postid == postId);
    //checking if the post is already flowered by the user
    // bool? isLiked = post?.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");

    if (isChecked && reaction != null) {
      ReactionModel reactionModel = ReactionModel(userId: UserModel.to.uId ?? '', reaction: reaction);
      // post?.reactionModel = reactionModel;

      if (post?.postReactionData == null) {
        post?.postReactionData = PostReactionDataModel(
          like: reaction == 'Like' ? 1 : 0,
          inLove: reaction == 'Love' ? 1 : 0,
          sad: reaction == 'Sad' ? 1 : 0,
          angry: reaction == 'Angry' ? 1 : 0,
          surprized: reaction == 'Surprised' ? 1 : 0,
          funny: reaction == 'Funny' ? 1 : 0,
        );
        post?.reactionModel = reactionModel;
      } else {
        final postModel = _helper.getPostModelOnReactionChange(reaction, post);
        post?.postReactionData = postModel?.postReactionData;
        post?.reactionModel = reactionModel;
      }

      //db operation
      _likeReactionDebounce(() async {
        await likeReactionAPost(postId, communityId, reactionModel);
        //send notification
        if (receiverUser != null) {
          sendLikeNotification(postId: postId, user: receiverUser, communityId: post?.communityId ?? "", type: reactionModel.reaction);
        }
      });
      try {
        // score
        EngagementScoreController.to.instance.onLike(communityId: post?.communityId ?? "", postId: postId);
      } catch (_) {}

      operationPerformed = PostReaction.like;
    } else {
      if (post?.postReactionData != null) {
        post?.postReactionData = PostReactionDataModel(
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
      post?.reactionModel = null;
      try {
        // score
        EngagementScoreController.to.instance.onDislike(communityId: post?.communityId ?? "", postId: postId);
      } catch (_) {}

      unLikeReactionAPost(postId, post?.communityId ?? "");
      operationPerformed = PostReaction.unlike;
    }

    update();
    _updateHomeFeedPost(post);
    return operationPerformed;
  }

/*  PostReaction flowerPost(String? postId, {UserModel? receiverUser}) {
    PostReaction operationPerformed = PostReaction.idle;
    try {
      if (postId == null) return operationPerformed;
      var post = _posts.firstWhereOrNull((element) => element.postid == postId);

      //checking if the post is already flowered by the user

*/
  final _notificationApiHitting = NotificationApiHitting();

  Future<PostReaction> crownPost(String? postId, {UserModel? receiverUser}) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return operationPerformed;
    var post = _posts.firstWhereOrNull((element) => element.postid == postId);
    if (post?.postedBy == null) return operationPerformed;
    //checking if the post is already flowered by the user
    bool? isCrowned = post?.crownsBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");
    if (isCrowned == true) {
    } else if (isCrowned == false) {
      // Invoke to log crown post event
      AnalyticsController.to.instance.logCrownPost(
        communityId: communityId,
        postId: post?.postid ?? '',
        userId: UserModel.to.uId ?? '',
      );

      post?.crownsBy ??= [];
      post!.postedBy = post.postedBy.updateCrown(shouldIncreament: true);
      // cache author update
      CacheController.to.updateUser(post.postedBy);
      //locally
      post.crownsBy?.add(currentUserId);
      final tempCrown = userModel.userDailyCrowns;

      userModel.userDailyCrowns = (userModel.userDailyCrowns != null) ? userModel.userDailyCrowns! - 1 : userModel.userDailyCrowns;
      // cache current user update
      CacheController.to.updateUser(userModel);
      update();
      //db operation
      bool isSuccess = await crownAPost(postId, receiverUser?.uId ?? '', currentUserId);
      if (!isSuccess) {
        post.crownsBy?.remove(currentUserId);
        post.postedBy = post.postedBy.updateCrown(shouldIncreament: false);
        // cache author update
        CacheController.to.updateUser(post.postedBy);
        userModel.userDailyCrowns = tempCrown;
        // userModel.userDailyCrowns = (userModel.userDailyCrowns != null) ? userModel.userDailyCrowns! + 1 : userModel.userDailyCrowns;
        // cache current user update
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
      _updateAllOfThePostAuthorsCrownslocally(post);
      //send notification
      if (receiverUser != null) sendCrownNotification(postId: postId, user: receiverUser);
      operationPerformed = PostReaction.like;
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }
    update();
    _updateHomeFeedPost(post);
    return operationPerformed;
  }

  Future<void> sendCrownNotification({required String postId, required UserModel user}) async {
    //don't send notification if the user is the same.
    if (userModel.uId == user.uId) return;

    UserModel? userData = await _commonService.getUserById(user.uId, forcefullyServer: true);

    final fcmPostModel = FcmCreatePostModel(
      postid: postId,
      communityId: communityId,
      messageContent: "${userModel.name} ${GayaStrings.dash_has_crowned_post.tr}",
      messageTitle: GayaStrings.your_post_was_crowned_checkout.tr,
      receiverFcm: userData?.fm_token ?? '',
    );

    _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel
        // gaya_message: "${usermodel.name} sent you a new message.", fcmToken: otherChatParticipantFcmToken
        );

    //store notification
    _commonService.addNotification(
        posId: postId,
        isRead: false,
        body: "${userModel.name} ${GayaStrings.dash_has_crowned_post.tr}",
        title: GayaStrings.your_post_was_crowned_checkout.tr,
        receiverUserID: user.uId ?? '',
        senderId: UserModel.to.uId!,
        time: DateTime.now().toString(),
        type: "postCrowned",
        userImage: UserModel.to.profilePicture ?? "");
  }

  void _updateAllOfThePostAuthorsCrownslocally(Post post) {
    for (int i = 0; i < _posts.length; i++) {
      if (posts[i].memberId == post.memberId) {
        posts[i].postedBy = post.postedBy;
      }
    }
  }

  /// adds the post to the top of the list
  void addPostToTop(Post post) {
    _posts.removeFirstWhere((element) => element.postid == post.postid);

    _posts.insert(0, post);
  }

  /// returns [true] if the post is pinned
  /// returns [false] if the post is not pinned
  bool togglePinPost(Community communityModel, Post postModel) {
    /// if post was not pinned and it pinned successfully
    bool isPinnedSuccess = false;
    if (postModel.postid == null) return false;
    bool isPinned = postModel.community.pinnedPostList?.contains(postModel.postid ?? '') ?? false;
    MyLoggerServices.to.print('post is pinned or not? : $isPinned');
    if (isPinned == true) {
      postModel.community.pinnedPostList = [];

      unpinAPost(communityModel.communityId ?? '', postModel.postid ?? '');
    } else if (isPinned == false) {
      //locally
      postModel.community.pinnedPostList = [postModel.postid ?? ''];
      //db operation
      pinAPost(communityModel.communityId ?? '', postModel.postid ?? '');
      isPinnedSuccess = true;

      /// Add post to top of the list
      addPostToTop(postModel);
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }
    update();
    MyLoggerServices.to.print("post comunity is: ${postModel.community.pinnedPostList}");
    updatePostLocally(postModel);
    _updateHomeFeedPost(postModel);
    addPostToTop(postModel);
    return isPinnedSuccess;
  }

/*  /// update community locally
  void _updateAllPostsCommunityLocally(CreateCommunityModel? community){
    if(community == null) return;
    for(int i = 0; i < _posts.length; i++){
      if(posts[i].communityId == community.communityId){
        posts[i].community = community;
      }
    }

  }*/

  bool _shouldUpdateAllPostAuthorCrowns({required Post oldPost, required Post newPost}) =>
      oldPost.postedBy.userTotalCrowns != newPost.postedBy.userTotalCrowns;

  Future<bool> requestMoreData({bool fromInit = false, String? topic}) async {
    debugPrint("selected TOPIC IS: $topic");
    // to avoid double loading at top andbottom on screen
    // if (fromInit == false) {
    //   refreshController.callLoad();
    // }

    ///////// waqar work //////////
    String? topicc;
    if (topic != null) {
      topicc = await getTopicFromcommunityTopicsList(topic: topic);
      // debugPrint("topicc: ${topicc.toString()} ");
    }
    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      // print("from init called");
      setState(true);
      if (!shouldHaveSeenPost) {
        await requestPinnedPosts();
        _posts.insertAll(0, _pinnedPosts);
      }
    }

    isFirstTime = true;
    final newPosts = await postServices.requestMoreData(topic: topicc);

    // print("new posts length: ${_newPosts.length}");

    _posts.addAll(newPosts);

    _posts = _posts.distinctBy((e) => e.postid ?? "").toList();

    // print("shouldHaveSeenPost $shouldHaveSeenPost");

    /// workaround for seen and unseen posts for Community Feed v2 only
    if (shouldHaveSeenPost) {
      /// clear the lists for new data
      oldPosts = [];
      newPostsList = [];
      try {
        // gets last visits to a community
        final lastSeenCommunity = await SeenUnseenPostServices.instance.getLastVisit(communityId);
        // print("last seen community: $lastSeenCommunity");
        for (var e in _posts) {
          // print("post created on: ${e.postCreatedOn} last seen on: $lastSeenCommunity");

          /// if post is created after last visit to a community, then it is unseen
          if (lastSeenCommunity == null || e.postCreatedOn!.isAfter(lastSeenCommunity)) {
            newPostsList.add(e);
          } else {
            // print("post created on: ${e.postCreatedOn} last seen on: $lastSeenCommunity");

            /// if post is created before last visit to a community, then it is seen
            oldPosts.add(e);
          }
        }
      } catch (e) {
        print("error in seen unseen post: $e");
      }

      SeenUnseenPostServices.instance.setLastVisit(communityId);
    }
    debugPrint("new posts length: ${newPostsList.length} old posts length: ${oldPosts.length}");

    setState(false);
    return newPosts.isNotEmpty;
  }

  // requesting for pinned posts in a community
  Future<void> requestPinnedPosts() async {
    _pinnedPosts = [];

    final communityProfileController = CommunityProfileController.to(tag: communityId);
    final pinnedPosts = await postServices.requestPinnedPosts(postIds: communityProfileController.communityModel?.pinnedPostList ?? []);
    print("pinned posts length: ${pinnedPosts.length}");
    _pinnedPosts.addAll(pinnedPosts);
  }

///////// waqar work //////////
  Future<String?> getTopicFromcommunityTopicsList({String? topic}) async {
    final communityProfileController = CommunityProfileController.to(tag: communityId);
    final communitymodel = communityProfileController.communityModel;
    String? topicc;
    print('topics is in feed controller is: ${communitymodel?.communityTopicList?.length}');
    if (topic != null && communitymodel?.communityTopicList != null) {
      int index = communitymodel!.communityTopicList!.indexWhere((element) => element.toLowerCase().contains(topic.toLowerCase()));
      if (index != -1) {
        selectedTopic = communitymodel.communityTopicList?[index];
        topicc = selectedTopic;
      } else {
        selectedTopic = null;
        topicc = null;
      }
    } else {}

    return topicc;
  }

  ///////// waqar work ended //////////

  void setNoMorePosts() {
    refreshController.finishLoad(IndicatorResult.noMore);
  }

  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  void _updateHomeFeedPost(Post? post, {bool shouldDelete = false}) {
    try {
      if (post == null) return;
      //update post at home feed
      FeedControllerUtils.updatePostLocally(post, shouldDelete: shouldDelete, metadata: runtimeType.toString());
    } catch (_) {}
  }

  // A dispose method.
  Future<void> resetController({BuildContext? context, Community? communityModel}) async {
    _posts = [];

    isFirstTime = false;
    isLoading = true;
    postServices.reset();
    if (context != null && communityModel != null) {
      await loadCommunityProfile(context, communityModel);
    }
    await refreshController.callLoad();
    isLoading = false;
    await requestMoreData(fromInit: true, topic: selectedTopic);

    refreshController.finishRefresh(IndicatorResult.success, true);
  }

  Future<void> resetV2Controller({BuildContext? context, Community? communityModel}) async {
    /// stop scrolling, as refresh is in progress
    _pauseScrolling();

    _posts = [];

    isFirstTime = false;
    isLoading = true;
    postServices.reset();

    await refreshController.callLoad();

    isLoading = false;
    await requestMoreData(fromInit: true, topic: selectedTopic);
    refreshController.finishRefresh(IndicatorResult.success, true);

    /// resume scrolling as loading is finished now
    _resumeScrolling();
  }

  /// Workaround for: when loading and you start scroll, it throws
  /// widget deactivated error, so we pause scrolling when loading
  void _pauseScrolling() {
    if (HomeFeedUserCommunities.isRegistered) {
      HomeFeedUserCommunities.to.setCommunityLoading = true;
    }
  }

  void _resumeScrolling() {
    if (HomeFeedUserCommunities.isRegistered) {
      HomeFeedUserCommunities.to.setCommunityLoading = false;
    }
  }

  // fetch and store community profile in community editing controller
  Future<void> loadCommunityProfile(context, Community communityModel) async {
    if (EditCommunityController.isRegistered(communityModel.communityId)) {
      EditCommunityController.to(tag: communityModel.communityId).fetchCommunityProfile(communityModel, isFirstTime: true);
    }
    if (CommunityProfileController.isRegistered(tag: communityModel.communityId)) {
      CommunityProfileController.to(tag: communityModel.communityId).fetchCommunityProfile();
      if (CommunityProfileController.to(tag: communityModel.communityId).communityModel != null) {
        community = CommunityProfileController.to(tag: communityModel.communityId).communityModel;
      }
    }
  }

  // setCommunityModel
  void setCommunityModel(Community? communityModel) {
    if (communityModel != null) {
      community = communityModel;
      CommunityProfileController.to(tag: communityModel.communityId ?? "").updateGroupViewCommunity(community: communityModel);
    }
  }

  Future<Community?> fetchCommunityFromServer() async => await _commonService.getCommunityDetailsModel(communityId);
}
