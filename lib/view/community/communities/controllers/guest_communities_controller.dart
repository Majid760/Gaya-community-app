import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/community/communities/models/topic_communties.dart';
import 'package:gaya/view/community/communities/services/communities_services.dart';
import 'package:get/get.dart';

import '../../../../model/topic.model.dart';
import '../../controllers/base_controller.dart';

class GuestCommunitiesController extends BaseController {
  static GuestCommunitiesController get to => Get.find();

  static bool get isRegistered => Get.isRegistered<GuestCommunitiesController>();

  @override
  void onInit() {
    super.onInit();
    getCommunities();
  }

  final _logger = MyLoggerServices.to;
  final _communitiesServices = CommunitiesServices();

  final List<TopicCommunities> _communities = [];

  List<TopicCommunities> get communities => _communities;

  /// topics that are not in guest user's interest == recommended topics, fetch it
  /// and add them to [_communities]
  /// then update the UI
  Future<void> getCommunities() async {
    setLoading(true);
    for (int i = 0; i < topics.length; i++) {
      final communities = await _communitiesServices.getCommunityByTopic(topic: topics[i], limit: 8);
      if (communities != null && communities.communities.isNotEmpty) {
        _communities.add(communities);
        setLoading(false);
      }
    }
  }

  Future<void> onRefreshPull() async {
    _communities.clear();
    await getCommunities();
  }

  ///  returns topics that are not in guest user's interest
  List<String> get topics {
    final userTopics = UserModel.to.interests?.map((e) => e.title ?? "").toList() ?? [];
    final grandTopics = topicsList.map((e) => e.title).toList();
    final topics = grandTopics.where((element) => !userTopics.contains(element)).toList();
    return topics;
  }

  /// Returns true if user has interests
  bool get isInterestsAvailable => UserModel.to.interests?.isNotEmpty ?? false;

  /// perform as locally because
  /// already handling at parent controller
  void hideOrUnHideACommunity({required String id, bool isUnHide = false}) {
    if (isUnHide) {
      // /// refresh the list
      // onRefreshPull();
    } else {

       for (var element in _communities) {
        element.communities.removeWhere((element) => element.communityId == id);
      }
    }
    update();
  }
}
