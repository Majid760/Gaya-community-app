// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
//
//
// /// This script is used to clone firestore users to realtime database [just saving uid] for maintaing their last
// /// seen and active status. As this was expensive task for using firestore, so we are using realtime database just for
// /// this purpose. As alot of writes and reads are going to consume for this so realtime is best option for this.
// ///
// /// TODO: Cloud function on Auth trigger to create user in realtime database.
// class TransferUserToRealtimeServices {
//
//  final twentyDaysAgo =  DateTime.now().subtract(const Duration(days: 20)).millisecondsSinceEpoch;
//   Future<void> transferAllUsers() async {
//     try {
//       final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection("users").get();
//       final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = querySnapshot.docs;
//       for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
//         final String uid = doc.id;
//         await createUserPresence(uid: uid);
//       }
//     } catch (_) {
//       print("Err at TransferALLUser: ${_.toString()}");
//     }
//   }
//
//   Future<void> createUserPresence({required String uid}) async {
//     try {
//
//       final DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("active_status");
//
//       Map<String, dynamic> presenceStatusTrue = {
//         'presence': false,
//         'last_seen': twentyDaysAgo,
//       };
//
//       await databaseReference.child(uid).set(presenceStatusTrue).onError((error, stackTrace) => print("Err at createUserPresence: ${error.toString()}"));
//       debugPrint("Creating user presence for $uid");
//       debugPrint("User $uid created");
//     } catch (_) {
//       print("Err at createUserPresence: ${_.toString()}");
//     }
//   }
//
//
//
// }
//
//
// /// Cloud function to create user in realtime database on user creation.
// /// TODO: Merged currently written script with this cloud function.
// /* const rt = admin.database();
// exports.onAuthUserCreated = functions.auth.user().onCreate(async (user) => {
//     try {
//         const uid = user.uid;
//         const res = await axios.post('https://api-prod-ws7ku6426a-nw.a.run.app/api/users?apiKey=4MnDqFRLBGZDqxljDdSM8Rzfwcl2', {
//             uid: uid
//         })
//
//         //for realtime database (to main user's presence and last seen for chat module) *B*
//         await rt.ref('users/' + uid).set({
//             "presence": false,
//             "lastSeen": null,
//         });
//
//
//         if (res.data.failed) {
//             functions.logger.error(res.data.message)
//             return new Error(res.data.message)
//         } else {
//             functions.logger.info(res.data.message)
//             return res.data.message
//         }
//     }
//     catch (error) {
//         functions.logger.error(error)
//         return new Error(error)
//     }
// }); */
