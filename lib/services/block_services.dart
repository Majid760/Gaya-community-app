import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaya/utils/logger.dart';


abstract class BlockServicesImpl {
  Future<void> blockAUser({required String userId});

  Future<List<String>> fetchMyBlockedUsersIds();
}

class BlockServices implements BlockServicesImpl {
  @override
  Future<void> blockAUser({required String userId}) async {
    final myAppUser = FirebaseAuth.instance.currentUser;
    if (myAppUser == null) return;
    FirebaseFirestore.instance.collection("users").doc(myAppUser.uid).collection("blockedUsers").doc(userId).set({
      "blockedAt": DateTime.now(),
    });
  }

  Future<void> unblockAUser({required String userId}) async {
    final myAppUser = FirebaseAuth.instance.currentUser;
    if (myAppUser == null) return;
      FirebaseFirestore.instance.collection("users").doc(myAppUser.uid).collection("blockedUsers").doc(userId).delete();
  }

  @override
  Future<List<String>> fetchMyBlockedUsersIds() async {
    final myAppUser = FirebaseAuth.instance.currentUser;
    if (myAppUser == null) return [];
    final blockedUsers = await FirebaseFirestore.instance.collection("users").doc(myAppUser.uid).collection("blockedUsers").get();
    final blockedUsersList = blockedUsers.docs.map((e) => e.id).toList();
    MyLoggerServices.to.print("blockedUsersList: $blockedUsersList");
    return blockedUsersList;
  }
}