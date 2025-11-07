import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/shared/service/engagement_score_services/engagement_helpers/engagement_consts.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../services/block_services.dart';
import 'app_config_controller.dart';
import 'firebase_analytics_controller.dart';

enum BlockedStatus { blocked, unblocked, idle }

class BlockController extends GetxService {
  static BlockController get to => Get.find();
  final AppConfigurationController _appConfig = AppConfigurationController.to;
  final BlockServices _blockServices = BlockServices();

  bool isUserBlocked(String uid) {
    return _appConfig.isUserBlockedAlready(userId: uid);
  }

  ///Either it will block a user, or unblocked depending upon AppConfig List.
  Future<BlockedStatus> block({required String userId, required BuildContext context}) async {
    try {
      if (isUserBlocked(userId)) {
        await _unblockAUser(userId: userId);
        // Logging block user event to analytics
        AnalyticsController.to.instance.logUserBlock(
          blockedUserId: userId,
          userId: FirebaseAuth.instance.currentUser?.uid,
        );
        _showDialogForBlockUser(BlockedStatus.unblocked, ctx: context);
        return BlockedStatus.unblocked;
      } else {
        await _blockAUser(userId: userId);
        _showDialogForBlockUser(BlockedStatus.blocked, ctx: context);
        return BlockedStatus.blocked;
      }
    } catch (_) {}
    return BlockedStatus.idle;
  }

  ///show dialog according to blocked status.
  _showDialogForBlockUser(BlockedStatus status, {required BuildContext ctx}) {
    if (ctx.mounted == false) return;
    switch (status) {
      case BlockedStatus.blocked:
        GayaSnackBar.show(context: ctx, type: GayaSnackBarType.other, text: GayaStrings.blocked_successfully.tr);

        /*     Get.showSnackbar(const GetSnackBar(
            title: 'Blocked',
            message: 'User has been blocked successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            margin: EdgeInsets.all(10),
            borderRadius: 10,
            duration: Duration(seconds: 3)));*/
        break;
      case BlockedStatus.unblocked:
        GayaSnackBar.show(context: ctx, type: GayaSnackBarType.other, text: GayaStrings.unblock_successfully.tr);
        // Get.showSnackbar(const GetSnackBar(
        //     title: 'Unblocked',
        //     message: 'User has been unblocked successfully',
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: Colors.green,
        //     margin: EdgeInsets.all(10),
        //     borderRadius: 10,
        //     duration: Duration(seconds: 3)));
        break;
      default:
    }
  }

  Future<void> _blockAUser({required String userId}) async {
    await _blockServices.blockAUser(userId: userId);
    _appConfig.addBlockedUserId(userId: userId);
    _updateBlockScoresInUserProfile(userId, -5);
  }

  Future<void> _unblockAUser({required String userId}) async {
    await _blockServices.unblockAUser(userId: userId);
    _appConfig.removeBlockedUserId(userId: userId);
    _updateBlockScoresInUserProfile(userId, 5);
  }

  void _updateBlockScoresInUserProfile(String userId, int score) {
    try {
      EngagementConsts.userRef(userId).set({"influenceScore": FieldValue.increment(score)}, SetOptions(merge: true));
    } catch (_) {}
  }
}
