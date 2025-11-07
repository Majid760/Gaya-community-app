import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReportScript {
  static Future<void> updatePostsReports() async {
    // updation start
    debugPrint('----> updation start');
    final reportsDocs = await FirebaseFirestore.instance.collection('PostsReport').get();
    for (var reportDoc in reportsDocs.docs) {
      final postReportMapWithAdditionalField = {
        'isReportHandled': false,
      };
      await FirebaseFirestore.instance.collection('PostsReport').doc(reportDoc.id).update(postReportMapWithAdditionalField);
      debugPrint('----> updation end');
    }
  }

  static Future<void> updateUsersReports() async {
    // updation start
    debugPrint('----> updation start');
    final reportsDocs = await FirebaseFirestore.instance.collection('userReport').get();
    for (var reportDoc in reportsDocs.docs) {
      final postReportMapWithAdditionalField = {
        'isReportHandled': false,
      };
      await FirebaseFirestore.instance.collection('userReport').doc(reportDoc.id).update(postReportMapWithAdditionalField);
      debugPrint('----> updation end');
    }
  }

  static Future<void> updateCommunityReports() async {
    // updation start
    debugPrint('----> updation start');
    final reportsDocs = await FirebaseFirestore.instance.collection('communityReport').get();
    for (var reportDoc in reportsDocs.docs) {
      final postReportMapWithAdditionalField = {
        'isReportHandled': false,
      };
      await FirebaseFirestore.instance.collection('communityReport').doc(reportDoc.id).update(postReportMapWithAdditionalField);
      debugPrint('----> updation end');
    }
  }

  static Future<void> updateCommentReports() async {
    // updation start
    debugPrint('----> updation start');
    final reportsDocs = await FirebaseFirestore.instance.collection('commentReport').where('type', isEqualTo: 'commentReport').get();
    for (var reportDoc in reportsDocs.docs) {
      final postReportMapWithAdditionalField = {
        'isReportHandled': false,
      };
      await FirebaseFirestore.instance.collection('commentReport').doc(reportDoc.id).update(postReportMapWithAdditionalField);
      debugPrint('----> updation end');
    }
  }

  static Future<void> updateCommentReplyReports() async {
    // updation start
    debugPrint('----> updation start');
    final reportsDocs = await FirebaseFirestore.instance.collection('commentReport').where('type', isEqualTo: 'replyCommentReport').get();
    for (var reportDoc in reportsDocs.docs) {
      final postReportMapWithAdditionalField = {
        'isReportHandled': false,
      };
      await FirebaseFirestore.instance.collection('commentReport').doc(reportDoc.id).update(postReportMapWithAdditionalField);
      debugPrint('----> updation end');
    }
  }
}
