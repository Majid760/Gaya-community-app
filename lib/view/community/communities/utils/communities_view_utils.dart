import 'package:gaya/view/community/communities/controllers/interest_communities_controller.dart';
import 'package:gaya/view/community/communities/controllers/recommended_communities_controller.dart';
import 'package:get/get.dart';

/// Known as GroupView, A NavBar Item of [Communities] at index 2 related Utils
class CommunitiesViewUtils {
  /// Checks [RecommendedCommunitiesController] and [InterestCommunitiesController]
  ///
  /// If they are registered, then call [hideOrUnHideACommunity] method
  static void hideOrUnHideCommunityEverywhere({required String id, bool isUnhide = false}) {
    if (Get.isRegistered<InterestCommunitiesController>()) {
      InterestCommunitiesController.to.hideOrUnHideACommunity(id: id, isUnHide: isUnhide);
    }

    if (Get.isRegistered<RecommendedCommunitiesController>()) {
      RecommendedCommunitiesController.to.hideOrUnHideACommunity(id: id, isUnHide: isUnhide);
    }
  }
}
