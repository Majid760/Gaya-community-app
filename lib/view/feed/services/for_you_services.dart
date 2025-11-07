import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/topic.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/create_post/models/post_poll_model.dart';

import '../../../controller/firebase_analytics_controller.dart';
import '../../../model/community.model.dart';
import '../../../model/create.post.model.dart';
import '../../../model/reaction_model.dart';

int randomNumberF = 30;
int randomNumberC = 100;
// there function 50, 60

/// currently fetching in sorted form either public or private/secret.
class ForYouFeedServices extends IPostImpl {
  DocumentSnapshot? _lastOrganicPostRef;
  DocumentSnapshot? _lastHighScorePostRef;
  bool _hasMoreOrganicPosts = true;
  int _currentHighPostIndex = 0;

  void reset() {
    _lastOrganicPostRef = null;
    _lastHighScorePostRef = null;
    _hasMoreOrganicPosts = true;
    _currentHighPostIndex = 0;
  }

  bool get isGuestUser => FirebaseAuth.instance.currentUser == null;

  Future<List<Post>> _requestPosts({bool isRefresh = false}) async {
    /// If user is guest, then fetch only high score posts.
    if (isGuestUser) {
      return await __guestRequestPost(isRefresh: isRefresh);
    }

    /// Fetch for logged in user.
    ///
    /// to reset the hightscore post index because we are fetching new posts.
    _currentHighPostIndex = 0;

    /// Contains both highScorePosts + OrganicPosts.
    List<Post> newPosts = [];
    try {
      performance.startHomeFeedLoadTime();

      /// organic
      Query<Map<String, dynamic>> organicQuery = _postsQueryV2.orderBy("createdOn", descending: true).limit(postLimitSize);

      // _logger.print("organic Query v2 #${organicQuery.parameters}");

      /// high score
      // Query<Map<String, dynamic>> highScoreQuery = highScorePostQuery(isRefresh: isRefresh);

      /// organic
      if (_lastOrganicPostRef != null) {
        organicQuery = organicQuery.startAfterDocument(_lastOrganicPostRef!);
      }

      // /// high score
      // if (_lastHighScorePostRef != null) {
      //   // _logger.print("==> STARTING AFTER HIGH SCORE POST: ${_lastHighScorePostRef!.id}");
      //   highScoreQuery = highScorePostQuery(isRefresh: isRefresh).startAfterDocument(_lastHighScorePostRef!);
      // }

      if (_hasMoreOrganicPosts == false) {
        performance.stopHomeFeedLoadTime();

        if (!isAllTopics) {}

        return [];
      }

      List<Post> posts = [];

      /// organic hitting + high score, both at once
      final multiPostsSnap = await Future.wait([
        organicQuery.get(),
        // highScoreQuery.get(),
      ]);
      // stopwatch.stop();

      /// organic snap
      final organicPostSnap = multiPostsSnap[0];
      _logger.print("postSnapshot feed data length: ${organicPostSnap.docs.length}");

      if (organicPostSnap.docs.isNotEmpty) {
        _lastOrganicPostRef = organicPostSnap.docs.last;
      } else {
        _logger.print("==> NO MORE ORGANIC POSTS");
        _hasMoreOrganicPosts = false;

        ///
        isAllTopics = true;
        return [];
      }
      var localPosts = await _parseInIsolation(organicPostSnap);

      /// highscore snap
      // // final highScorePostSnap = multiPostsSnap[1];
      // _logger.print("highScorePostSnap feed data length: ${highScorePostSnap.docs.length}");
      // if (highScorePostSnap.docs.isNotEmpty) {
      //   _lastHighScorePostRef = highScorePostSnap.docs.last;
      // }
      // var highScorePosts = await _parseInIsolation(highScorePostSnap);

      /// merge both list but with 3 organic and 1 high score algorithm
      for (var i = 0; i < localPosts.length; i++) {
        /// check if community is hidden or not
        if (appConfig.isHiddenCommunityV2(communityId: localPosts[i].communityId)) {
          continue;
        }

        posts.add(localPosts[i]);

        // /// check if high score posts are avialable
        // if (getModulusHighScorePosts(i: i, isRefresh: isRefresh) && _currentHighPostIndex < highScorePosts.length) {
        //   // highScorePosts[_currentHighPostIndex].community.communityName = "Trending";
        //   if (isRefresh) {
        //     highScorePosts.shuffle();
        //   }
        //   posts.add(highScorePosts[_currentHighPostIndex]);
        //   _currentHighPostIndex = _currentHighPostIndex + 1;
        // }
      }

      newPosts = posts;

      /// if refresh, shuffle posts randomly
      if (isRefresh) {
        newPosts.shuffle();
      }

      // _logger.print('time elapsed ${stopwatch.elapsed}');

      _hasMoreOrganicPosts = localPosts.length == postLimitSize;
      performance.stopHomeFeedLoadTime();
    } catch (_) {
      performance.stopHomeFeedLoadTime();
    }
    return newPosts;
  }

  /// Change modulus according to the [isRefresh] value.
  bool getModulusHighScorePosts({bool isRefresh = false, required int i}) {
    // if (isRefresh) {
    //   return i % 5 == 0;
    // }

    int rand = (random.nextInt(15 - 10) + 10);
    return i % rand == 0;
  }

  final Random random = Random();

  /// make query according to available chunked list.
  @Deprecated('Use [_postsQueryV2] instead')
  Query<Map<String, dynamic>> get _postsQueryV1 {
    final communitiesList = _splitCommunitiesIntoSublist(sortByInterest: true, isRefresh: true, sortByLastPostAt: true);
    late Query<Map<String, dynamic>> query;
    final length = communitiesList.length;

    if (length == 2) {
      _logger.print("2 communities");
      query = FirebaseFirestore.instance.collection("communityposts").where(
            Filter.and(
              Filter("isDeleted", isEqualTo: false),
              Filter("approve", isEqualTo: true),
              Filter.or(
                Filter('communityId', whereIn: communitiesList[0]),
                Filter('communityId', whereIn: communitiesList[1]),
              ),
            ),
          );
    } else if (length > 3) {
      _logger.print("3 communities");
      query = FirebaseFirestore.instance.collection("communityposts").where(
            Filter.and(
              Filter("isDeleted", isEqualTo: false),
              Filter("approve", isEqualTo: true),
              Filter.or(
                Filter('communityId', whereIn: communitiesList[0]),
                Filter('communityId', whereIn: communitiesList[1]),
                Filter('communityId', whereIn: communitiesList[2]),
              ),
            ),
          );
    } else {
      query = FirebaseFirestore.instance
          .collection("communityposts")
          .where("isDeleted", isEqualTo: false)
          .where("approve", isEqualTo: true)
          .where('communityId', whereIn: communitiesList[0])
          .limit(8);
    }
    return query;
  }

  /// make query according to available chunked list.
  Query<Map<String, dynamic>> get _postsQueryV2 {
    final interests = _splitInterestsIntoSublist(sortByInterest: true, isRefresh: true, sortByLastPostAt: true);

    /// in-case of no interest, make query for all topics.
    if (interests.isEmpty) {
      isAllTopics = true;
    }
    final privateCommunitiesIds = getJoinedPrivateCommunities;
    late Query<Map<String, dynamic>> query;
    final length = interests.length;
    if (length == 2) {
      _logger.print("2 communities");

      if (privateCommunitiesIds.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
        query = FirebaseFirestore.instance.collection("communityposts").where(
              Filter.and(
                Filter("isDeleted", isEqualTo: false),
                Filter('showInFeed', isEqualTo: true),
                Filter("approve", isEqualTo: true),
                Filter.or(
                  Filter.and(
                    Filter("community.type", isEqualTo: "Public"),
                    Filter('community.topics.topicName', whereIn: interests[0]),
                  ),
                  Filter('communityId', whereIn: privateCommunitiesIds),
                ),
              ),
            );
      } else {
        ///case if there are no private communities.
        query = FirebaseFirestore.instance.collection("communityposts").where(
              Filter.and(
                Filter('showInFeed', isEqualTo: true),
                Filter("isDeleted", isEqualTo: false),
                Filter("approve", isEqualTo: true),
                Filter("community.type", isEqualTo: "Public"),
                Filter.or(
                  Filter('community.topics.topicName', whereIn: interests[0]),
                  Filter('community.topics.topicName', whereIn: interests[1]),
                ),
              ),
            );
      }
    } else if (length > 3) {
      _logger.print("3 communities");
      if (privateCommunitiesIds.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
        query = FirebaseFirestore.instance.collection("communityposts").where(
              Filter.and(
                Filter('showInFeed', isEqualTo: true),
                Filter("isDeleted", isEqualTo: false),
                Filter("approve", isEqualTo: true),
                Filter.or(
                  Filter.and(
                    Filter("community.type", isEqualTo: "Public"),
                    Filter('community.topics.topicName', whereIn: interests[0]),
                  ),
                  Filter('communityId', whereIn: privateCommunitiesIds),
                ),
              ),
            );
      } else {
        /// case where there are no private communities.
        query = FirebaseFirestore.instance.collection("communityposts").where(
              Filter.and(
                Filter('showInFeed', isEqualTo: true),
                Filter("isDeleted", isEqualTo: false),
                Filter("approve", isEqualTo: true),
                Filter("community.type", isEqualTo: "Public"),
                Filter.or(
                  Filter('community.topics.topicName', whereIn: interests[0]),
                  Filter('community.topics.topicName', whereIn: interests[1]),
                  Filter('community.topics.topicName', whereIn: interests[2]),
                ),
              ),
            );
      }
    } else if (isAllTopics) {
      _logger.print("making query for all topics");
      query = FirebaseFirestore.instance
          .collection("communityposts")
          .where('showInFeed', isEqualTo: true)
          .where("isDeleted", isEqualTo: false)
          .where("approve", isEqualTo: true)
          .where("community.type", isEqualTo: "Public");
    } else {
      _logger.print("1 communities ${interests[0]}");
      _logger.print("1 communities $privateCommunitiesIds");

      query = FirebaseFirestore.instance.collection("communityposts").where(
            Filter.and(
              Filter('showInFeed', isEqualTo: true),
              Filter("isDeleted", isEqualTo: false),
              Filter("approve", isEqualTo: true),
              privateCommunitiesIds.isNotEmpty
                  ? Filter.or(
                      Filter.and(
                        Filter("community.type", isEqualTo: "Public"),
                        Filter('community.topics.topicName', whereIn: interests[0]),
                      ),
                      Filter('communityId', whereIn: privateCommunitiesIds),
                    )
                  : Filter.and(
                      Filter("community.type", isEqualTo: "Public"),
                      Filter('community.topics.topicName', whereIn: interests[0]),
                    ),
            ),
          );
    }
    return query;
  }

  /// get high score posts
  Query<Map<String, dynamic>> highScorePostQuery({bool isRefresh = false}) {
    int ceil = getRandomNumber();
    int floor = getRandomNumber();
    final isGuest = FirebaseAuth.instance.currentUser == null;

    /// make sure ceil is always greater than floor
    if (floor > ceil) {
      int temp = ceil;
      ceil = floor;
      floor = temp;
    }
    _logger.print("ceil: $ceil, floor: $floor");
    final communitiesList = _splitCommunitiesIntoSublist(isRefresh: isRefresh, sortByLastPostAt: false);
    late Query<Map<String, dynamic>> query;
    final length = communitiesList.length;
    final LIMIT = isGuest ? postLimitSize : 8;
    if (length == 2) {
      _logger.print("2 communtiies");
      query = FirebaseFirestore.instance
          .collection("communityposts")
          .where(
            Filter.and(
              Filter("isDeleted", isEqualTo: false),
              Filter("approve", isEqualTo: true),
              Filter('score', isGreaterThanOrEqualTo: floor),
              Filter('score', isLessThanOrEqualTo: ceil),
              Filter.or(
                Filter('communityId', whereIn: communitiesList[0]),
                Filter('communityId', whereIn: communitiesList[1]),
              ),
            ),
          )
          .orderBy('score', descending: true)
          .limit(LIMIT);
    } else if (length > 3) {
      _logger.print("3 communtiies ");
      query = FirebaseFirestore.instance
          .collection("communityposts")
          .where(
            Filter.and(
              Filter("isDeleted", isEqualTo: false),
              Filter("approve", isEqualTo: true),
              Filter('score', isGreaterThanOrEqualTo: floor),
              Filter('score', isLessThanOrEqualTo: ceil),
              Filter.or(
                Filter('communityId', whereIn: communitiesList[0]),
                Filter('communityId', whereIn: communitiesList[1]),
                Filter('communityId', whereIn: communitiesList[2]),
              ),
            ),
          )
          .orderBy('score', descending: isRefresh)
          .limit(LIMIT);
    } else {
      query = FirebaseFirestore.instance
          .collection("communityposts")
          .where("isDeleted", isEqualTo: false)
          .where("approve", isEqualTo: true)
          .where('communityId', whereIn: communitiesList[0])
          .where('score', isGreaterThanOrEqualTo: floor)
          .where('score', isLessThanOrEqualTo: ceil)
          .orderBy('score', descending: true)
          .limit(LIMIT);
    }
    return query;
  }

  Query<Map<String, dynamic>> guestFeedPostQuery() {
    return FirebaseFirestore.instance
        .collection("communityposts")
        .where("isDeleted", isEqualTo: false)
        .where("approve", isEqualTo: true)
        .where('showInFeed', isEqualTo: true)
        .where('community.type', isEqualTo: 'Public')
        .orderBy('score', descending: true)
        .limit(postLimitSize);
  }

  Future<List<Post>> requestMoreData({bool isRefresh = false}) async => await _requestPosts(isRefresh: isRefresh);

  Future<List<Post>> __guestRequestPost({bool isRefresh = false}) async {
    /// to reset the hightscore post index because we are fetching new posts.
    _currentHighPostIndex = 0;

    /// Contains both highScorePosts
    List<Post> newPosts = [];

    try {
      performance.startHomeFeedLoadTime();

      Query<Map<String, dynamic>> highScoreQuery = guestFeedPostQuery();

      if (_lastHighScorePostRef != null) {
        highScoreQuery = guestFeedPostQuery().startAfterDocument(_lastHighScorePostRef!);
      }

      if (_hasMoreOrganicPosts == false) {
        performance.stopHomeFeedLoadTime();
        return [];
      }

      /// organic hitting + high score, both at once
      final highScorePostSnap = await highScoreQuery.get();

      _logger.print("highScorePostSnap feed data length: ${highScorePostSnap.docs.length}");
      if (highScorePostSnap.docs.isNotEmpty) {
        _lastHighScorePostRef = highScorePostSnap.docs.last;
      }
      var highScorePosts = await _parseInIsolation(highScorePostSnap, isGuestUser: true);

      newPosts = highScorePosts;

      /// if refresh, shuffle posts randomly
      if (isRefresh) {
        newPosts.shuffle();
      }
    } catch (_) {}
    return newPosts;
  }
}

abstract class IPostImpl {
  final _commonServices = Services();
  final appConfig = AppConfigurationController.to;
  final _logger = MyLoggerServices.to;

  /// to check if all topics - posts are fetching or not.
  bool isAllTopics = false;

  /// performance metric calculators
  final performance = PerformanceController.to.instance;
  int postLimitSize = 25;

  // split all communities into sublist of 10
  List<List<String?>> _splitCommunitiesIntoSublist({bool isRefresh = false, bool sortByInterest = false, required bool sortByLastPostAt}) {
    List<String?> allCommunities = getAllCommunities(sortByInterest: sortByInterest, sortByLastPostDate: sortByLastPostAt);

    List<List<String?>> chunkedCommunities = Methods.generateListOfChunks(allCommunities);
    if (isRefresh) {
      chunkedCommunities.shuffle();
    }
    return chunkedCommunities;
  }

  // split all communities into sublist of 10
  List<List<String>> _splitInterestsIntoSublist({bool isRefresh = false, bool sortByInterest = false, required bool sortByLastPostAt}) {
    List<String> userInterests = userInterestTags();
    _logger.print("user interest length: ${userInterests.length}");

    List<List<String>> interests = Methods.generateListOfChunks(userInterests);
    if (isRefresh) {
      interests.shuffle();
    }
    return interests;
  }

  /// returns all joined communities and public communities
  /// joined communities are sorted by last post date
  /// public communities are sorted by last post date
  List<String?> getAllCommunities({bool sortByInterest = false, bool sortByLastPostDate = false}) {
    final joinedCommunities = AppConfigurationController.to.joinedCommunities;
    final publicCommunities = AppConfigurationController.to.publicCommunities;

    List<Community> allCommunities = joinedCommunities + publicCommunities;

    /// sort all communities by last post date
    if (sortByLastPostDate) {
      allCommunities.sort((a, b) {
        try {
          return b.lastPostAt!.compareTo(a.lastPostAt!);
        } catch (_) {
          return 0;
        }
      });
    }

    /// get all community ids
    List<String?> allCommunitiesIds = [];

    /// remove duplicate community ids in O(n)
    Map<String?, String?> map = {};
    for (Community element in allCommunities) {
      map[element.communityId] = element.communityId;
    }
    allCommunitiesIds = map.values.toList();

    /// removing hidden communities -- hidden communities are communities which are not visible to user
    for (var element in appConfig.hiddenCommunities) {
      allCommunitiesIds.remove(element.communityId);
    }

    _logger.print("getAllCommunities length: ${allCommunitiesIds.length}");

    /// return all community ids
    return allCommunitiesIds;
  }

  Future<List<Post>> _parseInIsolation(QuerySnapshot<Map<String, dynamic>> postsSnapshot, {bool isGuestUser = false}) async {
    List<Post> posts = [];
    List<String?> userIds = [];
    final rawPosts = postsSnapshot.docs;

    for (var rawPost in rawPosts) {
      final Post? post = await _parsePostModel(rawPost.data());

      // check if community name is null or empty
      if (post?.community.communityName == null || post?.community.communityName == "") {
        // get community name from local db if not found in post
        final Community? localCommunity = AppConfigurationController.to.getCommunityById(communityId: post?.communityId ?? "");
        // if community name is still null or empty then continue/skip
        if (localCommunity?.communityName == null || localCommunity?.communityName == "") {
          continue;
        }
        // update community from local db
        post?.community = localCommunity!;
      }
      if (post != null) {
        // add user to list for bulk fetch later #ref1
        userIds.add(post.postedBy.uId);

        // get like reaction of current login user on single post
        // final reactionModel = await _commonServices.getUserReactionOnPost(post.postid ?? '');
        // post.reactionModel = reactionModel;
        //
        List<CommentCustomModel> comments = await _commonServices.parseRecentComment(postAuthor: post.postedBy, payload: rawPost.data());
        post.recentComments = comments;

        // List<MultiCommentModel> comments = await _commonServices.loadPostsComments(post.postid ?? "");
        // post.recentComments = comments;

        /// add post to list
        if (isGuestUser) post.forGuestFeed = true;
        posts.add(post);
      }
    }

    /// get users in bulk #ref1
    if (userIds.isNotEmpty) {
      /// Get User Profiles in BULK
      ///Get My reactions on post in BULK
      final bulks = await Future.wait([
        _getUserInBulk(userIds: userIds),
        _getMyReactionInBulk(postIds: posts.map((e) => e.postid).toList()),
        _getMyPollsInBulk(postIds: posts.map((e) => e.postid).toList())
      ]);

      List<UserModel?> users = bulks[0] as List<UserModel?>;
      Map<String, ReactionModel?> reactions = bulks[1] as Map<String, ReactionModel?>;
      Map<String, PostPollModel?> polls = bulks[2] as Map<String, PostPollModel?>;

      // make map of users for faster access
      Map<String?, UserModel?> usersMap = {};
      for (var user in users) {
        usersMap[user?.uId] = user;
      }

      /// (O(m + n)) :: n = posts.length, m = users.length
      /// update user in post
      for (var post in posts) {
        final UserModel? user = usersMap[post.postedBy.uId];
        if (user != null && user.uId != null) {
          post.postedBy = user;
        }

        final ReactionModel? reaction = reactions[post.postid];
        if (reaction != null) {
          post.reactionModel = reaction;
        }
        final PostPollModel? poll = polls[post.postid];
        if (poll != null) {
          post.postPollModel = poll;
        }
      }
    }
    //
    // for (var post in posts) {
    //   if(post.isCommunityPrivate){
    //     _logger.print("private community post: ${post.postid}");
    //   }
    //
    // }
    return posts;
  }

  Future<List<UserModel?>> _getUserInBulk({required List<String?> userIds}) async {
    List<UserModel?> users = [];
    users = await _commonServices.getUserByIdsWithCompound(userIds);
    return users;
  }

  Future<Map<String, ReactionModel?>> _getMyReactionInBulk({required List<String?> postIds}) async {
    Map<String, ReactionModel?> reactions = {};
    reactions = await _commonServices.getMyPostReactionWithCompoundV2(postIds);
    return reactions;
  }

  Future<Map<String, PostPollModel?>> _getMyPollsInBulk({required List<String?> postIds}) async {
    Map<String, PostPollModel?> polls = {};
    polls = await _commonServices.getMyPostPolls(postIds);
    return polls;
  }

  Future<Post?> _parsePostModel(Map<String, dynamic> rawPost) async {
    return Post.fromMap(rawPost);
  }

  Future<List<UserModel?>> getUsersByIds(List<String> uIds) async {
    List<UserModel?> users = [];
    users = await _commonServices.getUsersByIds(uIds);
    return users;
  }

  /// returns joined communities tags
  Map<String, dynamic> joinedCommunitiesTags() {
    Map<String, dynamic> joinedCommunitiesTags = <String, dynamic>{};
    try {
      /// fetch from user's collection, if empty, pick from storage.
      List<Community> joinedCommunities = [];

      // get
      joinedCommunities = AppConfigurationController.to.joinedCommunities;
      for (Community community in joinedCommunities) {
        final tag = community.communityTopics?['topicName'];
        if (tag != null) {
          joinedCommunitiesTags[tag] = tag;
        }
      }

      _logger.print("joined communities tags: ${joinedCommunitiesTags.length}");
    } catch (_) {}

    return joinedCommunitiesTags;
  }

  /// returns list of interest of a user
  List<String> userInterestTags() {
    Map<String, dynamic> interestTopics = <String, dynamic>{};

    try {
      /// 1) Extract from user's collection, if empty, pick from storage.
      for (TopicsModel interest in (UserModel.to.interests ?? _getSavedInterestTopics())) {
        interestTopics[interest.title] = interest.title;
      }

      /// 2) Extract recommended topics to user interest tags
      TopicsUtils.getRecommendedTopics(interestTopics.keys.toList()).forEach((element) {
        interestTopics[element] = element;
      });

      /// 3) Extract tags from joined communities
      interestTopics = {...interestTopics, ...joinedCommunitiesTags()};
    } catch (_) {}

    List<String> userInterests = interestTopics.keys.toList();
    return userInterests;
  }

  List<Map<String, dynamic>> userInterestTagsMap() {
    List<Map<String, dynamic>> userInterestTags = [];
    try {
      /// fetch from user's collection, if empty, pick from storage.
      List<TopicsModel> interests = UserModel.to.interests ?? _getSavedInterestTopics();
      for (TopicsModel interest in (interests)) {
        userInterestTags.add(interest.toMap());
      }
      _logger.print("user interest tags: ${userInterestTags.length}");
    } catch (_) {}

    return userInterestTags;
  }

  // fetch user interest from storage
  List<TopicsModel> _getSavedInterestTopics() {
    return GetInterestStorageController.to.getInterestModelList();
  }

  List<String?> get getJoinedPrivateCommunities => AppConfigurationController.to.getPrivateJoinedCommunitiesIds();

  ///change current query count to get next 10 joined communities return ***[true]*** if can change query count
  bool _canChangeQueryCount() {
    // currentQueryCount = currentQueryCount + 1;
    //
    // if (currentQueryCount < totalQueriesCount) {
    //   chunkedCommunitiesIds = _splitCommunitiesIntoSublist()[currentQueryCount];
    //   _hasMorePosts = true;
    //   return true;
    // }
    //
    // _hasMorePosts = false;
    // _logger.print("can;t change query count");
    return false;
  }

  int kFloor = 50;
  int kCeil = 1000;

  //generates random number
  int getRandomNumber() {
    var random = Random();
    //generate between [kCeil] 50 and [kFloor] 1000
    return (random.nextInt(kCeil - kFloor) + kFloor);
  }
}
