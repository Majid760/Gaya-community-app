class CrownPayload {
  String postId;
  String senderId;
  String receiverId;
  String? commentId;
  String? replyId;

  CrownPayload({required this.postId, required this.senderId, required this.receiverId, this.commentId, this.replyId});

  Map<String, dynamic> toPostJson() {
    return {
      'postId': postId,
      'userId': senderId,
      'recieverUserId': receiverId,
    };
  }

  Map<String, dynamic> toCommentJson() {
    return {
      'postId': postId,
      'userId': senderId,
      'recieverUserId': receiverId,
      'commentId': commentId,
    };
  }

  Map<String, dynamic> toReplyJson() {
    return {
      'postId': postId,
      'userId': senderId,
      'recieverUserId': receiverId,
      'commentId': commentId,
      'replyCommentId': replyId,
    };
  }
}
