// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/cache_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.communities.model.dart';
import 'package:gaya/scripts/communities_scripts.dart';
import 'package:gaya/shared/service/engagement_score_services/engagement_helpers/engagement_consts.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/create_post/models/post_poll_model.dart';
import 'package:get/get.dart';

import '../model/communities.memebers.model.dart';
import '../model/community.model.dart';
import '../model/friendship.model.dart';
import '../model/user.communities.dart';
import '../model/user.model.dart';
import '../view/feed/services/local/posts/seen_unseen_post_services.dart';

class Services extends GetxService {
  static Services get to => Get.find();
  final FirebaseAuth _firebaseUser = FirebaseAuth.instance;
  DocumentSnapshot? getUserDetails;

  // increment 0.25 influence score in user profile incase of crown reward
  void increaseInfluencePointOnCrownReward(String? userId) {
    if (userId == null) return;
    try {
      EngagementConsts.userRef(userId).set({"dailyCrownRewardInfluencePoints": FieldValue.increment(0.25)}, SetOptions(merge: true));
    } catch (_) {}
  }

  // increment 0.25 influence score in user profile incase of profile compliment
  void increaseInfluencePointOnProfileCompliment(String? userId) {
    if (userId == null) return;
    try {
      EngagementConsts.userRef(userId).set({"dailyProfileComplimentInfluencePoints": FieldValue.increment(0.25)}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<Post?> getPostDetailsSnapshot(String postId) async {
    Post? postDetails;
    try {
      final post = await FirebaseFirestore.instance.collection('communityposts').doc(postId).get();
      if (post.exists && post.data() != null) {
        postDetails = Post.fromMap(post.data()!);
        final author = await getUserById(postDetails.memberId, forcefullyServer: true);

        // get like reaction of current login user on single post
        final reactionModel = await getUserReactionOnPost(postDetails.postid ?? '');
        final pollModel = await getUserPollOnPost(postDetails.postid ?? '');
        postDetails.reactionModel = reactionModel;
        postDetails.postPollModel = pollModel;

        List<CommentCustomModel> comments =
            await loadPostRecentCommentsFromPostMap(postDetails.postedBy, map: post.data() as Map<String, dynamic>);
        postDetails.recentComments = comments;

        // List<MultiCommentModel> comments = await loadPostsComments(postDetails.postid ?? "");
        // postDetails.recentComments = comments;

        if (author != null) {
          postDetails.postedBy = author;
        }
      }
    } catch (e) {
      // log(e.toString());
    }
    return postDetails;
  }

  Future<ReactionModel?> getUserReactionOnPost(String postId) async {
    try {
      if (UserModel.to.uId.isBlank == true || postId.isBlank == true) return null;

      final userReactionDoc =
          await FirebaseFirestore.instance.collection('communityposts').doc(postId).collection('reactions').doc(UserModel.to.uId!).get();

      if (userReactionDoc.exists) {
        MyLoggerServices.to.print('exists');
        return ReactionModel.fromMap(userReactionDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<PostPollModel?> getUserPollOnPost(String postId) async {
    try {
      if (UserModel.to.uId.isBlank == true || postId.isBlank == true) return null;

      final userPollDoc =
          await FirebaseFirestore.instance.collection('communityposts').doc(postId).collection('poll').doc(UserModel.to.uId!).get();

      if (userPollDoc.exists) {
        MyLoggerServices.to.print('exists');

        return PostPollModel.fromMap(userPollDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, ReactionModel?>> getUserReactionOnPostInMap(String postId) async {
    try {
      if (UserModel.to.uId.isBlank == true || postId.isBlank == true) return {postId: null};

      final userReactionDoc =
          await FirebaseFirestore.instance.collection('communityposts').doc(postId).collection('reactions').doc(UserModel.to.uId!).get();

      if (userReactionDoc.exists) {
        MyLoggerServices.to.print('exists');
        return {postId: ReactionModel.fromMap(userReactionDoc.data() as Map<String, dynamic>)};
      }
      return {postId: null};
    } catch (_) {
      return {postId: null};
    }
  }

  Future<Map<String, PostPollModel?>> getPostPolls(String postId) async {
    try {
      if (UserModel.to.uId.isBlank == true || postId.isBlank == true) return {postId: null};

      final postPoll =
          await FirebaseFirestore.instance.collection('communityposts').doc(postId).collection('poll').doc(UserModel.to.uId!).get();

      if (postPoll.exists) {
        MyLoggerServices.to.print('exists');
        return {postId: PostPollModel.fromMap(postPoll.data() as Map<String, dynamic>)};
      }
      return {postId: null};
    } catch (_) {
      return {postId: null};
    }
  }

  // get post recent 5 comments
  Future<List<MultiCommentModel>> loadPostsComments(String postId) async {
    List<MultiCommentModel> comments = [];
    try {
      var postCommentQuery = FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('comments')
          .orderBy('commentTime', descending: true)
          .limit(5);
      final postComments = await postCommentQuery.get();
      if (postComments.docs.isEmpty) return [];
      comments = await loadCommentsFromQuerySnapshot(postComments, postId: postId);
    } catch (_) {
      // debugPrint("Handled Error loading comments: $getAllCommentException");
    }
    comments.removeWhere((element) => element.comment.user.uId == null);
    return comments;
  }

  Future<List<MultiCommentModel>> loadCommentsFromQuerySnapshot(QuerySnapshot<Map<String, dynamic>> parentComments,
      {required String postId}) async {
    final List<MultiCommentModel> comments = [];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> parentComment in parentComments.docs) {
      try {
        final batchQueryParentResult = await Future.wait([
          //get parentUserModel user.
          getUserById(parentComment.data()['userId']),
        ]);
        final parentUserModel = batchQueryParentResult[0] as UserModel;

        /// if user is deleted
        if (parentUserModel.uId == null) {
          continue;
        }
        comments.add(MultiCommentModel(
          comment: CommentCustomModel(
            id: parentComment.id,
            comment: parentComment.data()['comment'],
            user: parentUserModel,
            createdAt: parentComment.data()['commentTime'].toDate(),
            // isLiked: parentCommentLikes['isLiked'],
            commentReactionData: (parentComment.data()['commentReactionData'] != null)
                ? PostReactionDataModel.fromMap(parentComment.data()['commentReactionData'] as Map<String, dynamic>)
                : null,
            isLiked: false,
            photoUrl: parentComment.data()['photoUrl'],
            videoUrl: parentComment.data()['videoUrl'],
            mentionedUsers: parentComment.data()['mentionedUsers'] != null
                ? (parentComment.data()['mentionedUsers'] as List)
                    .map<Map<String, dynamic>>((user) => {
                          "display": user['display'],
                          "senderUid": user['senderUid'],
                          "senderProfile": user['senderProfile'],
                          "id": user['id'],
                          "isCommunity": user['isCommunity'] ?? false
                        })
                    .toList()
                : null,
            pdfFiles: parentComment.data()['pdfFiles'] != null
                ? (parentComment.data()['pdfFiles'] as List)
                    .map<Map<String, dynamic>>((file) =>
                        {"title": file['title'], "fileUrl": file['fileUrl'], "fileName": file['fileName'], "thumbnail": file['thumbnail']})
                    .toList()
                : [],
          ),
          replies: [],
        ));
      } catch (parentException) {
        MyLoggerServices.to.print('error thruwo due to ${parentException.toString()}');
      }
    }
    return comments;
  }

  ///BAHADUR
  Future<List<CommentCustomModel>> loadPostRecentCommentsFromPostMap(UserModel userModel, {required Map<String, dynamic> map}) async {
    if (map["recentComments"] == null) return [];
    if ((map['recentComments'] as List).isEmpty) return [];

    final List<CommentCustomModel> comments = [];

    for (var comment in map["recentComments"]) {
      UserModel? user;
      if (comment['userId'] == userModel.uId) {
        user = userModel;
      } else {
        user = await getUserById(comment['userId']);
      }
      try {
        comments.add(CommentCustomModel(
          id: comment['commentId'],
          photoUrl: comment['photoUrl'],
          videoUrl: comment['videoUrl'],
          pdfFiles: comment['pdfFiles'] != null
              ? (comment['pdfFiles'] as List)
                  .map<Map<String, dynamic>>((file) =>
                      {"title": file['title'], "fileUrl": file['fileUrl'], "fileName": file['fileName'], "thumbnail": file['thumbnail']})
                  .toList()
              : [],
          user: user ?? UserModel(),
          mentionedUsers: comment['mentionedUsers'] != null
              ? (comment['mentionedUsers'] as List)
                  .map<Map<String, dynamic>>((user) => {
                        "display": user['display'],
                        "senderUid": user['senderUid'],
                        "senderProfile": user['senderProfile'],
                        "id": user['id'],
                        "isCommunity": user['isCommunity'] ?? false
                      })
                  .toList()
              : null,
          createdAt: comment['commentTime'].toDate(),
          comment: comment['comment'],
        ));
      } catch (e) {
        debugPrint('this is issue ${e.toString()}');
      }
    }
    return comments;
  }

  /// returns true if [`author`] key is present in recent comments
  bool _isAuthorKeyPresent(Map<String, dynamic> comment) => comment['author'] != null;

  /// Parse map of recent comments to list of
  /// comment model - used in post model to parse recent comments
  Future<List<CommentCustomModel>> parseRecentComment({required UserModel postAuthor, required Map<String, dynamic> payload}) async {
    if (payload['recentComments'] == null) return [];
    if ((payload['recentComments'] as List).isEmpty) return [];

    final List<CommentCustomModel> comments = [];

    UserModel? commentAuthor;
    for (var comment in payload["recentComments"]) {
      /// check if user profile is present in recent comments
      bool isAuthorPresent = _isAuthorKeyPresent(comment);

      /// if author of both comment and post are same, then assign post author to comment author
      if (postAuthor.uId != null && comment['userId'] == postAuthor.uId) {
        commentAuthor = postAuthor;
      }

      /// if author is not present in recent comments then fetch from firestore
      else if (!isAuthorPresent) {
        debugPrint('author is not present in recent comments');
        commentAuthor = await getUserById(comment['userId']);
      }
      try {
        ///parse
        CommentCustomModel parsedComment = CommentCustomModel.fromJson(comment, commentAuthor);

        // /// assign user
        // parsedComment.user.name.isBlank == true ? null : parsedComment = parsedComment.copyWith(user: commentAuthor);

        /// add to list
        comments.add(parsedComment);
      } catch (e) {
        debugPrint('parseRecentComment() error occured ${e.toString()}');
      }
    }
    return comments;
  }

  Future<List<String>> getSavedPostsIds() async {
    if (_firebaseUser.currentUser == null) return [];
    List<String> _savedPostsID = [];
    try {
      QuerySnapshot _savedPostsSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(_firebaseUser.currentUser!.uid).collection('saveposts').get();
      for (var element in _savedPostsSnapshot.docs) {
        if (element.exists) {
          try {
            final _data = element.data() as Map<String, dynamic>;
            _savedPostsID.add(_data['postId']);
          } catch (_) {}
        }
      }
      // _analyticsController.instance.logAddToSaveList(contentType, itemId)
    } catch (e) {
      // log(e.toString());
    }
    return _savedPostsID;
  }

  //returns communities where current user is admin
  Future<List<Community>> getAdminCommunities() async {
    if (_firebaseUser.currentUser == null) return [];
    List<Community> _adminCommunities = [];
    try {
      QuerySnapshot _adminCommunitiesSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where('adminUid', isEqualTo: _firebaseUser.currentUser?.uid ?? "-1")
          .get();
      for (var element in _adminCommunitiesSnapshot.docs) {
        _adminCommunities.add(Community.fromMap(element.data() as Map<String, dynamic>));
      }
    } catch (e) {
      // log(e.toString());
    }
    return _adminCommunities;
  }

  //returns communities where current user is moderator
  Future<List<Community>> getModeratorCommunities() async {
    if (_firebaseUser.currentUser == null) return [];
    List<Community> _moderatorCommunities = [];
    try {
      QuerySnapshot _moderatorsCommunitiesSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where('moderators', arrayContains: _firebaseUser.currentUser?.uid)
          .get();
      for (var element in _moderatorsCommunitiesSnapshot.docs) {
        _moderatorCommunities.add(Community.fromMap(element.data() as Map<String, dynamic>));
      }
    } catch (e) {
      // log(e.toString());
    }
    return _moderatorCommunities;
  }

  ///returns communties where user has joined it.
  /// returns [memberships] and [communities]
  Future<Map<String, dynamic>> getJoinedCommunities() async {
    List<Community> _joinedCommunitiesId = [];
    List<Community> _joinedCommunities = [];
    List<String> _pendingRequestCommunitiesIds = [];
    List<UserCommunities> _joinedCommunitiesMembership = [];
    try {
      User? _firebaseUser = FirebaseAuth.instance.currentUser;
      if (_firebaseUser == null) {
        return {
          "memberships": _joinedCommunitiesMembership,
          "communities": _joinedCommunities,
          'requestSentCommunities': _pendingRequestCommunitiesIds,
        };
      }

      final querySnapshots = await Future.wait([
        //getting joined community ids
        FirebaseFirestore.instance.collection('users').doc(_firebaseUser.uid).collection('communities').get(),
        // getting user joined or request sent communities
        FirebaseFirestore.instance.collectionGroup('communityMembers').where('userUid', isEqualTo: _firebaseUser.uid).get(),
      ]);

      if (querySnapshots.isEmpty) {
        return {
          "memberships": _joinedCommunitiesMembership,
          "communities": _joinedCommunities,
          'requestSentCommunities': _pendingRequestCommunitiesIds,
        };
      }

      // parsing sent communities ids
      if (querySnapshots[1].docs.isNotEmpty) {
        for (var doc in querySnapshots[1].docs) {
          if (doc.data()['isMember'] as bool == false) {
            _pendingRequestCommunitiesIds.add(doc.data()['userUid'] as String);
          }
        }
      }

      for (var community in querySnapshots[0].docs) {
        try {
          // memberships
          final userMembership = UserCommunities.fromMap(community.data());
          _joinedCommunitiesMembership.add(userMembership);
          //community
          final Community _community = Community.fromMap(community.data());
          _joinedCommunitiesId.add(_community);
        } catch (e) {
          debugPrint("Error at getJoinedCommunities: $e");
        }
      }

      //getting the community details
      if (_joinedCommunitiesId.isNotEmpty) {
        /// remove null and blank community ids
        _joinedCommunitiesId.removeWhere((element) => element.communityId == null || element.communityId.isBlank == true);
        List<List<String?>> _joinedCommunitiesIdList =
            Methods.generateListOfChunks(_joinedCommunitiesId.map((e) => e.communityId).toList());

        for (var communityChunk in _joinedCommunitiesIdList) {
          final joinedGroupSnap =
              await FirebaseFirestore.instance.collection('communities').where("communityId", whereIn: communityChunk).get();
          for (var community in joinedGroupSnap.docs) {
            try {
              final Community _community = Community.fromMap(community.data());

              _joinedCommunities.add(_community);
            } catch (e) {
              debugPrint("Error at getJoinedCommunities: $e");
            }
          }
        }
      } else {
        debugPrint("No joined communities for user ${_firebaseUser.uid}");
      }
    } catch (mainError) {
      debugPrint("Error at getJoinedCommunities: $mainError");
    }
    //sorting so we get all the latest posts on feed.
    try {
      _joinedCommunities.sort((a, b) => b.lastPostAt!.compareTo(a.lastPostAt!));
    } catch (_) {}

    return {
      "memberships": _joinedCommunitiesMembership,
      "communities": _joinedCommunities,
      'requestSentCommunities': _pendingRequestCommunitiesIds,
    };
  }

  ///returns communties where user has joined it.
  Future<List<Community>> getJoinedCommunitiesFromUserCollection() async {
    List<Community> _joinedCommunitiesId = [];
    List<Community> _joinedCommunities = [];
    try {
      User? _firebaseUser = FirebaseAuth.instance.currentUser;
      if (_firebaseUser == null) {
        return [];
      }

      //getting joined community ids
      final joinedGroupIdsSnap =
          await FirebaseFirestore.instance.collection('users').doc(_firebaseUser.uid).collection('communities').get();
      //remove those where its pendings
      for (var community in joinedGroupIdsSnap.docs) {
        try {
          //community
          final Community _community = Community.fromMap(community.data());
          _joinedCommunitiesId.add(_community);
        } catch (e) {
          debugPrint("Error at getJoinedCommunities: $e");
        }
      }

      //getting the community details
      if (_joinedCommunitiesId.isNotEmpty) {
        /// remove null and blank community ids
        _joinedCommunitiesId.removeWhere((element) => element.communityId == null || element.communityId.isBlank == true);
        List<List<String?>> _joinedCommunitiesIdList =
            Methods.generateListOfChunks(_joinedCommunitiesId.map((e) => e.communityId).toList());
        final communitiesAsync = await Future.wait(
          _joinedCommunitiesIdList.map(
            (communityChunk) => FirebaseFirestore.instance.collection('communities').where("communityId", whereIn: communityChunk).get(),
          ),
        );

        for (var joinedGroupSnap in communitiesAsync) {
          for (var community in joinedGroupSnap.docs) {
            try {
              final Community _community = Community.fromMap(community.data());

              _joinedCommunities.add(_community);
            } catch (e) {
              debugPrint("Error at getJoinedCommunities: $e");
            }
          }
        }
      } else {
        debugPrint("No joined communities for user ${_firebaseUser.uid}");
      }
    } catch (mainError) {
      debugPrint("Error at getJoinedCommunities: $mainError");
    }
    return _joinedCommunities;
  }

  List<String?> getOnlyRandomTen(List<String?> list) {
    List<String?> _list = [];
    list.shuffle();
    if (list.length > 10) {
      _list = list.sublist(0, 10);
    } else {
      _list = list;
    }

    return _list;
  }

  // returns communities that are public
  Future<List<Community>> getPublicCommunities() async {
    List<Community> _publicCommunities = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where("type", isEqualTo: "Public")
          .orderBy("lastPostCreatedAt", descending: true)
          .get();

      for (var community in querySnapshot.docs) {
        try {
          _publicCommunities.add(Community.fromMap(community.data()));
        } catch (e) {
          debugPrint("Error at getPublicCommunities: $e");
        }
      }
    } catch (mainError) {
      debugPrint("Error at getPublicCommunities: $mainError");
    }

    return _publicCommunities;
  }

  // returns communities that are public
  Future<List<Community>> getAllCommunitiesExceptSecret() async {
    List<Community> _allCommunitiesExceptSecret = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('communities').where("type", isNotEqualTo: "Secret").get();
      for (var community in querySnapshot.docs) {
        try {
          _allCommunitiesExceptSecret.add(Community.fromMap(community.data()));
        } catch (e) {
          debugPrint("Error at getJoinedCommunities: $e");
        }
      }
    } catch (mainError) {
      debugPrint("Error at getPublicCommunities: $mainError");
    }

    return _allCommunitiesExceptSecret;
  }

  // returns communities that are hidden
  Future<List<UserCommunities>> getHiddenCommunities() async {
    List<UserCommunities> _hiddenCommunities = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isBlank == true) return _hiddenCommunities;
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("hiddenCommunities").get();
      for (var community in querySnapshot.docs) {
        try {
          _hiddenCommunities.add(UserCommunities.fromMap(community.data()));
        } catch (e) {
          debugPrint("Error at _hiddenCommunities: $e");
        }
      }
    } catch (mainError) {
      debugPrint("Error at _hiddenCommunities: $mainError");
    }

    debugPrint("Length at _hiddenCommunities: ${_hiddenCommunities.length}");
    return _hiddenCommunities;
  }

  Future<void> hideACommunity({required String? communityId}) async {
    if (communityId == null) return;
    final user = UserModel.to;
    if (user.uId.isBlank == true || communityId.isBlank == true) return;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uId)
          .collection("hiddenCommunities")
          .doc(communityId)
          .set({"communityId": communityId}, SetOptions(merge: true));
    } catch (mainError) {
      debugPrint("Error at _hiddenCommunities: $mainError");
    }
  }

  Future<void> unhideACommunity({required String? communityId}) async {
    final user = UserModel.to;
    if (communityId == null || communityId.isBlank == true || user.uId.isBlank == true) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uId).collection("hiddenCommunities").doc(communityId).delete();
    } catch (mainError) {
      debugPrint("Error at _hiddenCommunities: $mainError");
    }
  }

  /// 10 users at a time
  Future<List<UserModel>> getUsersByIds(List<String?> userIds) async {
    List<UserModel> _users = [];

    /// remove null values
    userIds.removeWhere((element) => element == null);

    /// return empty list if no userIds
    if (userIds.isEmpty) return _users;

    /// get users
    final _userSnap = await FirebaseFirestore.instance.collection('users').where("uid", whereIn: userIds).get();
    for (var user in _userSnap.docs) {
      try {
        final _user = UserModel.fromSnapshot(user);
        _users.add(_user);
      } catch (e) {
        debugPrint("Error at getJoinedCommunities: $e");
      }
    }
    return _users;
  }

  /// fetch multiple users at a time
  Future<List<UserModel>> getUserByIdsWithCompound(List<String?> userIds) async {
    return await getUserByIdsWithCompoundv2(userIds);
/*    late Query<Map<String, dynamic>> query;
    List<UserModel> _users = [];

    /// remove null values
    userIds.removeWhere((element) => element == null);

    /// return empty list if no userIds
    if (userIds.isEmpty) return _users;

    /// converting from List<String?> to List<String>
    List<String> _userIds = [];
    for (var id in userIds) {
      _userIds.add(id!);
    }
    List<List<String>> chunckedUsers = Methods.generateListOfChunks(_userIds);
    print("=>>>> ${chunckedUsers.length}");
    if (chunckedUsers.isEmpty) {
      return _users;
    } else if (chunckedUsers.length == 3) {
      debugPrint("total users to fetch is 30");
      query = FirebaseFirestore.instance.collection('users').where(
            Filter.or(
              Filter(FieldPath.documentId, whereIn: chunckedUsers[0]),
              Filter(FieldPath.documentId, whereIn: chunckedUsers[1]),
              Filter(FieldPath.documentId, whereIn: chunckedUsers[2]),
            ),
          );
    } else if (chunckedUsers.length == 2) {
      debugPrint("total users to fetch is 20, ids: ${chunckedUsers[0] + chunckedUsers[1]}");
      query = FirebaseFirestore.instance.collection('users').where(
          Filter.or(Filter(FieldPath.documentId, whereIn: chunckedUsers[0]), Filter(FieldPath.documentId, whereIn: chunckedUsers[1])));
    } else {
      debugPrint("total users to fetch is 10");
      query = FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: chunckedUsers[0]);
    }

    final _userSnap = await query.get();
    for (var user in _userSnap.docs) {
      try {
        final _user = UserModel.fromMap(user.data(), userId: user.id);
        _users.add(_user);
      } catch (e) {
        debugPrint("Error at getJoinedCommunities: $e");
      }
    }
    return _users;*/
  }

  Future<List<UserModel>> getUserByIdsWithCompoundv2(List<String?> userIds) async {
    List<UserModel> _users = [];

    /// remove null values
    userIds.removeWhere((element) => element == null);

    /// return empty list if no userIds
    if (userIds.isEmpty) return _users;

    /// converting from List<String?> to List<String>
    List<String> _userIds = [];
    for (var id in userIds) {
      _userIds.add(id!);
    }
    List<List<String>> chunckedUsers = Methods.generateListOfChunks(_userIds);

    final futures = await Future.wait(
      chunckedUsers.map((e) => FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: e).get()).toList(),
    );

    for (var element in futures) {
      for (var user in element.docs) {
        try {
          final _user = UserModel.fromSnapshot(user);
          _users.add(_user);
        } catch (e) {
          debugPrint("Error at getJoinedCommunities: $e");
        }
      }
    }

    return _users;
  }

  Future<Map<String, ReactionModel?>> getMyPostReactionWithCompoundV2(List<String?> postIds) async {
    Map<String, ReactionModel?> _reactions = {};

    /// remove null values
    postIds.removeWhere((element) => element == null);

    /// return empty list if no userIds
    if (postIds.isEmpty) return {};

    /// converting from List<String?> to List<String>
    List<String> _postIds = [];
    for (var id in postIds) {
      _postIds.add(id!);
    }

    final reactions = await Future.wait(_postIds.map((postId) => getUserReactionOnPostInMap(postId)).toList());

    for (var element in reactions) {
      _reactions[element.keys.first] = element.values.first;
    }

    return _reactions;
  }

  Future<Map<String, PostPollModel?>> getMyPostPolls(List<String?> postIds) async {
    Map<String, PostPollModel?> _polls = {};

    /// remove null values
    postIds.removeWhere((element) => element == null);

    /// return empty list if no userIds
    if (postIds.isEmpty) return {};

    /// converting from List<String?> to List<String>
    List<String> _postIds = [];
    for (var id in postIds) {
      _postIds.add(id!);
    }

    final poll = await Future.wait(_postIds.map((postId) => getPostPolls(postId)).toList());

    for (var element in poll) {
      _polls[element.keys.first] = element.values.first;
    }

    return _polls;
  }

  Future<List<Community>> getCommunitiesByIds(List<String?> communityIds) async {
    List<Community> _communities = [];

    /// remove null values
    communityIds.removeWhere((element) => element == null);

    /// return empty list if no communityIds
    if (communityIds.isEmpty) return _communities;

    /// get communities
    final _communitySnap = await FirebaseFirestore.instance.collection('communities').where("communityId", whereIn: communityIds).get();
    for (var community in _communitySnap.docs) {
      try {
        final _community = Community.fromMap(community.data());
        _communities.add(_community);
      } catch (e) {
        debugPrint("Error at getJoinedCommunities: $e");
      }
    }
    return _communities;
  }

  /// returns list of UserModel(friends) bypassing whereIn limit
  Future<List<UserModel>> getMyAllFriends() async {
    if (UserModel.to.uId == null) return [];
    try {
      final freindsSnaps = await Future.wait([
        FirebaseFirestore.instance
            .collection("friendship")
            .where("Recieveruid", isEqualTo: UserModel.to.uId)
            .where("isaccepted", isEqualTo: true)
            .get(),
        FirebaseFirestore.instance
            .collection("friendship")
            .where("senderUid", isEqualTo: UserModel.to.uId)
            .where("isaccepted", isEqualTo: true)
            .get()
      ]);

      final List<String> senderFriendsUid = [];
      final List<String> recieverFriendsUid = [];
      // recievers
      for (var index in freindsSnaps[1].docs) {
        FriendShipModel friendShipModel = FriendShipModel.fromMap(index.data());

        recieverFriendsUid.add(friendShipModel.recieverUid!);
      }

      // senders
      for (var index in freindsSnaps[0].docs) {
        FriendShipModel friendShipModel = FriendShipModel.fromMap(index.data());

        senderFriendsUid.add(friendShipModel.senderUid!);
      }

      List<String> allFriendsIds = [...senderFriendsUid, ...recieverFriendsUid];

      Map<String, String> map = {};
      for (var element in allFriendsIds) {
        map[element] = element;
      }
      allFriendsIds = map.values.toList();

      List<UserModel> allFriendsData = [];
      try {
        /// split the list into chunks of 10
        /// then get the users by ids
        /// then add the users to the list
        /// then return the list
        allFriendsData = await _splitAndGetUsersModel(userIds: allFriendsIds);
      } catch (e) {
        debugPrint(e.toString());
      }

      return allFriendsData;
    } catch (_) {}
    return [];
  }

  // Future<List<UserModel>> getUsersProfileByIds(List<String> userIds) async {
  //   List<UserModel> usersList = [];
  //   try {
  //     /// split the list into chunks of 10
  //     /// then get the users by ids
  //     /// then add the users to the list
  //     /// then return the list
  //     usersList = await _splitAndGetUsersModel(userIds: userIds);
  //   } catch (e) {
  //     print(e);
  //   }
  //   return usersList;
  // }

  Future<List<UserModel>> splsit({required List<String> userIds}) async {
    List<List<String>> chunkedIds = Methods.generateListOfChunks(userIds);
    final List<UserModel> _users = [];
    try {
      for (var split in chunkedIds) {
        List<UserModel> chunkedUsers = await getUsersByIds(split);
        _users.addAll(chunkedUsers);
      }
    } on Exception catch (_) {}
    return _users;
  }

  Future<List<UserModel>> _splitAndGetUsersModel({required List<String> userIds}) async {
    List<List<String>> chunkedIds = Methods.generateListOfChunks(userIds);
    final List<UserModel> _users = [];
    try {
      for (var split in chunkedIds) {
        List<UserModel> chunkedUsers = await getUsersByIds(split);
        _users.addAll(chunkedUsers);
      }
    } on Exception catch (_) {}
    return _users;
  }

  Future<UserModel?> getUserById(String? userId, {bool forcefullyServer = false}) async {
    if (userId.isBlank == true || userId == null) return null;

    UserModel? _user;
    try {
      /// search in cache
      if (forcefullyServer == false) {
        _user = CacheController.to.getUserProfileById(userId);
      }

      // return from cache
      if (_user != null) return _user;
      final _userSnap = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!_userSnap.exists) {
        return null;
      }
      _user = UserModel.fromSnapshot(_userSnap);
      CacheController.to.addUser(_user);

      return _user;
    } catch (_) {
      debugPrint("getUserById error: $_");
    }
    return null;
  }

//Get the user details
  Future<DocumentSnapshot?> getUserDetailsServices() async {
    User? user = _firebaseUser.currentUser;
    if (user == null) return null;
    getUserDetails = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    try {
      final myAppUser = UserModel.fromSnapshot(getUserDetails!);
      UserModel.to.update(myAppUser);
    } catch (_) {}
    // log(getUserDetails!.data().toString());
    return getUserDetails!;
  }

  //Get the other user details
  Future<DocumentSnapshot?> getOtherUserDetailsServices(String otherUid) async {
    try {
      if (otherUid.isBlank == true) return null;
      getUserDetails = await FirebaseFirestore.instance.collection('users').doc(otherUid).get();
    } on Exception catch (_) {}

    // log(getUserDetails!.data().toString());
    return getUserDetails!;
  }

  //update the user profile
  Future updateUserDetails(List<Map<String, dynamic>> updateData) async {
    User? user = _firebaseUser.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'interests': updateData});
    } catch (e) {
      // log(e.toString());
      // log('This is catch');
    }
  }

  Future<void> updateUserDetails1(Map<String, dynamic> updateData) async {
    User? user = _firebaseUser.currentUser;
    if (user == null || updateData.isEmpty == true) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      // log(e.toString());
      // log('This is catch');
    }
  }

  // update user profile with set operation
  Future<void> updateUserProfileInDb(Map<String, dynamic> updateData) async {
    User? user = _firebaseUser.currentUser;
    if (user == null || updateData.isEmpty == true) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(updateData, SetOptions(merge: true));
    } catch (e) {}
  }

  //set the post data to firebase
  Future setPostDetails(Map<String, dynamic> data, String docId) async {
    if (docId.isBlank == true) return;
    try {
      return await FirebaseFirestore.instance.collection('communityposts').doc(docId).set({...data, "score": 0});
    } on Exception catch (_) {}
  }

  //set the communities against a user in which he is the memeber
  Future setUserCommunity(Map<String, dynamic> setCommunities) async {
    User? user = _firebaseUser.currentUser;
    if (user == null || setCommunities['communityId'] == null || setCommunities['communityId'] == '') return;
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('communities')
          .doc(setCommunities['communityId'])
          .set(setCommunities);
    } on Exception catch (_) {
      debugPrint('error $_');
    }
  }

  //like of post
  Future<void> likeOnPost(
    String postId,
    String communityId,
  ) async {
    if (postId.isBlank == true) return;
    try {
      await FirebaseFirestore.instance.collection('communityposts').doc(postId).set({
        "likedBy": FieldValue.arrayUnion([_firebaseUser.currentUser!.uid])
      }, SetOptions(merge: true));

      // Logging like on post event
      AnalyticsController.to.instance.logLikeUnlikePost(
        eventType: 'like',
        communityId: communityId,
        postId: postId,
        userId: _firebaseUser.currentUser?.uid ?? '',
      );
    } on Exception catch (_) {}
  }

  //unlike of post
  Future<void> unlikeOnPost(
    String postId,
    String communityId,
  ) async {
    if (postId.isBlank == true) return;
    try {
      await FirebaseFirestore.instance.collection('communityposts').doc(postId).set({
        "likedBy": FieldValue.arrayRemove([_firebaseUser.currentUser!.uid])
      }, SetOptions(merge: true));

      // Logging unlike on post event
      AnalyticsController.to.instance.logLikeUnlikePost(
        eventType: 'unlike',
        postId: postId,
        communityId: communityId,
        userId: _firebaseUser.currentUser?.uid ?? '',
      );
    } on Exception catch (_) {}
  }

  //like of post
  Future<void> unLikeReactionOnPost(
    String postId,
    String communityId,
  ) async {
    if (postId.isBlank == true || UserModel.to.uId.isBlank == true) return;
    try {
      // await FirebaseFirestore.instance.collection('communityposts').doc(postId).set({"reactionModel": null}, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('communityposts').doc(postId).collection('reactions').doc(UserModel.to.uId).delete();
      // Logging like on post event
      AnalyticsController.to.instance.logLikeUnlikePost(
        eventType: 'like',
        communityId: communityId,
        postId: postId,
        userId: _firebaseUser.currentUser?.uid ?? '',
      );
    } on Exception catch (_) {}
  }

  //like of post
  Future<void> likeReactionOnPost(
    String postId,
    String communityId,
    ReactionModel reactionModel,
  ) async {
    if (postId.isBlank == true || UserModel.to.uId.isBlank == true) return;
    try {
      // await FirebaseFirestore.instance
      //     .collection('communityposts')
      //     .doc(postId)
      //     .set({"reactionModel": reactionModel.toMap()}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('reactions')
          .doc(UserModel.to.uId ?? '')
          .set(reactionModel.toMap(), SetOptions(merge: true));
      // Logging like on post event
      AnalyticsController.to.instance.logLikeUnlikePost(
        eventType: 'like',
        communityId: communityId,
        postId: postId,
        userId: _firebaseUser.currentUser?.uid ?? '',
      );
    } on Exception catch (_) {}
  }

  //pin a post
  Future<void> pinAPost(
    String communityId,
    String postId,
  ) async {
    if (communityId.isBlank == true || postId.isBlank == true) return;
    try {
      /// if already there is pinned post, just unpin it.
      await FirebaseFirestore.instance.collection('communityposts').where("isPinned", isEqualTo: true).get().then((pinnedPost) {
        if (pinnedPost.docs.isNotEmpty) {
          pinnedPost.docs.first.reference.update({"isPinned": false});
        }
      });
      await FirebaseFirestore.instance.collection('communities').doc(communityId).set({
        "pinnedPostList": [postId]
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('communityposts').doc(postId).set({"isPinned": true}, SetOptions(merge: true));

      // Logging pin a post event
      AnalyticsController.to.instance.logPinUnpinPost(
        eventType: 'pin',
        postId: postId,
        communityId: communityId,
        userId: _firebaseUser.currentUser?.uid ?? '',
      );
    } catch (_) {}
  }

  /// pin a community in My communities row at groups.view.
  /// if already there is pinned community, just unpin it.
  /// [pinnedCommunities] is the list of pinned communities.
  Future<void> pinOrUnpinCommunity(
      {required String? communityId, bool shouldPin = true, List<DocumentReference<Object?>> pinnedCommunities = const []}) async {
    User? user = _firebaseUser.currentUser;
    try {
      if (user != null && communityId.isBlank == false) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        batch.set(FirebaseFirestore.instance.collection('users').doc(user.uid).collection('communities').doc(communityId),
            {"isPinned": shouldPin}, SetOptions(merge: true));
        for (var pinnedCommunity in pinnedCommunities) {
          batch.update(pinnedCommunity, {"isPinned": false});
        }

        batch.commit();
      }
    } on Exception catch (_) {}
  }

  //like of post
  Future<void> unpinAPost(
    String communityId,
    String postId,
  ) async {
    if (communityId.isBlank == true || postId.isBlank == true) return;
    try {
      await FirebaseFirestore.instance.collection('communities').doc(communityId).set({"pinnedPostList": []}, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('communityposts').doc(postId).set({"isPinned": false}, SetOptions(merge: true));

      // Logging un pin a post event
      AnalyticsController.to.instance.logPinUnpinPost(
        eventType: 'unpin',
        postId: postId,
        communityId: communityId,
        userId: _firebaseUser.currentUser?.uid ?? '',
      );
    } catch (_) {}
  }

  // unpin a post
  // Future<void> crownOnPost(String postId,  String receiverId, String userId) async {
  //   await FirebaseFirestore.instance.collection('communityposts').doc(postId).set({
  //     "crownsBy": FieldValue.arrayUnion([_firebaseUser.currentUser!.uid])
  //   }, SetOptions(merge: true));
  //   // .collection('likes').
  //   // .doc(docId)
  //   // .set(setPostLikesData);
  // }

  //save the post
  Future savePost(String postId, Map<String, dynamic> setPostFlowerPosts, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('communityposts').doc(postId).collection('savepost').doc(docId).set(setPostFlowerPosts);
    } catch (_) {}
  }

  //comment post func
  Future postComment(String currentPostId, String currentCommentDocId, Map<String, dynamic> setComments) async {
    try {
      await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(currentPostId)
          .collection('comments')
          .doc(currentCommentDocId)
          .set({...setComments, "score": 0});
      //todo: shift to cloud function
      FirebaseFirestore.instance
          .collection('communityposts')
          .doc(currentPostId)
          .set({"totalCommentsCount": FieldValue.increment(1)}, SetOptions(merge: true));
    } on Exception catch (_) {}
  }

  Future<void> deleteComment({required String postId, required String commentId, required int totalCommentsCount}) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('communityposts').doc(postId);
      final commentRef = postRef.collection('comments').doc(commentId);

      /// run with transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final rawPost = await transaction.get(postRef);

        if (rawPost.exists && rawPost.data() != null) {
          final post = Post.fromMap(rawPost.data()!);
          final recentComments = rawPost.data()!['recentComments'] as List<dynamic>?;

          /// find comment at index and remove it from recent comments
          if (recentComments != null) {
            final commentIndex = recentComments.indexWhere((element) => element['commentId'] == commentId);
            if (commentIndex != -1) {
              recentComments.removeAt(commentIndex);
              transaction.update(postRef, {"recentComments": recentComments});
            }
          }

          /// delete comment
          commentRef.delete();

          /// decrement total comments count but
          /// first check if total comments count is greater than 0
          if ((post.totalCommentsCountInt ?? 0) > 0) {
            transaction.update(postRef, {"totalCommentsCount": FieldValue.increment(-totalCommentsCount)});
          }

          MyLoggerServices.to.print("Comment has been deleted!");
        }
      });

      // final batch = FirebaseFirestore.instance.batch();
      // batch.delete(FirebaseFirestore.instance.collection('communityposts').doc(postId).collection('comments').doc(commentId));
      // batch.set(FirebaseFirestore.instance.collection('communityposts').doc(postId),
      //     {"totalCommentsCount": FieldValue.increment(-totalCommentsCount)}, SetOptions(merge: true));
      // await batch.commit();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteChildComment({required String postId, required String commentId, required String childCommentId}) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.delete(FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(childCommentId));

      batch.set(FirebaseFirestore.instance.collection('communityposts').doc(postId), {"totalCommentsCount": FieldValue.increment(-1)},
          SetOptions(merge: true));
      await batch.commit();
    } catch (_) {}
  }

  //set the reply
  Future setReply(String postId, String commentId, String replyDocId, Map<String, dynamic> setReplies) async {
    try {
      await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyDocId)
          .set(setReplies);
      //todo: shift to cloud function
      FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .set({"totalCommentsCount": FieldValue.increment(1)}, SetOptions(merge: true));
    } on Exception catch (_) {}
  }

  //get the community details about the post
  Future<DocumentSnapshot?> getCommunityDetails(String docID) async {
    if (docID.isBlank == true) return null;
    try {
      DocumentSnapshot getCommunityDetails = await FirebaseFirestore.instance.collection('communities').doc(docID).get();

      return getCommunityDetails;
    } on Exception catch (_) {}
    return null;
  }

  /// Fetches Community Offline first, if not found then fetches from server
  Future<Community?> getCommunityObject({required String communityId, bool forcefullyServer = false}) async {
    if (!forcefullyServer) {
      final Community? community = CacheController.to.getCommunityById(communityId);
      if (community != null) {
        return community;
      }
    }

    return await getCommunityDetailsModel(communityId);
  }

  //get all the members in the community
  Stream<QuerySnapshot?> getAllMembers(String communityId) async* {
    if (communityId.isBlank == true) return;
    try {
      yield* FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .where("isMember", isEqualTo: true)
          .orderBy('isAdmin', descending: true)
          .snapshots();
    } on Exception catch (_) {}
  }

  //change notification subscription in a community
  Future changeNotificationSubscription(String communityid, bool isNotificationEnabled) async {
    try {
      /// update the membership notification
      final membershipQuery = _updateMembershipNotification(communityId: communityid, isNotificationEnabled: isNotificationEnabled);

      /// update the subscription notification in user collection + subscribe to topic
      // final subscriptionQuery =
      //     isNotificationEnabled ? subscribeToCommunity(communityId: communityid) : unsubscribeFromCommunity(communityId: communityid);
      Future.wait([
        membershipQuery,
      ]);
    } catch (_) {
      print('toggleNotificationsubscription error $_');
    }
  }

  // toggle fingerprint status for a secret community member
  Future toggleFingerprintStatusOfASecretCommunityMember(String communityid, bool fingerprintStatus) async {
    try {
      final membershipQuery = _updateSecretCommunityMemberFingerprintStatus(communityId: communityid, fingerprintStatus: fingerprintStatus);
      Future.wait([membershipQuery]);
    } catch (_) {
      debugPrint('toggleNotificationsubscription error $_');
    }
  }

  //change toggle Dm (who can send you message) Setting Status
  Future toggleDmSettingStatus(String userId, bool isEnable) async {
    try {
      final membershipQuery = _updateDmMessagesSettingStatus(userId: userId, isEnable: isEnable);
      Future.wait([membershipQuery]);
    } catch (_) {
      debugPrint('toggleNotificationsubscription error $_');
    }
  }

  //change toggle community auto post approval status
  Future toggleCommunityAutoPostsApprovalStatus(String communityId, bool isEnable) async {
    try {
      final membershipQuery = _updateCommunityAutoPostsApprovalStatus(communityId: communityId, isEnable: isEnable);
      Future.wait([membershipQuery]);
    } catch (_) {
      debugPrint('toggleNotificationsubscription error $_');
    }
  }

  Future<CommunityMembership?> getUserMembershipByCommunityId({required String communityId}) async {
    if (communityId.trim().isEmpty || UserModel.to.uId.isBlank == true) return null;
    CommunityMembership? membership;

    try {
      final membershipSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .doc(UserModel.to.uId)
          .get();
      if (membershipSnapshot.exists) {
        membership = CommunityMembership.fromMap(membershipSnapshot.data() as Map<String, dynamic>);
      }
    } catch (_) {
      MyLoggerServices.to.print('Error in getting user membership by community id: $_');
    }

    return membership;
  }

  Future<CommunityMembership?> getUserMembership({required String communityId, required String? userId}) async {
    if (communityId.trim().isEmpty || userId.isBlank == true) return null;
    CommunityMembership? membership;

    try {
      final membershipSnapshot =
          await FirebaseFirestore.instance.collection('communities').doc(communityId).collection('communityMembers').doc(userId).get();
      if (membershipSnapshot.exists) {
        membership = CommunityMembership.fromMap(membershipSnapshot.data() as Map<String, dynamic>);
      }
    } catch (_) {
      MyLoggerServices.to.print('Error in getting user membership by community id: $_');
    }

    return membership;
  }

  /// updates membership notification
  Future<void> _updateMembershipNotification({required String communityId, required bool isNotificationEnabled}) async {
    try {
      if (UserModel.to.uId.isBlank == true) return;
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .doc(UserModel.to.uId)
          .update({'isNotificationEnabled': isNotificationEnabled});
    } catch (_) {
      print('object');
    }
  }

  /// updates Secret Community Member Fingerprint Status
  Future<void> _updateSecretCommunityMemberFingerprintStatus({required String communityId, required bool fingerprintStatus}) async {
    try {
      if (UserModel.to.uId.isBlank == true) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserModel.to.uId)
          .collection('communities')
          .doc(communityId)
          .update({'allowFingerprint': fingerprintStatus});
    } catch (_) {
      print('object');
    }
  }

  /// update community auto posts approval Status
  Future<void> _updateCommunityAutoPostsApprovalStatus({required String communityId, required bool isEnable}) async {
    try {
      await FirebaseFirestore.instance.collection('communities').doc(communityId).update({'isPostApprovalNeeded': isEnable});
    } catch (_) {
      print('object');
    }
  }

  /// updates Dm Messages Status
  Future<void> _updateDmMessagesSettingStatus({required String userId, required bool isEnable}) async {
    try {
      if (userId.isBlank == true) return;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'allowToDm': isEnable});
    } catch (_) {
      print('object');
    }
  }

  //get all community moderators id's of the community
  Future<Map<String, List<UserModel>>> getCommunityModerators(Community createCommunityModel) async {
    List<UserModel> _allMembers = [];
    List<UserModel> _allModerators = [];
    Map<String, List<UserModel>> allMembersAndModerators = {'allMembers': _allMembers, 'allModerators': _allModerators};
    try {
      List<UserModel> _allMembers = [];
      List<UserModel> _allModerators = [];
      QuerySnapshot<Map<String, dynamic>> communityMembers = await FirebaseFirestore.instance
          .collection('communities')
          .doc(createCommunityModel.communityId)
          .collection('communityMembers')
          .where("isMember", isEqualTo: true)
          .where("isAdmin", isEqualTo: false)
          .get();

      if (communityMembers.size > 0) {
        return await getCommunityModeratorsProfile(communityMembers, createCommunityModel);
      }
      allMembersAndModerators = {'allMembers': _allMembers, 'allModerators': _allModerators};
    } catch (e) {
      debugPrint("error in getting the members ids in the communitttt ${e.toString()}");
    }
    return allMembersAndModerators;
  }

  //get all community moderators profile of the community
  Future<Map<String, List<UserModel>>> getCommunityModeratorsProfile(
      QuerySnapshot<Map<String, dynamic>> communityMemberIds, Community createCommunityModel) async {
    List<UserModel> _allMembers = [];
    List<UserModel> _allModerators = [];
    Map<String, List<UserModel>> allMembersAndModerators = {'allMembers': _allMembers, 'allModerators': _allModerators};

    try {
      for (var member in communityMemberIds.docs) {
        try {
          if (member.data()['userUid']?.toString().isBlank == true) continue;
          final user = await FirebaseFirestore.instance.collection('users').doc(member.data()['userUid']).get().catchError((_) {});
          if (user.data() != null) {
            _allMembers.add(UserModel.fromSnapshot(user));
            if (createCommunityModel.moderators != null && createCommunityModel.moderators!.contains(user.id)) {
              _allModerators.add(UserModel.fromSnapshot(user));
            }
          }
        } catch (_) {}
      }
      allMembersAndModerators = {'allMembers': _allMembers, 'allModerators': _allModerators};
    } catch (_) {
      debugPrint("error in getting the members profiles from member ids in the community ${_.toString()}");
    }

    return allMembersAndModerators;
  }

  // making user moderator in the communnity
  Future toggleCommunityModerator(String communityId, String userId, bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .doc(userId)
          .update({'isModerator': value});
    } on Exception catch (_) {}
  }

  // making user moderator in the communnity
  Future setCommunityModeratorTapColor(String communityId, String color) async {
    try {
      await FirebaseFirestore.instance.collection('communities').doc(communityId).update({'moderatorTagColor': color});
    } on Exception catch (_) {}
  }

  //check whether the user is memeber of community or not
  Future<QuerySnapshot?> checkUserMemberOfCommunity(String communityId) async {
    User? user = _firebaseUser.currentUser;
    if (user == null) return null;
    try {
      QuerySnapshot checkUserMembers = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .where('userUid', isEqualTo: user.uid)
          .get();
      return checkUserMembers;
    } on Exception catch (_) {}
    return null;
  }

  //join the group
  Future<DocumentSnapshot?> joinTheGroup(String communityDocId, Map<String, dynamic> joinGroup) async {
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityDocId)
          .collection('communityMembers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set(joinGroup);
      requestToCommunity(id: communityDocId);
    } catch (_) {}

    //MyLoggerServices.to.print("$communityDocId response of jopining ${(await response.path)}");
    return null;
  }

  /// this is for the community request
  ///   /// for deletion purpose because if request is pending we dont
  //     /// know when to delete it. so this is for reference.
  Future<void> requestToCommunity({required String id}) async {
    /// for deletion purpose because if request is pending we dont
    /// know when to delete it. so this is for reference.
    try {
      if (id.isBlank == true || FirebaseAuth.instance.currentUser?.uid == null) {
        return;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('sentCommunitiesRequests')
          .doc(id)
          .set({'communityId': id});
    } on Exception catch (_) {}
  }

  Future<DocumentSnapshot?> addCommunityToUser(UserCommunitiesModel community) async {
    User? user = _firebaseUser.currentUser;
    if (user == null) return null;
    try {
      print("addCommunityToUser community.communityId ${community.communityId}");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('communities')
          .doc(community.communityId)
          .set(community.toMap());
    } on Exception catch (_) {}
    return null;
  }

  Future<DocumentSnapshot?> addCommunityToTheAcceptedUsers(Map<String, dynamic> addCommunitiesToUsers, String userUid) async {
    try {
      if (userUid.isBlank == true || addCommunitiesToUsers["communityId"].toString().isBlank == true) {
        return null;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('communities')
          .doc(addCommunitiesToUsers["communityId"])
          .set(addCommunitiesToUsers);
    } on Exception catch (_) {}
    return null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserCommunites() async* {
    User? user = _firebaseUser.currentUser;
    if (user == null) yield* const Stream.empty();
    try {
      yield* FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('communities')
          .snapshots(includeMetadataChanges: true);
    } on Exception catch (_) {}
  }

  /// Returns Future of my communities ids from user collection
  Future<QuerySnapshot<Map<String, dynamic>>?> getMyCommunities() async {
    User? user = _firebaseUser.currentUser;
    if (user == null) null;
    try {
      return FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('communities').get();
    } on Exception catch (_) {}
    return null;
  }

  //get all the users communities
  Future<int> getMyCommunitesCount() async {
    int count = 0;
    if (FirebaseAuth.instance.currentUser?.uid == null) return count;
    try {
      final communitiesCount = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('communities')
          .count()
          .get();
      count = communitiesCount.count;
    } catch (_) {}

    return count;
  }

  //to get the other user community details
  Future<int> getOtherUserCommunitiesCount(String otherUserUid) async {
    if (otherUserUid.isBlank == true) return 0;
    try {
      final communitiesCount =
          await FirebaseFirestore.instance.collection('users').doc(otherUserUid).collection('communities').count().get();
      int count = communitiesCount.count;
      return count;
    } on Exception catch (_) {}
    return 0;
  }

  //get the other user friends count
  Future<int> getOtherUserFriendCount(String otherUserUid) async {
    int totalFriends = 0;
    try {
      AggregateQuerySnapshot recievers = await FirebaseFirestore.instance
          .collection('friendship')
          .where('Recieveruid', isEqualTo: otherUserUid)
          .where('isaccepted', isEqualTo: true)
          .count()
          .get();
      AggregateQuerySnapshot senders = await FirebaseFirestore.instance
          .collection('friendship')
          .where('senderUid', isEqualTo: otherUserUid)
          .where('isaccepted', isEqualTo: true)
          .count()
          .get();
      totalFriends = recievers.count + senders.count;
    } catch (e) {
      MyLoggerServices.to.print(e);
    }

    return totalFriends;
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getFriendshipWithOtherUser({required String otherUserId}) async {
    try {
      if (otherUserId.isBlank == true || FirebaseAuth.instance.currentUser?.uid == null) return null;
      final response = await FirebaseFirestore.instance
          .collection('friendship')
          .where(
            Filter.or(
              Filter.and(
                  Filter('senderUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid), Filter('Recieveruid', isEqualTo: otherUserId)),
              Filter.and(
                Filter('senderUid', isEqualTo: otherUserId),
                Filter('Recieveruid', isEqualTo: FirebaseAuth.instance.currentUser?.uid),
              ),
            ),
          )
          .get();

      return response;
    } catch (_) {
      debugPrint("error in getFriendshipWithOtherUser");
    }
    return null;
  }

  //get the current user friends count
  Future<int> currentUserFriendCount() async {
    int totalFriends = 0;
    if (FirebaseAuth.instance.currentUser?.uid == null) return totalFriends;
    try {
      AggregateQuerySnapshot recievers = await FirebaseFirestore.instance
          .collection('friendship')
          .where(
            'Recieveruid',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid,
          )
          .where('isaccepted', isEqualTo: true)
          .count()
          .get();
      AggregateQuerySnapshot senders = await FirebaseFirestore.instance
          .collection('friendship')
          .where('senderUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('isaccepted', isEqualTo: true)
          .count()
          .get();
      totalFriends = recievers.count + senders.count;
    } catch (e) {
      MyLoggerServices.to.print(e);
    }
    return totalFriends;
  }

  //Leave the community
  Future leaveTheCommunity(String communityId) async {
    User? user = _firebaseUser.currentUser;
    if (communityId.isBlank == true || user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('communities')
          .where('communityId', isEqualTo: communityId)
          .get()
          .then((snapshot) => snapshot.docs.first.reference.delete());
    } catch (_) {}
  }

  //remove the user from the community
  Future removeTheUserFromCommunity(String communityId, String userUid) async {
    if (userUid.isBlank == true || communityId.isBlank == true) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('communities')
          .where('communityId', isEqualTo: communityId)
          .get()
          .then((snapshot) => snapshot.docs.first.reference.delete());
    } catch (_) {}
  }

  //delete the user from community
  Future<void> deleteUserFromCommunity(String communityId) async {
    User? user = _firebaseUser.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .where('userUid', isEqualTo: user.uid)
          .get()
          .then((value) => value.docs.first.reference.delete());
    } on Exception catch (_) {}
    return;
  }

  //remove the user from community
  Future<void> removeTheUserFromTheUserCollection(String communityId, String userUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .where('userUid', isEqualTo: userUid)
          .get()
          .then((value) => value.docs.first.reference.delete());
    } on Exception catch (_) {}
    return;
  }

  //search all the public communites
  Future<QuerySnapshot?> serchTheCommunities() async {
    try {
      QuerySnapshot data = await FirebaseFirestore.instance.collection('communities').get();
      return data;
    } on Exception catch (_) {}
    return null;
  }

  //get the all community details in which user is login on community view page
  Future<DocumentSnapshot?> getCommunitiesDetails(String? communityId) async {
    if (communityId.isBlank == true || communityId == null) return null;
    try {
      DocumentSnapshot data = await FirebaseFirestore.instance.collection('communities').doc(communityId).get();
      return data;
    } on Exception catch (_) {
      print("getCommunitiesDetails Error : $_");
    }
    return null;
  }

  //get the random communities from the list
  Future<QuerySnapshot?> randomCommunities(List<String> randomCommunities) async {
    try {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('communities')
          .where('topics.${'topicName'}', whereIn: getOnlyRandomTen(randomCommunities))
          .where('type', isEqualTo: 'Public')
          .get();
      return data;
    } on Exception catch (_) {}
    return null;
  }

  /*Notification Services*/
  //Add Notification
  Future<void> addNotification({
    required String title,
    required String senderId,
    required String userImage,
    required String body,
    required String receiverUserID,
    required String time,
    required bool isRead,
    required String type,
    String? posId,
    String? communityId,
  }) async {
    try {
      if (receiverUserID.isBlank == true) return;
      await FirebaseFirestore.instance.collection('users').doc(receiverUserID).collection("notifications").add({
        "sender_name": title,
        "sender_user_id": senderId,
        "userImage": userImage,
        "message": body,
        "receiverUserID": receiverUserID,
        "time": time,
        "isRead": false,
        "type": type,
        'postId': posId,
        'communityId': communityId
      });
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  readNotification({
    required String? receiverUserID,
    required String? notificationId,
    String? type,
  }) async {
    if (receiverUserID.isBlank == true || notificationId.isBlank == true || UserModel.to.uId.isBlank == true) {
      return;
    }
    try {
      if (receiverUserID == null || notificationId == null) return;
      await FirebaseFirestore.instance.collection('users').doc(receiverUserID).collection("notifications").doc(notificationId).update({
        "isRead": true,
      });

      // Logging view notification analytics event
      AnalyticsController.to.instance.logViewNotification(
        userId: UserModel.to.uId ?? '',
        notificationId: notificationId,
        type: type ?? '',
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId.isBlank == true) return;
    try {
      final allNotification = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("notifications")
          .where("isRead", isEqualTo: false)
          .get();

      final totalDocs = allNotification.docs;

      final noOfChunks = splitIntoChunks(totalDocs: totalDocs);
      for (var split in noOfChunks) {
        final chunk = totalDocs.sublist(0, split);
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var doc in chunk) {
          batch.update(
            FirebaseFirestore.instance.collection('users').doc(userId).collection("notifications").doc(doc.id),
            {"isRead": true},
          );
        }
        await batch.commit();
      }
    } on Exception catch (_) {}
  }

  //updateing a post topics list
  Future updatePostTopics(Post post) async {
    try {
      if (post.postid.isBlank == true) return;
      FirebaseFirestore.instance.collection('communityposts').doc(post.postid).update({
        'postTopicList': post.postTopicList,
      });
    } catch (_) {}
  }

/*Notifications Services End*/

  Future updateModeratorsTagData(String communityId, Map<String, dynamic> moderatorTagData) async {
    try {
      if (communityId.isBlank == true) return;
      await FirebaseFirestore.instance.collection('communities').doc(communityId).update({
        'moderatorTagData': moderatorTagData,
      });
    } catch (_) {}
  }

  Future<bool> isMemberOfCommunity(String communityId) async {
    /// check offline first
    bool isMember = AppConfigurationController.to.isMemberOfCommunity(communityId);
    if (isMember) {
      debugPrint("isMemberOfCommunity local : $isMember");
      return true;
    }
    if (UserModel.to.uId.isBlank == true || communityId.isBlank == true) return false;

    /// for further, check from server
    (await FirebaseFirestore.instance.collection('communities').doc(communityId).collection('communityMembers').doc(UserModel.to.uId).get())
            .exists
        ? isMember = true
        : isMember = false;

    debugPrint("isMemberOfCommunity server : $isMember");
    return isMember;
  }

  //get all memebers id's of the community
  Future<List<UserModel>> getCommunityMemeberIds(String communityId) async {
    try {
      if (communityId.isBlank == true) return [];
      QuerySnapshot<Map<String, dynamic>> communityMembers = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .where('isMember', isEqualTo: true)
          .get();
      if (communityMembers.size > 0) {
        return await getCommunityMembersProfile(communityMembers);
      }
    } catch (e) {
      debugPrint("error in getting the members ids in the community ${e.toString()}");
    }
    return [];
  }

  //get all community moderators profile of the community
  Future<List<UserModel>> getCommunityMembersProfile(QuerySnapshot<Map<String, dynamic>> communityMemberIds) async {
    List<UserModel> _allMembers = [];

    for (var member in communityMemberIds.docs) {
      if ((member.data()["userUid"]?.toString().isBlank == true)) continue;
      final user = await FirebaseFirestore.instance.collection('users').doc(member.data()["userUid"]).get().catchError((_) {});
      if (user.data() != null) {
        try {
          _allMembers.add(UserModel.fromSnapshot(user));
        } catch (_) {
          debugPrint("error in getting the members profiles from member ids in the community ${_.toString()}");
        }
      }
    }

    return _allMembers;
  }

  Future<int> getCommunityTotalMembers(String communityId) async {
    try {
      if (communityId.isBlank == true) return 0;
      return await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .where('isMember', isEqualTo: true)
          .getCount();
    } catch (e) {
      debugPrint("error in getting the community total members ${e.toString()}");
    }
    return 0;
  }

  Future<List<Community>> getCommunityList() async {
    List<Community> _communityList = [];
    try {
      QuerySnapshot<Map<String, dynamic>> communityList = await FirebaseFirestore.instance.collection('communities').get();
      if (communityList.size > 0) {
        communityList.docs.sort((a, b) => b.data()["totalmembers"].compareTo(a.data()["totalmembers"]));
        for (var community in communityList.docs) {
          _communityList.add(Community.fromMap(community.data()));
        }
      }
    } catch (e) {
      debugPrint("error in getting the community list ${e.toString()}");
    }
    return _communityList;
  }

  Future<Community?> getCommunityDetailsModel(String docID, {bool shouldHavePostCount = false}) async {
    if (docID.isBlank == true) return null;
    try {
      final lastVisitTimeStamp = await SeenUnseenPostServices.instance.getLastVisit(docID);

      /// get community details
      final futures = <Future>[FirebaseFirestore.instance.collection('communities').doc(docID).get()];

      if (shouldHavePostCount) {
        /// get post counts
        if (lastVisitTimeStamp != null) {
          futures.add(FirebaseFirestore.instance
              .collection('communityposts')
              .where("communityId", isEqualTo: docID)
              .where("createdOn", isGreaterThan: lastVisitTimeStamp)
              .count()
              .get());
        } else {
          futures.add(FirebaseFirestore.instance.collection('communityposts').where("communityId", isEqualTo: docID).count().get());
        }
      }

      final response = await Future.wait(futures);
      final getCommunityDetails = response[0] as DocumentSnapshot;
      final postCount = response.getOrNull(1) as AggregateQuerySnapshot?;

      return Community.fromMap(getCommunityDetails.data() as Map<String, dynamic>, totalUnseenPosts: postCount?.count ?? 0);
    } catch (_) {}
    return null;
  }

// update community last visit time of a user
  void updateCommunityLastVisitTimeForUser(String communityId) async {
    try {
      if (FirebaseAuth.instance.currentUser?.uid == null || communityId == "") return;
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('communities')
          .doc(communityId)
          .set({
        "lastVisit": DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  ///returns communties where user has joined it. and also returns the post count of the community
  Future<List<Community>> getMyCommunitiesWithPostCount({bool ignoreArchived = true}) async {
    List<String> _joinedCommunitiesId = [];
    List<Community> _joinedCommunities = [];
    try {
      User? _firebaseUser = FirebaseAuth.instance.currentUser;
      if (_firebaseUser == null) {
        return [];
      }

      //getting joined community ids
      final joinedGroupIdsSnap =
          await FirebaseFirestore.instance.collection('users').doc(_firebaseUser.uid).collection('communities').get();
      //remove those where its pendings
      print("getting joined getMyCommunitiesWithPostCount ${joinedGroupIdsSnap.docs.length}");
      final _configController = AppConfigurationController.to;
      for (var community in joinedGroupIdsSnap.docs) {
        if (!_configController.isHiddenCommunityV2(communityId: community.id)) {
          _joinedCommunitiesId.add(community.id);
        }
      }

      //getting the community details
      if (_joinedCommunitiesId.isNotEmpty) {
        final futures = Future.wait(_joinedCommunitiesId.map((e) => getCommunityDetailsModel(e, shouldHavePostCount: true)));

        final List<Community?> response = await futures;

        _joinedCommunities = response.whereType<Community>().toList();
        if (ignoreArchived) {
          _joinedCommunities.removeWhere((element) => element.isArchived == true);
        }
      } else {
        debugPrint("No joined communities for user ${_firebaseUser.uid}");
      }
    } catch (mainError) {
      debugPrint("Error at getJoinedCommunities: $mainError");
    }
    print("returning joined communities ${_joinedCommunities.length}");
    return _joinedCommunities;
  }

  /// returns 30 unread notifications max, if user is not logged in, it will return 0
  Stream<int> getUnreadNotification() {
    if (FirebaseAuth.instance.currentUser?.uid == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .orderBy('time', descending: true)
        .limit(100)
        .snapshots()
        .map((event) => event.docs.length);
  }

  /// update my communities list to get updated stream
  /// in My Communities Horizontal list view
  void updateMyCommunities(String? communityId) {
    try {
      if (FirebaseAuth.instance.currentUser?.uid == null || communityId == null) return;
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('communities')
          .doc(communityId)
          .set({
        "updatedOn": DateTime.now(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}

mixin CommunitySubscriptionTopics {
  /// reference.
  DocumentReference<Map<String, dynamic>> subscriptionRef(String? userId) =>
      FirebaseFirestore.instance.collection('users').doc(userId).collection('subscribedTopics').doc("communities");

  /// Firebase field
  String get subscriptionField => "subscriptions";

  /// Subscribe to all the communities that the user is subscribed to
  Future<void> subscribeToAllSubscribedCommunity() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) return;
    try {
      final subscribedCommunitiesIds = await getSubscribedCommunitiesIds();
      for (var communityId in subscribedCommunitiesIds) {
        await subscribeToCommunity(communityId: communityId);
      }
    } catch (_) {}
  }

  /// Unsubscribe from all the communities that the user is subscribed to...
  /// [disposeToken] if true, only unsubscribe from the topic
  Future<void> unsubscribeFromAllSubscribedCommunity({bool disposeToken = false}) async {
    if (FirebaseAuth.instance.currentUser?.uid == null) return;
    try {
      final subscribedCommunitiesIds = await getSubscribedCommunitiesIds();
      for (var communityId in subscribedCommunitiesIds) {
        if (disposeToken) {
          // unsubscribe from topic only
          await disposeFCMToken(communityId: communityId);
        } else {
          // remove from collection + unsubscribe from topic
          await unsubscribeFromCommunity(communityId: communityId);
        }
      }
    } catch (_) {}
  }

  Future<void> disposeFCMToken({required String communityId}) async {
    if (FirebaseAuth.instance.currentUser?.uid == null) return;
    await _unsubscribeTopicById(communityId);
  }

  Future<List<String>> getSubscribedCommunitiesIds() async {
    List<String> _subscribedCommunitiesIds = [];
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return _subscribedCommunitiesIds;
    }
    try {
      final snapshot = await subscriptionRef(FirebaseAuth.instance.currentUser?.uid).get();
      if (snapshot.exists) {
        _subscribedCommunitiesIds = List<String>.from(snapshot.data()?['subscriptions'] ?? []);
      }
    } catch (_) {}

    return _subscribedCommunitiesIds;
  }

  Future<void> subscribeToCommunity({required String communityId}) async {
    MyLoggerServices.to.print("subscribeToCommunity $communityId");
    if (FirebaseAuth.instance.currentUser?.uid == null) return;
    try {
      await subscriptionRef(FirebaseAuth.instance.currentUser?.uid).set({
        subscriptionField: FieldValue.arrayUnion([communityId])
      });

      await _subscribeTopicById(communityId);
    } catch (_) {}
  }

  Future<void> unsubscribeFromCommunity({required String communityId}) async {
    MyLoggerServices.to.print("unsubscribeFromCommunity $communityId");
    if (FirebaseAuth.instance.currentUser?.uid == null) return;
    try {
      await subscriptionRef(FirebaseAuth.instance.currentUser?.uid).set({
        subscriptionField: FieldValue.arrayRemove([communityId])
      });
      await _unsubscribeTopicById(communityId);
    } catch (_) {}
  }

  Future<void> _unsubscribeTopicById(String communityId) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(communityId);
  }

  Future<void> _subscribeTopicById(String communityId) async {
    await FirebaseMessaging.instance.subscribeToTopic(communityId);
  }

/*  // add into array union if array union is less than 10
  Future<void> addCommunityToUserSubscribedTopics({required String communityId}) async {
    if (FirebaseAuth.instance.currentUser?.uid == null) return;
    try {
      final snapshot = await subscriptionRef(FirebaseAuth.instance.currentUser?.uid).get();
      if (snapshot.exists) {
        final subscriptions = List<String>.from(snapshot.data()?['subscriptions'] ?? []);
        if (subscriptions.length <= 10) {
          await subscriptionRef(FirebaseAuth.instance.currentUser?.uid).set({
            "subscriptions": FieldValue.arrayUnion([communityId])
          });
        }
      } else {
        await subscriptionRef(FirebaseAuth.instance.currentUser?.uid).set({
          "subscriptions": FieldValue.arrayUnion([communityId])
        });
      }
    } catch (_) {}
  }*/
}

extension ListHelper on List {
  /// returns value on index if index is less than list length then return null
  dynamic getOrNull(int index) {
    if (index < length) {
      return this[index];
    }
    return null;
  }
}
