import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:gaya/view/community/communities_archive/services/archive_services.dart';

import '../../../../controller/app_config_controller.dart';
import '../../../../model/community.model.dart';
import '../../../chat/controllers/base_controller.dart';

class ArchiveController extends BaseController {
  /// List of Archived Communities
  List<Community> communities = [];

  final CommunityArchiveServices _communityArchiveServices = CommunityArchiveServices();
  final EasyRefreshController refreshController = EasyRefreshController();

  @override
  void onInit() {
    super.onInit();
    fetchCommunities();
  }

  Future<void> fetchCommunities() async {
    setLoading(true);
    _communityArchiveServices.reset();
    communities = await _communityArchiveServices.requestMore();
    setLoading(false);
  }

  Future<bool> loadMore() async {
    debugPrint("onLoadMore");
    bool isHavingMore = false;
    final _moreCommunities = await _communityArchiveServices.requestMore();

    /// if empty, return false
    if (_moreCommunities.isEmpty) return isHavingMore;

    /// if not empty, add to the list
    communities.addAll(_moreCommunities);

    update();

    /// if not empty, return true
    return !isHavingMore;
  }

  Future<void> onRefresh() async {
    debugPrint("onRefresh");

    await fetchCommunities();
  }

  void hideACommunity({required String id}) {
    debugPrint("hideACommunity");
    AppConfigurationController.to.hideOrUnHideCommunity(communityId: id);
    communities.removeWhere((element) => element.communityId == id);
    update();
  }

  bool get isEmpty => communities.isEmpty;
}
