import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/community/communities/services/communities_services.dart';
import 'package:get/get.dart';

import '../../../../model/community.model.dart';
import '../../controllers/base_controller.dart';

class TopPrivateCommunitiesController extends BaseController {
  static TopPrivateCommunitiesController get to => Get.find();

  static bool get isRegistered => Get.isRegistered<TopPrivateCommunitiesController>();

  @override
  void onInit() {
    super.onInit();
    getCommunities();
  }

  final _logger = MyLoggerServices.to;
  final _communitiesServices = CommunitiesServices();

  List<Community> _communities = [];

  List<Community> get communities => _communities;

  /// topics that are not in guest user's interest == recommended topics, fetch it
  /// and add them to [_communities]
  /// then update the UI
  Future<void> getCommunities() async {
    setLoading(true);
    final communities = await _communitiesServices.getTopPrivateCommunities();
    if (communities.isNotEmpty) {
      _communities = communities;
      setLoading(false);
    }

    if (_communities.isEmpty) {
      setLoading(false);
    }
  }

  Future<void> onRefreshPull() async {
    _communities.clear();
    await getCommunities();
  }

  /// perform as locally because
  /// already handling at parent controller
  void hideOrUnHideACommunity({required String id, bool isUnHide = false}) {
    if (isUnHide) {
      // /// refresh the list
      // onRefreshPull();
    } else {
      // /// remove the community from the list
      _communities.removeWhere((element) => element.communityId == id);
    }
    update();
  }

  Query<Map<String, dynamic>> get getTopPrivateCommunities => _communitiesServices.getTopPrivateCommunitiesQuery();
}
