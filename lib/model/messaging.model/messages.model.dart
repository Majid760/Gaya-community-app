import 'package:gaya/services/encryption/password_encryption.dart';
import 'package:gaya/utils/helper/helper.functions.dart';


class MessageModel {
  String? sender, message, messageId;
  DateTime? createTime;
  bool? isread;
  MessageType? messageType;

  MessageModel({this.sender, this.message, this.isread, this.createTime, this.messageId, this.messageType});

  //From map function to get the data from the firebase
  MessageModel.fromMap(Map<String, dynamic> map) {
    // MessageType.values.firstWhere((e) => e.toString() == map['messageType']);

    sender = map['sender'];
    //  message = map['message'];
    message = EncryptData.decryption(data: map['message']);
    isread = map['isRead'] ?? map["isread"] ?? true;
    // createTime = map['createdAt'].toDate();
    createTime = map['createdAt'] == null ? DateTime.now() : map['createdAt'].toDate().toLocal();

    messageId = map['messageId'];
    messageType = map['messageType'] != null ? _getMessageTypeFromString(map['messageType']) : MessageType.text;
  }

//to map function to send the send to firebase
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'message': EncryptData.encryption(data: message).toString(),
      // 'message': message,

      'isRead': isread,
      'createdAt': createTime?.toUtc(),
      // 'createdAt': createTime,
      'messageId': messageId,
      'messageType': _getMessageType(messageType),
    };
  }

  String _getMessageType(MessageType? type) {
    switch (type) {
      case MessageType.text:
        return "text";
      case MessageType.image:
        return "image";
      case MessageType.post:
        return "post";
      case MessageType.community:
        return "community";
      default:
        return "text";
    }
  }

  MessageType _getMessageTypeFromString(String? type) {
    switch (type) {
      case "text":
        return MessageType.text;
      case "image":
        return MessageType.image;
      case "post":
        return MessageType.post;
      case "community":
        return MessageType.community;
      default:
        return MessageType.text;
    }
  }
}
