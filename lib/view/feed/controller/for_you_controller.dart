import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/crowns_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/features_cards/view/widgets/child_widgets/child_widgets.dart';
import 'package:gaya/view/features_cards/view/widgets/feature_card.dart';
import 'package:gaya/view/feed/controller/post_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

import '../../../controller/cache_controller.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../services/notification/notification_api/notification_api.dart';
import '../../../services/services.dart';
import '../../../utils/language/translation.dart';
import '../../community/communities/services/communities_services.dart';
import '../services/base/post_db_operations.dart';
import '../services/base/post_notification_operations.dart';
import '../services/for_you_services.dart';
import '../services/post_isolations.dart';

class ForYouFeedController extends GetxController with PostDbOperationsImpl, PostNotificationImpl {
  static ForYouFeedController get to => Get.find();
  List<Widget> feedItems = [];
  List<Post> _posts = [];

  /// [suggestedCommunities] is used to show the suggested communities in the for you feed.
  List<Community> suggestedCommunities = [];

  /// [showSuggestedCommunities] is used to show the suggested communities in the for you feed.
  bool showSuggestedCommunities = false;

  /// Whether the feed is showing for the first time or not.
  bool _feedShowingFirstTime = true;

  /// [random] is used to check whether to show the feature cards or suggested communities.
  final Random random = Random();

  /// [featureCards] is used to show the feature cards in the for you feed.
  List<Widget> featureCards = [
    FeatureCardWidget(
      title: GayaStrings.crown_feature_title,
      description: GayaStrings.crown_feature_des,
      widget1: crownChildWidget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.post_exposure_title1,
      description: GayaStrings.post_exposure_des1,
      widget1: postExposureFeatureCardWidget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.post_exposure_title2,
      description: GayaStrings.post_exposure_des2,
      widget1: postExposureFeatureCard2Widget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.secret_community_feature_title,
      description: GayaStrings.secret_community_feature_des,
      widget1: secretCommunityFeatureCardWidget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.get_more_crown_feature_title,
      description: GayaStrings.get_more_crown_feature_des,
      widget1: getMoreCrownsWidget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.secret_community_help_feature_title,
      description: GayaStrings.secret_community_help_feature_des,
      widget1: needHelpWithGayaWidget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.hide_community_feature_title,
      description: GayaStrings.hide_community_feature_des,
      widget1: hideCommunityWidget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.grow_community_feature_title,
      description: GayaStrings.grow_community_feature_des,
      widget1: growCommunityWidget(),
    ),
    FeatureCardWidget(
      title: GayaStrings.hide_community_feature_title2,
      description: GayaStrings.hide_community_feature_des2,
      widget1: interestCommunityWidget(),
    ),
  ];
  final postServices = ForYouFeedServices();
  final _rand = Random();

  List<Post> get posts => _posts.distinctBy((e) => e.postid ?? "").toList();

  bool get isFeedEmpty => _posts.isEmpty;

  bool isFirstTime = false;
  bool isLoading = false;

  @override
  onInit() {
    super.onInit();
    homeScrollController = ScrollController();
    requestMoreData(fromInit: true);
  }

  setState(bool value) {
    isLoading = value;
    update();
  }

  List<Post> getPosts() => _posts;

  //return the feature card to home feed view.
  Widget featureCard(int index) {
    if (index > 0) {
      if (index % 31 == 0) {
        return Column(
          children: [
            Container(color: AppColors.divider, height: 6.h),
            featureCards[generateRandomIndex(max: featureCards.length)],
          ],
        );
      }
    }
    return const SizedBox.shrink();
  }

  ///[shouldResetController] is used to reset the controller when there is no post. To avoid
  ///Infinite loading, we are passing it true by default but from reset controller we are making it false so
  ///that it will not reset the controller again and again (inifinite).
  Future requestMoreData({bool fromInit = false, bool isRefresh = false, bool shouldResetController = true}) async {
    // to avoid double loading at top and bottom on screen
    if (fromInit == false) refreshController.callLoad();

    await showSuggestedCommunitiesOrFeatureCards();

    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      setState(true);
    }
    final newPosts = await postServices.requestMoreData(isRefresh: isRefresh);

    MyLoggerServices.to.print("newPosts.length ${newPosts.length}");
    _posts.addAll(newPosts);

    /// In case if there is no post then reset the controller (Refresh view.).
    if (_posts.isEmpty && shouldResetController) {
      return await resetController();
    }
    //sort and distinct in new thread.
    _posts = await CustomIsolatePost.sortPostInThread(_posts);

    setState(false);
    return refreshController.finishLoad(IndicatorResult.success);
  }

  /// Invoke this method to check whether to show the suggested communities or not.
  Future<void> showSuggestedCommunitiesOrFeatureCards() async {
    // if feed is showing first time then check whether to show suggested communities or not.
    // else every time show feature cards.
    if (!showSuggestedCommunities && _feedShowingFirstTime) {
      showSuggestedCommunities = _showSuggestedCommunities;
      debugPrint("showSuggestedCommunities: $showSuggestedCommunities");
      if (showSuggestedCommunities) {
        suggestedCommunities = await getRandomCommunities();
      }
      _feedShowingFirstTime = false;
    } else {
      showSuggestedCommunities = false;
    }
  }

  late ScrollController homeScrollController;

  void scrollToTop() {
    try {
      if (homeScrollController.hasClients == false) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeScrollController.animateTo(
          homeScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.bounceIn,
        );
      });
    } catch (_) {}
  }

  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  //call when new post is posted
  void addAPostLocally(Post post,) {
    _posts.insert(0, post);
    update();
  }

  //call when any post is updated.
  void updatePostLocally(Post post, {bool shouldDelete = false}) {
    print("updatwWIIIITH");
    if (shouldDelete == true) {
      _posts.removeWhere((element) => element.postid == post.postid);
    } else {
      final index = _posts.indexWhere((element) => element.postid == post.postid);
      if (index != -1) {
        // tell us wether to update all of the posts or not.
        bool updateAllPosts = _shouldUpdateAllPostAuthorCrowns(oldPost: _posts[index], newPost: post);
        // update post
        _posts[index] = post;

        /// update all posts where same user posted (specifically for crowns.)
        if (updateAllPosts) {
          _updateAllOfThePostAuthorsCrownslocally(post);
        }
      }
    }

    update();
  }

  void _updateAllOfThePostAuthorsCrownslocally(Post post) {
    try {
      for (int i = 0; i < _posts.length; i++) {
        if (posts[i].memberId == post.memberId) {
          posts[i].postedBy = post.postedBy;
        }
      }
    } catch (_) {}
  }

  void updateAllOfTheCommunitieslocally(Community community) {
    for (int i = 0; i < _posts.length; i++) {
      if (posts[i].communityId == community.communityId) {
        posts[i].community = community;
      }
    }
    update();
  }

  bool _shouldUpdateAllPostAuthorCrowns({required Post oldPost, required Post newPost}) =>
      oldPost.postedBy.userTotalCrowns != newPost.postedBy.userTotalCrowns;

  Post? likePost(String? postId, {UserModel? receiverUser}) {
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return null;
    var post = _posts.firstWhereOrNull((element) => element.postid == postId);

    //checking if the post is already flowered by the user
    bool? isLiked = post?.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");
    debugPrint("post operation isLiked already? $isLiked, total: ${post?.likedBy?.length}");
    if (isLiked == true) {
      EngagementScoreController.to.instance.onDislike(communityId: post?.communityId ?? "", postId: postId);

      final isUnliked = post?.likedBy?.remove(FirebaseAuth.instance.currentUser?.uid ?? "");
      debugPrint("Unlike Success? $isUnliked, total: ${post?.likedBy?.length}");
      unlikeAPost(postId, post?.communityId ?? "");
      operationPerformed = PostReaction.unlike;
    } else if (isLiked == false) {
      //locally
      post?.likedBy?.add(FirebaseAuth.instance.currentUser?.uid ?? "");
      //db operation
      likeAPost(postId, post?.communityId ?? '');

      // score
      EngagementScoreController.to.instance.onLike(communityId: post?.communityId ?? "", postId: postId);
      //send notification
      if (receiverUser != null) {
        sendLikeNotification(postId: postId, user: receiverUser, communityId: post?.communityId ?? "", type: "postLiked");
      }
      operationPerformed = PostReaction.like;
    } else {
      //// CASE WHERE POST WAS NOT PRESENT IN THIS CONTROLLER
      MyLoggerServices.to.print("nothing performed on post");
      return null;
    }
    debugPrint("post operation performed: $operationPerformed");
    update();

    return post;
  }

  final _likeReactionDebounce = Debouncer(delay: const Duration(milliseconds: 500));
  final _helper = HelperFunc();

  Post? likeReactionOnPost(String? postId, {UserModel? receiverUser, String? reaction, bool isChecked = false}) {
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return null;
    var post = _posts.firstWhereOrNull((element) => element.postid == postId);

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
        await likeReactionAPost(postId, post?.communityId ?? '', reactionModel);
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

      unLikeReactionAPost(postId, post?.communityId ?? "");
      // setting post reaction to unlike
      operationPerformed = PostReaction.unlike;
      // updating score of community
      EngagementScoreController.to.instance.onDislike(
        communityId: post?.communityId ?? "",
        postId: postId,
      );
    }
    update();
    return post;
  }

  final Services _commonService = Services();
  UserModel userModel = UserModel.to;

  Future<Post?> crownPost(String? postId, {UserModel? receiverUser}) async {
    debugPrint("user daily crowns are 0");
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return null;
    var post = _posts.firstWhereOrNull((element) => element.postid == postId);
    if (post?.postedBy == null) return null;
    //checking if the post is already flowered by the user
    bool? isCrowned = post?.crownsBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");
    if (isCrowned == true) {
      print('Post already crowned');
      return null;
    } else if (isCrowned == false) {
      print('Post crowning');
      post?.crownsBy ??= [];
      //locally
      post?.crownsBy?.add(currentUserId);
      post!.postedBy = post.postedBy.updateCrown(shouldIncreament: true);
      // cache author update
      CacheController.to.updateUser(post.postedBy);

      final tempCrown = userModel.userDailyCrowns;
      userModel.userDailyCrowns = (userModel.userDailyCrowns != null && userModel.userDailyCrowns != 0)
          ? userModel.userDailyCrowns! - 1
          : userModel.userDailyCrowns;
      // cache currentUser update
      CacheController.to.updateUser(userModel);
      update();

      // Invoke to log crown post event
      AnalyticsController.to.instance.logCrownPost(
        communityId: post.communityId ?? '',
        postId: post.postid ?? '',
        userId: UserModel.to.uId ?? '',
      );

      //db operation
      bool isSuccess = await crownAPost(postId, receiverUser?.uId ?? '', currentUserId);
      if (!isSuccess) {
        post.crownsBy?.remove(currentUserId);
        post.postedBy = post.postedBy.updateCrown(shouldIncreament: false);
        // cache author update
        CacheController.to.updateUser(post.postedBy);
        userModel.userDailyCrowns = tempCrown;
        // cache currentUser update
        CacheController.to.updateUser(userModel);
        operationPerformed = PostReaction.idle;
      } else {
        if (receiverUser != null) {
          _commonService.increaseInfluencePointOnCrownReward(receiverUser.uId);
        }
        EngagementScoreController.to.instance.onCrown(postId: postId, communityId: post.communityId ?? '');
        final CrownsController crownsController = Get.find();

        if (userModel.userDailyCrowns == 0) {
          debugPrint("user daily crowns are 0");
          crownsController.getCrownServerTimeStamp();
        } else {
          crownsController.updateCurrentUser();
        }
        if (receiverUser?.uId != null) {
          sendCrownNotification(postId: postId, user: receiverUser!, communityId: post.communityId!);
        }
        operationPerformed = PostReaction.crown;
      }
      _updateAllOfThePostAuthorsCrownslocally(post);
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }
    update();
    return post;
  }

  Future<void> sendCrownNotification({required String postId, required UserModel user, required String communityId}) async {
    //don't send notification if the user is the same.
    if (userModel.uId == user.uId) return;

    //send fcm notification
    // await _notificationApiHitting.callOnFcmApiSendPushNotifications(gaya_message: postIsLikedNotification, fcmToken: user.fm_token);

    UserModel? userData = await _commonService.getUserById(user.uId, forcefullyServer: true);

    final fcmPostModel = FcmCreatePostModel(
      postid: postId,
      communityId: communityId,
      messageContent: "${userModel.name} ${GayaStrings.dash_has_crowned_post.tr}",
      messageTitle: GayaStrings.your_post_was_crowned_checkout.tr,
      receiverFcm: userData?.fm_token ?? '',
    );

    notificationApi.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

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

  /// update locally and in db the topics
  /// for the post that is being updated...
  Future<void> updatePostTopics({required Post post}) async {
    /// doing db at Utils for feed
    // await _commonService.updatePostTopics(post);
    updatePostLocally(post);
  }

  // A dispose method.
  resetController() async {
    //if feed empty means there was no internet connection
    // so call appConfigInit
    if (isFeedEmpty) {
      await AppConfigurationController.to.loadAppConfiguration();
    }
    _posts = [];
    isFirstTime = false;
    isLoading = false;
    postServices.reset();
    await requestMoreData(fromInit: true, isRefresh: true, shouldResetController: false);
  }

  void onHideCommunity({required String communityId}) {
    _posts.removeWhere((element) => element.communityId == communityId);
    update();
  }

  int generateRandomIndex({required int max}) {
    return _rand.nextInt(max);
  }
}

/// Extension for Communities Suggestions
extension CommunitiesSuggestions on ForYouFeedController {
  ///
  /// STATE VARIABLES
  ///

  /// Service to serve communities
  static final CommunitiesServices _communitiesServices = CommunitiesServices();

  ///
  /// MAIN API'S
  ///

  /// Check whether already joined the community with [communityId]
  bool checkIsCommunityJoined(String communityId) =>
      AppConfigurationController.to.joinedCommunities.any((community) => community.communityId == communityId);

  /// Check whether community joining request sent for [communityId]
  bool checkIsCommunityJoinRequestSent(String communityId) =>
      AppConfigurationController.to.requestSentCommunitiesIds.any((requestCommunityId) => requestCommunityId == communityId);


  /// Invoke to get random communities
  Future<List<Community>> getRandomCommunities() async {

    final List<Community> rndCommunities = [];

    final joinedCommunities = await AppConfigurationController.to.joinedCommunities.map((e) => e.communityId).toList();

    /// fetch the communities that are not joined by the user
    /// and are not hidden
   final List<Community>communities = await _communitiesServices.getCommunityByTopiclist(getRandomUserTopic(), limit: 12);

communities.forEach((community) {
     try {
      print("IsJoined? :${joinedCommunities.contains(community.communityId)}, IsHidden? :${AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? "")}");
        if ((!joinedCommunities.contains(community.communityId) && !AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? ""))){
          rndCommunities.add(community);
          print("Added communti");
        }
      } catch (e) {
        print("Error in makingModel: $e");
      }
 });
 
    return rndCommunities.length > 12 ? rndCommunities.sublist(0, 12) : rndCommunities;
  }

  /// Invoke to check whether to show suggested communities or not
  bool shouldShowSuggestedCommunities(int index) =>
      (showSuggestedCommunities && suggestedCommunities.isNotEmpty && (index == 10 || index == 100));

  ///
  /// HELPER API'S
  ///

  /// Invoke to update the suggested community locally
  updateSuggestedCommunityLocally({required String communityId}) {
    if (communityId.isEmpty) return;
    update([communityId]);
  }

  ///
  /// GETTERS
  ///

  /// Invoke to check whether to show suggested communities or not
  bool get _showSuggestedCommunities => random.nextInt(2) == 1;
  
  String getRandomUserTopic() {
    final int topicCount = UserModel.to.interests?.length ?? 0;
    return UserModel.to.interests?[random.nextInt(topicCount)].title ?? "";
  }
}
