import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/app.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/communities.memebers.model.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/community.report.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../components/report_dialogue.dart';
import '../model/save.post.model.dart';
import '../model/user.communities.dart';
import '../services/notification/notification_api/notification_api.dart';
import '../utils/collections.dart';
import '../view/feed/controller/for_you_controller.dart';
import '../view/search/controllers/search_controller.dart';
import 'firebase_analytics_controller.dart';

class GroupController extends ChangeNotifier with CommunitySubscriptionTopics {
  ScrollController commentsScroll = ScrollController();

  bool isJoined = false;
  bool isLeave = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Services services = Services();

  UserModel get myAppUser => UserModel.to;

  groupDetailsSwitch index = groupDetailsSwitch.Discussion;

  get getView => index;
  final _commonServices = Services();

  bool isSubscribedToNotification = false;

  groupDetailsSwitch setView(groupDetailsSwitch Setindex) {
    index = Setindex;
    notifyListeners();
    return index;
  }

  //Get all the members in the community

  Stream<QuerySnapshot?> getMembers(String communityId) async* {
    yield* services.getAllMembers(communityId);
  }

  Stream<bool> isNotificationEnabled(String communityId) {
    try {
      return FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .doc(UserModel.to.uId)
          .snapshots()
          .map((event) => event["isNotificationEnabled"] == true);
    } catch (_) {
      print('error in stream: $_');
    }
    return Stream.value(false);
  }

  Future toggleNotificationSubscription(String communityId, bool isNotificationEnabled) async {
    await services.changeNotificationSubscription(communityId, isNotificationEnabled);
  }

  //check the user in the community or not
  Future<QuerySnapshot?> isUserInCommunity(String communityId) async {
    return services.checkUserMemberOfCommunity(communityId);
  }

  QuerySnapshot<Object?>? data;

//check whthere the current user in the group or not
  Future<QuerySnapshot?> checkJoinOrNot(String? docId) async {
    if (docId == null) return null;
    User? user = _firebaseAuth.currentUser;

    data = await FirebaseFirestore.instance
        .collection('communities')
        .doc(docId)
        .collection('communityMembers')
        .where('userUid', isEqualTo: user!.uid)
        .where("isMember", isEqualTo: true)
        .get();
    return data;
  }

  String? communityType;

  Future<Community?> checkWhetherTheCommunityisPrivateorPublic(String docId) async {
    return await FirebaseFirestore.instance.collection('communities').doc(docId).get().then((value) {
      Community communityModel = Community.fromMap(value.data() as Map<String, dynamic>);
      communityType = communityModel.communityType;

      // log("Community Type is  $communityType");

      return communityModel;
    });
  }

  QuerySnapshot<Object?>? data1;

//check whthere the current user in the group or not
  Future<QuerySnapshot?> checkPending(String docId) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return null;
      data = await FirebaseFirestore.instance
          .collection('communities')
          .doc(docId)
          .collection('communityMembers')
          .where('userUid', isEqualTo: user.uid)
          .where("isMember", isEqualTo: false)
          .get();

      return data;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<CommunityMembership?> getUserMembershipByCommunityId({required String communityId}) async {
    return await services.getUserMembershipByCommunityId(communityId: communityId);
  }

  //join the private group
  Future<DocumentSnapshot?> joinTheGroup(String communityDocId) async {
    User? user = _firebaseAuth.currentUser;
    CommunityMembership addMember = CommunityMembership(
      isAdmin: false,
      isMember: false,
      userUid: user!.uid,
      createdOn: DateTime.now(),
    );

    // adding community request sent to locally managing request sent communities
    AppConfigurationController.to.requestSentCommunitiesIds.add(communityDocId);

    // updating search controller local state for community searches
    if (Get.isRegistered<GayaSearchController>()) {
      GayaSearchController.to.update([communityDocId]);
    }

    // updating suggested communities (for you controller) local state
    if (Get.isRegistered<ForYouFeedController>()) {
      ForYouFeedController.to.updateSuggestedCommunityLocally(communityId: communityDocId);
    }

    return services.joinTheGroup(communityDocId, addMember.toMap());
  }

  // this is for the community request
  Future<void> requestToCommunity({required String communityId}) async {
    return await services.requestToCommunity(id: communityId);
  }

  Future sendCommunityJoiningApprovalNotificationToAdmin(Community communitymodel) async {
    UserModel userData = UserModel.to;

    UserModel? adminData = await _commonServices.getUserById(communitymodel.adminUid, forcefullyServer: true);

    if (adminData != null && communitymodel.communityId != null) {
      final fcmcCommunityModel = FcmCreateCommunityModel(
        communityId: communitymodel.communityId,
        communityName: communitymodel.communityName,
        communityDescription: communitymodel.communityDescription ?? '',
        CommunityPic: communitymodel.CommunityPic ?? '',
        coverPicture: communitymodel.coverPicture ?? '',
        adminUid: communitymodel.adminUid ?? '',
        messageContent: GayaStrings.new_community_applications.tr,
        messageTitle: GayaStrings.community_joining_request.tr,
        receiverFcm: adminData.fm_token ?? '',
      );

      await NotificationApiHitting().callOnFcmApiForCommunityNotifications(fcmcCommunityModel
          // gaya_message: "${usermodel.name} sent you a new message.", fcmToken: otherChatParticipantFcmToken
          );

      await _commonServices.addNotification(
          isRead: false,
          communityId: communitymodel.communityId,
          body: GayaStrings.new_community_applications.tr,
          title: GayaStrings.community_joining_request.tr,
          receiverUserID: adminData.uId ?? '',
          senderId: userData.uId ?? "",
          time: DateTime.now().toString(),
          type: "communityJoiningrequest",
          userImage: communitymodel.CommunityPic ?? userData.profilePicture ?? "");
    }
  }

  //join the public group
  Future<DocumentSnapshot?> joinThePublicGroup(String communityDocId) async {
    User? user = _firebaseAuth.currentUser;
    CommunityMembership addMember = CommunityMembership(
      isAdmin: false,
      isMember: true,
      userUid: user!.uid,
      createdOn: DateTime.now(),
    );

    // updating search controller local state for community searches
    if (Get.isRegistered<GayaSearchController>()) {
      GayaSearchController.to.update([communityDocId]);
    }

    // updating suggested communities (for you controller) local state
    if (Get.isRegistered<ForYouFeedController>()) {
      ForYouFeedController.to.updateSuggestedCommunityLocally(communityId: communityDocId);
    }

    return services.joinTheGroup(communityDocId, addMember.toMap());
  }

  Future<DocumentSnapshot?> addCommunityToUserList(
    String communityName,
    String communityId,
  ) async {
    UserCommunitiesModel userCommunities = UserCommunitiesModel(
      communityName: communityName,
      communityId: communityId,
    );

    return services.addCommunityToUser(userCommunities);
  }

  //accepted users
  Future<DocumentSnapshot?> acceptedUsersAddedCommunities(String communityName, String communityId, String userUid) async {
    UserCommunitiesModel userCommunities = UserCommunitiesModel(
      communityName: communityName,
      communityId: communityId,
    );

    return services.addCommunityToTheAcceptedUsers(userCommunities.toMap(), userUid);
  }

  //leave the community
  Future leaveTheCommunity(String communityId) async {
    return services.leaveTheCommunity(communityId);
  }

  //Delete the user from the community

  Future deleteTheUserFromCommunity(String communityId) async {
    // updating search controller local state for community searches
    if (Get.isRegistered<GayaSearchController>()) {
      GayaSearchController.to.update([communityId]);
    }

    // updating suggested communities (for you controller) local state
    if (Get.isRegistered<ForYouFeedController>()) {
      ForYouFeedController.to.updateSuggestedCommunityLocally(communityId: communityId);
    }

    return services.deleteUserFromCommunity(communityId);
  }

  //remove the user community from the user collection
  Future removeTheUserFromComm(String communityId, String userUid) async {
    return services.removeTheUserFromTheUserCollection(communityId, userUid);
  }

  //remove the user from the community
  Future removeTheuser(String communityId, String userUid) async {
    return services.removeTheUserFromCommunity(communityId, userUid);
  }

  //after joining the group
  bool afterJoiningTheGroup() {
    isJoined = true;
    notifyListeners();
    return isJoined;
  }

  //after leaving the group
  bool afterLeavingTheGroup() {
    isLeave = true;
    notifyListeners();
    return isLeave;
  }

  //get the specific group post
  Stream<QuerySnapshot?> getThePostsOfACommunity(String communityId) async* {
    yield* FirebaseFirestore.instance
        .collection('communityposts')
        .where('communityId', isEqualTo: communityId)
        .where('approve', isEqualTo: true)
        .where("isDeleted", isEqualTo: false)
        .orderBy('createdOn', descending: true)
        .snapshots();
  }

  // Future<LikePostModel?> testingFuture(String communityId) async {
  //   FutureProvider<QuerySnapshot?>(
  //     initialData: null,
  //     create: (context) => getThePostsOfACommunity(communityId),
  //   );
  //   return null;
  // }

  //in particular post with comments
  Future<DocumentSnapshot?> savePost(String docId) async {
    User? user = _firebaseAuth.currentUser;
    SavePostModel saveModel = SavePostModel(userUid: user!.uid, saveDocID: uuid.v1());
    await services.savePost(docId, saveModel.toMap(), saveModel.saveDocID!);
    return null;
  }

  //in particular post with comments
  Future<QuerySnapshot?> unSavePost(String postId) async {
    User? usr = _firebaseAuth.currentUser;
    QuerySnapshot unsavePost = await FirebaseFirestore.instance
        .collection('communityposts')
        .doc(postId)
        .collection('savepost')
        .where('userUid', isEqualTo: usr!.uid)
        .get()
        .then((value) {
      value.docs.first.reference.delete();
      return value;
    });
    debugPrint('unsaving the post');

    return unsavePost;
  }

//get the users which are waiting for the approval

  List pendingUsersArrayIds = [];
  List allDocsIdArray = [];
  int totalApprovalsWaiting = 0;

  Future<QuerySnapshot?> getApprovalUsers(String communityId) async {
    return await FirebaseFirestore.instance
        .collection("communities")
        .doc(communityId)
        .collection("communityMembers")
        .where("isMember", isEqualTo: false)
        .get()
        .then((value) {
      // log(value.docs.length.toString());
      totalApprovalsWaiting = value.docs.length;
      log("totalApprovalsWaiting length is: $totalApprovalsWaiting");
      notifyListeners();
      pendingUsersArrayIds.clear();
      for (var i in value.docs) {
        CommunityMembership communitiesMemebers = CommunityMembership.fromMap(i.data());
        // log(communitiesMemebers.userUid.toString());
        pendingUsersArrayIds.add(communitiesMemebers.userUid);

        notifyListeners();
      }

      allDocsIdArray.clear();
      for (var i = 0; i < value.docs.length; i++) {
        allDocsIdArray.add(value.docs[i].id);
      }
      // log("This is our document ids ${allDocsIdArray.toString()}");
      return value;
    });
  }

  // //check the admin is there or other community users
  // String? adminId;
  //
  // Future<QuerySnapshot?> getCommunityAdmin(String communityId) async {
  //   return await FirebaseFirestore.instance
  //       .collection("communities")
  //       .doc(communityId)
  //       .collection("communityMembers")
  //       .where("isAdmin", isEqualTo: true)
  //       .get()
  //       .then((value) {
  //     for (var i in value.docs) {
  //       CommunityMembership communitiesMemebers = CommunityMembership.fromMap(i.data());
  //
  //       // log("This is the admin id : ${communitiesMemebers.userUid.toString()}");
  //       adminId = communitiesMemebers.userUid!;
  //       notifyListeners();
  //     }
  //
  //     return value;
  //   });
  // }

  //get the approve posts
  Stream<QuerySnapshot?> getApprovePosts(String communityId) async* {
    yield* FirebaseFirestore.instance
        .collection("communityposts")
        .where("approve", isEqualTo: false)
        .where('communityId', isEqualTo: communityId)
        .snapshots();
  }

  Stream<QuerySnapshot?> getPendingMembers(String communityId) async* {
    // get group member and then check if the user is not found then remove it from group members sub collection
    var snapshot = await FirebaseFirestore.instance
        .collection("communities")
        .doc(communityId)
        .collection('communityMembers')
        .where('isMember', isEqualTo: false)
        .get();
    if (snapshot.docs.isNotEmpty) {
      for (var groupMember in snapshot.docs) {
        if (groupMember.data()['userUid'] != null) {
          var userSnapshot = await FirebaseFirestore.instance.collection("users").doc(groupMember.data()['userUid']).get();
          if (!userSnapshot.exists) {
            groupMember.reference.delete();
          }
        }
      }
    }
    // return stream of pending users
    yield* FirebaseFirestore.instance
        .collection("communities")
        .doc(communityId)
        .collection('communityMembers')
        .where('isMember', isEqualTo: false)
        .snapshots();
  }

  //get the approve user details
  Future<DocumentSnapshot?> getuserDetailsApprovePosts(String userUid) async {
    return FirebaseFirestore.instance.collection("users").doc(userUid).get();
  }

  //check whether the current user report the post already

  int size = 0;

  Future<QuerySnapshot?> checkThepostAlreadyReported(String postId) async {
    return await FirebaseFirestore.instance
        .collection(postReport)
        .where(
          "reporterUid",
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .where("postId", isEqualTo: postId)
        .get()
        .then((snapshot) {
      size = snapshot.docs.length;
      return snapshot;
    });
  }

  //delete the post by maiking the isdeleted to true
  Future deleteYourPost(
    String postId,
    BuildContext context,
    String? communityId,
  ) async {
    try {
      await FirebaseFirestore.instance.collection(communityPosts).doc(postId).update({"isDeleted": true}).then((value) {
        // Logging delete post event
        AnalyticsController.to.instance.logDeletePost(
          communityId: communityId ?? '',
          postId: postId,
          userId: UserModel.to.uId ?? '',
        );

        return value;
      });

      // snackBar(context, "post will be deleted soon", kprimaryColor);
    } catch (e) {
      snackBar(context, GayaStrings.could_not_complete_operation.tr, kRedColor);
    } finally {}
  }

  //report a community
  Future reportCommunity(
    String communityId,
    BuildContext context,
    String reportMsg,
  ) async {
    try {
      final docId = uuid.v1();
      CommunityReport communityReports = CommunityReport(
        communityId: communityId,
        reportId: docId,
        reportMsg: reportMsg,
        reporterUid: FirebaseAuth.instance.currentUser!.uid,
      );
      await FirebaseFirestore.instance.collection(communityReport).doc(docId).set(
            communityReports.toMap(),
            SetOptions(merge: true),
          );

      // Logging community report analytics event
      AnalyticsController.to.instance.logReportCommunity(
        userId: UserModel.to.uId ?? '',
        reportMessage: reportMsg,
        communityId: communityId,
      );

      if (context.mounted) {
        await showDialog(
            context: context,
            builder: (_) {
              return const ReportDialogue();
            });
      }
    } catch (ex) {
      snackBar(context, GayaStrings.unable_report_community.tr, kRedColor);
    } finally {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return const ReportDialogue();
            });
      }
    }
  }

  //check whether the current user report the post already

  int reportSize = 0;

  Future<bool> didCommunityAlreadyReported(String communityId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(communityReport)
          .where("reporterUid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("communityId", isEqualTo: communityId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('error caught during during community reporting checking!');
      return false;
    }
  }

  // GET THE COMMUNITY ADMIN
  String? groupAdminId;

  Future<QuerySnapshot?> adminofCommunity(String docId) async {
    return await FirebaseFirestore.instance
        .collection(communities)
        .doc(docId)
        .collection(communityMembersCollection)
        .where('isAdmin', isEqualTo: true)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        return null;
      }
      CommunityMembership communitiesMemebers = CommunityMembership.fromMap(value.docs[0].data());
      groupAdminId = communitiesMemebers.userUid;

      return value;
    });
  }

  static leaveCommunityById({required String communityId}) async {}
}
