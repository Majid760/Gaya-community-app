import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/community/controllers/community_profile_controller.dart';
import 'package:gaya/view/create_post/models/post_poll_model.dart';
import 'package:get/get.dart';

import '../../../controller/app_config_controller.dart';
import '../../../controller/firebase_analytics_controller.dart';

class CommunityFeedServices {
  String communityId;

  CommunityFeedServices({required this.communityId});

  final _commonServices = Services();

  int PostsLimit = kDebugMode ? 15 : 15;
  bool isPublicPosts = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMorePosts = true;

  void reset() {
    _lastDocument = null;
    _hasMorePosts = true;
    isPublicPosts = false;
  }

  final performance = PerformanceController.to.instance;

// #1: Move the request posts into it's own function
  Future<List<Post>> _requestPosts(String? topic) async {
    List<Post> newPosts = [];
    try {
      performance.startCommunitiesViewLoadTime();
      var pagePostsQuery = topic == null
          ? FirebaseFirestore.instance
              .collection('communityposts')
              .where('communityId', isEqualTo: communityId)
              .where('approve', isEqualTo: true)
              .where("isDeleted", isEqualTo: false)
              .orderBy('createdOn', descending: true)
              .limit(PostsLimit)
          : FirebaseFirestore.instance
              .collection('communityposts')
              .where('communityId', isEqualTo: communityId)
              .where('approve', isEqualTo: true)
              .where("isDeleted", isEqualTo: false)
              .where("postTopicList", arrayContains: topic)
              .orderBy('createdOn', descending: true)
              .limit(PostsLimit);
      // #5: If we have a document start the query after it
      if (_lastDocument != null) {
        pagePostsQuery = pagePostsQuery.startAfterDocument(_lastDocument!);
      }

      if (!_hasMorePosts) {
        if (isPublicPosts == false) {
          isPublicPosts = true;
          _hasMorePosts = true;
          _lastDocument = null;
          MyLoggerServices.to.print("public loading");
          performance.stopCommunitiesViewLoadTime();
          _requestPosts(topic);
        }
        MyLoggerServices.to.print("no more posts from PostServices");
        performance.stopCommunitiesViewLoadTime();
        return [];
      }

      List<Post> posts = [];
      final postsSnapshot = await pagePostsQuery.get();
      MyLoggerServices.to.print("postSnapshot data length: ${postsSnapshot.docs.length}");
      if (postsSnapshot.docs.isNotEmpty) {
        _lastDocument = postsSnapshot.docs.last;
      } else {
        _hasMorePosts = true;
      }

      List<Post?> localPosts = [];
      localPosts = await _parseInIsolation(postsSnapshot);

      localPosts.removeWhere((element) => element == null);
      for (var element in localPosts) {
        posts.add(element!);
      }

      newPosts = posts;
      MyLoggerServices.to.print("newPosts length servies: ${newPosts.length}");

      // #14: Determine if there's more posts to request
      _hasMorePosts = posts.length == PostsLimit;
      performance.stopCommunitiesViewLoadTime();
    } catch (_, s) {
      performance.stopCommunitiesViewLoadTime();
    }
    return newPosts;
  }

  Future<List<Post>> _parseInIsolation(QuerySnapshot<Map<String, dynamic>> postsSnapshot) async {
    List<Post> posts = [];
    List<String?> userIds = [];
    final rawPosts = postsSnapshot.docs;

    Community? _community;
    bool isCommunityAvailable = CommunityProfileController.isRegistered(tag: communityId);
    if (isCommunityAvailable) {
      _community = CommunityProfileController.to(tag: communityId).communityModel;
    }
    for (var rawPost in rawPosts) {
      final Post? post = await _parsePostModel(rawPost.data());

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

        if (_community != null && post.community.communityName.isBlank == false) {
          post.community = _community;
        }

        /// add post to list
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

      bool isCommunityAvailable = CommunityProfileController.isRegistered(tag: communityId);
      Community? _community;
      if (isCommunityAvailable) {
        _community = CommunityProfileController.to(tag: communityId).communityModel;
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
        final PostPollModel? pollModel = polls[post.postid];
        if (pollModel != null) {
          post.postPollModel = pollModel;
        }

        /// check if its not null as we are assigning from profile of community
        /// workaround: because we are dealing with color theme.
        if (_community != null && post.community.communityName.isBlank == false) {
          post.community = _community;
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
    try {
      return await compute(Post.fromMap, rawPost);
    } catch (_) {
      // _logger.print("error in parsePostModel $_");
    }
    return null;
  }

  // #2: request pinnedPosts
  Future<List<Post>> _requestPinnedPosts({required List<String> postIds}) async {
    List<Post> newPosts = [];
    if (postIds.isEmpty) return newPosts;
    try {
      // pinnedPostList
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('communityposts')
          .where('isDeleted', isEqualTo: false)
          .where('postId', whereIn: postIds)
          .get();
      print("postSnapshot data length: $communityId");
      for (var rawPost in postsSnapshot.docs) {
        try {
          final post = Post.fromMap(rawPost.data());
          if (post.postCreatedOn == null) continue;
          if (AppConfigurationController.to.isUserBlockedAlready(userId: post.postedBy.uId ?? "") == false) {
            UserModel? userModel = await _commonServices.getUserById(post.postedBy.uId);
            if (userModel != null) {
              post.postedBy = userModel;
            }

            try {
              // get like reaction of current login user on single post
              final reactionModel = await _commonServices.getUserReactionOnPost(post.postid ?? '');
              post.reactionModel = reactionModel;

              List<CommentCustomModel> comments =
                  await _commonServices.loadPostRecentCommentsFromPostMap(post.postedBy, map: rawPost.data());
              post.recentComments = comments;

              // List<MultiCommentModel> comments = await _commonServices.loadPostsComments(post.postid ?? "");
              // post.recentComments = comments;
            } catch (_) {}

            newPosts.add(post);
          }
        } catch (_) {}
      }
      return newPosts;
    } catch (_) {
      return newPosts;
    }
  }

  Future<List<Post>> requestMoreData({String? topic}) async => await _requestPosts(topic);

  Future<List<Post>> requestPinnedPosts({required List<String> postIds}) async => await _requestPinnedPosts(postIds: postIds);
}
