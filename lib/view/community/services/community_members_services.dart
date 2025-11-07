import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/model/communities.memebers.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/logger.dart';

class CommunityMembersServices {
  String communityId;

  CommunityMembersServices({required this.communityId});

  int MembersLimit = kDebugMode ? 15 : 15;

  DocumentSnapshot? _lastDocument;
  bool _hasMoreMembers = true;

  void reset() {
    _lastDocument = null;
    _hasMoreMembers = true;
  }

  final _commonServices = Services.to;

// #1: Move the request posts into it's own function
  Future<List<UserModel>> _requestMembers() async {
    List<UserModel> newMembers = [];
    var membersQuery = FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('communityMembers')
        .where("isMember", isEqualTo: true)
        .limit(MembersLimit);

    // #5: If we have a document start the query after it
    if (_lastDocument != null) {
      membersQuery = membersQuery.startAfterDocument(_lastDocument!);
    }

    if (_hasMoreMembers == false) {
      MyLoggerServices.to.print("no more members from memberServices");
      return [];
    }

    List<UserModel> members = [];
    final membersSnapshot = await membersQuery.get();
    MyLoggerServices.to.print("membersSnapshot data length: ${membersSnapshot.docs.length}");

    List<UserModel?> localMember = [];
    for (var snapshot in membersSnapshot.docs) {
      try {
        final user = await _commonServices.getUserById(snapshot.id);
        if (user != null) {
          localMember.add(user);
        }
      } catch (_) {}
    }

    // List<UserModel?> localMembers = membersSnapshot.docs.map((snapshot) async {
    //   try {
    //     final user = await FirebaseFirestore.instance.collection('users').doc(snapshot.id).get().catchError((_) {});
    //     if (user.data() == null) {
    //       return null;
    //     }
    //     final member = UserModel.fromMap(snapshot.data());
    //     return member;
    //   } catch (_) {}
    // }).toList();
    // .where((mappedItem) => mappedItem?.communityId != null)
    // .toList();

    localMember.removeWhere((member) => member == null);
    if (membersSnapshot.docs.isNotEmpty) {
      _lastDocument = membersSnapshot.docs.last;
    } else {
      _hasMoreMembers = false;
    }
    for (var member in localMember) {
      members.add(member!);
    }

    newMembers = members;
    _hasMoreMembers = membersSnapshot.size == MembersLimit;

    return newMembers;
  }

  Future<List<UserModel>> requestMoreData() async => await _requestMembers();
}

class PendingCommunityPostsAndMembersServices {
  String communityId;

  PendingCommunityPostsAndMembersServices({required this.communityId});

  int MembersLimit = kDebugMode ? 5 : 15;

  DocumentSnapshot? _lastDocument;
  bool _hasMoreMembers = true;

  void reset() {
    _lastDocument = null;
    _hasMoreMembers = true;
  }

// #1: Move the request posts into it's own function
  Future<List<Map<String, dynamic>>> _requestMembers() async {
    List<UserModel> newMembers = [];
    var membersQuery = FirebaseFirestore.instance
        .collection("communities")
        .doc(communityId)
        .collection("communityMembers")
        .where("isMember", isEqualTo: false)
        .limit(MembersLimit);

    // #5: If we have a document start the query after it
    if (_lastDocument != null) {
      membersQuery = membersQuery.startAfterDocument(_lastDocument!);
    }

    if (_hasMoreMembers == false) {
      MyLoggerServices.to.print("no more members from memberServices");
      return [];
    }

    List<UserModel> members = [];
    List<CommunityMembership> communityMemberShipModel = [];

    final membersSnapshot = await membersQuery.get();
    MyLoggerServices.to.print("membersSnapshot data length: ${membersSnapshot.docs.length}");

    List<UserModel?> localMember = [];
    List<CommunityMembership> localCommunityMembers = [];
    for (var snapshot in membersSnapshot.docs) {
      try {
        final user = await FirebaseFirestore.instance.collection('users').doc(snapshot.data()['userUid']).get().catchError((_) {});
        if (user.data() != null) {
          final member = UserModel.fromMap(user.data()!, userId: user.id);
          localMember.add(member);
        }
        final communityMember = CommunityMembership.fromMap(snapshot.data());
        if (communityMember.userUid != null) {
          localCommunityMembers.add(communityMember);
        }
      } catch (_) {}
    }

    localMember.removeWhere((member) => member == null);
    localCommunityMembers.removeWhere((communityMemb) => communityMemb.userUid == null);

    if (membersSnapshot.docs.isNotEmpty) {
      _lastDocument = membersSnapshot.docs.last;
    } else {
      _hasMoreMembers = false;
    }
    for (var member in localMember) {
      members.add(member!);
    }
    for (var communityMember in localCommunityMembers) {
      communityMemberShipModel.add(communityMember);
    }

    newMembers = members;
    _hasMoreMembers = membersSnapshot.size == MembersLimit;

    return [
      {
        'users': newMembers,
      },
      {'communityMembers': communityMemberShipModel}
    ];
    // return newMembers;
  }

  Future<List<Map<String, dynamic>>> requestMoreData() async => await _requestMembers();
}
