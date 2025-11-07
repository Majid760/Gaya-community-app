import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/notification/notification_api/notification_api.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../model/communities.memebers.model.dart';
import '../../../../model/community.model.dart';
import '../../../../model/user.communities.dart';
import '../../../../services/services.dart';
import '../../../../utils/language/translation.dart';

class MembershipApprovalServices with PaginationImpl, ApprovalImpl {
  final String communityId;

  MembershipApprovalServices({required this.communityId});

  /// Get posts from the database
  Future<List<UserMembershipModel>> requestMoreData() async => await _requestUsers(communityId);

  /// resets pagination
  void reset() => _reset();
}

/// Database Crud operations for approval
mixin class ApprovalImpl {
  final _commonServices = Services.to;
  final _notificationApiHitting = NotificationApiHitting();

  /// Approve user - returns true if successfully approved.
  ///* userId = Receiver (Post Author)
  Future<bool> approveUser({
    required UserModel user,
    required String communityId,
    required String communityName,
  }) async {
    try {
      /// Check if post id is null
      if (user.uId.isBlank == true) {
        throw Exception("userId is null");
      }

      /// Update membership
      await FirebaseFirestore.instance
          .collection("communities")
          .doc(communityId)
          .collection("communityMembers")
          .doc(user.uId!)
          .update({"isMember": true, "isPending": false});

      //add into usercollectiion
      UserCommunitiesModel userCommunities = UserCommunitiesModel(communityName: communityName, communityId: communityId);

      _commonServices.addCommunityToTheAcceptedUsers(userCommunities.toMap(), user.uId!);

      final community = await _commonServices.getCommunityDetailsModel(communityId);
      if (community?.communityId != null) {
        // logging member community joined log
        AnalyticsController.to.instance.logUserAddedToCommunity(
          communityId: community?.communityId ?? '',
          userId: user.uId!,
        );

        final fcmJoinedCommunity = FcmCreateCommunityModel(
          communityId: community?.communityId,
          communityName: community?.communityName,
          communityDescription: community!.communityDescription ?? '',
          CommunityPic: community.CommunityPic ?? '',
          coverPicture: community.coverPicture ?? '',
          adminUid: community.adminUid ?? '',
          messageContent:
              '${GayaStrings.welcome_to_space.tr}${community.communityName}${GayaStrings.the_community_manager_approved_entry_request.tr}',
          messageTitle: GayaStrings.requested_approved.tr,
          receiverFcm: user.fm_token ?? '',
        );

        await Future.wait([
          _notificationApiHitting.callOnFcmApiForCommunityNotifications(fcmJoinedCommunity),
          _commonServices.addNotification(
              isRead: false,
              communityId: community.communityId,
              body:
                  '${GayaStrings.welcome_to_space.tr}${community.communityName}${GayaStrings.the_community_manager_approved_entry_request.tr}',
              receiverUserID: user.uId ?? '',
              senderId: UserModel.to.uId ?? "",
              title: GayaStrings.requested_approved.tr,
              time: DateTime.now().toString(),
              type: "communityJoiningApproved",
              userImage: community.CommunityPic ?? UserModel.to.profilePicture ?? "")
        ]);
      }

      return true;
    } catch (_) {
      CrashlyticsController.to.instance.recordError(_, reason: 'ApprovalImplementation.approvePost()');
    }
    return false;
  }

  /// Reject user - returns true if successfully rejected.
  /// * userId = Receiver ( Author)
  Future<bool> rejectUser({required UserModel user, required String communityId, required String communityName}) async {
    try {
      /// Check if post id is null
      if (user.uId.isBlank == true) {
        throw Exception("PostId is null");
      }

      if (user.uId != null) {
        final community = await _getCommunityById(communityId: communityId);

        /// Send Notification
        await Future.wait(
          [
            FirebaseFirestore.instance.collection("communities").doc(communityId).collection("communityMembers").doc(user.uId!).delete(),
            _notificationApiHitting.callOnFcmApiSendPushNotifications(
                gaya_message: '${GayaStrings.entry_request_initial.tr} $communityName ${GayaStrings.entry_request_end.tr}',
                fcmToken: user.fm_token ?? ''),
            _commonServices.addNotification(
                isRead: false,
                // posId: postId,
                body: '${GayaStrings.entry_request_initial.tr} $communityName ${GayaStrings.entry_request_end.tr}',
                receiverUserID: user.uId ?? '',
                senderId: UserModel.to.uId ?? "",
                title: UserModel.to.name ?? "Gaya User",
                time: DateTime.now().toString(),
                type: "communityJoiningRejected",
                userImage: community?.CommunityPic ?? UserModel.to.profilePicture ?? ""),
          ],
        );
      }
      return true;
    } catch (_) {
      CrashlyticsController.to.instance.recordError(_, reason: 'ApprovalImplementation.rejectPost()');
    }
    return false;
  }

  Future<Community?> _getCommunityById({required String communityId}) async {
    return await Get.find<Services>().getCommunityObject(communityId: communityId);
  }
}

/// Pagination operations
mixin class PaginationImpl {
  int membersLimitSize = 15;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreMembers = true;

  void _reset() {
    _lastDocument = null;
    _hasMoreMembers = true;
  }

  Future<List<UserMembershipModel>> _requestUsers(String communityId) async {
    List<UserMembershipModel> newUsers = [];
    try {
      var userMembershipSnap = FirebaseFirestore.instance
          .collection("communities")
          .doc(communityId)
          .collection('communityMembers')
          .where('isMember', isEqualTo: false)
          .orderBy('createdOn', descending: true)
          .limit(membersLimitSize);

      // #5: If we have a document start the query after it
      if (_lastDocument != null) {
        userMembershipSnap = userMembershipSnap.startAfterDocument(_lastDocument!);
      }

      if (_hasMoreMembers == false) {
        return [];
      }

      List<UserMembershipModel> users = [];
      final membershipSnap = await userMembershipSnap.get();
      MyLoggerServices.to.print("_requestUsers data length: ${membershipSnap.docs.length}");
      if (membershipSnap.docs.isNotEmpty) {
        _lastDocument = membershipSnap.docs.last;
      } else {
        _hasMoreMembers = false;
        return _requestUsers(communityId);
      }

      List<UserMembershipModel> localPosts = await parse(membershipSnap);
      for (var element in localPosts) {
        users.add(element);
      }

      newUsers = users;
      // newUsers.sort((a, b) => (b.communityMembership.createdOn)!.compareTo(a.communityMembership.createdOn!));
      MyLoggerServices.to.print("_requestUsers length servies d: ${newUsers.length}");

      // #14: Determine if there's more posts to request
      _hasMoreMembers = users.length == membersLimitSize;
    } catch (_) {
      CrashlyticsController.to.instance.recordError(_, reason: '_requestUsers._requestPosts()');
    }
    return newUsers;
  }

  Future<List<UserMembershipModel>> parse(QuerySnapshot<Map<String, dynamic>> users) async {
    List<UserMembershipModel> allUsers = [];
    debugPrint("all users: ${users.size}");
    final members = users.docs;
    if (members.isNotEmpty) {
      List<UserModel?> users = await _getUserInBulk(userIds: members.map((e) => e.id).toList());

      // make map of users for faster access
      Map<String?, UserModel?> usersMap = {};
      Map<String?, CommunityMembership?> memberJoinedMap = {};
      for (var user in users) {
        usersMap[user?.uId] = user;
      }
      for (var member in members) {
        memberJoinedMap[member.id] = CommunityMembership.fromMap(member.data());
      }

      /// (O(m + n)) :: n = posts.length, m = users.length
      /// update user in post
      for (var user in usersMap.values) {
        final UserModel? fetchedUser = usersMap[user?.uId];
        final CommunityMembership? communityMembership = memberJoinedMap[user?.uId];
        if (fetchedUser != null && fetchedUser.uId != null && communityMembership != null && fetchedUser.name.isBlank == false) {
          allUsers.add(UserMembershipModel(user: fetchedUser, communityMembership: communityMembership));
        }
      }
    }

    // allUsers.sort((a, b) => b.user.createdOn?.compareTo(a.user.createdOn ?? DateTime(2017)) ?? 0);

    return allUsers;
  }

  final _commonServices = Services.to;

  Future<List<UserModel?>> _getUserInBulk({required List<String?> userIds}) async {
    List<UserModel?> users = [];
    if (userIds.length == 1) {
      final user = await _commonServices.getUserById(userIds.first);
      return [user];
    }

    users = await _commonServices.getUserByIdsWithCompoundv2(userIds);
    return users;
  }
}

class UserMembershipModel {
  final UserModel user;
  final CommunityMembership communityMembership;

  UserMembershipModel({required this.user, required this.communityMembership});
}
