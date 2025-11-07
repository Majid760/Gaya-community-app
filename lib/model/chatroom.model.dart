import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/encryption/password_encryption.dart';

class ChatRoomModel {
  String? chatRoomId;
  List<String>? participants;
  String? lastMessage;
  String? lastMesgUserId;
  bool? isReadSender;
  bool? isReadReceiver;
  DateTime? lastMessageTime;
  List<dynamic>? typing;

  ChatRoomModel(
      {this.chatRoomId,
      this.participants,
      this.lastMessage,
      this.lastMessageTime,
      this.lastMesgUserId,
      this.typing,
      this.isReadReceiver,
      this.isReadSender});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    lastMessage = EncryptData.decryptionOfLastMessage(data: map['lastMessage']); // map['lastMessage'];
    chatRoomId = map['chatroomId'];
    isReadSender = map['isReadSender'];
    isReadReceiver = map['isReadReceiver'];
    lastMesgUserId = map['lastMesgUserId'];
    lastMessageTime = map['lastMessageTime'] == null ? null : (map['lastMessageTime'] as Timestamp).toDate();
    participants = List<String>.from(map['userIds']);
    typing = map['typing'] ?? [];
  }
  Map<String, dynamic> toUpdateRoomOnSentMap() {
    return {
      'lastMessage': EncryptData.encryption(data: lastMessage).toString(),
      'lastMessageTime': lastMessageTime,
      'lastMesgUserId': lastMesgUserId,
      'isReadSender': isReadSender,
      'isReadReceiver': isReadReceiver,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'chatroomId': chatRoomId,
      'isReadReceiver': isReadReceiver,
      'isReadSender': isReadSender,
      'lastMessageTime': lastMessageTime,
      'userIds': participants?..sort(),
      'lastMesgUserId': lastMesgUserId,
      'lastMessage': EncryptData.encryption(data: lastMessage).toString(), //lastMessage,
      'typing': typing ?? [],
    };
  }

  Map<String, dynamic> toMapForCreateRoom({required UserModel participant1, required UserModel participant2}) {
    return {
      'chatroomId': chatRoomId,
      'isReadReceiver': isReadReceiver,
      'isReadSender': isReadSender,
      'lastMessageTime': lastMessageTime,
      'userIds': participants?..sort(),
      'lastMesgUserId': lastMesgUserId,
      'lastMessage': EncryptData.encryption(data: lastMessage).toString(), //lastMessage,
      'typing': typing ?? [],
      participant1.uId!: participant1.toPublicJson(shouldHaveEmail: false),
      participant2.uId!: participant2.toPublicJson(shouldHaveEmail: false),
    };
  }
}
