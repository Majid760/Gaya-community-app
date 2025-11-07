import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

class NotificationDeleteScript {
  // Future<void> deleteANotification()async {
  //   List<DocumentSnapshot> airdropNotifications = [];
  //   final notification = await FirebaseFirestore.instance.collection("users").doc("i3NMHQhPh2d4dp3e2rOtuhrUNXJ2").collection("notifications").where(
  //       'type', isEqualTo: "crownAirdrop").get();
  //   if (notification.docs.isNotEmpty) {
  //     airdropNotifications.addAll(notification.docs);
  //   }
  //
  //   _splitAndDelete(totalDocs: airdropNotifications);
  //
  //   debugPrint("My Total Docs: ${airdropNotifications.length}}");
  // }
  Future<void> deleteAirDropNotifications() async {
    final ref = FirebaseFirestore.instance.collection('users');
    final users = (await ref.get()).docs;

    List<DocumentSnapshot> airdropNotifications = [];
    for (var user in users) {
      final notification = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .collection("notifications")
          .where('type', isEqualTo: "crownAirdrop")
          .get();
      if (notification.docs.isNotEmpty) {
        airdropNotifications.addAll(notification.docs);
      }
    }
    if (airdropNotifications.isNotEmpty) {
      _splitAndDelete(totalDocs: airdropNotifications);
    }
  }

  ///configured for large items
  ///split into 500, then do batch delete to respect firebase limits.
  Future<void> _splitAndDelete({required List<DocumentSnapshot> totalDocs}) async {
    print("Total Docs: ${totalDocs.length}");

    final totalDocsLength = totalDocs.length;
    final totalDocsSplit = totalDocsLength ~/ 499;
    final totalDocsRemainder = totalDocsLength % 499;
    final totalDocsSplitList = List.generate(totalDocsSplit, (index) => 499);
    if (totalDocsRemainder > 0) {
      totalDocsSplitList.add(totalDocsRemainder);
    }
    totalDocsSplitList.forEach((split) async {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final docsToBeDeleted = totalDocs.sublist(0, split);
      docsToBeDeleted.forEach((doc) {
        batch.delete(doc.reference);
      });
      await batch.commit();
    });
  }
}

class SubscribeToCommunity {

  void unsubscribeFromAllCommunities()async {
    final communities = await _getAllCommunities();
    for (var community in communities) {
      final members = await _getCommunityMembers(community.id);

      /// iterate over all members and subscribe them to the community topic
      for (var member in members) {
        await _unSubscribeAndToggle(communityId: community.id, userId: member.id);
      }
    }

    debugPrint("Done _unSubscribeAndToggle to topics");
  }

  /// run script to sync group membership to topics
  /// It will iterate overall communities and subsribe to it.
  void subscribeToTopics() async {
    final communities = await _getAllCommunities();
    for (var community in communities) {
      final members = await _getCommunityMembers(community.id);

      /// iterate over all members and subscribe them to the community topic
      for (var member in members) {
        await _subscribeAndToggle(communityId: community.id, userId: member.id);
      }
    }

    debugPrint("Done subscribing to topics");
  }

  /// this script is to subscribe to specific community members (sync
  /// community members with topics)
  void subscribeByCommunityId({required String communityId})async {
    debugPrint("this is the communityId: $communityId");
    final members = await _getCommunityMembers(communityId);

    /// iterate over all members and subscribe them to the community topic
    /// this is for testing purposes only
    for (var member in members) {
      await _subscribeAndToggle(communityId: communityId, userId: member.id);
    }
  }

  Future<List<QueryDocumentSnapshot>> _getAllCommunities() async {
    return (await FirebaseFirestore.instance.collection("communities").get()).docs;
  }

  Future<List<QueryDocumentSnapshot>> _getCommunityMembers(String communityId) async {
    return (await FirebaseFirestore.instance.collection("communities").doc(communityId).collection("communityMembers").get()).docs;
  }

  Future<void> _subscribeAndToggle({required String communityId, required String userId}) async {
    debugPrint("this is the communityId: $communityId");
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'SubscribeToTopicByUid',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    HttpsCallableResult response = await callable.call({
      "communityid": communityId,
      "userId": userId,
    });

    debugPrint("this is the response: ${response.data}");
  }
  Future<void> _unSubscribeAndToggle({required String communityId, required String userId}) async {
    debugPrint("this is the communityId: $communityId");
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'unSubscribeToTopicByUid',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    HttpsCallableResult response = await callable.call({
      "communityid": communityId,
      "userId": userId,
    });

    debugPrint("this is the response: ${response.data}");
  }

}
