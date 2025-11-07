import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserScripts {
  Future<void> getAllUser() async {
    final users =
        await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: "0S97hNmzTpRijdM8pa78OH14TRK2").get();

    if (users.docs.isNotEmpty) {
      debugPrint("All users that have null: ${users.docs.length}");
      for (var doc in users.docs) {
        if (doc.data()['uid'] == null) {
          debugPrint("${doc.id}");
        }
      }
    } else {
      debugPrint("no users");
    }
  }
}
