import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class DeleteCommunityServices with Splits {
  DeleteCommunityServices._();

  static DeleteCommunityServices? _instance;

  static DeleteCommunityServices get instance {
    _instance ??= DeleteCommunityServices._();
    return _instance!;
  }

  Future<void> deleteCommunity({required String communityId}) async {
    final ref = FirebaseFirestore.instance.collection('communities').doc(communityId);

    await Future.wait([
      _deleteFromMembers(ref, communityId),
      deleteCommunityFromUserCollection(ref, communityId),
      deleteCommunityPosts(communityId),
    ]);

    /// delete community ref
    ref.delete();
  }

  Future<void> archiveCommunity({required String communityId}) async {
    final ref = FirebaseFirestore.instance.collection('communities').doc(communityId);

    return await ref.update({"isArchived": true});
  }

  Future<void> unarchiveCommunity({required String communityId}) async {
    final ref = FirebaseFirestore.instance.collection('communities').doc(communityId);

    return await ref.update({"isArchived": false});
  }

  Future<void> _deleteFromMembers(DocumentReference<Map<String, dynamic>> ref, String communityId) async {
    final totalMembers = (await ref.collection("communityMembers").get()).docs;

    for (var doc in totalMembers) {
      final map = doc.data();
      final userId = map["userUid"];
      final ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('communities')
          .where("communityId", isEqualTo: communityId)
          .get();
      for (var element in ref.docs) {
        try {
          await element.reference.delete();
        } catch (e) {
          print("******* couldn't delete for this user $e      \n ${element.data()}");
        }
      }
    }
  }
}

extension UserCollection on DeleteCommunityServices {
  /// deletes community reference from [`users`] collection
  Future<void> deleteCommunityFromUserCollection(DocumentReference<Map<String, dynamic>> ref, String communityId) async {
    final allMembers = (await ref.collection("communityMembers").get()).docs;

    /// unwrap user ids
    final allMemberIds = allMembers.map((e) => e.id).toList();

    /// prepare batches
    final totalBatches = splitIntoChunks(totalDocs: allMemberIds, chunkSize: 249);

    /// iterate over batches and delete
    for (var batch in totalBatches) {
      WriteBatch writeBatch = FirebaseFirestore.instance.batch();
      final chunk = allMemberIds.sublist(0, batch);
      for (var userId in chunk) {
        final communityRef = _getCommunityRef(userId, communityId);
        final hiddenCommunityRef = _getHiddenCommunityRef(userId, communityId);

        /// deleting community from userCollection
        writeBatch.delete(communityRef);

        /// deleting hidden community from userCollection
        writeBatch.delete(hiddenCommunityRef);
      }
      await writeBatch.commit();
    }
  }

  DocumentReference<Map<String, dynamic>> _getCommunityRef(String userId, String communityId) {
    return FirebaseFirestore.instance.collection("users").doc(userId).collection("communities").doc(communityId);
  }

  DocumentReference<Map<String, dynamic>> _getHiddenCommunityRef(String userId, String communityId) {
    return FirebaseFirestore.instance.collection("users").doc(userId).collection('hiddenCommunities').doc(communityId);
  }
}

extension Posts on DeleteCommunityServices {
  Future<void> deleteCommunityPosts(String communityId) async {
    final communityPostsRef = FirebaseFirestore.instance.collection('communityposts');
    final totalPosts = (await communityPostsRef.where("communityId", isEqualTo: communityId).get()).docs;
    await deleteIntoChunks(totalDocs: totalPosts);
  }
}

mixin Splits {
  List<int> splitIntoChunks({required List totalDocs, int chunkSize = 499}) {
    debugPrint("Total Docs: ${totalDocs.length}");
    final totalDocsLength = totalDocs.length;
    final totalDocsSplit = totalDocsLength ~/ chunkSize;
    final totalDocsRemainder = totalDocsLength % chunkSize;
    final totalDocsSplitList = List.generate(totalDocsSplit, (index) => chunkSize);
    if (totalDocsRemainder > 0) {
      totalDocsSplitList.add(totalDocsRemainder);
    }
    return totalDocsSplitList;
  }

  Future<void> deleteIntoChunks({required List<DocumentSnapshot> totalDocs}) async {
    final totalDocsSplitList = splitIntoChunks(totalDocs: totalDocs);
    for (var split in totalDocsSplitList) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final docsToBeDeleted = totalDocs.sublist(0, split);
      for (var doc in docsToBeDeleted) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> updateIntoChunks({required List<DocumentSnapshot> totalDocs, required Map<String, dynamic> data}) async {
    final totalDocsSplitList = splitIntoChunks(totalDocs: totalDocs);
    for (var split in totalDocsSplitList) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final docsToBeUpdate = totalDocs.sublist(0, split);
      for (var doc in docsToBeUpdate) {
        batch.update(doc.reference, data);
      }
      await batch.commit();
    }
  }

  Future<void> writeIntoChunks({required List<DocumentSnapshot> totalDocs, required Map<String, dynamic> data}) async {
    final totalDocsSplitList = splitIntoChunks(totalDocs: totalDocs);
    for (var split in totalDocsSplitList) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final docsToBeWrite = totalDocs.sublist(0, split);
      for (var doc in docsToBeWrite) {
        batch.set(doc.reference, data);
      }
      await batch.commit();
    }
  }
}