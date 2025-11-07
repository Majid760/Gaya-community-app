import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';

import '../controller/firebase_analytics_controller.dart';

class AccountDeletionServices {
  AccountDeletionServices._();

  static AccountDeletionServices? _instance;

  static AccountDeletionServices get instance {
    _instance ??= AccountDeletionServices._();
    return _instance!;
  }

  ///plus two more variables

  ///Delete all my data and account
  Future<void> deleteMyAccountPermenantly({required UserCredential credential}) async {
    try {
      // Logging delete account analytics event
      AnalyticsController.to.instance.logDeleteAccount(
        userId: FirebaseAuth.instance.currentUser?.uid ?? "",
        metadata: credential.credential?.asMap(),
      );

      await deleteFriendshipData();
      await deletePostsData();

      await deleteCommunitiesAsAdmin();
      await fetchAndDeleteMeFromCommunities();
      await _removeFromSentCommunitiesRequests();
      await deleteChatroom();

      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).delete();
      await credential.user?.delete();
    } catch (e) {
      print(e);
    }
  }

  Future<UserCredential?> reAuthenticateUserGoogle() async {
    final googleCredentials = await LoginController().reAuthenticateGoogle();
    if (googleCredentials == null) return null;
    UserCredential? credential = await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(googleCredentials);

    debugPrint('reAuthenticateUserGoogle: ${credential?.user?.email}');
    return credential;
  }

  Future<UserCredential?> reAuthenticateUserApple() async {
    final appleCredentials = await LoginController().reAuthenticateApple();
    if (appleCredentials == null) return null;
    UserCredential? credential = await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(appleCredentials);
    debugPrint('reAuthenticateUserApple: ${credential?.user?.email}');
    return credential;
  }

  Future<UserCredential?> reAuthenticateUserWithPassword({required String password}) async {
    UserCredential? credential = await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: FirebaseAuth.instance.currentUser?.email ?? '', password: password));
    return credential;
  }

  Future<String?> sendOtp() async {
    String? verificationId = '';
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: FirebaseAuth.instance.currentUser?.phoneNumber,
        verificationCompleted: (_) => {},
        verificationFailed: (_) => {},
        codeSent: (String verificationId, int? resendToken) async {
          verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
        });
    return verificationId;
  }

  Future<UserCredential?> reAuthenticateUserWithPhone({required String smsCode, required String verificationId}) async {
    UserCredential? credential = await FirebaseAuth.instance.currentUser
        ?.reauthenticateWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode));
    return credential;
  }

  Future<void> deleteFriendshipData() async {
    try {
      final userAsReciever = await FirebaseFirestore.instance
          .collection('friendships')
          .where('Recieveruid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      final userAsSender = await FirebaseFirestore.instance
          .collection('friendships')
          .where('Senderuid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      final totalDocs = userAsReciever.docs + userAsSender.docs;
      if (totalDocs.isNotEmpty) {
        _splitAndDelete(totalDocs: totalDocs);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deletePostsData() async {
    try {
      final userPosts = await FirebaseFirestore.instance
          .collection('communityposts')
          .where('memberId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (userPosts.docs.isNotEmpty) {
        _splitAndDelete(totalDocs: userPosts.docs);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteCommunitiesAsAdmin() async {
    try {
      final userCommunities = await FirebaseFirestore.instance
          .collection('communities')
          .where('adminUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      for (var element in userCommunities.docs) {
        // _removeCommunityIdFromMembersCollections(element.id);
        // hiding posts.
        await deleteAllPostsOfCommunity(communityId: element.id);
      }
      if (userCommunities.docs.isNotEmpty) {
        _splitAndDelete(totalDocs: userCommunities.docs);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchAndDeleteMeFromCommunities() async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final myCommunities = await FirebaseFirestore.instance.collection("users").doc(userId).collection("communities").get();
      if (myCommunities.docs.isNotEmpty) {
        for (var communityId in myCommunities.docs) {
          batch.delete(FirebaseFirestore.instance.collection('communities').doc(communityId.id).collection('communityMembers').doc(userId));
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteChatroom() async {
    try {
      final userChatrooms = await FirebaseFirestore.instance
          .collection('chatrooms')
          .where('userIds', arrayContains: FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (userChatrooms.docs.isNotEmpty) {
        _splitAndDelete(totalDocs: userChatrooms.docs);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _removeFromSentCommunitiesRequests() async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final myCommunities = await FirebaseFirestore.instance.collection("users").doc(userId).collection("sentCommunitiesRequests").get();
      if (myCommunities.docs.isNotEmpty) {
        for (var communityId in myCommunities.docs) {
          batch.delete(FirebaseFirestore.instance.collection('communities').doc(communityId.id).collection('communityMembers').doc(userId));
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<void> _removeCommunityIdFromMembersCollections(String communityId) async {
  //   try {
  //     final batch = FirebaseFirestore.instance.batch();
  //     final batch2 = FirebaseFirestore.instance.batch();
  //     final members = await FirebaseFirestore.instance.collection('communities').doc(communityId).collection('members').get();
  //     if (members.docs.isNotEmpty) {
  //       members.docs.forEach((element) async {
  //         batch.delete(FirebaseFirestore.instance.collection('users').doc(element.id).collection('communities').doc(communityId));
  //         batch.delete(FirebaseFirestore.instance.collection('communities').doc(communityId.id).collection('communityMembers').doc(userId));
  //       });
  //
  //       await batch.commit();
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  ///configured for large items
  ///split into 500, then do batch delete to respect firebase limits.
  Future<void> _splitAndDelete({required List<DocumentSnapshot> totalDocs}) async {
    final totalDocsLength = totalDocs.length;
    final totalDocsSplit = totalDocsLength ~/ 499;
    final totalDocsRemainder = totalDocsLength % 499;
    final totalDocsSplitList = List.generate(totalDocsSplit, (index) => 499);
    if (totalDocsRemainder > 0) {
      totalDocsSplitList.add(totalDocsRemainder);
    }
    for (var split in totalDocsSplitList) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final docsToBeDeleted = totalDocs.sublist(0, split);
      for (var doc in docsToBeDeleted) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  ///configured for large items
  ///split into 500, then do batch delete to respect firebase limits.
  Future<void> _splitAndUpdate({required List<DocumentSnapshot> totalDocs, required Map<String, dynamic> updatedField}) async {
    final totalDocsLength = totalDocs.length;
    final totalDocsSplit = totalDocsLength ~/ 499;
    final totalDocsRemainder = totalDocsLength % 499;
    final totalDocsSplitList = List.generate(totalDocsSplit, (index) => 499);
    if (totalDocsRemainder > 0) {
      totalDocsSplitList.add(totalDocsRemainder);
    }
    for (var split in totalDocsSplitList) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final docsToBeUpdated = totalDocs.sublist(0, split);
      for (var doc in docsToBeUpdated) {
        batch.update(doc.reference, updatedField);
      }
      await batch.commit();
    }
  }

  Future<void> deleteAllPostsOfCommunity({required String communityId}) async {
    try {
      final communityPosts =
      await FirebaseFirestore.instance.collection('communityposts').where('communityId', isEqualTo: communityId).get();
      if (communityPosts.docs.isNotEmpty) {
        _splitAndUpdate(totalDocs: communityPosts.docs, updatedField: {'isDeleted': true});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
