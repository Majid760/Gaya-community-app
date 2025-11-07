import 'package:cloud_firestore/cloud_firestore.dart';

///
/// Transfer Messages from firestore to ConnectyCube
///

class MessageTransferScript {
  final messagesRef = FirebaseFirestore.instance.collection('chatrooms');

  init() async {
    await _fetchAllMessagesFromFirestore();
  }

  _fetchAllMessagesFromFirestore() async {
    // fetch all messages from firestore
    final totalRooms = (await messagesRef.where("lastMessageTime", isNotEqualTo: null).orderBy("lastMessageTime").count().get()).count;
    print('totalRooms $totalRooms');
  }
}
