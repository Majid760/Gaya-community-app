

enum PostReaction { like, unlike, save, unSave, report, unReport, idle, crown }

/*class FeedPostsController extends GetxController with PostDbOperationsImpl, PostNotificationImpl {
  static FeedPostsController get to => Get.find();
  List<Post> _posts = [];
  final postServices = PostFeedServices();

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

  Future<void> requestMoreData({bool fromInit = false, bool isRefresh = false}) async {
    // to avoid double loading at top andbottom on screen
    if (fromInit == false) refreshController.callLoad();

    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) setState(true);
    isFirstTime = true;
    final newPosts = await postServices.requestMoreData(isRefresh: isRefresh);
    MyLoggerServices.to.print("newPosts.length ${newPosts.length}");
    _posts.addAll(newPosts);

    //sort and distinct in new thread.
    _posts = await CustomIsolatePost.sortPostInThread(_posts);

    setState(false);
  }

  late ScrollController homeScrollController;

  void scrollToTop() {
    try {
      if (homeScrollController.hasClients == false) return;
      if (homeScrollController.position.minScrollExtent == homeScrollController.position.maxScrollExtent) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeScrollController.animateTo(
          homeScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.bounceIn,
        );
      });
    } catch (_) {}
  }

  EasyRefreshController refreshController = EasyRefreshController();

  //call when new post is posted
  void addAPostLocally(Post post) {
    _posts.insert(0, post);
    update();
  }

  //call when any post is updated.
  void updatePostLocally(Post post, {bool shouldDelete = false}) {
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
    for (int i = 0; i < _posts.length; i++) {
      if (posts[i].memberId == post.memberId) {
        posts[i].postedBy = post.postedBy;
      }
    }
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

  PostReaction likePost(String? postId, {UserModel? receiverUser, PostReaction? performForcefully}) {
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return operationPerformed;
    var post = _posts.firstWhereOrNull((element) => element.postid == postId);

    if (performForcefully != null && performForcefully != PostReaction.idle) {
      if (performForcefully == PostReaction.unlike) {
        post?.likedBy?.remove(FirebaseAuth.instance.currentUser?.uid ?? "");
        operationPerformed = PostReaction.unlike;
      } else {
        post?.likedBy?.add(FirebaseAuth.instance.currentUser?.uid ?? "");
        operationPerformed = PostReaction.like;
      }
      update();
      return operationPerformed;
    }
    //checking if the post is already flowered by the user
    bool? isLiked = post?.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");

    if (isLiked == true) {
      EngagementScoreController.to.instance.onDislike(communityId: post?.communityId ?? "", postId: postId);
      post?.likedBy?.remove(FirebaseAuth.instance.currentUser?.uid ?? "");
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
        sendLikeNotification(postId: postId, user: receiverUser, communityId: post?.communityId ?? "");
      }
      operationPerformed = PostReaction.like;
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }
    update();
    MyLoggerServices.to.print("Organic post liked by ${post?.likedBy}");
    return operationPerformed;
  }

  final Services _commonService = Services();
  UserModel userModel = UserModel.to;

  Future<PostReaction> crownPost(String? postId, {UserModel? receiverUser, PostReaction? performForcefully}) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return operationPerformed;
    var post = _posts.firstWhereOrNull((element) => element.postid == postId);
    if (post?.postedBy == null) return operationPerformed;

    /// case where user already done the reaction from different feed.
    /// so we need to update the post locally only here in this controller.
    if (performForcefully != PostReaction.idle && performForcefully != null && performForcefully == PostReaction.crown) {
      //locally
      // post?.crownsBy?.add(currentUserId);
      // post!.postedBy = post.postedBy.updateCrown(shouldIncreament: true);
      update();
      return performForcefully;
    }

    //checking if the post is already flowered by the user
    bool? isCrowned = post?.crownsBy?.contains(FirebaseAuth.instance.currentUser?.uid ?? "");
    if (isCrowned == true) {
      print('Post already crowned');
      return operationPerformed;
    } else if (isCrowned == false) {
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
      //db operation
      bool isSuccess = await crownAPost(postId, receiverUser?.uId ?? '', currentUserId);
      if (!isSuccess) {
        post.crownsBy?.remove(currentUserId);
        post.postedBy = post.postedBy.updateCrown(shouldIncreament: false);
        // cache author update
        CacheController.to.updateUser(post.postedBy);
        userModel.userDailyCrowns = tempCrown;
        //(userModel.userDailyCrowns != null) ? userModel.userDailyCrowns! + 1 : userModel.userDailyCrowns;
        // cache currentUser update
        CacheController.to.updateUser(userModel);
        operationPerformed = PostReaction.idle;
      } else {
        EngagementScoreController.to.instance.onCrown(postId: postId, communityId: post.communityId ?? '');
        final CrownsController crownsController = Get.find();

        if (userModel.userDailyCrowns == 0) {
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
      //send notification
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }

    update();
    return operationPerformed;
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
        receiverUserID: user.uId ?? '',
        senderId: UserModel.to.uId!,
        title: GayaStrings.your_post_was_crowned_checkout.tr,
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
  void resetController() async {
    //if feed empty means there was no internet connection
    // so call appConfigInit
    if (isFeedEmpty) {
      await AppConfigurationController.to.loadAppConfiguration();
    }
    _posts = [];
    isFirstTime = false;
    isLoading = false;
    postServices.reset();
    await requestMoreData(fromInit: true, isRefresh: true);
  }

  void onHideCommunity({required String communityId}) {
    _posts.removeWhere((element) => element.communityId == communityId);
    update();
  }
}*/
