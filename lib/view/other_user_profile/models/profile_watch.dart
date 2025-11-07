import 'package:flutter/foundation.dart' show immutable;

@immutable

/// Data class for profile viewed stuff
class ProfileWatch {
  const ProfileWatch({
    required this.userWhoViewedProfileId,
    required this.userWhoseProfileViewedId,
    required this.visitedTime,
  });

  final String userWhoViewedProfileId;
  final String userWhoseProfileViewedId;
  final DateTime visitedTime;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userWhoViewedProfileId': userWhoViewedProfileId,
      'userWhoseProfileViewedId': userWhoseProfileViewedId,
      'visitedTime': visitedTime.millisecondsSinceEpoch,
    };
  }

  factory ProfileWatch.fromMap(Map<String, dynamic> map) {
    return ProfileWatch(
      userWhoViewedProfileId: map['userWhoViewedProfileId'] as String,
      userWhoseProfileViewedId: map['userWhoseProfileViewedId'] as String,
      visitedTime: DateTime.fromMillisecondsSinceEpoch(map['visitedTime'] as int),
    );
  }
}
