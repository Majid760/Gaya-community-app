class NotificationModel {
  bool? isRead;
  String? message;
  String? receiverUserID;
  String? sender_name;
  String? sender_user_id;
  String? type;
  String? postId;
  String? communityId;

  Map<String, dynamic>? communityTopics;

  NotificationModel(this.isRead,
      {this.message, this.receiverUserID, this.sender_name, this.sender_user_id, this.type, this.postId, this.communityId});

  NotificationModel.fromMap(Map<String, dynamic> map) {
    isRead = map['isRead'];
    message = map['message'];
    receiverUserID = map['receiverUserID'];
    sender_name = map['sender_name'];
    sender_user_id = map['sender_user_id'];
    type = map['type'];
    postId = map['postId'];
    communityId = map['communityId'];
  }

  Map<String, dynamic> toMap() {
    return {
      'isRead': isRead,
      'message': message,
      'receiverUserID': receiverUserID,
      'sender_name': sender_name,
      'sender_user_id': sender_user_id,
      'type': type,
      'postId': postId,
      'communityId': communityId
    };
  }
}
