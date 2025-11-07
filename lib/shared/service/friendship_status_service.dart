import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:flutter/widgets.dart' show AsyncSnapshot;

import '../../utils/enum.dart';

/// Singleton FriendshipStatusService service, serves in friendship status
class FriendshipStatusService {
  // Private named constructor
  FriendshipStatusService._();

  /// Static FriendshipStatusService instance variable for singleton
  static FriendshipStatusService? _friendshipStatusService;

  /// Static getter to get a singleton instance of FriendshipStatusService
  static FriendshipStatusService get instance => _friendshipStatusService ??= FriendshipStatusService._();

  /* -------------------------------------------------------------------------- */
  /*                                 MAIN API'S                                 */
  /* -------------------------------------------------------------------------- */

  /// Invoke to get friendship status of [me] and [other] via [friendshipSnapshot]
  FriendshipStatus getFriendshipStatus({
    required AsyncSnapshot<QuerySnapshot<Object?>> friendshipSnapshot,
    required String me,
    required String other,
  }) {
    // if friendShip doc is empty, means no friendship yet
    if (friendshipSnapshot.data!.docs.isEmpty) {
      return FriendshipStatus.addFriend;
    }

    /// calling getFriendshipStatusFromMap to get friendship status form map
    return getFriendshipStatusFromMap(
      friendshipMap: friendshipSnapshot.data!.docs[0].data() as Map<String, dynamic>,
      me: me,
      other: other,
    );
  }

  /// Invoke to get friendship status of [me] and [other] via [friendshipMap]
  FriendshipStatus getFriendshipStatusFromMap({
    required Map<String, dynamic> friendshipMap,
    required String me,
    required String other,
  }) {
    // helper bool variables
    final meAsReceiver = friendshipMap['Recieveruid'] == me;
    final meAsSender = friendshipMap['senderUid'] == me;
    final otherAsSender = friendshipMap['senderUid'] == other;
    final otherAsReceiver = friendshipMap['Recieveruid'] == other;
    final friendshipAccepted = friendshipMap['isaccepted'];

    // if I am receiver or sender OR the other person is sender or receiver and isaccepted is true, means we are friends
    if (((meAsReceiver && otherAsSender) || (otherAsReceiver && meAsSender)) && friendshipAccepted) {
      return FriendshipStatus.unFriend;
    }

    // if I am the receiver and other person is friend request sender and isaccepted is false, i have to accept request
    if (meAsReceiver && otherAsSender && !friendshipAccepted) {
      return FriendshipStatus.acceptRequest;
    }

    // if I am the sender and other person is friend request receiver and isaccepted is false, friend request sent
    if (otherAsReceiver && meAsSender && !friendshipAccepted) {
      return FriendshipStatus.requestSent;
    }

    return FriendshipStatus.addFriend;
  }
}
