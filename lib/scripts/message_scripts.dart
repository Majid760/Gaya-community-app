// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:gaya/model/chatroom.model.dart';
// import 'package:gaya/services/services.dart';
// import 'package:gaya/shared/service/message_service/message_service.dart';
// import 'package:gaya/utils/helper/helper.functions.dart';
// import 'package:gaya/view/messaging/services/firestore/messages_firestore_services.dart';
// import 'package:get/get_utils/get_utils.dart';
//
// import '../app.dart';
// import '../model/messaging.model/messages.model.dart';
// import '../model/user.model.dart';
// import '../services/notification/notification_api/notification_api.dart';
//
// class SendMessageToUser {
//   final _chatroom = MessagesFirestoreServices();
//   final _commonServices = Services();
//   final messageServices = MessageService();
//   final _notification = NotificationApiHitting();
//   final POST_ID = "1a66d8f0-fb1b-11ed-a975-652026699255";
//   final MESSAGE =
//       "📣📣 צופים ותנועות נוער, הקשיבו טוב, כי את זה לא תרצו לפספס!!! 🎉🎉\n\n👏👏 פתחתם קהילות מדהימות, מלאות בפוסטים מרגשים. כל הכבוד לכם! 😍\n\nאז שימו לב, כי אנחנו פותחים אפשרות חדשה מטורפת לקבל נקודות!!🌟🌟\n\n🔥🔥 יצאה אפשרות חדשה, חמה מהתנור, לקבל נקודות לתחרות..\n\n📲📲 כפתור שיתוף לסטורי באינסטגרם!\n\n🥳 מה אפשר לקבל על כל שיתוף? כל שיתוף שווה ניקוד, וכל לחיצה על לינק ששיתפתם גם כן, כלומר בשקלול הנקודות יש לשיתופים בסטורי משקל קריטי!\n\n🎈 מה אפשר לשתף?? הכל! אפשר לשתף את הקהילה שלכם עם תיאור עליה, אפשר לשתף פוסטים מצחיקים או מעניינים מתוך הקהילות (גם מקהילות אחרות נחשב)\n\n🚀 איך משתמשים ומשתפים??\n\n1️⃣) לכו לחנות האפליקציות ושדרגו את אפליקציית גאיה, לעדכון האחרון שכולל את האפשרות\n2️⃣) עקבו אחר הצעדים בסרטון המצורף\n\n🎉🎉אז בהצלחה";
//
//   Future<List<String>> fetchUserIds() async {
//     return userIds;
//   }
//
//   Future<void> sendAMessage() async {
//     return;
//     final recieverUids = await fetchUserIds();
//     String message = MESSAGE;
//     debugPrint("total Users batch ${recieverUids.length}");
//     recieverUids.forEach((receiverId) async {
//       final chatroom = await _chatroom.getchatRoomCustom(receiverId);
//       if (chatroom != null) {
//         try {
//           await Future.wait([
//             _sendMessage(chatroom, message, isTextMessageOnly: false, receiverUid: receiverId),
//             _sendPostMessage(chatroom, receiverId),
//           ]);
//         } catch (_) {}
//       } else {
//         debugPrint("couldn't create chatroom for user: $receiverId");
//       }
//     });
//   }
//
//   Future<void> _sendMessage(ChatRoomModel chatRoomModel, String message,
//       {required bool isTextMessageOnly, required String receiverUid}) async {
//     final now = DateTime.now();
//
//     if (message.isBlank == true && isTextMessageOnly == true) return;
//
//     FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//     User? user = firebaseAuth.currentUser;
//     MessageModel messagesModel = MessageModel(
//       sender: user!.uid,
//       message: message,
//       createTime: now,
//       messageId: uuid.v1(),
//     );
//     await messageServices.sendMessage(chatRoomModel, messagesModel);
//     chatRoomModel.lastMessage = message;
//     chatRoomModel.lastMessageTime = now;
//     chatRoomModel.isReadSender = true;
//     chatRoomModel.isReadReceiver = false;
//     chatRoomModel.lastMesgUserId = user.uid.toString();
//     await messageServices.updateSetChatRoomData(chatRoomModel);
//
//     int? receiverIndex = chatRoomModel.participants?.indexWhere((element) => element != user.uid);
//
//     if (receiverIndex != null && receiverIndex != -1) {
//       final FCM = (await FirebaseFirestore.instance.collection('users').doc(receiverUid).get()).data()?['fm_token'];
//       if (FCM != null && FCM.toString().isBlank == false) {
//         final fcmMessageModel = FcmMessageModel(
//           chatroomId: chatRoomModel.chatRoomId ?? '',
//           messageContent: '📣📣 צופים ותנועות נוער, הקשיבו טוב, כי את זה לא תרצו לפספס!!! 🎉🎉',
//           messageTitle: "הודעה חשובה לצופים ותנועות הנוער מגאיה! 🤫😱",
//           receiverFcm: FCM,
//         );
//         await _notification.callOnFcmApiChat(fcmMessageModel);
//         debugPrint("Message Sent token: $FCM");
//       } else {
//         debugPrint("Couldnt send message to user: ${receiverIndex}");
//       }
//     }
//   }
//
//   Future<void> _sendPostMessage(ChatRoomModel chatRoomModel, String receieverId) async {
//     FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//     User? user = firebaseAuth.currentUser;
//     MessageModel messagesModel = MessageModel(
//       sender: user!.uid,
//       message: POST_ID,
//       createTime: DateTime.now(),
//       messageId: uuid.v1(),
//       messageType: MessageType.post,
//     );
//
//     await FirebaseFirestore.instance
//         .collection('chatrooms')
//         .doc(chatRoomModel.chatRoomId)
//         .collection('messages')
//         .doc(messagesModel.messageId)
//         .set(messagesModel.toMap());
//
//     await messageServices.updateSetChatRoomData(chatRoomModel);
//
//     // int? receiverIndex = chatRoomModel.participants?.indexWhere((element) => element != user.uid);
//     //
//     // if (receiverIndex != null && receiverIndex != -1) {
//     //   final FCM = (await FirebaseFirestore.instance.collection('users').doc(receieverId).get()).data()?['fm_token'];
//     //   if (FCM != null && FCM.toString().isBlank == false) {
//     //     final fcmMessageModel = FcmMessageModel(
//     //       chatroomId: chatRoomModel.chatRoomId ?? '',
//     //       messageContent: "Shared A Post With You, Check it!",
//     //       messageTitle: "GAYA TEAM",
//     //       receiverFcm: FCM,
//     //     );
//     //     await _notification.callOnFcmApiChat(fcmMessageModel);
//     //     debugPrint("Message Sent token: $FCM");
//     //   } else {
//     //     debugPrint("Couldnt send message to user: ${receiverIndex}");
//     //   }
//     // }
//   }
//
//   Future<ChatRoomModel?> getchatRoomCustom(String? recieverId) async {
//     ChatRoomModel? chatRoom;
//     User? myUser = FirebaseAuth.instance.currentUser;
//     if (myUser == null) {
//       return null;
//     }
//     final participants = [myUser.uid, recieverId ?? ""]..sort();
//     final querySnapshot = await FirebaseFirestore.instance.collection('chatrooms').doc(participants.join()).get();
//
//     if (querySnapshot.exists && querySnapshot.data() != null) {
//       chatRoom = ChatRoomModel.fromMap(querySnapshot.data()!);
//     } else {
//       //create room if dont exist
//       ChatRoomModel newChatRoom = ChatRoomModel(
//           chatRoomId: participants.join(),
//           typing: [],
//           participants: participants,
//           isReadSender: true,
//           isReadReceiver: false,
//           lastMessage: '',
//           lastMesgUserId: myUser.uid);
//
//       final participantData =
//           await Future.wait([_commonServices.getUserById(FirebaseAuth.instance.currentUser!.uid), _commonServices.getUserById(recieverId)]);
//       final UserModel? participant1 = participantData[0];
//       final UserModel? participant2 = participantData[1];
//       await FirebaseFirestore.instance
//           .collection('chatrooms')
//           .doc(participants.join())
//           .set(newChatRoom.toMapForCreateRoom(participant1: participant1!, participant2: participant2!));
//       chatRoom = newChatRoom;
//     }
//     return chatRoom;
//   }
// }
// List<String> userIds = [
// ];
