import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../model/user.model.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

class AuthenticationServices {
  GoogleSignInAccount? _user;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  GoogleSignInAccount? get user => _user;

  User? get authUser => auth.currentUser;

  // get the fcm token and update/add to user account
  Future<void> updateUser({required String userId, required Map<String, dynamic> updatedData}) async {
    try {
      await _firebaseFirestore.collection('users').doc(userId).set(updatedData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('Failed with error code: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint("error during to update fcm token:$e");
      rethrow;
    }
  }

  Future<void> addUserUIDOnly() async {
    final appUserId = FirebaseAuth.instance.currentUser?.uid;
    if (appUserId != null) {
      await _firebaseFirestore.collection('users').doc(appUserId).set({'uid': appUserId}, SetOptions(merge: true));
    }
  }

  // add user  account
  Future<void> addUser(Map<String, dynamic> user) async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      user['fm_token'] = fcmToken ?? '';
      await _firebaseFirestore.collection('users').doc(user['uid']).set(user, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('Failed with error code: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint("error during to update fcm token:$e");
      rethrow;
    }
  }

  /// returns true if user exists.
  Future<bool> isUserExistsByEmail(String email) async {
    try {
      final isExists = await _firebaseFirestore.collection("users").where("email", isEqualTo: email).get();
      return isExists.size != 0;
    } on FirebaseException catch (e) {
      debugPrint('Failed with error code: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint("${e}error at get users by email");
      rethrow;
    }
  }

  // update the password store in collection document
  Future<void> updatePassword({required String email, required String password}) async {
    try {} on FirebaseException catch (e) {
      debugPrint('Failed with error code: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint("error during to update fcm token:$e");
      rethrow;
    }
  }

  final Services _services = Services();
  // get the single user from the Firebase
  Future<UserModel?> getUserById(String? userId) async {
    return _services.getUserById(userId, forcefullyServer: true);
  }

  // get the user collection
  Future<QuerySnapshot<Map<String, dynamic>>> getUsersByEmail(String email) async {
    try {
      return await _firebaseFirestore.collection("users").where("email", isEqualTo: email).get();
    } on FirebaseException catch (e) {
      debugPrint('Failed with error code: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint("${e}error at get users by email");
      rethrow;
    }
  }

  // update the user
  // Future<void> updateUser({required String userId, required Map<String, dynamic> updatedData}) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(userId).update(updatedData);
  //   } on FirebaseException catch (e) {
  //     debugPrint('Failed with error code: ${e.code}');
  //     rethrow;
  //   } catch (e) {
  //     debugPrint(e.toString() + "error at update user by id");
  //     rethrow;
  //   }
  // }

  Future<void> addUserDetails(User? user, {String? name}) async {
    int docLength = 0;
    try {
      QuerySnapshot result = await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: user?.email ?? '').get();
      docLength = result.docs.length;
      if (docLength > 0) {
      } else {
        Map<String, dynamic> data = {
          'name': name ?? user?.displayName ?? '',
          'email': user?.email ?? '',
          'password': '',
          'bio': '',
          'profilePic': user?.photoURL ?? '',
          'coverphoto': '',
          'interests': [],
          'uid': user?.uid ?? '',
          'admin': false,
          'phoneNumber': '',
          'userCreatedOn': DateTime.now(),
          'fm_token': await _firebaseMessaging.getToken(), 
          'isActive': true, 
        };
        await _firebaseFirestore.collection('users').doc(user!.uid).set(data, SetOptions(merge: true));
        // just for asking interest when user signup
        GetInterestStorageController getStorage = Get.find<GetInterestStorageController>();
        await getStorage.removeGetStorage();
      }
      // UserModel? myAppuser = await getUserById(user?.uid);
      // UserModel.to.update(myAppuser);
    } on FirebaseException catch (e) {
      debugPrint('Failed with error code: ${e.code}');
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
