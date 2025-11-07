import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/logger.dart';

import '../../../view/search/models/searched_post_item.dart';

class AlgoliaService {
  /// algolia api credential
  static const String algoliaAppId = "7V8WUJ2HVJ";
  static const String algoliaSearchKey = "48366a10f2f6da5c63b7d0ccafb37c91";
  User? user = FirebaseAuth.instance.currentUser;

  // indices
  final String userIndex = "users";
  final String communityIndex = "community";
  final String postIndex = "posts";
  final int userHitsPerPage = 20;
  final int postHitsPerPage = 10;
  final int communityHitsPerPage = 60;

  // indices searchable fields
  List<String> usersSearchAbleFields = ['name'];
  List<String> communitySearchAbleFields = ['name'];
  List<String> postsSearchAbleFields = ['caption'];

  late Algolia algolia;

  AlgoliaService() {
    algolia = const Algolia.init(applicationId: algoliaAppId, apiKey: algoliaSearchKey);
  }

  Algolia get getAlgolia => algolia;

  // get the user from algolia database
  // algolia-users
  Future<List<UserModel>> getsAllUsers(String queryData) async {
    try {
      List<UserModel> users = [];
      AlgoliaQuery query = algolia.instance.index(userIndex).query(queryData);
      query.setRestrictSearchableAttributes(usersSearchAbleFields);
      AlgoliaQuerySnapshot snapshot = await query.setHitsPerPage(userHitsPerPage).getObjects();
      final usersRawHits = snapshot.toMap()['hits'] as List;
      users = List<UserModel>.from(usersRawHits.map((hit) => UserModel.fromAlgoliaMap(hit)));

      /// remove myself from the list
      users.removeWhere((element) => element.uId == UserModel.to.uId);
      return users;
    } catch (e) {
      MyLoggerServices.to.print('error thrown here:=>${e.toString()}');
      return [];
    }
  }

  // algolia-users
  Future<List<dynamic>> getFeedsData(String queryData) async {
    try {
      List<UserModel> users = [];
      List<Community> communities = [];
      // queryA.
      AlgoliaQuery queryA = algolia.instance.index(userIndex).query(queryData);
      queryA.setRestrictSearchableAttributes(usersSearchAbleFields);
      // queryB
      AlgoliaQuery queryB = algolia.instance.index(communityIndex).query(queryData);
      queryB.setRestrictSearchableAttributes(communitySearchAbleFields);
      // Perform multiple facetFilters
      // queryA = queryA.facetFilter('status:active');
      // queryA = queryA.facetFilter('isDelete:false');
      // Get Result/Objects
      List<AlgoliaQuerySnapshot> algoliaSnapshots = await getAlgolia.multipleQueries
          .addQueries([queryA.setHitsPerPage(userHitsPerPage), queryB.setHitsPerPage(communityHitsPerPage)]).getObjects();
      final usersRawHits = algoliaSnapshots.first.toMap()['hits'] as List;
      final communitiesRawHits = algoliaSnapshots.last.toMap()['hits'] as List;
      users = List<UserModel>.from(usersRawHits.map((hit) => UserModel.fromAlgoliaMap(hit)));
      communities = List<Community>.from(communitiesRawHits.map((hit) => Community.fromAlgoliaMap(hit)));

      /// remove myself from the list
      users.removeWhere((element) => element.uId == UserModel.to.uId);

      return [users, communities];
    } catch (e) {
      MyLoggerServices.to.print('error thrown here:=>${e.toString()}');
      return [];
    }
  }

  /// invoke to get users with [usernameTextToSearch]
  Future<List<UserModel>> getUsersWithUsernameText(
    String usernameTextToSearch, {
    int perPageHits = 20,
    int page = 0,
  }) async {
    try {
      List<UserModel> users = [];
      // creating search query for getting users with the usernameTextToSearch
      AlgoliaQuery usersWithUsernameTextQuery = algolia.instance
          .index(userIndex)
          // setting per page hits
          .setHitsPerPage(perPageHits)
          // setting page for pagination
          .setPage(page)
          .query(usernameTextToSearch);

      // restricting search query only to usernames
      usersWithUsernameTextQuery.setRestrictSearchableAttributes(usersSearchAbleFields);
      // getting algolia snapshot for usersWithUsernameTextQuery
      AlgoliaQuerySnapshot usersWithUsernameTextQuerySnapshot = await usersWithUsernameTextQuery.getObjects();
      // getting raw users list form snapshot
      final List usersRawHits = usersWithUsernameTextQuerySnapshot.toMap()['hits'] as List;
      // parsing raw users to List<UserModel>
      users = List<UserModel>.from(usersRawHits.map((userRawHit) => UserModel.fromAlgoliaMap(userRawHit)));

      /// remove myself from the list
      users.removeWhere((element) => element.uId == UserModel.to.uId);
      return users;
    } catch (e) {
      MyLoggerServices.to.print('error thrown here:=>${e.toString()}');
      return [];
    }
  }

  /// invoke to get posts with [postTextToSearch]
  Future<List<SearchedPostItem>> getPostsWithPostText(
    String postTextToSearch, {
    int perPageHits = 10,
    int page = 0,
  }) async {
    try {
      List<SearchedPostItem> posts = [];
      // creating search query for getting posts with the postTextToSearch
      AlgoliaQuery postsWithPostTextQuery = algolia.instance
          .index(postIndex)
          // setting per page hits
          .setHitsPerPage(perPageHits)
          // setting page for pagination
          .setPage(page)
          .query(postTextToSearch);
      // restricting search query only to caption
      postsWithPostTextQuery.setRestrictSearchableAttributes(postsSearchAbleFields);
      // getting algolia snapshot for postsWithPostTextQuery
      AlgoliaQuerySnapshot postsWithPostTextQuerySnapshot = await postsWithPostTextQuery.getObjects();
      // getting raw posts list form snapshot
      final List postsRawHits = postsWithPostTextQuerySnapshot.toMap()['hits'] as List;
      // parsing raw users to List<SearchedPostItem>
      posts = List<SearchedPostItem>.from(postsRawHits.map((userRawHit) => SearchedPostItem.fromAlgoliaMap(userRawHit)));

      return posts;
    } catch (e) {
      MyLoggerServices.to.print('error thrown here:=>${e.toString()}');
      return [];
    }
  }

  /// invoke to get communities with [communityTextToSearch]
  Future<List<Community>> getCommunitiesWithCommunityText(
    String communityTextToSearch, {
    int perPageHits = 10,
    int page = 0,
  }) async {
    try {
      List<Community> communities = [];
      // creating search query for getting communities with the communityTextToSearch
      AlgoliaQuery communitiesWithCommunityTextQuery = algolia.instance
          .index(communityIndex)
          // setting per page hits
          .setHitsPerPage(perPageHits)
          // setting page for pagination
          .setPage(page)
          .query(communityTextToSearch);
      // restricting search query only to community name
      communitiesWithCommunityTextQuery.setRestrictSearchableAttributes(communitySearchAbleFields);
      // getting algolia snapshot for communityTextToSearch
      AlgoliaQuerySnapshot communitiesWithCommunityTextQuerySnapshot = await communitiesWithCommunityTextQuery.getObjects();
      // getting raw communities list form snapshot
      final List communitiesRawHits = communitiesWithCommunityTextQuerySnapshot.toMap()['hits'] as List;
      // parsing raw communities to List<Community>
      communities = List<Community>.from(
        communitiesRawHits.map(
          (communityRawHit) => Community.fromAlgoliaMap(communityRawHit),
        ),
      );

      return communities;
    } catch (e) {
      MyLoggerServices.to.print('error thrown here:=>${e.toString()}');
      return [];
    }
  }

  // algolia-community
  Future<List<Community>> getCommunities(String queryData) async {
    try {
      MyLoggerServices.to.print(('this is query:=>$queryData'));
      List<Community> communities = [];
      AlgoliaQuery query = getAlgolia.instance.index(communityIndex).query(queryData);
      query.setRestrictSearchableAttributes(communitySearchAbleFields);
      AlgoliaQuerySnapshot snapshot = await query.setHitsPerPage(communityHitsPerPage).getObjects();
      final communitiesRawHits = snapshot.toMap()['hits'] as List;
      communities = List<Community>.from(communitiesRawHits.map((hit) => Community.fromAlgoliaMap(hit)));
      MyLoggerServices.to.print('this is length:${communities.length}');
      return communities;
    } catch (e) {
      MyLoggerServices.to.print(('this is error:=>${e.toString()}'));
      return <Community>[];
    }
  }

// algolia-users
  Future<List<UserModel>> getCommunityMembers(String queryData) async {
    try {
      AlgoliaQuery query = getAlgolia.instance.index(communityIndex).query(queryData);
      // query.facetFilter('isTechnicianAssigned:false').facetFilter("orgId:${user.organizationId}");
      AlgoliaQuerySnapshot snapshot = await query.getObjects();
      final rawHits = snapshot.toMap()['hits'] as List;
      print("OBJKE ID ${rawHits.first['objectID']}");
      final hits = List<UserModel>.from(rawHits.map((hit) => UserModel.fromMap(hit, userId: hit['objectID'])));
      if (hits.isEmpty) {
        return <UserModel>[];
      } else {
        return hits;
      }
    } catch (e) {
      return <UserModel>[];
    }
  }

  // algolia-post
  Future<List<Post>> getPosts(String queryData) async {
    try {
      AlgoliaQuery query = getAlgolia.instance.index(postIndex).query(queryData);
      // query.facetFilter('isTechnicianAssigned:false').facetFilter("orgId:${user.organizationId}");
      AlgoliaQuerySnapshot snapshot = await query.getObjects();
      final rawHits = snapshot.toMap()['hits'] as List;
      final hits = List<Post>.from(rawHits.map((hit) => Post.fromMap(hit)));
      if (hits.isEmpty) {
        return <Post>[];
      } else {
        return hits;
      }
    } catch (e) {
      return <Post>[];
    }
  }

  // algolia-users-and communities
  Future<List<Map<String, dynamic>>> getUserAndCommunitiesForMentions(String queryData) async {
    try {
      List<Map<String, dynamic>> users = [];
      List<Map<String, dynamic>> communities = [];
      // queryA.
      AlgoliaQuery queryA = algolia.instance.index(userIndex).query(queryData);
      queryA.setRestrictSearchableAttributes(usersSearchAbleFields);
      // queryB
      AlgoliaQuery queryB = algolia.instance.index(communityIndex).query(queryData);
      queryB.setRestrictSearchableAttributes(communitySearchAbleFields);

      // Get Result/Objects
      List<AlgoliaQuerySnapshot> algoliaSnapshots =
          await getAlgolia.multipleQueries.addQueries([queryA.setHitsPerPage(30), queryB.setHitsPerPage(30)]).getObjects();

      final usersRawHits = algoliaSnapshots.first.toMap()['hits'] as List;
      final communitiesRawHits = algoliaSnapshots.last.toMap()['hits'] as List;
      users = List.from(usersRawHits.map((hit) {
        return {
          "id": hit['objectID'] ?? '',
          "display": hit['name'] ?? '',
          "senderUid": hit['objectID'] ?? '',
          "profilePic": hit['profilePic'] ?? ''
        };
      }));
      communities = List.from(communitiesRawHits.map((hit) {
        return {
          "id": hit['objectID'] ?? '',
          "display": hit['name'] ?? '',
          "senderUid": hit['objectID'] ?? '',
          "profilePic": hit['profilePicture'] ?? '',
          "isCommunity": true,
        };
      }));
      users.addAll(communities);

      /// remove myself from the list
      users.removeWhere((element) => element['id'] == UserModel.to.uId);
      return users;
    } catch (e) {
      print('error thrown here:=>${e.toString()}');
      rethrow;
    }
  }
}
