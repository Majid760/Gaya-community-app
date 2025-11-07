// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_refresh/easy_refresh.dart';
// import 'package:flutter/material.dart';
// import 'package:gaya/controller/group.controller.dart';
// import 'package:gaya/model/communities.memebers.model.dart';
// import 'package:gaya/model/community.model.dart';
// import 'package:gaya/model/user.model.dart';
// import 'package:gaya/services/notification/notification_api/notification_api.dart';
// import 'package:gaya/services/services.dart';
// import 'package:gaya/utils/language/translation.dart';
// import 'package:gaya/utils/logger.dart';
// import 'package:gaya/utils/strings.dart';
// import 'package:gaya/view/community/controllers/base_controller.dart';
// import 'package:gaya/view/community/services/community_members_services.dart';
// import 'package:get/get.dart';
// import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
// import 'package:jiffy/jiffy.dart';
//
// import '../../../controller/firebase_analytics_controller.dart';
//
// class CommunityPendingPostsAndUsersController extends BaseController {
//   Community? community;
//
//   CommunityPendingPostsAndUsersController({this.community});
//
//   static CommunityPendingPostsAndUsersController to({required String? tag}) =>
//       Get.find(tag: tag);
//   late Services services;
//   PendingCommunityPostsAndMembersServices? _communityMembersServices;
//   EasyRefreshController refreshController = EasyRefreshController();
//   Community? createCommunityModel;
//   @override
//   bool isLoading = false;
//   bool isFirstTime = false;
//
//   List<UserModel> _paginatedCommunityMembers = [];
//   List<CommunityMembership> _paginatedCommunityMemberShips = [];
//   final Debouncer _debouncer = Debouncer(delay: 1000.milliseconds);
//   bool get isMembersEmpty => _paginatedCommunityMembers.isEmpty;
//   List<UserModel> getMembers() => _paginatedCommunityMembers;
//   bool get isCommunityMembersEmpty => _paginatedCommunityMemberShips.isEmpty;
//   List<CommunityMembership> getCommunityMembers() =>
//       _paginatedCommunityMemberShips;
//   @override
//   onInit() {
//     super.onInit();
//     services = Services();
//     setCommunityModel(community);
//     // requestMoreData(fromInit: true);
//   }
//
//   @override
//   void onClose() {
//     // resetState();
//     super.onClose();
//   }
//
//   initializeCommunityMembersServices() {
//     _communityMembersServices = PendingCommunityPostsAndMembersServices(
//         communityId: community?.communityId ?? '');
//   }
//
//   setCommunityModel(Community? communityModel) {
//     createCommunityModel = communityModel;
//     update();
//   }
//
//   Future<void> requestMoreData({bool fromInit = false}) async {
//     if (createCommunityModel?.communityId == null) return;
//     // _communityMembersServices = CommunityMembersServices(communityId: createCommunityModel?.communityId ?? '');
//     // to avoid double loading at top andbottom on screen
//     if (fromInit == false) refreshController.callLoad();
//
//     MyLoggerServices.to.print(" requestMoreData called");
//     if (fromInit) {
//       isLoading = true;
//       update();
//     }
//     isFirstTime = true;
//     final pendingUsers = await _communityMembersServices!.requestMoreData();
//     if (pendingUsers.isEmpty) {
//       isLoading = false;
//       update();
//       return;
//     }
//     MyLoggerServices.to.print("newMembers.length ${pendingUsers.length}");
//     List<UserModel> users = pendingUsers[0]['users'] as List<UserModel>;
//     List<CommunityMembership> communityMembers =
//         pendingUsers[1]['communityMembers'] as List<CommunityMembership>;
//     _paginatedCommunityMembers.addAll(users);
//     _paginatedCommunityMemberShips.addAll(communityMembers);
//
//     isLoading = false;
//     update();
//   }
//
//   // A dispose method.
//   void resetController({bool isDisposing = false}) async {
//     _paginatedCommunityMembers = [];
//     _paginatedCommunityMemberShips = [];
//     isFirstTime = false;
//     isLoading = false;
//     if (_communityMembersServices != null) {
//       _communityMembersServices?.reset();
//     }
//     if (isDisposing) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         update();
//       });
//     } else {
//       await requestMoreData(
//         fromInit: true,
//       );
//     }
//     _debouncer.cancel();
//   }
//
//   acceptJoiningRequest(
//       UserModel receiverModel, GroupController groupController) async {
//     try {
//       removeUserLocally(receiverModel);
//       await FirebaseFirestore.instance
//           .collection("communities")
//           .doc(community?.communityId ?? '')
//           .collection("communityMembers")
//           .doc(receiverModel.uId)
//           .update({"isMember": true, "isPending": false});
//       //add into usercollectiion
//       await groupController.acceptedUsersAddedCommunities(
//           community?.communityName ?? "",
//           community?.communityId ?? "",
//           receiverModel.uId ?? "");
//       groupController.getApprovalUsers(community?.communityId ?? "");
//       final communityDetail = await groupController.services
//           .getCommunityDetails(community?.communityId ?? "");
//       if (receiverModel.uId != null && communityDetail?.data() != null) {
//         Community model =
//             Community.fromMap(communityDetail?.data() as Map<String, dynamic>);
//
//         // logging member community joined log
//         AnalyticsController.to.instance.logUserAddedToCommunity(
//           communityId: community?.communityId ?? '',
//           userId: receiverModel.uId ?? '',
//         );
//
//         final fcmcCommunityModel = FcmCreateCommunityModel(
//           communityId: community?.communityId,
//           communityName: community?.communityName,
//           communityDescription: model.communityDescription ?? '',
//           CommunityPic: model.CommunityPic ?? '',
//           coverPicture: model.coverPicture ?? '',
//           adminUid: model.adminUid ?? '',
//           messageContent:
//               'Welcome to ${community?.communityName}. $entryApplicationApproved2',
//           messageTitle: community?.communityName ?? "Gaya Community",
//           receiverFcm: receiverModel.fm_token ?? '',
//         );
//         await NotificationApiHitting()
//             .callOnFcmApiForCommunityNotifications(fcmcCommunityModel);
//         await groupController.services.addNotification(
//             isRead: false,
//             communityId: community?.communityId,
//             message:
//                 'Welcome to ${community?.communityName}. $entryApplicationApproved2',
//             receiverUserID: receiverModel.uId ?? '',
//             senderId: UserModel.to.uId ?? "",
//             senderName: UserModel.to.name ?? "Gaya User",
//             time: DateTime.now().toString(),
//             type: "communityJoiningApproved",
//             userImage: UserModel.to.profilePicture ?? "");
//       }
//     } catch (_) {
//       addUserLocally(receiverModel);
//     }
//   }
//
//   removeUserLocally(UserModel userModel) {
//     _paginatedCommunityMembers
//         .removeWhere((element) => element.uId == userModel.uId);
//     _paginatedCommunityMemberShips
//         .removeWhere((element) => element.userUid == userModel.uId);
//     update();
//   }
//
//   addUserLocally(UserModel userModel) {
//     int index = _paginatedCommunityMembers
//         .indexWhere((element) => element.uId == userModel.uId);
//     int index2 = _paginatedCommunityMemberShips
//         .indexWhere((element) => element.userUid == userModel.uId);
//     if (index == -1) {
//       _paginatedCommunityMembers.insert(0, userModel);
//     }
//     if (index2 == -1) {
//       _paginatedCommunityMemberShips.insert(
//           0, CommunityMembership(userUid: userModel.uId));
//     }
//     update();
//   }
//
//   rejectJoiningRequest(
//       UserModel receiverModel, GroupController groupController) async {
//     try {
//       removeUserLocally(receiverModel);
//
//       await FirebaseFirestore.instance
//           .collection("communities")
//           .doc(community?.communityId)
//           .collection("communityMembers")
//           .doc(receiverModel.uId)
//           .delete();
//       groupController.getApprovalUsers(community?.communityId ?? "");
//       if (receiverModel.uId != null) {
//         await NotificationApiHitting().callOnFcmApiSendPushNotifications(
//             gaya_message:
//                 'Your entry request to ${community?.communityName} $entryApplicationRejected2',
//             fcmToken: receiverModel.fm_token ?? '');
//         await groupController.services.addNotification(
//             isRead: false,
//             // posId: postId,
//             message:
//                 'Your entry request to ${community?.communityName} $entryApplicationRejected2',
//             receiverUserID: receiverModel.uId ?? '',
//             senderId: groupController.myAppUser.uId ?? "",
//             senderName: groupController.myAppUser.name ?? "Gaya User",
//             time: DateTime.now().toString(),
//             type: "communityJoiningRejected",
//             userImage: groupController.myAppUser.profilePicture ?? "");
//       }
//     } catch (_) {
//       print('error is: ${_.toString()}');
//       addUserLocally(receiverModel);
//     }
//   }
//
//   // get jiffy time of joining request
//   String getUserJoiningRequestJiffyTime(UserModel userModel) {
//     if (_paginatedCommunityMemberShips.isEmpty) return GayaStrings.just_now.tr;
//     final member = _paginatedCommunityMemberShips
//         .firstWhereOrNull((element) => element.userUid == userModel.uId);
//     if (member == null) return '';
//     return Jiffy(member.createdOn).fromNow();
//   }
// }
