import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/community/communities/models/topic_communties.dart';
import 'package:gaya/view/community/communities/services/communities_services.dart';
import 'package:get/get.dart';

import '../../../../model/topic.model.dart';
import '../../controllers/base_controller.dart';

class RecommendedCommunitiesController extends BaseController {
  static RecommendedCommunitiesController get to => Get.find();

  static bool get isRegistered => Get.isRegistered<RecommendedCommunitiesController>();

  @override
  void onInit() {
    super.onInit();
    chunkedTopicList = chunkedTopics;
    onLoadMore();
  }

  final _logger = MyLoggerServices.to;

  int currentTopicIndex = 0;
  List<List<String>> chunkedTopicList = [];
  bool _isMoreCommunitiesAvailable = true;

  final _communitiesServices = CommunitiesServices();

  final List<TopicCommunities> _communities = [];

  List<TopicCommunities> get communities => _communities;

  /// topics that are not in user's interest == recommended topics, fetch it
  /// and add them to [_communities]
  /// then update the UI
  Future<void> getCommunities({bool shouldNotify = true}) async {
    if (shouldNotify) setLoading(true);

    /// if the index is greater than the length of the list, then
    /// we have reached the end of the list - no more communities to load
    if (currentTopicIndex >= chunkedTopicList.length) {
      setLoading(false);
      return;
    }

    for (int i = 0; i < chunkedTopicList[currentTopicIndex].length; i++) {
      final communities = await _communitiesServices.getCommunityByTopic(topic: chunkedTopicList[currentTopicIndex][i], limit: 8);
      if (communities != null && communities.communities.isNotEmpty) {
        if (!_communities.contains(communities)) {
          _communities.add(communities);
        }

        // setLoading(false);
      }
    }
    setLoading(false);
  }

  Future<void> onRefreshPull() async {
    reset();
    await getCommunities();
  }

  reset() {
    _communities.clear();
    _isMoreCommunitiesAvailable = true;
    currentTopicIndex = 0;
    chunkedTopicList = chunkedTopics;
  }

  /// returns [true] if there are more communities to load
  Future<bool> onLoadMore() async {
    /// change the topic index, so that we can get new communities
    /// from new topic list. If we reach the end of the list, then
    /// start from the beginning
    _changeChangeTopicIndex();

    /// this means that we have reached the end of the list
    if (_isMoreCommunitiesAvailable == false) return false;

    /// get communities from new topic list
    await getCommunities(shouldNotify: false);
    return true;
  }

  /// change the topic index, so that we can get new communities
  void _changeChangeTopicIndex() {
    if (currentTopicIndex < chunkedTopicList.length - 1) {
      _logger.print("currentTopicIndex: $currentTopicIndex");
      currentTopicIndex++;
    } else {
      _isMoreCommunitiesAvailable = false;
    }
  }

  ///  returns topics that are not in user's interest
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
      onRefreshPull();
    } else {
      for (var element in _communities) {
        element.communities.removeWhere((element) => element.communityId == id);
      }
    }
    update();
  }

  /// returns list of topics in chunks of 10
  List<List<String>> get chunkedTopics {
    return Methods.generateListOfChunks(topics);
  }
}
