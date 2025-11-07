import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaya/model/chatroom.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';

class MessagesFirestoreServices {
  final _commonServices = Services();

  //Function to check whether the chatroom between the current user and reciver is created or not
  Future<ChatRoomModel?> getchatRoomCustom(String? recieverId) async {

    ChatRoomModel? chatRoom ;
    User? myUser = FirebaseAuth.instance.currentUser;
    if (myUser == null) {
      return null;
    }
    final participants = [myUser.uid, recieverId ?? ""]..sort();
    final querySnapshot = await FirebaseFirestore.instance.collection('chatrooms').doc(participants.join()).get();

    if (querySnapshot.exists && querySnapshot.data() != null) {
      chatRoom = ChatRoomModel.fromMap(querySnapshot.data()!);
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

      final participantData =
          await Future.wait([_commonServices.getUserById(FirebaseAuth.instance.currentUser!.uid), _commonServices.getUserById(recieverId)]);
      final UserModel? participant1 = participantData[0];
      final UserModel? participant2 = participantData[1];
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(participants.join())
          .set(newChatRoom.toMapForCreateRoom(participant1: participant1!, participant2: participant2!));
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }
}
