import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/app.dart';
import 'package:gaya/model/chatroom.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/notification/notification_api/notification_api.dart';
import 'package:gaya/shared/service/message_service/message_service.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/messaging.model/messages.model.dart';
import '../model/messaging.model/personmessage.model.dart';
import 'firebase_analytics_controller.dart';

class MessageController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? message;
  TextEditingController messagetextfieldController = TextEditingController();
  String writtenMessage = '';
  bool isTyping = false;
  File? messageImage;
  String? downloadUrl = "";
  double? percentage;
  var snapshot;
  bool isSendingNewMessage = false;
  var getMesssages;

  String otherChatParticipantFcmToken = '';
  final NotificationApiHitting _notificationApiHitting = NotificationApiHitting();
  // var getpostsIds;

  // List<Map<String, dynamic>> postsId = [];
  //
  // List<Map<String, dynamic>> communityId = [];
  //
  // List<String> postsIds = [];
  // List<String> communityIds = [];

//  StreamController<int> messagesStream = StreamController();
//  Stream<QuerySnapshot> get Messages => messagesStream.stream<QuerySnapshot>;

  @override
  void dispose() {
    messagetextfieldController.dispose();
    // messagesStream.close();
    super.dispose();
  }

  late ScrollController messagesScrollController;

  void scrollToTop() {
    try {
      if (messagesScrollController.hasClients == false) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messagesScrollController.animateTo(
          messagesScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.bounceIn,
        );
      });
    } catch (_) {}
  }

  Future<void> seeMsg(var docid, var sender) async {
    try {
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .where("userIds", arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((snapshot) {
        notifyListeners();
        log("Snapshot size is ${snapshot.size.toString()}");
        for (var element in snapshot.docs) {
          if (element.id == docid) {
            if (element.get("lastMesgUserId") != FirebaseAuth.instance.currentUser!.uid) {
              element.reference.update({"isReadReceiver": true});
            } else {
              element.reference.update({"isReadSender": true});
            }
          }
        }
      });
    } on FirebaseException catch (e) {
      log(e.code);
    }
  }

  onChanged(value) {
    writtenMessage = value;
    notifyListeners();
  }

  uploadMessage(String message, bool isMe) {
    messagetextfieldController.clear();
    final newMessage = personMessages(message: writtenMessage, isMe: true, isContinue: false);
    messagingList.add(newMessage);
    notifyListeners();
  }

  //send the message
  sendMessage(BuildContext context, ChatRoomModel chatroomId) {
    message = messagetextfieldController.text.trim();
    messagetextfieldController.clear();

    if (message == '') {
    } else {
      User? user = _firebaseAuth.currentUser;
      MessageModel messagesModel = MessageModel(
        sender: user!.uid,
        message: message,
        // isread: false,
        createTime: DateTime.now(),
        messageId: uuid.v1(),
      );

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatroomId.toString())
          .collection('messages')
          .doc(messagesModel.messageId)
          .set(messagesModel.toMap());

      log('Message sent by me');
    }
  }

  Future messagingImage(ChatRoomModel chatroom) async {
    try {
      XFile? imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (imagePick != null) {
        File convertedFile = File(imagePick.path);
        messageImage = convertedFile;

        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        notifyListeners();
        // uploadMessageImage(chatroom);
      } else {
        return;
      }
    } on PlatformException catch (e) {
      log(e.toString());
    }
  }

  removeNewImage() {
    if (messageImage == null) return;
    messageImage = null;
    print(messageImage.toString());
    notifyListeners();
  }

  //upload image in message
  // uploadMessageImage(ChatRoomModel chatRoomModel) async {
  //   User user = FirebaseAuth.instance.currentUser!;
  //   UploadTask uploadTask = FirebaseStorage.instance.ref().child('images').child(Uuid().v1()).putFile(messageImage!);
  //   StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
  //     percentage = (data.bytesTransferred / data.totalBytes);
  //     notifyListeners();
  //     if (data.state == TaskState.success) {
  //       percentage = null;
  //       log('Our image uploading done');
  //     }
  //     log('This is our uploading image task : ${percentage.toString()}');
  //   });
  //   TaskSnapshot taskSnapshot = await uploadTask;
  //   downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //   listenEvent.cancel();
  //   log(downloadUrl!);
  //   //upload the data
  //   MessageModel messagesModel = MessageModel(
  //     sender: user.uid,
  //     message: downloadUrl,
  //     createTime: DateTime.now(),
  //     messageId: uuid.v1(),
  //   );
  //   await FirebaseFirestore.instance
  //       .collection('chatrooms')
  //       .doc(chatRoomModel.chatRoomId)
  //       .collection('messages')
  //       .doc(messagesModel.messageId)
  //       .set(messagesModel.toMap());
  //   // chatRoomModel.lastMessage != downloadUrl;
  //   chatRoomModel.lastMessage = 'Photo';
  //   await FirebaseFirestore.instance
  //       .collection('chatrooms')
  //       .doc(chatRoomModel.chatRoomId)
  //       .set(chatRoomModel.toUpdateRoomOnSentMap(), SetOptions(merge: true));
  // }

  //upload image in message
  Future<void> uploadImageMessage(ChatRoomModel chatRoomModel) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      UploadTask uploadTask = FirebaseStorage.instance.ref().child('images').child(const Uuid().v1()).putFile(messageImage!);
      messageImage = null;
      isSendingNewMessage = true;
      notifyListeners();
      StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
        percentage = (data.bytesTransferred / data.totalBytes);
        if (data.state == TaskState.success) {
          percentage = null;
          log('Our image uploading done');
        }
        log('This is our uploading image task : ${percentage.toString()}');
      });
      TaskSnapshot taskSnapshot = await uploadTask;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
      listenEvent.cancel();
      MessageModel messagesModel = MessageModel(sender: user.uid, message: downloadUrl, createTime: DateTime.now(), messageId: uuid.v1());
      await messageService.sendMessage(chatRoomModel, messagesModel);
      chatRoomModel.lastMessage = 'Photo';
      await messageService.updateSetChatRoomData(chatRoomModel);
      downloadUrl = null;
      messageImage = null;
      isSendingNewMessage = false;
      int? receiverIndex = chatRoomModel.participants?.indexWhere((element) => element != messagesModel.sender);
      final userModel = UserModel.to;
      if (receiverIndex != null && receiverIndex != -1) {
        otherChatParticipantFcmToken =
            (await FirebaseFirestore.instance.collection('users').doc(chatRoomModel.participants?[receiverIndex]).get())
                .data()?['fm_token'];
        final fcmMessageModel = FcmMessageModel(
            chatroomId: chatRoomModel.chatRoomId ?? '',
            messageContent: messagesModel.message ?? '',
            messageTitle: userModel.name ?? '',
            receiverFcm: otherChatParticipantFcmToken);
        _notificationApiHitting.callOnFcmApiChat(fcmMessageModel);
      }
      log('UPLOAD SUCCCESSFULL');

      notifyListeners();
    } catch (e) {
      log('Catch block error: $e');
      downloadUrl = null;
      messageImage = null;
      isSendingNewMessage = false;
      notifyListeners();
    }
  }

  final CollectionReference _collectionReference = FirebaseFirestore.instance.collection('chatrooms');

  Stream<QuerySnapshot> messages(ChatRoomModel chatRoomModel) =>
      _collectionReference.doc(chatRoomModel.chatRoomId).collection('messages').orderBy('createdAt', descending: false).snapshots();
  listeningForMessages(ChatRoomModel chatRoomModel) {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomModel.chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot?> getAllChats() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) return null;
    QuerySnapshot snapShot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where("userIds", arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .get();
    return snapShot;
  }

  //get the messages
  Stream<DocumentSnapshot> getMessages(String chatroomId) async* {
    yield* FirebaseFirestore.instance.collection("chatrooms").doc(chatroomId).snapshots();
  }

  Future deleteChatroom(String chatroomId) async {
    try {
      deleteChatroomMessagesSubcollection(chatroomId);
      FirebaseFirestore.instance.collection('chatrooms').doc(chatroomId).delete().then((value) => print('deleted'));
    } catch (e) {
      MyLoggerServices.to.print('Chatroom deletion error: ${e.toString()}');
    }
  }

  Future<void> deleteChatroomMessagesSubcollection(String chatroomId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final messages = await FirebaseFirestore.instance.collection('chatrooms').doc(chatroomId).collection('messages').get();
      if (messages.docs.isNotEmpty) {
        _splitAndDelete(totalDocs: messages.docs);
      }
      await batch.commit();
      MyLoggerServices.to.print('failed not but success to delete subcollection');
    } catch (e) {
      MyLoggerServices.to.print('failed to delete subcollection');
      debugPrint(e.toString());
    }
  }

  ///configured for large items
  ///split into 500, then do batch delete to respect firebase limits.
  Future<void> _splitAndDelete({required List<DocumentSnapshot> totalDocs}) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    final totalDocsLength = totalDocs.length;
    final totalDocsSplit = totalDocsLength ~/ 499;
    final totalDocsRemainder = totalDocsLength % 499;
    final totalDocsSplitList = List.generate(totalDocsSplit, (index) => 499);
    if (totalDocsRemainder > 0) {
      totalDocsSplitList.add(totalDocsRemainder);
    }
    for (var split in totalDocsSplitList) {
      final docsToBeDeleted = totalDocs.sublist(0, split);
      for (var doc in docsToBeDeleted) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  Future<void> deleteChatroomSinglemessage(String chatroomId, String messageId) async {
    try {
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatroomId)
          .collection('messages')
          .doc(messageId)
          .delete()
          .then((value) => print('deleted'));
    } catch (e) {
      print('Chatroom single message deletion error: ${e.toString()}');
    }
  }

  Future<void> deleteChatroomLastMessage(String chatroomId) async {
    try {
      FirebaseFirestore.instance.collection('chatrooms').doc(chatroomId).update({
        'lastMessage': '',
      }).then((value) => print('deleted last message'));
    } catch (e) {
      print('Chatroom last message deletion error: ${e.toString()}');
    }
  }

  // done by mak
  MessageService messageService = MessageService();

  Future<void> sendMessages(BuildContext context, ChatRoomModel chatRoomModel,
      {required bool isTextMessageOnly, required String token}) async {
    String message = '';
    if (isTextMessageOnly == false) {
      await uploadImageMessage(chatRoomModel);
      return;
    } else {
      message = messagetextfieldController.text.trim();
      messagetextfieldController.clear();
    }
    if (message.isBlank == true && isTextMessageOnly == true) return;
    if (isTextMessageOnly == false && message.length > 10000) {
      GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: GayaStrings.long_message.tr);
      return;
    }
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user = firebaseAuth.currentUser;
    MessageModel messagesModel = MessageModel(
      sender: user!.uid,
      message: message,
      createTime: DateTime.now(),
      messageId: uuid.v1(),
    );
    await messageService.sendMessage(chatRoomModel, messagesModel);
    // await FirebaseFirestore.instance
    //     .collection('chatrooms')
    //     .doc(chatRoomModel.chatRoomId)
    //     .collection('messages')
    //     .doc(messagesModel.messageId)
    //     .set(messagesModel.toMap());
    chatRoomModel.lastMessage = message;
    chatRoomModel.lastMessageTime = DateTime.now();
    chatRoomModel.isReadSender = true;
    chatRoomModel.isReadReceiver = false;
    chatRoomModel.lastMesgUserId = user.uid.toString();
    await messageService.updateSetChatRoomData(chatRoomModel);
    // await FirebaseFirestore.instance
    //     .collection('chatrooms')
    //     .doc(chatRoomModel.chatRoomId)
    //     .set(chatRoomModel.toUpdateRoomOnSentMap(), SetOptions(merge: true));

    FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomModel.chatRoomId).update({
      "typing": FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
    });

    int? receiverIndex = chatRoomModel.participants?.indexWhere((element) => element != user.uid);
    final usermodel = UserModel.to;
    if (receiverIndex != null && receiverIndex != -1 && token != '') {
      //do notification on fcm
      final fcmMessageModel = FcmMessageModel(
          chatroomId: chatRoomModel.chatRoomId ?? '',
          messageContent: messagesModel.message ?? '',
          messageTitle: usermodel.name ?? '',
          receiverFcm: token);
      _notificationApiHitting.callOnFcmApiChat(fcmMessageModel);
      log('new message sent successfully: $token');
    }
  }
}
