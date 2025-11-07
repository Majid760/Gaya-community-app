class UserReport {
  String? reportedByUid;
  String? reportedUserUid;
  bool isMessageReport;
  String? reportMessage;

  UserReport({
    this.reportedByUid,
    this.reportedUserUid,
    this.reportMessage,
    this.isMessageReport = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportedByUid': reportedByUid,
      'reportedUserUid': reportedUserUid,
      'reportMessage': reportMessage,
      'isReportHandled': false,
      'type': isMessageReport ? 'userMessageReport' : 'userReport',
      'createdAt': DateTime.now()
    };
  }
}

class PostReport {
  String? reportedByUid;
  String? reportedPostId;
  String? reportedMsg;

  PostReport({this.reportedByUid, this.reportedPostId, this.reportedMsg});

  PostReport.fromMap(Map<String, dynamic> map) {
    reportedByUid = map['reportedByUid'];
    reportedPostId = map['reportedPostId'];
    reportedMsg = map['reportedMsg'];
  }

  Map<String, dynamic> toMap() {
    return {
      'reportedByUid': reportedByUid,
      'reportedPostId': reportedPostId,
      'type': 'postReport',
      'isReportHandled': false,
      'reportedMsg': reportedMsg,
      'createdAt': DateTime.now()
    };
  }
}

class CommentReport {
  String? reportedByUid;
  String? reportedPostId;
  String? reportedCommentId;
  String? content;
  String? reportMsg;

  CommentReport({this.reportedByUid, this.reportedCommentId, this.reportedPostId, this.content, this.reportMsg});

  Map<String, dynamic> toMap() {
    return {
      'reportedByUid': reportedByUid,
      'reportedCommentId': reportedCommentId,
      'reportedPostId': reportedPostId,
      "content": content,
      "reportMsg": reportMsg,
      'isReportHandled': false,
      'type': 'commentReport',
      'createdAt': DateTime.now()
    };
  }
}

class CommentReplyReport {
  String? reportedByUid;
  String? reportedPostId;
  String? reportedCommentId;
  String? reportedReplyId;
  String? content;
  String? reportMsg;

  CommentReplyReport({this.reportedByUid, this.reportedCommentId, this.reportedPostId, this.reportedReplyId, this.content, this.reportMsg});

  Map<String, dynamic> toMap() {
    return {
      'reportedByUid': reportedByUid,
      'reportedCommentId': reportedCommentId,
      'reportedPostId': reportedPostId,
      'reportedReplyId': reportedReplyId,
      "content": content,
      "reportMsg": reportMsg,
      'isReportHandled': false,
      'type': 'replyCommentReport',
      'createdAt': DateTime.now()
    };
  }
}
