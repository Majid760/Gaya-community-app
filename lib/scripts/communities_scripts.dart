import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CommunitiesScript extends ICommunityMembershipScript with DeleteUserCommunitiesScript {
  Future<void> addNewFieldToAllCommunities({required Map<String, dynamic> newField}) async {
    final batch = FirebaseFirestore.instance.batch();

    final rawCommunities = await FirebaseFirestore.instance.collection("communities").get();
    for (var community in rawCommunities.docs) {
      batch.set(community.reference, newField, SetOptions(merge: true));
    }

    await batch.commit();
    debugPrint("added new field: lastPostCreatedAt");
  }
}

abstract class ICommunityMembershipScript {
  final _communityRef = FirebaseFirestore.instance.collection("communities");
  DocumentReference<Map<String, dynamic>> _userRef({required String userId}) => FirebaseFirestore.instance.collection("users").doc(userId);


  /// add community to user collection
  Future<void> syncCommunitiesMembershipWithUserCollection() async {
    final communities = await _fetchAllCommunities();
    for (var community in communities.docs)  {
      final String communityId = community.id;
      final String communityName = community.data()["name"].toString();
      final communityMembers = await _fetchCommunityMembers(communityId: communityId);
      final data = {"communityId": communityId, "communityName": communityName};
      final noOfChunk = splitIntoChunks(totalDocs: communityMembers);
      debugPrint("totalChunks: ${noOfChunk.length}");
      for (var split in noOfChunk) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        final chunk = communityMembers.sublist(0, split);
        for (var doc in chunk) {
          final memberId = doc.data()["userUid"];
          final docId = communityId;
          final userCommunitiesRef = _userRef(userId: memberId).collection("communities");
          batch.set(userCommunitiesRef.doc(docId), data, SetOptions(merge: true));
        }
        await batch.commit();
      }
    }
  }


  // fetch community all members
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchCommunityMembers({required String communityId}) async {
    final members = await _communityRef.doc(communityId).collection("communityMembers").where("isMember", isEqualTo: true).get();
    return members.docs;
  }
  /// fetch all communities
  Future<QuerySnapshot<Map<String, dynamic>>> _fetchAllCommunities() async {
    return await _communityRef.get();
  }



}

///configured for large items
///split into 500, then do batch delete to respect firebase limits.
List<int> splitIntoChunks({required List<DocumentSnapshot> totalDocs}) {
  debugPrint("Total Docs: ${totalDocs.length}");
  final totalDocsLength = totalDocs.length;
  final totalDocsSplit = totalDocsLength ~/ 499;
  final totalDocsRemainder = totalDocsLength % 499;
  final totalDocsSplitList = List.generate(totalDocsSplit, (index) => 499);
  if (totalDocsRemainder > 0) {
    totalDocsSplitList.add(totalDocsRemainder);
  }
  return totalDocsSplitList;
}
mixin DeleteUserCommunitiesScript {
  Future<void> deleteUserCommunities() async {
    final users = await FirebaseFirestore.instance.collection("users").get();
    final noOfChunks = splitIntoChunks(totalDocs: users.docs);
    for (var split in noOfChunks) {
      final chunk = users.docs.sublist(0, split);
      for (var doc in chunk) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        final userCommunitiesRef = FirebaseFirestore.instance.collection("users").doc(doc.id).collection("communities");
        final userCommunities = await userCommunitiesRef.get();
        debugPrint("path: ${userCommunitiesRef.path}");
        debugPrint("userCommunities: ${userCommunities.docs.length}");
        debugPrint("userid: ${doc.id}");
        for (var community in userCommunities.docs) {
          batch.delete(community.reference);
        }
        await batch.commit();
      }


    }
  }
}