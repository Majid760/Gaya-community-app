import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CommunityAnalyticsFirestoreService extends GetxService {
  /// static getter to get instance of CommunityAnalyticsFirestoreService
  static CommunityAnalyticsFirestoreService get instance => Get.find();

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  late final FirebaseFirestore _firebaseFirestore;

  /* -------------------------------------------------------------------------- */
  /*                                 MAIN API'S                                 */
  /* -------------------------------------------------------------------------- */

  /// invoke to query for community members of [communityId] added from
  /// [startingTime] to [endingTime]
  Future<QuerySnapshot<Map<String, dynamic>>> getCommunityMembersViaTime({
    required String communityId,
    required DateTime startingTime,
    required DateTime endingTime,
  }) async =>
      _firebaseFirestore
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .orderBy('createdOn')
          .startAt([startingTime]).endAt([endingTime]).get();

  /// invoke to query for community members posts of [communityId] added from
  /// [startingTime] to [endingTime]
  Future<QuerySnapshot<Map<String, dynamic>>> getCommunityPostsViaTime({
    required String communityId,
    required DateTime startingTime,
    required DateTime endingTime,
  }) async =>
      _firebaseFirestore
          .collection('communityposts')
          .where("communityId", isEqualTo: communityId)
          .orderBy('createdOn')
          .startAt([startingTime]).endAt([endingTime]).get();

  /* -------------------------------------------------------------------------- */
  /*                               LIFECYCLE API'S                              */
  /* -------------------------------------------------------------------------- */
  @override
  onInit() {
    super.onInit();
    _firebaseFirestore = FirebaseFirestore.instance;
  }
}
