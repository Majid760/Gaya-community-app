import 'package:cloud_firestore/cloud_firestore.dart';

class FriendShipModel {
  String? reciverName;
  String? recieverUid;
  DateTime? createdOn;
  String? senderName;
  String? profilePicture;
  String? senderUid;
  bool? isAccepted;

  FriendShipModel(
      {this.reciverName, this.recieverUid, this.createdOn, this.senderName, this.profilePicture, this.senderUid, this.isAccepted});

  String get getUserIds {
    if (senderUid == null || recieverUid == null) return '';
    return senderUid! + recieverUid!;
  }

  FriendShipModel.fromMap(Map<String, dynamic> map) {
    reciverName = map['RecieverName'];
    recieverUid = map['Recieveruid'];
    createdOn = (map['createdOn'] as Timestamp).toDate();
    senderName = map['senderName'];
    profilePicture = map['senderProfile'];
    senderUid = map['senderUid'];
    isAccepted = map['isaccepted'];
  }

  Map<String, dynamic> toMap() {
    return {
      'RecieverName': reciverName,
      'Recieveruid': recieverUid,
      'createdOn': createdOn,
      'senderName': senderName,
      'senderProfile': profilePicture,
      'senderUid': senderUid,
      'isaccepted': isAccepted,
    };
  }
}
