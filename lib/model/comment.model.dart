import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsModel {
  String? userId;
  String? comment;
  String? commentId;
  DateTime? commentTime;
  Map<String, dynamic>? videoUrl;
  String? photoUrl;
  List<Map<String, dynamic>>? mentionedUsers;
  List<Map<String, dynamic>>? pdfFiles;

  CommentsModel(
      {this.userId, this.comment, this.commentId, this.commentTime, this.videoUrl, this.photoUrl, this.mentionedUsers, this.pdfFiles});
  CommentsModel.fromMap(Map<String, dynamic> map) {
    userId = map['userId'];
    comment = map['comment'];
    commentId = map['commentId'];
    videoUrl = map['videoUrl'];
    photoUrl = map['photoUrl'];
    commentTime = (map['commentTime'] as Timestamp).toDate();
    mentionedUsers = map['mentionedUsers'];
    pdfFiles = map['pdfFiles'];
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'comment': comment,
      'commentId': commentId,
      'commentTime': commentTime,
      'videoUrl': videoUrl,
      'photoUrl': photoUrl,
      'mentionedUsers': mentionedUsers?.toList(),
      'pdfFiles': (pdfFiles == null || pdfFiles!.isEmpty) ? [] : pdfFiles?.toList(),
    };
  }
}
