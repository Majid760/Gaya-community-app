// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// enum UserStatus { first, multiple }
//
// class BlockController extends GetxService {
//   static BlockController get to => Get.find();
//   final AppConfigurationController _appConfig = AppConfigurationController.to;
//   final BlockServices _blockServices = BlockServices();
//
//   bool isUserBlocked(String uid) {
//     return _appConfig.isUserBlockedAlready(userId: uid);
//   }
//
//   ///Either it will block a user, or unblocked depending upon AppConfig List.
//   Future<BlockedStatus> block({required String userId}) async {
//     try {
//       if (isUserBlocked(userId)) {
//         await _unblockAUser(userId: userId);
//         _showDialogForBlockUser(BlockedStatus.unblocked);
//         return BlockedStatus.unblocked;
//       } else {
//         await _blockAUser(userId: userId);
//         _showDialogForBlockUser(BlockedStatus.blocked);
//         return BlockedStatus.blocked;
//       }
//     } catch (_) {}
//     return BlockedStatus.idle;
//   }
//
//   ///show dialog according to blocked status.
//   _showDialogForBlockUser(BlockedStatus status) {
//     switch (status) {
//       case BlockedStatus.blocked:
//         Get.showSnackbar(const GetSnackBar(
//             title: 'Blocked',
//             message: 'User has been blocked successfully',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             margin: EdgeInsets.all(10),
//             borderRadius: 10,
//             duration: Duration(seconds: 3)));
//         break;
//       case BlockedStatus.unblocked:
//         Get.showSnackbar(const GetSnackBar(
//             title: 'Unblocked',
//             message: 'User has been unblocked successfully',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             margin: EdgeInsets.all(10),
//             borderRadius: 10,
//             duration: Duration(seconds: 3)));
//         break;
//       default:
//         debugPrint("Couldn't block or unblock this user");
//     }
//   }
//
//   Future<void> _blockAUser({required String userId}) async {
//     debugPrint("Blocked A User");
//     await _blockServices.blockAUser(userId: userId);
//     _appConfig.addBlockedUserId(userId: userId);
//   }
//
//   Future<void> _unblockAUser({required String userId}) async {
//     debugPrint("Unblocking A User");
//
//     await _blockServices.unblockAUser(userId: userId);
//     _appConfig.removeBlockedUserId(userId: userId);
//   }
// }
