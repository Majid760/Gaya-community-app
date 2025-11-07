import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class RepliesModel {
  String? userUid;
  String? replyId;
  DateTime? replyTime;
  String? reply;
  String? photoUrl;
  Map<String, dynamic>? videoUrl;
  List<Map<String, dynamic>>? mentionedUsers;
  List<Map<String, dynamic>>? pdfFiles;

  RepliesModel({this.userUid, this.replyId, this.reply, this.replyTime, this.photoUrl, this.videoUrl, this.mentionedUsers, this.pdfFiles});

  RepliesModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    replyId = map['replyId'];
    replyTime = (map['replyTime'] as Timestamp).toDate();
    reply = map['reply'];
    videoUrl = map['videoUrl'];
    photoUrl = map['photoUrl'];
    mentionedUsers = map['mentionedUsers'] != null
        ? (map['mentionedUsers'] as List)
            .map<Map<String, dynamic>>((user) =>
                {"display": user['display'], "senderUid": user['senderUid'], "senderProfile": user['senderProfile'], "id": user['id']})
            .toList()
        : null;
    pdfFiles = map['pdfFiles'];
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'replyId': replyId,
      'replyTime': replyTime,
      'reply': reply,
      'photoUrl': photoUrl,
      'videoUrl': videoUrl,
      'mentionedUsers': mentionedUsers,
      'pdfFiles': (pdfFiles == null || pdfFiles!.isEmpty) ? [] : pdfFiles?.toList(),
    };
  }
}
