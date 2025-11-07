import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/chatroom.model.dart';
import 'package:gaya/model/messaging.model/messages.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/service/shared_service.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:get/get.dart';

class MessageService {
  final firebaseInstance = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  //get ref
  CollectionReference<Map<String, dynamic>> getRef(String? chatRoomId) {
    return firebaseInstance.collection('chatrooms').doc(chatRoomId).collection('messages');
  }

  // send the messsage
  Future<void> sendMessage(ChatRoomModel chatRoomModel, MessageModel messageModel) async {
    try {
      await getRef(chatRoomModel.chatRoomId).doc(messageModel.messageId).set(messageModel.toMap());
      await updateSetChatRoomData(chatRoomModel);
    } catch (e) {
      rethrow;
    }
  }

  // update/set the message/chatroom data
  Future<void> updateSetChatRoomData(ChatRoomModel chatRoomModel) async {
    try {
      await firebaseInstance
          .collection('chatrooms')
          .doc(chatRoomModel.chatRoomId)
          .set(chatRoomModel.toUpdateRoomOnSentMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}

class MessageUtils {
  static final _commonServices = Get.find<Services>();

  static sendAMessage(UserModel user, {required BuildContext context}) async {
    try {
      final otherUserId = user.uId ?? "";
      final appUserId = UserModel.to.uId ?? "";

      /// cant send message to yourself
      if (otherUserId.isEmpty || appUserId.isEmpty) return;

      String? canSend = await canSendAMessage(user: user);
      if (canSend == null) {
        if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
          if (ChatController.to().currentUser != null) {
            await ChatController.to().helperFunc.openOrCreateCubeConversation(context, otherUserId);
          }
        } else {
          ChatRoomModel? chatRoom = await getChatroomWithOtherUser(otherUserProfile: user);
          if ((chatRoom != null)) {
            EngagementScoreController.to.instance.onDirectMessage(toUserId: user.uId ?? "");
            Routes.personMessages(person: user, chatroom: chatRoom);
          }
        }
      } else {
        GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: canSend);
      }
      return;
    } catch (_) {
      GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: GayaStrings.cannot_send_message.tr);
    }
  }

  /// Call this method to check If user can chat with other user
  ///
  /// test cases @ [friendship_message_test.dart]
  /// * It will return null if the user is allowed to send a message
  ///  otherwise it will return an error message
  ///
  /// checks friendship status from firestore and age validation
  static Future<String?> canSendAMessage({required UserModel user}) async {
    final userId = user.uId;

    /// cant send because of empty user id
    if (userId.isBlank == true) return GayaStrings.cannot_send_message.tr;

    /// fetch friendship status
    final friendshipSnap = await getFriendship(otherUserId: userId!);
    bool isFriend = _isFriend(document: friendshipSnap, otherUserId: userId);
    bool isAgeValid = SharedService.isEnteredAgeValid(user.dob ?? DateTime(2000), 16);
    bool isMessageDisabled = user.allowToDm == false;
    return canSendMessage(isFriend, isAgeValid, isMessageDisabled);
  }

  static String? canSendMessage(bool _isFriend, bool _isAgeValid, bool _messagesDisabled) {
    bool isFriend = _isFriend;

    /// Not using ageValidity for now
    bool isAgeValid = true;
    bool isMessageDisabled = _messagesDisabled;
/*    // Case 1: User influence points not enough to send DMs
    if (UserModel.to.userInfluenceScoreWithCrowns < 40) {
      return GayaStrings.dm_not_allowed_due_to_low_influence_points.tr;
    }*/

    // Case 2: User is not a friend, message is disabled, and age is not valid
    if (!isFriend && isMessageDisabled && !isAgeValid) {
      return GayaStrings.not_allowed_users_lower_than_16_years.tr;
    }

    // case 3: User is not friend, but his messages are allowed as well as his age is not valid.
    if (!isFriend && !isMessageDisabled && !isAgeValid) {
      return null;
    }
    // Case 4: User is a friend or message is not disabled, and age is valid
    if (isFriend || (!isMessageDisabled && isAgeValid)) {
      return null;
    }

    return GayaStrings.cannot_send_message.tr;

    // if (!isFriend && !isAgeValid && !allowToDm) {
    //   return 'not_allowed_users_lower_than_16_years';
    // } else if (!isFriend && !isAgeValid && allowToDm) {
    //   return null;
    // } else if (isFriend || (!allowToDm && isAgeValid)) {
    //   return null;
    // } else {
    //   return 'Some string';
    // }
  }

  static sendAPostMessage(UserModel user, {required BuildContext context, required VoidCallback onPostShare}) async {
    try {
      final otherUserId = user.uId ?? "";
      final appUserId = UserModel.to.uId ?? "";

      /// cant send message to yourself
      if (otherUserId.isEmpty || appUserId.isEmpty) return;
      final friendshipSnap = await getFriendship(otherUserId: otherUserId);
      bool isFriend = _isFriend(document: friendshipSnap, otherUserId: otherUserId);

      if (SharedService.isEnteredAgeValid(user.dob ?? DateTime(2000), 16) == false && isFriend == false) {
        GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: GayaStrings.not_allowed_users_lower_than_16_years.tr);
      } else {
        if (user.allowToDm == false) {
          GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: GayaStrings.cannot_send_message.tr);
        } else {
          ChatRoomModel? chatRoom = await getChatroomWithOtherUser(otherUserProfile: user);
          if ((chatRoom != null)) {
            EngagementScoreController.to.instance.onDirectMessage(toUserId: user.uId ?? "");
            onPostShare();
            Routes.personMessages(person: user, chatroom: chatRoom);
          }
        }
      }
    } catch (_) {
      GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: GayaStrings.cannot_send_message.tr);
    }
  }

  static bool _isFriend({required QueryDocumentSnapshot<Object?>? document, required String otherUserId}) {
    if (document == null) return false;
    if (document['isaccepted'] == true) {
      if (document['Recieveruid'] == UserModel.to.uId && document['senderUid'] == otherUserId ||
          document['Recieveruid'] == otherUserId && document['senderUid'] == UserModel.to.uId) {
        return true;
      }
    }
    return false;
    return (document['Recieveruid'] == UserModel.to.uId || document['senderUid'] == otherUserId && document['isaccepted'] == true);
  }

  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getFriendship({required String otherUserId}) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final friendshipSnapshot = await _commonServices.getFriendshipWithOtherUser(otherUserId: otherUserId);
    if (friendshipSnapshot?.docs.isNotEmpty == true) {
      return friendshipSnapshot!.docs[0];
    }
    return null;
  }

  //Function to check whether the chatroom between the current user and reciver is created or not
  static Future<ChatRoomModel?> getChatroomWithOtherUser({bool shouldRefresh = true, required UserModel otherUserProfile}) async {
    ChatRoomModel chatRoom = ChatRoomModel();
    User? myUser = FirebaseAuth.instance.currentUser;
    if (myUser == null) {
      return null;
    }
    List<String> participants = [myUser.uid, otherUserProfile.uId ?? ""]..sort();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('chatrooms').where("userIds", isEqualTo: participants).get();
    if (querySnapshot.docs.isNotEmpty) {
      chatRoom = ChatRoomModel.fromMap(querySnapshot.docs[0].data() as Map<String, dynamic>);
    } else {
      //create room if dont exist
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatRoomId: participants.join(),
          typing: [],
          participants: participants,
          isReadSender: true,
          isReadReceiver: false,
          lastMessage: '',
          lastMesgUserId: myUser.uid);

      final UserModel? participant1 = await _commonServices.getUserById(FirebaseAuth.instance.currentUser!.uid);
      final UserModel? participant2 = await _commonServices.getUserById(otherUserProfile.uId);
      if (participant1 == null || participant2 == null) return null;
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(participants.join())
          .set(newChatRoom.toMapForCreateRoom(participant1: participant1, participant2: participant2));
      chatRoom = newChatRoom;
    }

    return chatRoom;
  }
}
