import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:get/get.dart';

import '../../../../model/community.model.dart';
import '../../../../model/user.model.dart';
import '../../../../utils/logger.dart';
import '../models/topic_communties.dart';

abstract class ICommunitiesServices {
  Future<TopicCommunities?> getCommunityByTopic({required String topic});

  Future<List<Community>> getHotCommunities();

  Future<List<Community>> getNewCommunities();

  Future<List<Community>> getTopPrivateCommunities();
}

class CommunitiesServices implements ICommunitiesServices {
  final ref = FirebaseFirestore.instance.collection("communities");
  final _logger = MyLoggerServices.to;

  @override
  Future<List<Community>> getHotCommunities() async {
    List<Community> communities = [];
    try {
      final query = getHotCommunitiesQuery();

      final communitiesSnap = await query.get();

      for (var element in communitiesSnap.docs) {
        /// if community is hidden, then skip it
        if (AppConfigurationController.to.isHiddenCommunity(communityId: element.id)) {
          continue;
        }
        try {
          communities.add(Community.fromMap(element.data()));
        } catch (e) {
          _logger.print("Error in makingModel: $e");
        }
      }

      communities.sort((a, b) => b.communityMembers!.compareTo(a.communityMembers!));

      return communities;
    } catch (_) {
      _logger.print("Error in getHotCommunities(): $_");
    }
    return communities;
  }

  @override
  Future<List<Community>> getNewCommunities() async {
    List<Community> communities = [];
    try {
      final query = getNewCommunitiesQuery();

      final communitiesSnap = await query.get();

      for (var element in communitiesSnap.docs) {
        /// if community is hidden, then skip it
        if (AppConfigurationController.to.isHiddenCommunity(communityId: element.id)) {
          continue;
        }
        try {
          communities.add(Community.fromMap(element.data()));
        } catch (e) {
          _logger.print("Error in makingModel: $e");
        }
      }

      communities.sort((a, b) => b.communityMembers!.compareTo(a.communityMembers!));
      return communities;
    } catch (_) {
      _logger.print("Error in getHotCommunities(): $_");
    }
    return communities;
  }

  @override
  Future<List<Community>> getTopPrivateCommunities() async {
    List<Community> communities = [];
    try {
      final query = getTopPrivateCommunitiesQuery();

      final communitiesSnap = await query.get();

      for (var element in communitiesSnap.docs) {
        /// if community is hidden, then skip it
        if (AppConfigurationController.to.isHiddenCommunity(communityId: element.id)) {
          continue;
        }
        try {
          communities.add(Community.fromMap(element.data()));
        } catch (e) {
          _logger.print("Error in makingModel: $e");
        }
      }

      communities.sort((a, b) => b.communityMembers!.compareTo(a.communityMembers!));
      return communities;
    } catch (_) {
      _logger.print("Error in getTopPrivateCommunities(): $_");
    }
    return communities;
  }

  @override
  Future<TopicCommunities?> getCommunityByTopic({required String? topic, int? limit}) async {
    if (topic.isBlank == true || topic == null) return null;
    try {
      List<Community> communities = [];

      /// make a query to get communities with that topic
      final query = getCommunitiesByTopic(topic);

      /// If limit is not null, then limit the query
      if (limit != null) query.limit(limit);

      /// Get the snapshot of the query
      final communitiesSnap = await query.get();

      // communitiesSnap.docs.removeWhere((element) => AppConfigurationController.to.isHiddenCommunity(communityId: element.id));

      /// iterate over the snapshot and make a model for each community
      for (var element in communitiesSnap.docs) {
        try {
          final community = Community.fromMap(element.data());
          if (AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? "")) continue;
          communities.add(community);
        } catch (e) {
          _logger.print("Error in makingModel: $e");
        }
      }

      /// The most popular community will be on top
      /// `!` because in model default value is 0 for communityMembers
      communities.sort((a, b) => b.communityMembers!.compareTo(a.communityMembers!));

      return TopicCommunities(topicName: topic, communities: communities);
    } catch (_) {
      _logger.print("Error in getCommunityByTopic(): $_");
    }
    return null;
  }

  Future<List<Community>> getExploreMoreCommunities() async {
    
    final joinedCommunities = await AppConfigurationController.to.joinedCommunities.map((e) => e.communityId).toList();
    List<Community> communities = [];

    final userId = UserModel.to.uId;
    if (userId.isBlank == true) return communities;

    /// fetch the communities that are not joined by the user
    /// and are not hidden
    final rawCommunities = getExploreMoreHotCommunitiesQuery(limit: joinedCommunities.length + 7).get();

    final communitiesSnap = await rawCommunities;

    for (var element in communitiesSnap.docs) {
      print(element.data());
      try {
        final community = Community.fromMap(element.data());
        if (joinedCommunities.contains(community.communityId)) continue;
        if (AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? "")) continue;

        communities.add(community);
      } catch (e) {
        _logger.print("Error in makingModel: $e");
      }
    }

    communities = communities.length > 7 ? communities.sublist(0, 7) : communities;
    return communities;
  }

  Future<List<Community>> getCommunityByTopiclist(String topic, {int? limit}) async{
    
    try{
        if (topic.isBlank == true || topic==""){
     return getExploreMoreCommunities();
    }
    final rawCommunitiesList = await getCommunitiesByTopic(topic, limit:limit).get();
    List<Community> communities = [];
    for (var element in rawCommunitiesList.docs) {
      try {
        final community = Community.fromMap(element.data());
        if (AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? "")) continue;
        communities.add(community);
      } catch (e) {
        _logger.print("Error in makingModel: $e");
      }
    }
    return communities;
    }catch(_){
    print("Error at getCommunityByTopiclist $_ ");
    }
  
  return [];
  }


}


///
/// Extension for Communities Queries
///
extension Queries on CommunitiesServices {
  Query<Map<String, dynamic>> getCommunitiesByTopic(String topic, {int? limit}) {
   final query = ref
    .where('type', isNotEqualTo: 'Secret')
    .where('topics.topicName', isEqualTo: topic)
    .where('isArchived', isEqualTo: false)
    .orderBy('type', descending: true)
    .orderBy('score', descending: true);

    if(limit != null) return query.limit(limit);

   
    return query;
  }

  Query<Map<String, dynamic>> getHotCommunitiesQuery() {
    return ref
        .where(Filter.and(
          Filter.or(
            Filter('type', isEqualTo: 'Public'),
            Filter('type', isEqualTo: 'Private'),
          ),
          Filter('isArchived', isEqualTo: false),
        ))
        .orderBy('score', descending: true)
        .limit(8);
  }

  Query<Map<String, dynamic>> getExploreMoreHotCommunitiesQuery({int limit = 7}) {
    return ref
        .where(
          Filter.and(
            Filter.or(
              Filter('type', isEqualTo: 'Public'),
              Filter('type', isEqualTo: 'Private'),
            ),
            Filter('isArchived', isEqualTo: false),
          ),
        )
        .orderBy('totalmembers', descending: true)
        .limit(limit);
  }

  Query<Map<String, dynamic>> getNewCommunitiesQuery() {
    return ref
        .where(
          Filter.and(
            Filter.or(
              Filter('type', isEqualTo: 'Public'),
              Filter('type', isEqualTo: 'Private'),
            ),
            Filter('isArchived', isEqualTo: false),
          ),
        )
        .orderBy('createdOn', descending: true)
        .limit(8);
  }

  Query<Map<String, dynamic>> getTopPrivateCommunitiesQuery() {
    return ref
        .where(
          Filter.and(
            Filter('type', isEqualTo: 'Private'),
            Filter('isArchived', isEqualTo: false),
          ),
        )
        .orderBy('score', descending: true)
        .limit(10);
    // return ref.where("type", isEqualTo: "Private").orderBy('score', descending: true).limit(10);
  }

  Query<Map<String, dynamic>> getArchivedCommunitiesQuery() {
    return ref.where("isArchived", isEqualTo: true);
  }
}
