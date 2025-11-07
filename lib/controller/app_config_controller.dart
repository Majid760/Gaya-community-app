import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gaya/model/user.communities.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/crown_service/crown_services.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/community/communities/utils/communities_view_utils.dart';
import 'package:gaya/view/feed/services/local/posts/seen_unseen_post_services.dart';
import 'package:get/get.dart';

import '../model/community.model.dart';
import '../services/block_services.dart';
import '../services/services.dart';
import '../shared/service/super_admin/super_admin_services.dart';
import '../utils/logger.dart';

class AppConfigurationController extends GetxService with ReportedImpl, BlockedImpl, AppCacheImpl, AppSuperAdmin {
  static AppConfigurationController get to => Get.find();

  //communities
  List<Community> publicCommunities = [];

  // used for tagging/mentioning community in comment
  List<Community> allCommunitiesExceptSecret = [];

  List<Community> joinedCommunities = [];
  List<Community> asAdminCommunities = [];
  List<Community> asModeratorCommunities = [];
  List<UserCommunities> hiddenCommunities = [];
  List<String> requestSentCommunitiesIds = [];

  /// contains all the joined community memberships.
  List<UserCommunities> userCommunityMemberships = [];

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  GlobalKey<ScaffoldMessengerState> get getScaffoldKey => _scaffoldKey;

  //posts
  List<String> savedPostsID = [];

  final Services _commonServices = Services();

  Future<void> loadAppConfiguration() async {
    _getSavedPosts();
    getBlockedUsers();

    await Future.wait([
      _getPublicCommunities(),
      _getJoinedCommunities(),
      _getAdminCommunities(),
      _getModeratorCommunities(),
      _getHiddenCommunities(),
      checkIfSuperAdmin(),
    ]);

    _getAllCommunitiesExceptSecret();

    // getCrownServerTimeStamp();
  }

  Future<void> leaveCommunity(String communityId) async {
    try {
      joinedCommunities.removeWhere((community) => community.communityId == communityId);
      userCommunityMemberships.removeWhere((community) => community.communityId == communityId);
      publicCommunities.removeWhere((community) => community.communityId == communityId);
      asAdminCommunities.removeWhere((community) => community.communityId == communityId);
      asModeratorCommunities.removeWhere((community) => community.communityId == communityId);
      hiddenCommunities.removeWhere((community) => community.communityId == communityId);
      requestSentCommunitiesIds.removeWhere((reqCommunityId) => reqCommunityId == communityId);
      hiddenCommunitiesMap.removeWhere((key, value) => key == communityId);
    } catch (_) {
      MyLoggerServices.to.print("Error in leaveCommunity $communityId $_");
    }
  }

  // local in-app changes

  ///join public community
  void joinPublicCommunity(Community community) {
    publicCommunities.add(community);
    joinedCommunities.add(community);
  }

  /// joins a normal community
  void joinACommunity(Community community) {
    final alreadyJoined =
        joinedCommunities.indexWhere((element) => element.communityId == community.communityId && element.communityId != null);
    if (alreadyJoined != -1) {
      joinedCommunities.add(community);
    }
  }

  /// hides community from user
  Future<void> hideOrUnHideCommunity({required String? communityId, bool isUnhideOperation = false}) async {
    final userCommunities = UserCommunities(communityId: communityId);

    /// if unhide operation, remove from hidden communities
    if (isUnhideOperation) {
      hiddenCommunitiesMap.removeWhere((key, value) => key == communityId);
      hiddenCommunities.removeWhere((community) => community.communityId == communityId);
      await _commonServices.unhideACommunity(communityId: communityId);
      return;
    }

    /// Hide a community

    // if null or already exists, just return and do nothing.
    if (communityId == null || hiddenCommunities.contains(userCommunities)) return;

    // add locally
    hiddenCommunitiesMap[communityId] = communityId;
    hiddenCommunities.add(UserCommunities(communityId: communityId));
    // query to firestore
    await _commonServices.hideACommunity(communityId: communityId);

    /// hide or unhide community all over app.
    CommunitiesViewUtils.hideOrUnHideCommunityEverywhere(id: communityId, isUnhide: isUnhideOperation);
  }

  List<String> getHiddenCommunitiesIds() {
    List<String?> ids = hiddenCommunities.map((community) => community.communityId).toList();

    ids.removeWhere((element) => element == null);
    return ids.map((e) => e!).toList();
  }

  void removeSavedPostId(String postId) {
    try {
      savedPostsID.remove(postId);
    } catch (_) {}
  }

  bool isAdminOrModerator({required String? communityId, bool isAdminOnly = false}) {
    bool isAdmin = false;
    if (communityId == null) return false;

    /// if super admin that means admin of all communities
    if (isSuperAdmin) return true;

    List<String?> ids = isAdminOnly
        ? asAdminCommunities.map((community) => community.communityId).toList()
        : asAdminCommunities.map((community) => community.communityId).toList() +
            asModeratorCommunities.map((community) => community.communityId).toList();

    try {
      isAdmin = ids.contains(communityId);
    } catch (_) {}
    return isAdmin;
  }

  void updateLastPostCreatedAt({required String communityId}) {
    if (communityId.isBlank == true) return;

    final index = joinedCommunities.indexWhere((community) => community.communityId == communityId);

    if (index == -1) return;
    joinedCommunities[index].lastPostAt = joinedCommunities[index].lastPostAt = DateTime.now();
  }

  void resetOnLogInOrOut() {
    joinedCommunities.clear();
    allCommunitiesExceptSecret.clear();
    userCommunityMemberships.clear();
    asAdminCommunities.clear();
    savedPostsID.clear();
    asModeratorCommunities.clear();
    hiddenCommunities.clear();
    disposeBlocked();
    disposeReport();
    hiddenCommunitiesMap.clear();
    ChatController.to().removeListeners();

    UserModel.to.logOut();

    /// unsubscribe from all subscribed communities.
    // _commonServices.unsubscribeFromAllSubscribedCommunity(disposeToken: true);
    loadAppConfiguration();
  }

  ///it already ensures that no null value will be given for sure.
  List<String?> getJoinedCommunitiesIds() {
    List<String?> ids = joinedCommunities.map((community) => community.communityId).toList();
    ids.removeWhere((element) => element == null);
    return ids;
  }

  /// returns communities Id  that are private
  List<String?> getPrivateJoinedCommunitiesIds() {
    List<String?> ids =
        joinedCommunities.where((element) => element.isCommunityPrivate == true).map((community) => community.communityId).toList();

    if (ids.length < 10) {
      return ids;
    } else {
      return ids.sublist(0, 9);
    }
  }

  List<Community> getJoinedCommunityObjects() {
    List<Community> ids = joinedCommunities.map((community) => community).toList();
    ids.removeWhere(
        (element) => element.communityId == null || element.communityId!.isBlank == true || element.communityName.isBlank == true);
    return ids;
  }

  /// returns community object by id - protects from null values and blank values
  Community? getCommunityObjectById({required String? communityId}) {
    List<Community> communities = joinedCommunities + publicCommunities + asAdminCommunities + asModeratorCommunities;

    Community? community = communities.firstWhereOrNull((element) => element.communityId == communityId);
    if (community?.communityName.isBlank == true) {
      return null;
    }
    return community;
  }

//returns true if user is memeber of community.
  bool isMemberOfCommunity(String communityId, {bool includesAll = false}) {
    if (communityId.isBlank == true) return false;
    bool isMember = false;

    /// if super admin that means admin of all communities
    if (isSuperAdmin) return true;

    List<String?> ids = getJoinedCommunitiesIds() + asAdminCommunities.map((community) => community.communityId).toList();
    if (includesAll) {
      ids += publicCommunities.map((community) => community.communityId).toList() +
          asModeratorCommunities.map((community) => community.communityId).toList();
    }
    try {
      isMember = ids.contains(communityId);
      print("isMemberOfCommunity ${getJoinedCommunitiesIds()}");
    } catch (_) {
      MyLoggerServices.to.printError('Error in isMemberOfCommunity: $_');
    }
    return isMember;
  }

  Future<String> getUserMembershipByCommunityId({required String communityId}) async {
    String membership = 'notMember';

    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .doc(UserModel.to.uId)
          .get();

      if (snapshot.exists) {
        // Access the data from the snapshot
        var data = snapshot.data() as Map<String, dynamic>;
        if (data['isMember'] == true) {
          return membership = 'member';
        } else {
          return membership = 'waiting';
        }
      } else {
        return membership = 'notMember';
      }
    } catch (_) {
      MyLoggerServices.to.print('Error in getting user membership by community id: $_');
    }

    return membership;
  }

  bool isHiddenCommunity({required String? communityId}) {
    return isHiddenCommunityV2(communityId: communityId);
    // if (communityId.isBlank == true) return false;
    // bool isHidden = false;
    // try {
    //   isHidden = (hiddenCommunities.map((community) => community.communityId).toList()).contains(communityId);
    // } catch (_) {}
    //
    // return isHidden;
  }

  Map<String, String> hiddenCommunitiesMap = {};

  bool isHiddenCommunityV2({required String? communityId}) {
    if (communityId == null) return false;

    /// if empty, fill it.
    if (hiddenCommunitiesMap.isEmpty) {
      _fillHiddenCommunitiesIntoMap();
    }

    /// return true if communityId is in hiddenCommunitiesMap
    bool isHidden = hiddenCommunitiesMap.containsKey(communityId);
    return isHidden;
  }

  void _fillHiddenCommunitiesIntoMap() {
    hiddenCommunitiesMap.clear();
    for (var element in hiddenCommunities) {
      if (element.communityId != null) {
        hiddenCommunitiesMap[element.communityId!] = element.communityId!;
      }
    }
  }

  /// returns a community model if user is member of community/public.
  Community? getCommunityById({required String communityId}) {
    final List<Community> joinedCommunities = asAdminCommunities + asModeratorCommunities + publicCommunities;
    final Community foundedCommunity = joinedCommunities
        .firstWhere((community) => community.communityId == communityId && community.communityName != null, orElse: () => Community());
    if (foundedCommunity.communityId == null || foundedCommunity.communityName == null) return null;
    return foundedCommunity;
  }

  //private methods.
  Future<void> _getSavedPosts() async {
    savedPostsID = await _commonServices.getSavedPostsIds();
    // MyLoggerServices.to.print("saved posts: $savedPostsID");
  }

  Future<void> _getAdminCommunities() async {
    asAdminCommunities = await _commonServices.getAdminCommunities();
  }

  Future<void> _getModeratorCommunities() async {
    asModeratorCommunities = await _commonServices.getModeratorCommunities();
  }

  Future<void> _getPublicCommunities() async {
    publicCommunities = await _commonServices.getPublicCommunities();
  }

  // get the all communities except secret communities
  Future<void> _getAllCommunitiesExceptSecret() async {
    allCommunitiesExceptSecret = await _commonServices.getAllCommunitiesExceptSecret();
  }

  /// get hidden communities (hide by user purposely)
  Future<void> _getHiddenCommunities() async {
    hiddenCommunities = await _commonServices.getHiddenCommunities();

    /// fill hiddenCommunitiesMap with hidden communities Ids
    _fillHiddenCommunitiesIntoMap();
  }

  Future<void> _getJoinedCommunities() async {
    final data = await _commonServices.getJoinedCommunities();
    joinedCommunities = data["communities"] as List<Community>;
    userCommunityMemberships = data["memberships"] as List<UserCommunities>;
    requestSentCommunitiesIds = data["requestSentCommunities"] as List<String>;

    /// set last visit to joined communities
    _setLastVisitToJoinedCommunities();
  }

  Future<List<Community>> getMyJoinedCommunities() async {
    final data = await _commonServices.getJoinedCommunities();
    joinedCommunities = data["communities"] as List<Community>;
    return joinedCommunities;
  }

  /// sets the last visit to joined communities if it's the first time
  /// if it's not the first time, no need to set last visit
  Future<void> _setLastVisitToJoinedCommunities() async {
    try {
      if (GetStorageController.to.isFirstTime) {
        List<String?> groupIds = joinedCommunities.map((e) => e.communityId).toList();
        await SeenUnseenPostServices.instance.setLastVisits(groupIds);
      }
    } catch (_) {
      MyLoggerServices.to.printError('Error in setting last visit to joined communities: $_');
    }
  }

  // check biometric status of a member in a secret community
  Future<bool> isFingerprintEnabled(String? communityId) async {
    if (communityId == null) return true;
    UserCommunities? userCommunityModel = userCommunityMemberships.firstWhereOrNull((element) => element.communityId == communityId);
    if (userCommunityModel == null || userCommunityModel.allowFingerprint != false) return true;
    return userCommunityModel.allowFingerprint ?? true;
  }

  // toggle fingerprint status for a secret community member
  Future toggleFingerprintStatusOfASecretCommunityMember(String communityId, bool fingerprintStatus) async {
    int index = userCommunityMemberships.indexWhere((element) => element.communityId == communityId);
    if (index == -1 || UserModel.to.uId == null) return;
    userCommunityMemberships[index].allowFingerprint = fingerprintStatus;
    await _commonServices.toggleFingerprintStatusOfASecretCommunityMember(communityId, fingerprintStatus);
    print('user id: ${UserModel.to.uId}, community id: $communityId');
  }

  // Server TimeStamp Functions For Crown Feature
  CrownServices crownServices = CrownServices();
  DateTime? serverDateTime;

/*  Future<void> getCrownServerTimeStamp() async {
    return;
    final timeStamp = await crownServices.getServerTimeStamp();
    if (timeStamp == null) {
    } else {
      DateTime serverTimeInUtc = DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp), isUtc: true);
      DateTime next7oClockTime =
          serverTimeInUtc.add(const Duration(hours: 3)); //DateTime.utc(serverTimeInUtc.year, serverTimeInUtc.month, serverTimeInUtc.day);

      if (serverTimeInUtc.isAfter(next7oClockTime)) {
        next7oClockTime = next7oClockTime.add(const Duration(days: 1));
      }
      serverDateTime = next7oClockTime.toLocal();
    }
  }*/

  // Duration? timeLeft;
  Duration getCrownRemainingTimeDuration() {
    final currentTime = DateTime.now();

    /// get in 3 multiple hour
    final nextHour =
        DateTime(currentTime.year, currentTime.month, currentTime.day, currentTime.hour + 1, currentTime.minute, currentTime.second);

    /// check if next hour is multiple of 3 then set time to 0 else set time to 3 - nextHour.hour % 3
    final hoursToNextExecution = (nextHour.hour % 3 == 0 ? 0 : 3 - nextHour.hour % 3);
    final nextExecutionTime = nextHour.add(Duration(hours: hoursToNextExecution, minutes: -nextHour.minute, seconds: -nextHour.second));
    final timeLeft = nextExecutionTime.difference(DateTime.now());
    debugPrint("time left: $timeLeft");
    if (timeLeft.isNegative) {
      debugPrint("time left is negative #$nextExecutionTime");
      return DateTime.now().difference(nextExecutionTime);
    }
    return timeLeft;

    /*   final serverTime = serverDateTime?.toUtc() ?? DateTime.now();
    final nextHour = DateTime(serverTime.year, serverTime.month, serverTime.day, serverTime.hour + 1 , serverTime.minute , serverTime.second);
    /// check if next hour is multiple of 3 then set time to 0 else set time to 3 - nextHour.hour % 3
    final hoursToNextExecution = (nextHour.hour % 3 == 0  ? 0 : 3 - nextHour.hour % 3);
    final nextExecutionTime = nextHour.add(Duration(hours: hoursToNextExecution, minutes: -nextHour.minute, seconds: -nextHour.second));
    final timeLeft = nextExecutionTime.difference(DateTime.now());
     debugPrint("time left: $timeLeft");
     if(timeLeft.isNegative){
        debugPrint("time left is negative #$nextExecutionTime");
        return DateTime.now().difference(nextExecutionTime);
     }
    /// if time left is negative then set time to 3 hours, else return time left
    return  timeLeft;*/

    if (serverDateTime == null) return const Duration(seconds: 30);
    final nowDateTime = DateTime.now();

    Duration diff = serverDateTime!.difference(nowDateTime);
    if (diff.isNegative) return const Duration(minutes: 0);

    return diff;
  }
}

mixin BlockedImpl {
  List<String> blockedUsersID = [];
  final BlockServices _blockServices = BlockServices();

  Future<void> getBlockedUsers() async => blockedUsersID = await _blockServices.fetchMyBlockedUsersIds();

  bool isUserBlockedAlready({required String userId}) => userId.trim().isEmpty ? false : blockedUsersID.contains(userId);

  void addBlockedUserId({required String userId}) => blockedUsersID.add(userId);

  void removeBlockedUserId({required String userId}) => blockedUsersID.remove(userId);

  void disposeBlocked() {
    blockedUsersID.clear();
  }
}

mixin ReportedImpl {
  //reports
  List<String> reportedPostsID = [];
  List<String> reportedUsersID = [];
  List<String> reportedCommentsID = [];
  List<String> reportedCommentRepliesID = [];

  //getters
  bool isUserReportedAlready({required String userId}) => reportedUsersID.contains(userId);

  bool isPostReportedAlready({required String postId}) => reportedPostsID.contains(postId);

  bool isCommentReportedAlready({required String postId, required String commentId}) => reportedCommentsID.contains(postId + commentId);

  bool isCommentReplyReportedAlready({required String postId, required String commentId, required String commentReplyId}) =>
      reportedCommentRepliesID.contains(postId + commentId + commentReplyId);

  void addReportedUserId({required String userId}) {
    reportedUsersID.add(userId);
  }

  void addReportedPostId({required String postId}) {
    reportedPostsID.add(postId);
  }

  void addReportedCommentId({required String postId, required String commentId}) {
    reportedCommentsID.add(postId + commentId);
  }

  void addReportedCommentReplyId({required String postId, required String commentId, required String commentReplyId}) {
    reportedCommentRepliesID.add(postId + commentId + commentReplyId);
  }

  disposeReport() {
    reportedPostsID.clear();
    reportedUsersID.clear();
    reportedCommentsID.clear();
    reportedCommentRepliesID.clear();
  }
}

/// TODO: maintain user online status from here on app start up at
mixin PresenceImpl {
  // final OnlineStatusServices _onlineStatusServices = OnlineStatusServices();

// Future<void> setOnlineStatus({required bool isOnline}) async => await _onlineStatusServices.setOnlineStatus(isOnline: isOnline);
}

/// TODO: clear all cache data upon logout
mixin AppCacheImpl {
  /* Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if(appDir.existsSync()){
      appDir.deleteSync(recursive: true);
    }
  }*/
}

mixin AppSuperAdmin {
  bool isSuperAdmin = false;
  final SuperAdminServices _superAdminServices = SuperAdminServices.instance;

  Future<void> checkIfSuperAdmin() async {
    try {
      isSuperAdmin = await _superAdminServices.checkIfSuperAdmin();
    } catch (e) {
      isSuperAdmin = false;
    }
  }

  Future<void> banUnban(String userId, {required bool isBan}) async {
    try {
      if (isBan) {
        await _superAdminServices.banUser(userId: userId);
      } else {
        await _superAdminServices.unBanUser(userId: userId);
      }
    } catch (_) {}
  }

  Future<void> removePostFromFeedCompletely(String postId) async {
    await _superAdminServices.removeFromFeed(postId: postId);
  }
}