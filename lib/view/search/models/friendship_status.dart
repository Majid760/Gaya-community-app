// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart' show immutable;

import '../../../shared/service/friendship_status_service.dart';
import '../../../utils/enum.dart';

@immutable
class FriendshipStatusModel {
  const FriendshipStatusModel({
    required this.friendshipDocId,
    required this.senderUId,
    required this.receiverUid,
    required this.meAsSender,
    required this.friendshipStatus,
  });

  /// Friendship doc id on firestore
  final String friendshipDocId;

  /// friend request sender user id
  final String senderUId;

  /// friend request receiver uer id
  final String receiverUid;

  /// whether I am the friend request sender
  final bool meAsSender;

  /// our friendship status
  final FriendshipStatus friendshipStatus;

  factory FriendshipStatusModel.fromMap(
    Map<String, dynamic> map,
    String myUid,
    String friendshipDocId,
  ) {
    String senderUid = map['senderUid'] as String;
    String receiverUid = map['Recieveruid'] as String;
    bool meAsSender = map['senderUid'] as String == myUid;
    return FriendshipStatusModel(
      friendshipDocId: friendshipDocId,
      senderUId: senderUid,
      receiverUid: receiverUid,
      meAsSender: meAsSender,
      friendshipStatus: FriendshipStatusService.instance.getFriendshipStatusFromMap(
        friendshipMap: map,
        me: meAsSender ? senderUid : receiverUid,
        other: meAsSender ? receiverUid : senderUid,
      ),
    );
  }

  FriendshipStatusModel copyWith({
    String? friendshipDocId,
    String? senderUId,
    String? receiverUid,
    bool? meAsSender,
    FriendshipStatus? friendshipStatus,
  }) {
    return FriendshipStatusModel(
      friendshipDocId: friendshipDocId ?? this.friendshipDocId,
      senderUId: senderUId ?? this.senderUId,
      receiverUid: receiverUid ?? this.receiverUid,
      meAsSender: meAsSender ?? this.meAsSender,
      friendshipStatus: friendshipStatus ?? this.friendshipStatus,
    );
  }

  @override
  bool operator ==(covariant FriendshipStatusModel other) {
    if (identical(this, other)) return true;

    return other.friendshipDocId == friendshipDocId &&
        other.senderUId == senderUId &&
        other.receiverUid == receiverUid &&
        other.meAsSender == meAsSender &&
        other.friendshipStatus == friendshipStatus;
  }

  @override
  int get hashCode {
    return friendshipDocId.hashCode ^ senderUId.hashCode ^ receiverUid.hashCode ^ meAsSender.hashCode ^ friendshipStatus.hashCode;
  }
}
