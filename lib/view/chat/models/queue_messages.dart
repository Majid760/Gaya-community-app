import 'package:connectycube_sdk/connectycube_chat.dart';

/// Queue system for sending messages

class QueueCubeMessage {
  CubeMessage message;
  CubeDialog chatroom;

  QueueCubeMessage({required this.message, required this.chatroom});

  static QueueCubeMessage fromJson(Map<String, dynamic> json) {
    return QueueCubeMessage(message: CubeMessage.fromJson(json['message']), chatroom: CubeDialog.fromJson(json['chatroom']));
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson(), 'chatroom': chatroom.toJson()};
  }
}
