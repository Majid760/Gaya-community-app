import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/services/services.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../../model/community.model.dart';

class HomeFeedUserCommunities extends GetxController {
  static HomeFeedUserCommunities get to => Get.find();

  static bool get isRegistered => Get.isRegistered<HomeFeedUserCommunities>();
  final Services _commonServices = Services.to;

  final communities = <Community>[].obs;

  RxBool isLoading = false.obs;

  /// To control scroll over loading screen, when posts are loading
  /// It will be change from [CommunityFeedController] at init state to [false].
  RxBool isCommunityLoading = true.obs;

  final scrollController = AutoScrollController(

      //choose vertical/horizontal
      axis: Axis.horizontal,
      suggestedRowHeight: 100.h);

  Rx<Community> _selectedCommunity = Community().obs;

  set selectedCommunity(Community community) {
    _selectedCommunity.value = community;
    update();
  }

  set setCommunityLoading(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isCommunityLoading.value = value;
      update();
    });
  }

  void updateSelectedCommunity(Community community) {
    // SeenUnseenPostServices.instance.setLastVisit(_selectedCommunity.value.communityId ?? "");
    _selectedCommunity.value = community;
    update();
  }

  Community get selectedCommunity => _selectedCommunity.value;

  @override
  onInit() {
    super.onInit();
    fetchCommunities();
  }

  Future<void> fetchCommunities() async {
    isLoading.value = true;
    communities.clear();
    final _communities = await _commonServices.getMyCommunitiesWithPostCount();

    if (_communities.isEmpty) {
      isLoading.value = false;
      return;
    }
    communities.addAll(_communities);
    selectedCommunity = communities.first;
    communities.sort((a, b) => (b.totalUnseenPosts ?? 0).compareTo(a.totalUnseenPosts ?? 0));
    isLoading.value = false;
  }

  void updateCount(Community community) {
    final _index = communities.indexWhere((element) => element.communityId == community.communityId);

    communities[_index] = community;
  }

  int indexOf(Community community) {
    return communities.indexWhere((element) => element.communityId == community.communityId);
  }

  void addCommunity(Community community) {
    communities.insert(0, community);
  }

  void removeCommunity(Community community) {
    communities.removeWhere((element) => element.communityId == community.communityId);
    isLoading.value = false;
  }

  void updateCommunityLastVisitTimeForUser(Community community) {
    if (community.communityId == null) return;
    _commonServices.updateCommunityLastVisitTimeForUser(community.communityId ?? "");
  }
}
