// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/notification/notification_api/notification_api.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/engagement_score_services/engagement_helpers/engagement_consts.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

import '../components/report_dialogue.dart';
import '../components/snackbar.component.dart';
import '../model/user_report.model.dart';
import '../utils/collections.dart';
import '../utils/const.dart';

/// Public contract for reporting content inside app
abstract class ReportServicesImpl {
  /// Contract api for reporting a user
  Future<void> reportAUser(
    String reportedPersonUid, {
    bool isMessageReport = false,
    String reportMsg,
  });

  /// Contract api for reporting a problem (feedback) from user about a problem
  Future<void> reportAProblem(
    String userId, {
    bool isMessageReport = false,
    String reportMsg,
  });

  /// Contract api for reporting post
  Future<void> reportPost(
    String reportedPostId,
    String? adminUi, {
    required String reportMsg,
    required String communityId,
  });

  /// Contract api for reporting a comment
  Future<void> reportAComment({
    required String reportedCommentId,
    required BuildContext context,
    required String postId,
    required String content,
    required String reportMsg,
  });

  /// Contract api for reporting a comment reply
  Future<void> reportACommentReply({
    required String content,
    required String commentId,
    required String postId,
    required String commentReplyId,
    required String reportMsg,
    required BuildContext context,
  });

  Future<void> reportANotification({
    required String content,
    required String notificationId,
    required String reportMsg,
    required BuildContext context,
  });
}

/// Reporting contract implementation service for reporting content in app
class ReportServices implements ReportServicesImpl {
  final _commonServices = Services();
  final _notificationApiHitting = NotificationApiHitting();
  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  User? get _user => _firebaseAuth.currentUser;

  /// Report A User
  @override
  Future<void> reportAUser(String reportedPersonUid, {bool isMessageReport = false, String reportMsg = ''}) async {
    if (_user == null) return;
    try {
      UserReport reportModel = UserReport(
        reportedByUid: _user!.uid,
        reportMessage: reportMsg,
        reportedUserUid: reportedPersonUid,
        isMessageReport: isMessageReport,
      );
      await _firestore.collection(userReport).doc(reportedPersonUid).set(
            reportModel.toMap(),
            SetOptions(merge: true),
          );

      // EngagementScoreController.to.instance.onReportUser(toUserId: reportedPersonUid);
      updateReportScoresInUserProfile(reportedPersonUid);
    } catch (e) {
      rethrow;
    }
  }

  /// Report A Problem (Feedback from own profile)
  @override
  Future<void> reportAProblem(
    String userId, {
    bool isMessageReport = false,
    String reportMsg = '',
  }) async {
    if (_user == null) return;
    try {
      UserReport reportModel = UserReport(
        reportedByUid: _user!.uid,
        reportMessage: reportMsg,
        reportedUserUid: userId,
        isMessageReport: isMessageReport,
      );
      await _firestore.collection(problemReport).doc().set(
            reportModel.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }

  // update influence points in a user profile when report
  void updateReportScoresInUserProfile(String userId) {
    try {
      EngagementConsts.userRef(userId).set({"influenceScore": FieldValue.increment(-2)}, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Report A Post
  @override
  Future<void> reportPost(
    String reportedPostId,
    String? adminUi, {
    required String reportMsg,
    required String communityId,
  }) async {
    MyLoggerServices.to.print("reportPost");
    if (_user == null) return;
    try {
      PostReport reportModel = PostReport(
        reportedByUid: _user!.uid,
        reportedPostId: reportedPostId,
        reportedMsg: reportMsg,
      );
      await _firestore.collection(postReport).doc().set(reportModel.toMap());
      if (adminUi != null) {
        UserModel? adminData = await _commonServices.getUserById(adminUi, forcefullyServer: true);
        final fcmPostModel = FcmCreatePostModel(
            communityId: communityId,
            postid: reportedPostId,
            messageContent: GayaStrings.post_reported_consider_delete.tr,
            messageTitle: GayaStrings.post_reported.tr,
            receiverFcm: adminData?.fm_token ?? '');
        _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel
            // gaya_message: "${usermodel.name} sent you a new message.", fcmToken: otherChatParticipantFcmToken
            );
        //add into user's table.
        await _commonServices.addNotification(
          isRead: false,
          posId: reportedPostId,
          body: GayaStrings.post_reported_consider_delete.tr,
          receiverUserID: adminData?.uId ?? '',
          senderId: UserModel.to.uId ?? '',
          title: UserModel.to.name ?? "Gaya User",
          time: DateTime.now().toString(),
          type: "postReported",
          userImage: UserModel.to.profilePicture ?? "",
        );
        MyLoggerServices.to
            .print('reported post id=> ${reportedPostId}  report message  =>> ${reportMsg} and communityId by => ${communityId}');
      }
    } catch (e) {
      MyLoggerServices.to.print(e.toString());
      rethrow;
    }
  }

  /// Report A Comment
  @override
  Future<void> reportAComment({
    required String reportedCommentId,
    required BuildContext context,
    required String postId,
    required String content,
    required String reportMsg,
  }) async {
    if (_user == null) return;

    try {
      final String userId = _user!.uid;
      CommentReport reportModel = CommentReport(
        content: content,
        reportMsg: reportMsg,
        reportedByUid: userId,
        reportedCommentId: reportedCommentId,
        reportedPostId: postId,
      );

      final participants = [reportedCommentId, userId]..sort();
      await _firestore.collection(commentReports).doc(participants.join()).set(
            reportModel.toMap(),
            SetOptions(merge: true),
          );
      MyLoggerServices.to
          .print('reported comment id=> ${reportedCommentId}  comment of post id =>> ${postId} and reported by => ${userId}');
      await showDialog(
        context: context,
        builder: (context) {
          return const ReportDialogue();
        },
      );
    } catch (e) {
      snackBar(context, GayaStrings.unable_report_post.tr, kRedColor);
    }
  }

  /// Report A Comment Reply
  @override
  Future<void> reportACommentReply({
    required String content,
    required String commentId,
    required String postId,
    required String commentReplyId,
    required String reportMsg,
    required BuildContext context,
  }) async {
    if (_user == null) return;
    try {
      final String userId = _user!.uid;

      CommentReplyReport reportModel = CommentReplyReport(
        content: content,
        reportedByUid: userId,
        reportedCommentId: commentId,
        reportedReplyId: commentReplyId,
        reportMsg: reportMsg,
        reportedPostId: postId,
      );

      final participants = [commentReplyId, userId]..sort();
      await _firestore.collection(commentReports).doc(participants.join()).set(
            reportModel.toMap(),
            SetOptions(merge: true),
          );

      await showDialog(
        context: context,
        builder: (context) {
          return const ReportDialogue();
        },
      );
    } catch (e) {
      snackBar(context, GayaStrings.unable_report_post.tr, kRedColor);
    }
  }

  @override
  Future<void> reportANotification({
    required String content,
    required String notificationId,
    required String reportMsg,
    required BuildContext context,
  }) async {
    await _firestore.collection(notificationReport).doc(notificationId).set(
      {
        "content": content,
        "reportedByUid": _user!.uid,
        "reportMsg": reportMsg,
        "type": "notificationReport",
        "createdAt": DateTime.now(),
      },
    );
  }
}
