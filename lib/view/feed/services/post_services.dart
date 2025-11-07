


/// currently fetching in sorted form either public or private/secret.
@Deprecated('Use [ForYouFeedServices] instead')
class PostFeedServices extends IPostImpl {
  // DocumentSnapshot? _lastOrganicPostRef;
  // bool _hasMoreOrganicPosts = true;
  //
  // void reset() {
  //   _lastOrganicPostRef = null;
  //   _hasMoreOrganicPosts = true;
  // }
  //
  // Future<List<Post>> _requestPosts({bool isRefresh = false}) async {
  //   /// Contains both highScorePosts + OrganicPosts.
  //   List<Post> newPosts = [];
  //   try {
  //     // Stopwatch stopwatch = Stopwatch()..start();
  //     performance.startHomeFeedLoadTime();
  //
  //     /// organic
  //     Query<Map<String, dynamic>> organicQuery = _postsQuery.orderBy('createdOn', descending: true).limit(postLimitSize);
  //
  //     /// organic
  //     if (_lastOrganicPostRef != null) {
  //       organicQuery = organicQuery.startAfterDocument(_lastOrganicPostRef!);
  //     }
  //
  //     if (_hasMoreOrganicPosts == false) {
  //       performance.stopHomeFeedLoadTime();
  //       return [];
  //     }
  //
  //     List<Post> posts = [];
  //
  //     /// organic snap
  //     final organicPostSnap = await organicQuery.get();
  //
  //     MyLoggerServices.to.print("postSnapshot feed data length: ${organicPostSnap.docs.length}");
  //     if (organicPostSnap.docs.isNotEmpty) {
  //       _lastOrganicPostRef = organicPostSnap.docs.last;
  //     } else {
  //       _hasMoreOrganicPosts = false;
  //       return requestMoreData();
  //     }
  //     var localPosts = await _parseInIsolation(organicPostSnap);
  //
  //     for (var i = 0; i < localPosts.length; i++) {
  //       /// check if community is hidden or not
  //       if (appConfig.isHiddenCommunityV2(communityId: localPosts[i].communityId)) {
  //         continue;
  //       }
  //       posts.add(localPosts[i]);
  //     }
  //
  //     newPosts = posts;
  //     // stopwatch.stop();
  //     // MyLoggerServices.to.print("postSnapshot took time: ${stopwatch.elapsed}");
  //     _hasMoreOrganicPosts = localPosts.length == postLimitSize;
  //     performance.stopHomeFeedLoadTime();
  //   } catch (_) {
  //     CrashlyticsController.to.instance.recordError(_, reason: 'PostFeedServices');
  //     performance.stopHomeFeedLoadTime();
  //   }
  //   return newPosts;
  // }
  //
  // /// make query according to available chunked list.
  // Query<Map<String, dynamic>> get _postsQuery {
  //   final communitiesList = _splitCommunitiesIntoSublist();
  //   late Query<Map<String, dynamic>> query;
  //   final length = communitiesList.length;
  //   if (length == 2) {
  //     debugPrint("2 communtiies");
  //     query = FirebaseFirestore.instance.collection("communityposts").where(
  //           Filter.and(
  //             Filter("isDeleted", isEqualTo: false),
  //             Filter("approve", isEqualTo: true),
  //             Filter.or(
  //               Filter('communityId', whereIn: communitiesList[0]),
  //               Filter('communityId', whereIn: communitiesList[1]),
  //             ),
  //           ),
  //         );
  //   } else if (length > 3) {
  //     debugPrint("3 communtiies");
  //     query = FirebaseFirestore.instance.collection("communityposts").where(
  //           Filter.and(
  //             Filter("isDeleted", isEqualTo: false),
  //             Filter("approve", isEqualTo: true),
  //             Filter.or(
  //               Filter('communityId', whereIn: communitiesList[0]),
  //               Filter('communityId', whereIn: communitiesList[1]),
  //               Filter('communityId', whereIn: communitiesList[2]),
  //             ),
  //           ),
  //         );
  //   } else {
  //     query = FirebaseFirestore.instance
  //         .collection("communityposts")
  //         .where("isDeleted", isEqualTo: false)
  //         .where("approve", isEqualTo: true)
  //         .where('communityId', whereIn: communitiesList[0]);
  //   }
  //   return query;
  // }
  //
  // Future<List<Post>> requestMoreData({bool isRefresh = false}) async => await _requestPosts(isRefresh: isRefresh);
}

abstract class IPostImpl {
  // final _commonServices = Services();
  // final appConfig = AppConfigurationController.to;
  //
  // /// performance metric calculators
  // final performance = PerformanceController.to.instance;
  // int postLimitSize = 25;
  //
  // Future<List<Post>> getHighScorePosts() async {
  //   return [];
  // }
  //
  // // split all communities into sublist of 10
  // List<List<String?>> _splitCommunitiesIntoSublist({bool isRefresh = false}) {
  //   List<String?> allCommunities = getAllCommunities();
  //   debugPrint("all communities length: ${allCommunities.length}");
  //   List<List<String?>> chunkedCommunities = Methods.generateListOfChunks(allCommunities);
  //   if (isRefresh) {
  //     chunkedCommunities.shuffle();
  //   }
  //   return chunkedCommunities;
  // }
  //
  // /// returns all joined communities and public communities
  // /// joined communities are sorted by last post date
  // /// public communities are sorted by last post date
  // List<String?> getAllCommunities() {
  //   List<Community> allCommunities = AppConfigurationController.to.joinedCommunities;
  //
  //   /// sort all communities by last post date
  //   allCommunities.sort((a, b) {
  //     try {
  //       return b.lastPostAt!.compareTo(a.lastPostAt!);
  //     } catch (_) {
  //       return 0;
  //     }
  //   });
  //
  //   /// get all community ids
  //   List<String?> allCommunitiesIds = [];
  //
  //   /// remove duplicate community ids in O(n)
  //   Map<String?, String?> map = {};
  //   for (Community element in allCommunities) {
  //     map[element.communityId] = element.communityId;
  //   }
  //   allCommunitiesIds = map.values.toList();
  //
  //   /// removing hidden communities -- hidden communities are communities which are not visible to user
  //   for (var element in appConfig.hiddenCommunities) {
  //     allCommunitiesIds.remove(element.communityId);
  //   }
  //
  //   /// return all community ids
  //   return allCommunitiesIds;
  // }
  //
  // Future<List<Post>> _parseInIsolation(QuerySnapshot<Map<String, dynamic>> postsSnapshot) async {
  //   List<Post> posts = [];
  //   List<String?> userIds = [];
  //   final rawPosts = postsSnapshot.docs;
  //   for (var rawPost in rawPosts) {
  //     final Post post = _parsePostModel(rawPost.data());
  //
  //     // check if community name is null or empty
  //     if (post.community.communityName == null || post.community.communityName == "") {
  //       // get community name from local db if not found in post
  //       final Community? localCommunity = AppConfigurationController.to.getCommunityById(communityId: post.communityId ?? "");
  //       // if community name is still null or empty then continue/skip
  //       if (localCommunity?.communityName == null || localCommunity?.communityName == "") {
  //         continue;
  //       }
  //       // update community from local db
  //       post.community = localCommunity!;
  //     }
  //
  //     userIds.add(post.postedBy.uId);
  //
  //     /// add post to list
  //     posts.add(post);
  //   }
  //
  //   /// get users in bulk #ref1
  //   if (userIds.isNotEmpty) {
  //     List<UserModel?> users = await _getUserInBulk(userIds: userIds);
  //
  //     // make map of users for faster access
  //     Map<String?, UserModel?> usersMap = {};
  //     for (var user in users) {
  //       usersMap[user?.uId] = user;
  //     }
  //
  //     /// (O(m + n)) :: n = posts.length, m = users.length
  //     /// update user in post
  //     for (var post in posts) {
  //       final UserModel? user = usersMap[post.postedBy.uId];
  //       if (user != null && user.uId != null) {
  //         post.postedBy = user;
  //       }
  //     }
  //   }
  //
  //   /// fetch likes and crowns for posts
  //   return posts;
  // }
  //
  // Future<List<UserModel?>> _getUserInBulk({required List<String?> userIds}) async {
  //   List<UserModel?> users = [];
  //   users = await _commonServices.getUserByIdsWithCompound(userIds);
  //   return users;
  // }
  //
  // Post _parsePostModel(Map<String, dynamic> rawPost) {
  //   return Post.fromMap(rawPost);
  //   // try {
  //   //   return await compute(Post.fromMap, rawPost);
  //   // } catch (_) {
  //   //   // debugPrint("error in parsePostModel $_");
  //   // }
  //   // return null;
  // }
  //
  // Future<List<UserModel?>> getUsersByIds(List<String> uIds) async {
  //   List<UserModel?> users = [];
  //   users = await _commonServices.getUsersByIds(uIds);
  //   return users;
  // }
  //
  // ///change current query count to get next 10 joined communities return ***[true]*** if can change query count
  // bool _canChangeQueryCount() {
  //   // currentQueryCount = currentQueryCount + 1;
  //   //
  //   // if (currentQueryCount < totalQueriesCount) {
  //   //   chunkedCommunitiesIds = _splitCommunitiesIntoSublist()[currentQueryCount];
  //   //   _hasMorePosts = true;
  //   //   return true;
  //   // }
  //   //
  //   // _hasMorePosts = false;
  //   // debugPrint("can;t change query count");
  //   return false;
  // }
}
