// import 'package:firebase_database/firebase_database.dart';
//
// /// [TransferUserToRealtimeServices()] contains all the comments
// class OnlineStatusServices {
//   DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("active_status");
//
//   //  TODO:// write a cloud function to sync the data from firestore to realtime database
//   Future<void> createUserPresence({required String uid}) async {
//     try {
//       Map<String, dynamic> presenceStatusTrue = {
//         'presence': true,
//         'last_seen': ServerValue.timestamp,
//       };
//
//       await databaseReference.child(uid).set(presenceStatusTrue);
//       Map<String, dynamic> presenceStatusFalse = {
//         'presence': false,
//         'last_seen': ServerValue.timestamp,
//       };
//
//       databaseReference.child(uid).onDisconnect().update(presenceStatusFalse);
//     } catch (_) {}
//   }
//
//   Stream getUserActiveStatusStream({required String uid}) {
//     return databaseReference.child(uid).onValue;
//   }
//  Future<void> updateUserPresence({required String uid}) async {
//     try {
//       final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
//
//       Map<String, dynamic> presenceStatusTrue = {
//         'presence': true,
//         'last_seen': ServerValue.timestamp,
//       };
//
//       await databaseReference.child(uid).update(presenceStatusTrue);
//
//       Map<String, dynamic> presenceStatusFalse = {
//         'presence': false,
//         'last_seen': ServerValue.timestamp,
//       };
//
//       await databaseReference.child(uid).onDisconnect().update(presenceStatusFalse);
//     } catch (_) {}
//   }
// }
