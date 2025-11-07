import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show BuildContext, TabController, TextEditingController, VoidCallback;
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/community/communities/services/communities_services.dart';
import 'package:get/get.dart' show Get, GetNavigation, GetNumUtils, GetxController, Inst;
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:helpers/helpers.dart';
import 'package:provider/provider.dart';

import '../../../components/dialogue.dart';
import '../../../controller/app_config_controller.dart';
import '../../../controller/cache_controller.dart';
import '../../../controller/crowns_controller.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../controller/profile.controller.dart';
import '../../../model/community.model.dart';
import '../../../model/create.post.model.dart';
import '../../../model/user.model.dart';
import '../../../services/notification/notification_api/notification_api.dart';
import '../../../services/services.dart';
import '../../../shared/service/search_service/search_service.dart';
import '../../../utils/enum.dart' show FriendshipStatus, SearchType;
import '../../../utils/local.storage.dart';
import '../../../utils/logger.dart';
import '../../../utils/methods.dart';
import '../../feed/controller/post_controller.dart';
import '../../feed/services/base/post_db_operations.dart';
import '../../feed/services/base/post_notification_operations.dart';
import '../models/friendship_status.dart';
import '../models/searched_post_item.dart';

enum SearchScreenType {
  suggestions,
  search,
}

class GayaSearchController extends GetxController with PostDbOperationsImpl, PostNotificationImpl {
  /// static getter to get instance of GayaSearchController
  static GayaSearchController get to => Get.find();

  /* -------------------------------------------------------------------------- */
  /*                                 PROPERTIES                                 */
  /* -------------------------------------------------------------------------- */
  /* ------------------------ SERVICES AND CONTROLLERS ------------------------ */

  /// Instance of algolia service which helps in searching
  final AlgoliaService algoliaService = AlgoliaService();

  /// screen type:
  SearchScreenType screenType = SearchScreenType.search;

  setScreenType(SearchScreenType screenType) {
    if (this.screenType == screenType) return;
    this.screenType = screenType;
    update();
  }

  /// Finding instance of get storage from get injection for crud
  final GetStorageController getStorage = Get.find<GetStorageController>();

  /// TextEditingController for controlling gaya search text field
  final TextEditingController searchTextEditingController = TextEditingController();

  /// EasyRefreshController for controlling refreshes and pagination
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  /// TabController for controlling search tabs
  TabController? searchTabController;

  /// Debouncer for search (thread waits for 300 milliseconds)
  final Debouncer searchDebouncer = Debouncer(delay: 300.milliseconds);

  /// Instance of user logged in the the app
  UserModel userModel = UserModel.to;

  /// Common helper service to serve in many tasks (notification etc)
  final Services _commonService = Services();

  /* ---------------------------- HELPER VARIABLES ---------------------------- */

  /// Determine what we have to search (e.g. top, community, people, post)
  SearchType _searchType = SearchType.top;

  /// current search tab bar tab index
  int _tabIndex = 0;

  /// callback to pass to on tab change listener to searchTabController
  VoidCallback? onTabChangedListenerCallback;

  /// Helper loader variable to indicate loading
  bool isLoading = false;

  /// whether the search tab bar view widget changes index (rebuild tab)
  bool isTabBarViewTabBuildFirstTime = true;

  /* ----------------------------- STATE VARIABLES ---------------------------- */

  /// List of users which user searches for
  List<UserModel> people = [];

  /// List of communities which user searches for
  List<Community> communities = [];

  /// List of posts which user searches for
  List<Post> posts = [];

  /// List of recent searches data
  List<dynamic> recentSearches = [];

  /// List contains the friendship statues of searched [people]
  List<FriendshipStatusModel> friendshipStatuses = [];

  /* ----------------------- SEARCH PAGINATION VARIABLES ---------------------- */

  /// index search page for algolia
  int page = 0;

  /// whether we have more data to load in the index
  bool hasMoreData = true;

  /* -------------------------------------------------------------------------- */
  /*                                 MAIN API'S                                 */
  /* -------------------------------------------------------------------------- */

  /// Invoke to search top, communities, posts or people (TCPP)
  Future<void> searchTCPP(String textToSearch) async {
    // changing pagination page index to 0
    page = 0;

    // clearing data holder lists
    _clearSearchedDataHolders();

    // If textToSearch is empty, nothing to search
    if (textToSearch.isEmpty) {
      update();
      return;
    }

    // Starting loader
    _startLoader();

    // Tab is already build, making it false
    if (isTabBarViewTabBuildFirstTime) {
      isTabBarViewTabBuildFirstTime = false;
    }

    try {
      // Searching [textToSearch] according to [_searchType] (for current selected tab)
      switch (_searchType) {
        /* ------------------------------- top search ------------------------------- */
        case SearchType.top:
          // getting top results for communities, people and posts
          final results = await Future.wait([
            algoliaService.getCommunitiesWithCommunityText(textToSearch, perPageHits: 5),
            algoliaService.getPostsWithPostText(textToSearch, perPageHits: 5),
            algoliaService.getUsersWithUsernameText(textToSearch, perPageHits: 2),
          ]);

          if (results.isEmpty) return;

          // getting communities from results
          communities = results[0] as List<Community>;
          // getting searchedPostItems from results
          List<SearchedPostItem> searchedPostItems = results[1] as List<SearchedPostItem>;
          // getting people from results
          people = results[2] as List<UserModel>;

          await Future.wait(
            [
              // Invoking to get posts from [searchedPostItems (algolia)]
              _getPostsFromSearchedPostItems(
                searchedPostItems.map((searchedPostItem) => searchedPostItem.postId).toList(),
                searchedPostItems.map((searchedPostItem) => searchedPostItem.postedBy).toList(),
              ),
              // Invoking method to get friend statuses with searched users
              _checkUsersFriendshipStatuses(people),
            ],
          );
          break;
        /* --------------------------- communities search --------------------------- */
        case SearchType.communities:
          await searchCommunities(communityTextToSearch: textToSearch);
          break;
        /* ------------------------------ posts search ------------------------------ */
        case SearchType.posts:
          await searchPosts(postTextToSearch: textToSearch);
          break;
        /* ------------------------------ people search ----------------------------- */
        case SearchType.people:
          await searchPeople(userTextToSearch: textToSearch);
          break;
      }
    } catch (e) {
      MyLoggerServices.to.print('error throw during search in feed error:=>${e.toString()}');
    } finally {
      // Stopping loader
      _stopLoader();
    }
  }

  /* ---------------------------- PAGINATION API'S ---------------------------- */

  /// Invoke to load more data on pagination for (posts, communities and people)
  Future<void> loadMoreData() async {
    try {
      // Searching [textToSearch] according to [_searchType] (for current selected tab)
      switch (_searchType) {
        case SearchType.top:
          break;
        case SearchType.communities:
          await searchCommunities(isInitial: false);
          break;
        case SearchType.posts:
          await searchPosts(isInitial: false);
          break;
        case SearchType.people:
          await searchPeople(isInitial: false);
          break;
      }
    } catch (e) {
      MyLoggerServices.to.print('error throw during search in feed error:=>${e.toString()}');
    } finally {
      // Stopping loader
      update();
    }
  }

  /// invoke to search communities
  /// [communityTextToSearch] searchable community text
  /// [isInitial] is true so to get communities from first page (means fetching initially)
  Future<void> searchCommunities({
    String? communityTextToSearch,
    bool isInitial = true,
  }) async {
    final loadedCommunities = await algoliaService.getCommunitiesWithCommunityText(
      communityTextToSearch ?? searchTextEditingController.text,
      page: page,
      perPageHits: 10,
    );

    // checking isInitial is false (means users scrolls to end)
    if (!isInitial) {
      // Incrementing page for pagination
      page++;
    }

    // If we got nothing on fetch
    if (loadedCommunities.isEmpty) return;

    // adding loaded communities to our communities list
    communities.addAll(loadedCommunities);

    // Checking if length is not equal to 10 (no more data to fetch)
    if (loadedCommunities.length != 10) {
      hasMoreData = false;
      // Indicating refresh controller that no data to fetch more
      refreshController.finishLoad(IndicatorResult.noMore);
    } else {
      // Indicating refresh controller that data fetched with success
      refreshController.finishLoad(IndicatorResult.success);
    }
  }

  /// invoke to search posts
  /// [postTextToSearch] searchable post text
  /// [isInitial] is true so to get post from first page (means fetching initially)
  Future<void> searchPosts({
    String? postTextToSearch,
    bool isInitial = true,
  }) async {
    // getting list of searched post items
    List<SearchedPostItem> searchedPostItems = await algoliaService.getPostsWithPostText(
      postTextToSearch ?? searchTextEditingController.text,
      page: page,
      perPageHits: 10,
    );

    // checking isInitial is false (means users scrolls to end)
    if (!isInitial) {
      // Incrementing page for pagination
      page++;
    }

    // If we got nothing on fetch
    if (searchedPostItems.isEmpty) return;

    // Invoking to get posts from [searchedPostItems (algolia)]
    await _getPostsFromSearchedPostItems(
      searchedPostItems.map((searchedPostItem) => searchedPostItem.postId).toList(),
      searchedPostItems.map((searchedPostItem) => searchedPostItem.postedBy).toList(),
    );

    // Checking if length is not equal to 10 (no more data to fetch)
    if (searchedPostItems.length != 10) {
      hasMoreData = false;
      // Indicating refresh controller that no data to fetch more
      refreshController.finishLoad(IndicatorResult.noMore);
    } else {
      // Indicating refresh controller that data fetched with success
      refreshController.finishLoad(IndicatorResult.success);
    }
  }

  /// invoke to search people (users)
  /// [userTextToSearch] searchable people text
  /// [isInitial] is true so to get people from first page (means fetching initially)
  Future<void> searchPeople({
    String? userTextToSearch,
    bool isInitial = true,
  }) async {
    // getting searched list of people with [userTextToSearch]
    final loadedPeople = await algoliaService.getUsersWithUsernameText(
      userTextToSearch ?? searchTextEditingController.text,
      page: page,
      perPageHits: 20,
    );

    // checking isInitial is false (means users scrolls to end)
    if (!isInitial) {
      // Incrementing page for pagination
      page++;
    }

    // If we got nothing on fetch
    if (loadedPeople.isEmpty) return;

    // added fetched people to people list
    people.addAll(loadedPeople);

    // Invoking method to get friend statuses with searched users
    await _checkUsersFriendshipStatuses(loadedPeople);

    // Checking if length is not equal to 20 (no more data to fetch)
    if (loadedPeople.length != 20) {
      hasMoreData = false;
      // Indicating refresh controller that no data to fetch more
      refreshController.finishLoad(IndicatorResult.noMore);
    } else {
      // Indicating refresh controller that data fetched with success
      refreshController.finishLoad(IndicatorResult.success);
    }
  }

  final CommunitiesServices _communitiesServices = CommunitiesServices();

  /// Invoke to get random communities from firestore
  Future<List<Community>> getRandomCommunities() => _communitiesServices.getHotCommunities();

  /* -------------------------------------------------------------------------- */
  /*                                HELPER API'S                                */
  /* -------------------------------------------------------------------------- */

  /// Invoke to start the loader
  void _startLoader([String? id]) {
    isLoading = true;
    if (id != null) {
      update([id]);
    } else {
      update();
    }
  }

  /// Invoke to stop the loader
  void _stopLoader([String? id]) {
    isLoading = false;
    if (id != null) {
      update([id]);
    } else {
      update();
    }
  }

  /// Invoke to add [item] to recent search
  void addToRecentSearch(String item) {
    try {
      if (!(recentSearches.contains(item))) {
        // to show more recent search,inserted it 0 index
        recentSearches.insert(0, item);
        getStorage.storeRecentSearchedList(recentSearches: recentSearches);
      }
      update();
    } catch (e) {
      MyLoggerServices.to.print('error=>${e.toString()}');
    }
  }

  /// Invoke to remove item from recent searches at [index]
  void removeFromRecentSearch(int index) {
    try {
      recentSearches.removeAt(index);
      update();
      getStorage.storeRecentSearchedList(recentSearches: recentSearches);
    } catch (e) {
      MyLoggerServices.to.print('error=>${e.toString()}');
    }
  }

  /// Invoke to attach on tab change listener to tab controller
  void attachOnTabChangeListenerToTabController() {
    searchTabController?.addListener(
      onTabChangedListenerCallback ??= () {
        // changing search type only when the tab exactly changes
        if (searchTabController?.index != _tabIndex) {
          _tabIndex = searchTabController!.index;
          // changing pagination settings
          page = 0;
          hasMoreData = true;
          // setting search type according to current search tab
          _setSearchTypeForCurrentTab();
          // clearing searched data holder lists
          _clearSearchedDataHolders();
          // updating tab for search
          update();
          // TabBarView change the index so tab build again
          isTabBarViewTabBuildFirstTime = true;
          // enabling search automatically on tab change
          searchTCPP(searchTextEditingController.text);
        }
      },
    );
  }

  /// Check whether already joined the community with [communityId]
  bool checkIsCommunityJoined(String communityId) =>
      AppConfigurationController.to.joinedCommunities.any((community) => community.communityId == communityId);

  /// Check whether community joining request sent for [communityId]
  bool checkIsCommunityJoinRequestSent(String communityId) =>
      AppConfigurationController.to.requestSentCommunitiesIds.any((requestCommunityId) => requestCommunityId == communityId);

  /// Invoke to setting search type according to current search tab index.
  /// Setting search type because we have to search for specific searchType
  void _setSearchTypeForCurrentTab() {
    switch (searchTabController?.index) {
      case 0:
        _searchType = SearchType.top;
        break;
      case 1:
        _searchType = SearchType.communities;
        break;
      case 2:
        _searchType = SearchType.posts;
        break;
      case 3:
        _searchType = SearchType.people;
        break;
      default:
        _searchType = SearchType.top;
    }
  }

  /// Invoke to get friendship status of [people]
  Future<void> _checkUsersFriendshipStatuses(List<UserModel> people) async {
    // breaking out people list in a set of 10, 10 sub lists -> List<List<String>> (Total 20 hits)
    List<List<String>> usersUIdsSets = Methods.generateListOfChunks<String>(
      people.map((person) => person.uId!).toList(),
      10,
    );

    // getting all friendship (querySnapshots -> docs) with Recieveruid -> [usersUIdsSets]
    final friendshipQuerySnapshots1 = await Future.wait(
      usersUIdsSets.map(
        (usersIdsChunk) => FirebaseFirestore.instance
            .collection('friendship')
            .where(
              Filter.and(
                Filter('Recieveruid', whereIn: usersIdsChunk),
                Filter('senderUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid),
              ),
            )
            .get(),
      ),
    );

    // getting all friendship (querySnapshots -> docs) with senderUid -> [usersUIdsSets]
    final friendshipQuerySnapshots2 = await Future.wait(
      usersUIdsSets.map(
        (usersIdsChunk) => FirebaseFirestore.instance
            .collection('friendship')
            .where(
              Filter.and(
                Filter('senderUid', whereIn: usersIdsChunk),
                Filter('Recieveruid', isEqualTo: FirebaseAuth.instance.currentUser!.uid),
              ),
            )
            .get(),
      ),
    );

    // appending all query snapshots
    final friendshipQuerySnapshots = [...friendshipQuerySnapshots1, ...friendshipQuerySnapshots2];

    // if the friendshipQuerySnapshots is empty no friendships in any set
    if (friendshipQuerySnapshots.isEmpty) {
      return;
    }

    // query across all query snapshot (set of docs)
    for (var friendshipQuerySnapshot in friendshipQuerySnapshots) {
      // if friendshipQuerySnapshot is empty no friendships in this set
      if (friendshipQuerySnapshot.docs.isEmpty) {
        continue;
      }

      // query across all query docs
      for (final friendshipDoc in friendshipQuerySnapshot.docs) {
        String senderUid = friendshipDoc.data()['senderUid'];
        String receiverUid = friendshipDoc.data()['Recieveruid'];

        // checking whether the sender or receiver user id is not mine
        if (senderUid != FirebaseAuth.instance.currentUser!.uid && receiverUid != FirebaseAuth.instance.currentUser!.uid) {
          continue;
        }

        // adding FriendshipStatusModel if any doc has my id as sender or receiver
        friendshipStatuses.add(
          // Creating FriendshipStatusModel from friendshipDoc
          FriendshipStatusModel.fromMap(
            friendshipDoc.data(),
            FirebaseAuth.instance.currentUser!.uid,
            friendshipDoc.id,
          ),
        );
      }
    }
  }

  /// Invoke to check do we have a friendship with [userId]
  FriendshipStatusModel? isUserFriend(String userId) {
    return friendshipStatuses.firstWhereOrNull(
      (friendshipStatus) => friendshipStatus.receiverUid == userId || friendshipStatus.senderUId == userId,
    );
  }

  /// Callback for PeopleContainerButton
  Future<void> onPeopleContainerButtonTapCallback({
    required FriendshipStatusModel? friendshipStatusModel,
    required BuildContext context,
    required UserModel user,
  }) async {
    // starting loader
    _startLoader(user.uId);

    // getting user data from firestore
    await context.read<ProfileController>().getUserDetails().whenComplete(
      () async {
        // checking if there is any friendship already exist
        if (friendshipStatusModel != null) {
          switch (friendshipStatusModel.friendshipStatus) {
            /* -------------------------------- addFriend ------------------------------- */
            case FriendshipStatus.addFriend:
              await _createFriendship(context, user);
              break;
            /* -------------------------------- unFriend -------------------------------- */
            case FriendshipStatus.unFriend:
              DialogueC(
                user.name ?? '',
                () async {
                  Get.back();
                  await context.read<ProfileController>().unFriend(user.uId!);
                  friendshipStatuses.remove(friendshipStatusModel);
                  _stopLoader(user.uId);
                },
                context,
              );
              break;
            /* ------------------------------ acceptRequest ----------------------------- */
            case FriendshipStatus.acceptRequest:
              await context.read<ProfileController>().acceptFriendRequest(
                    friendshipStatusModel.friendshipDocId,
                  );
              int index = friendshipStatuses.indexOf(friendshipStatusModel);
              friendshipStatuses.replaceAt(
                index,
                friendshipStatusModel.copyWith(friendshipStatus: FriendshipStatus.unFriend),
              );
              break;
            /* ------------------------------- requestSent ------------------------------ */
            case FriendshipStatus.requestSent:
              await context.read<ProfileController>().unFriend(user.uId!);
              friendshipStatuses.remove(friendshipStatusModel);
              break;
          }
        } else {
          await _createFriendship(context, user);
        }

        _stopLoader(user.uId);
      },
    );
  }

  /// Invoke to create friendship with [user]
  Future<void> _createFriendship(
    BuildContext context,
    UserModel user,
  ) async {
    final myDetails = context.read<ProfileController>().userDetails!;
    await context.read<ProfileController>().createFriendShip(
          user.uId ?? '',
          user.name ?? '',
          myDetails['name'] ?? '',
          myDetails['profilePic'] ?? '',
          user.fm_token,
        );

    // adding newly created friendship status to friendshipStatuses
    friendshipStatuses.add(
      FriendshipStatusModel(
        friendshipDocId: '',
        senderUId: FirebaseAuth.instance.currentUser!.uid,
        receiverUid: user.uId ?? '',
        meAsSender: true,
        friendshipStatus: FriendshipStatus.requestSent,
      ),
    );
  }

  final _commonServices = Services.to;

  /// Invoke to get Posts from user searched text (using algolia -> [searchedPostItemsIds])
  /// Getting list of posted by users because the users data is in-completed in the post model
  Future<void> _getPostsFromSearchedPostItems(
    List<String> searchedPostItemsIds,
    List<String> postedByUserIds,
  ) async {
    try {
      if (searchedPostItemsIds.isEmpty) return;
      // getting all posts with [searchedPostItemsIds] and users with [postedByUserIds]
      final postsWithPostedByUsersSnapshot = await Future.wait(
        [
          FirebaseFirestore.instance
              .collection('communityposts')
              .where(FieldPath.documentId, whereIn: searchedPostItemsIds)
              .limit(10)
              .get(),
          FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: postedByUserIds).limit(10).get(),
        ],
      );

      // checking if there is any posts and users exist
      if (postsWithPostedByUsersSnapshot.isEmpty) return;

      // getting all searched posts
      final searchedPostsQuerySnapshot = postsWithPostedByUsersSnapshot[0];
      // getting all searched posts users
      final searchedPostsPostedUsersQuerySnapshot = postsWithPostedByUsersSnapshot[1];

      // checking if there is any user exist
      if (searchedPostsPostedUsersQuerySnapshot.docs.isEmpty) return;
      // checking if there is any post exist
      if (searchedPostsQuerySnapshot.docs.isEmpty) return;

      // creating list of users who posted the posts
      List<UserModel> postedByUsers = searchedPostsPostedUsersQuerySnapshot.docs
          .map(
            (userQueryDocSnapshot) => UserModel.fromMap(
          userQueryDocSnapshot.data(),
        ),
      )
          .toList();

      final rawPosts = searchedPostsQuerySnapshot.docs;
      for (var rawPost in rawPosts) {
        final postModel = Post.fromMap(rawPost.data());
        final reactionModel = await _commonServices.getUserReactionOnPost(postModel.postid ?? '');
        postModel.reactionModel = reactionModel;

        List<CommentCustomModel> comments =
        await _commonServices.loadPostRecentCommentsFromPostMap(postModel.postedBy, map: rawPost.data());
        postModel.recentComments = comments;
        posts.add(postModel);
      }
    } catch (e) {
      debugPrint("Err _getPostsFromSearchedPostItems: " + e.toString());
    }
  }

  /// Invoke to like or unlike a post with [postId]
  Post? likeOrUnlikePost(
    String? postId, {
    UserModel? receiverUser,
  }) {
    // Initial post reaction
    PostReaction operationPerformed = PostReaction.idle;

    if (postId == null) return null;

    // Getting post from [posts] to which we have to react like or unlike
    var post = posts.firstWhereOrNull(
      (postModel) => postModel.postid == postId,
    );

    //checking if the post is already liked by me
    bool? isLiked = post?.likedBy?.contains(
      FirebaseAuth.instance.currentUser?.uid ?? "",
    );
    debugPrint("post operation isLiked already? $isLiked, total: ${post?.likedBy?.length}");
    // if user already liked the post
    if (isLiked != null && isLiked) {
      // disliking post locally (inside posts list)
      final isUnLiked = post?.likedBy?.remove(
        FirebaseAuth.instance.currentUser?.uid ?? "",
      );
      debugPrint("Unlike Success? $isUnLiked, total: ${post?.likedBy?.length}");
      // disliking post to remote db
      unlikeAPost(postId, post?.communityId ?? "");
      // setting post reaction to unlike
      operationPerformed = PostReaction.unlike;
      // updating score of community
      EngagementScoreController.to.instance.onDislike(
        communityId: post?.communityId ?? "",
        postId: postId,
      );
    } else if (isLiked != null && !isLiked) {
      // liking post locally (inside posts list)
      post?.likedBy?.add(FirebaseAuth.instance.currentUser?.uid ?? "");
      // liking post to remote db
      likeAPost(postId, post?.communityId ?? '');
      // setting post reaction to like
      operationPerformed = PostReaction.like;
      // updating score of community
      EngagementScoreController.to.instance.onLike(
        communityId: post?.communityId ?? "",
        postId: postId,
      );

      // sending notification to the post posted user that your post is liked
      if (receiverUser != null) {
        // sending like notification
        sendLikeNotification(postId: postId, user: receiverUser, communityId: post?.communityId ?? "", type: "postLiked");
      }
    } else {
      // CASE WHERE POST WAS NOT PRESENT IN THIS CONTROLLER
      MyLoggerServices.to.print("nothing performed on post");
      return null;
    }
    debugPrint("post operation performed: $operationPerformed");

    // update([postId]);
    return post;
  }

  final _likeReactionDebounce = Debouncer(delay: const Duration(milliseconds: 500));
  final _helper = HelperFunc();

  /// Invoke to like or unlike a post with [postId]
  Post? likeOrUnlikeReactionOnPost(String? postId, {UserModel? receiverUser, String? reaction, bool isChecked = false}) {
    // Initial post reaction
    PostReaction operationPerformed = PostReaction.idle;

    if (postId == null) return null;

    // Getting post from [posts] to which we have to react like or unlike
    var post = posts.firstWhereOrNull(
      (postModel) => postModel.postid == postId,
    );

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
      _likeReactionDebounce(() {
        likeReactionAPost(postId, post?.communityId ?? '', reactionModel);
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
    // update([postId]);
    return post;
  }

  /// Invoke to crown a post with [postId]
  Future<Post?> crownPost(
    String? postId, {
    UserModel? receiverUser,
  }) async {
    if (postId == null) return null;

    // getting post from posts with [postId]
    var post = posts.firstWhereOrNull(
      (postModel) => postModel.postid == postId,
    );

    if (post?.postedBy == null) return null;

    //checking if the post is already crowned by the user
    bool? isCrowned = post?.crownsBy?.contains(
      FirebaseAuth.instance.currentUser?.uid ?? "",
    );

    if (isCrowned != null && isCrowned) {
      debugPrint('Post already crowned');
      return null;
    } else if (isCrowned != null && !isCrowned) {
      debugPrint('Post crowning');
      // Assigning empty list to post -> crownsBy if it is null
      post?.crownsBy ??= [];

      // Adding me as a crowner LOCALLY
      post?.crownsBy?.add(FirebaseAuth.instance.currentUser?.uid ?? "");
      // Incrementing post posted user crowns in post
      post!.postedBy = post.postedBy.updateCrown(shouldIncreament: true);
      // Updating user crowns in cache
      CacheController.to.updateUser(post.postedBy);

      // Getting current user (me) crowns in tempCrowns
      final tempCrowns = userModel.userDailyCrowns;
      // Decrementing the current user crowns by 1 (spent on post)
      userModel.userDailyCrowns = (userModel.userDailyCrowns != null && userModel.userDailyCrowns != 0)
          ? userModel.userDailyCrowns! - 1
          : userModel.userDailyCrowns;
      // Cache current user (me) in cache
      CacheController.to.updateUser(userModel);

      // Adding me as a crowner REMOTE DB
      bool isSuccess = await crownAPost(
        postId,
        receiverUser?.uId ?? '',
        FirebaseAuth.instance.currentUser?.uid ?? "",
      );

      // Invoke to log crown post event
      AnalyticsController.to.instance.logCrownPost(
        communityId: post.communityId ?? '',
        postId: post.postid ?? '',
        userId: UserModel.to.uId ?? '',
      );

      // If crowned post on db not done successfully
      if (!isSuccess) {
        // Removing me as a crowner LOCALLY
        post.crownsBy?.remove(FirebaseAuth.instance.currentUser?.uid ?? "");
        // Decrementing post posted user crowns in post
        post.postedBy = post.postedBy.updateCrown(shouldIncreament: false);
        // cache author update
        CacheController.to.updateUser(post.postedBy);

        // Assigning old crowns to to me
        userModel.userDailyCrowns = tempCrowns;
        // Updating current user (me) in cache
        CacheController.to.updateUser(userModel);
      } else {
        if (receiverUser != null) {
          _commonService.increaseInfluencePointOnCrownReward(receiverUser.uId);
        }
        // Incrementing score of community via crown on post with [postId]
        EngagementScoreController.to.instance.onCrown(
          postId: postId,
          communityId: post.communityId ?? '',
        );

        final CrownsController crownsController = Get.find();
        // if my crowns reaches to 0
        if (userModel.userDailyCrowns == 0) {
          debugPrint("user daily crowns are 0");
          // setting timer for getting new crown after timeStamp
          crownsController.getCrownServerTimeStamp();
        } else {
          // updating current user (my) crowns everywhere
          crownsController.updateCurrentUser();
        }
        if (receiverUser?.uId != null) {
          // sending crown receiving notification to crown receiver
          _sendCrownNotification(
            postId: postId,
            receiverUser: receiverUser!,
            communityId: post.communityId!,
          );
        }
      }
      _updateAllOfThePostAuthorsCrownsLocally(post);
    } else {
      MyLoggerServices.to.print("nothing performed on post");
    }

    return post;
  }

  /// Invoke to send crown notification to [receiverUser]
  Future<void> _sendCrownNotification({
    required String postId,
    required UserModel receiverUser,
    required String communityId,
  }) async {
    //don't send notification if the user is the same.
    if (userModel.uId == receiverUser.uId) return;
    UserModel? userData = await _commonService.getUserById(receiverUser.uId, forcefullyServer: true);

    final fcmPostModel = FcmCreatePostModel(
      postid: postId,
      communityId: communityId,
      messageContent: "${userModel.name} ${GayaStrings.dash_has_crowned_post.tr}",
      messageTitle: GayaStrings.post_is_crowned_notification.tr,
      receiverFcm: userData?.fm_token ?? '',
    );

    notificationApi.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

    //store notification
    _commonService.addNotification(
      posId: postId,
      isRead: false,
      body: "${userModel.name} ${GayaStrings.dash_has_crowned_post.tr}",
      receiverUserID: receiverUser.uId ?? '',
      senderId: UserModel.to.uId!,
      title: GayaStrings.post_is_crowned_notification.tr,
      time: DateTime.now().toString(),
      type: "postCrowned",
      userImage: UserModel.to.profilePicture ?? "",
    );
  }

  void _updateAllOfThePostAuthorsCrownsLocally(Post post) {
    try {
      for (int i = 0; i < posts.length; i++) {
        if (posts[i].memberId == post.memberId) {
          posts[i].postedBy = post.postedBy;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to update [post] locally in controller
  void updatePostLocally(
    Post post, {
    bool shouldDelete = false,
  }) {
    // whether to delete the post
    if (shouldDelete) {
      // removing post where postId equal to [post]
      posts.removeWhere(
        (postModel) => postModel.postid == post.postid,
      );
    } else {
      // getting post index
      final index = posts.indexWhere(
        (postModel) => postModel.postid == post.postid,
      );
      if (index != -1) {
        // updating post in posts
        posts[index] = post;
      }
    }

    if (shouldDelete) {
      update();
    } else {
      update([post.postid!]);
    }
  }

  /// Invoke to clear state of controller
  void clearState() {
    // Clearing search data holders
    _clearSearchedDataHolders();
    // removing search screen with tab bar so when build again build first time gonna true
    isTabBarViewTabBuildFirstTime = true;
    // clearing search text editing field
    searchTextEditingController.clear();
    // Making loader variable to false
    isLoading = false;
    // setting search tab bar index
    searchTabController!.animateTo(0);

    update();
  }

  /// Invoke to clear all the searched data holder lists
  void _clearSearchedDataHolders() {
    people.clear();
    communities.clear();
    posts.clear();
    friendshipStatuses.clear();
  }

  /* -------------------------------------------------------------------------- */
  /*                               LIFECYCLE API'S                              */
  /* -------------------------------------------------------------------------- */
  @override
  void onInit() {
    super.onInit();
    recentSearches = getStorage.getRecentSearchedList() ?? [];
  }

  /// Removing onTabChangedListenerCallback listener from searchTabController
  void disposeTabController() {
    searchTabController?.removeListener(onTabChangedListenerCallback!);
    searchTabController?.dispose();
    searchTabController = null;
    onTabChangedListenerCallback = null;
  }

  @override
  void dispose() {
    // Clear controller state
    clearState();

    searchTextEditingController.dispose();
    refreshController.dispose();
    searchDebouncer.cancel();
    super.dispose();
  }
}
