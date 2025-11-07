import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityMembership {
  bool? isMember;
  bool? isAdmin;
  String? userUid;
  DateTime? createdOn;
  bool? morePosts;
  bool? isNotificationEnabled;

  bool? isModerator;
  List<Questionnaires>? questionnaires;

  CommunityMembership(
      {this.isMember, this.isAdmin, this.userUid, this.createdOn, this.morePosts, this.isNotificationEnabled, this.isModerator});

  CommunityMembership.fromMap(Map<String, dynamic> map) {
    isMember = map['isMember'];

    isAdmin = map['isAdmin'];
    userUid = map['userUid'];
    createdOn = (map['createdOn'] as Timestamp).toDate();
    morePosts = map['morePosts'];
    isNotificationEnabled = map["isNotificationEnabled"] ?? false;
    isModerator = map['isModerator'];
    try {
      questionnaires = map['questionnaires'] != null
          ? (map['questionnaires'] as Map).entries.map((e) => Questionnaires(question: e.key, answer: e.value)).toList()
          : [];
    } catch (_) {}
  }

  Map<String, dynamic> toMap() {
    return {
      'isMember': isMember,
      'isAdmin': isAdmin,
      'userUid': userUid,
      'createdOn': createdOn,
      'morePosts': morePosts,
    };
  }

  CommunityMembership copyWith({bool? isMember, bool? isAdmin, String? userUid, bool? isNotificationEnabled}) {
    return CommunityMembership(
      isAdmin: isAdmin ?? this.isAdmin,
      isMember: isMember ?? this.isMember,
      userUid: userUid ?? this.userUid,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}

class Questionnaires {
  String question;
  String answer;

  Questionnaires({required this.question, required this.answer});
}
