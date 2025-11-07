// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gaya/components/report_dialogue.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/services/report_services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/profile/contact_us/model/contact_us.dart';
import 'package:get/get.dart';

import '../model/user.model.dart';
import '../view/profile/contact_us/services/contact_us_services.dart';
import 'firebase_analytics_controller.dart';

class ReportController extends GetxService {
  static ReportController get to => Get.find();
  final AppConfigurationController _appConfig = AppConfigurationController.to;
  final ReportServices _reportServices = ReportServices();
  final ContactUsServices _contactUsServices = ContactUsServices();

  Future<void> reportAUser(String reportedPersonUid, BuildContext context, {bool isMessageReport = false, String reportMsg = ''}) async {
    try {
      log('this is reported person uid => $reportedPersonUid');
      if (reportedPersonUid.isEmpty) return;
      await _reportServices.reportAUser(reportedPersonUid, isMessageReport: isMessageReport, reportMsg: reportMsg);
      //locally
      _appConfig.reportedUsersID.add(reportedPersonUid);
      await showDialog(
          context: context,
          builder: (context) {
            return const ReportDialogue();
          });
    } catch (e) {
      log('error caught during report user=>${e.toString()}');
      snackBar(context, GayaStrings.unable_report_post.tr, kRedColor);
    }
  }

  Future<void> reportPost(String reportedPostId, BuildContext context, String? adminUi,
      {String reportMsg = '', required String communityId, String? userId}) async {
    try {
      if (reportedPostId.isEmpty) return;
      await _reportServices.reportPost(
        reportedPostId,
        adminUi,
        reportMsg: reportMsg,
        communityId: communityId,
      );

      if (userId != null) {
        // EngagementScoreController.to.instance.onReportUser(toUserId: userId);
        _reportServices.updateReportScoresInUserProfile(userId);
      }

      // Logging community report analytics event
      AnalyticsController.to.instance.logReportPost(
        userId: UserModel.to.uId ?? '',
        reportMessage: reportMsg,
        communityId: communityId,
        postId: reportedPostId,
      );

      await showDialog(
          context: context,
          builder: (context) {
            return const ReportDialogue();
          });
      //locally
      _appConfig.addReportedPostId(postId: reportedPostId);
    } catch (e) {
      snackBar(context, GayaStrings.unable_report_post.tr, kRedColor);
    }
  }

  Future<void> reportAComment({
    required String reportedCommentId,
    required BuildContext context,
    required String postId,
    required String content,
    required String reportMsg,
    String? userId,
  }) async {
    if (reportedCommentId.isEmpty) return;
    await _reportServices.reportAComment(
      reportedCommentId: reportedCommentId,
      context: context,
      postId: postId,
      content: content,
      reportMsg: reportMsg,
    );

    if (userId != null) {
      // EngagementScoreController.to.instance.onReportUser(toUserId: userId);
      _reportServices.updateReportScoresInUserProfile(userId);
    }
    //locally
    _appConfig.addReportedCommentId(
      postId: postId,
      commentId: reportedCommentId,
    );
  }

  Future<void> reportACommentReply({
    required String content,
    required String commentId,
    required String postId,
    required String commentReplyId,
    required BuildContext context,
    required String reportMsg,
  }) async {
    if (commentReplyId.isEmpty) return;
    await _reportServices.reportACommentReply(
      content: content,
      commentId: commentId,
      postId: postId,
      commentReplyId: commentReplyId,
      reportMsg: reportMsg,
      context: context,
    );

    //locally
    _appConfig.addReportedCommentReplyId(
      postId: postId,
      commentId: commentId,
      commentReplyId: commentReplyId,
    );
  }

  Future<void> reportANotification(
      {required String notificationId, required String content, required String reportMsg, required BuildContext context}) async {
    if (notificationId.isEmpty) return;
    await _reportServices.reportANotification(
      notificationId: notificationId,
      content: content,
      reportMsg: reportMsg,
      context: context,
    );
  }
}

/// Report a problem
extension ReportProblemContactUs on ReportController {
  reportAProblem({required ContactUs contactUs}) async {
    try {
      await _contactUsServices.reportAProblem(contactUsModel: contactUs);
    } catch (e) {
      log('error caught during report user=>${e.toString()}');
    }
  }
}
