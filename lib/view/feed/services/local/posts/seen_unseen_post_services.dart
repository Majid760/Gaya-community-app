import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' show debugPrint;

import '../../../../../utils/local.storage.dart';

/// This class is used to store the seen, lastSeen and unseen posts in the local storage
class SeenUnseenPostServices {
  // Private named constructor
  SeenUnseenPostServices._();

  static SeenUnseenPostServices? _unseenPostServices;

  static SeenUnseenPostServices get instance => _unseenPostServices ??= SeenUnseenPostServices._();

  final String lastVisitKeyPrefix = 'last_visit_${FirebaseAuth.instance.currentUser?.uid}_}';

  // Function to set the timestamp of the last visit to a group
  Future<void> setLastVisit(String groupId) async =>
      await GetStorageController.to.write(key: lastVisitKeyPrefix + groupId, value: DateTime.now().millisecondsSinceEpoch);

  Future<DateTime?> getLastVisit(String groupId) async {
    final lastVisitTimestamp = await GetStorageController.to.read(lastVisitKeyPrefix + groupId);

    if (lastVisitTimestamp == null) {
      return DateTime.now();
    }

    return DateTime.fromMillisecondsSinceEpoch(lastVisitTimestamp);
  }

  // Function to check if a post is seen based on the last visit timestamp
  Future<bool> isPostSeen(String groupId, DateTime postTimestamp) async {
    DateTime? lastVisitTimestamp = await getLastVisit(groupId);

    if (lastVisitTimestamp == null) {
      return false;
    }

    return postTimestamp.isBefore(lastVisitTimestamp);
  }

  // Function to set the last visit timestamp of multiple groups
  Future<void> setLastVisits(List<String?> groupIds) async {
    debugPrint('setLastVisits called');
    for (String? groupId in groupIds) {
      await setLastVisit(groupId ?? '');
    }
  }
}
