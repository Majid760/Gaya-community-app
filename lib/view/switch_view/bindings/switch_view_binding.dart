import 'package:flutter/material.dart';
import 'package:gaya/view/ai_daily_user_matches/controller/ai_matches_controller.dart';
import 'package:get/get.dart';

import '../../feed/controller/feeds_view_controller.dart';
import '../../feed/controller/for_you_controller.dart';
import '../../feed/view/community_user_feed/controller/home_feed_user_communities_controller.dart';
import '../controllers/switch_view_controller.dart';

/// SwitchViewBindings class for injecting dependencies
class SwitchViewBindings extends Bindings {
  /// SwitchViewBindings constructor
  SwitchViewBindings({this.initialIndex = 0, this.context});

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  int initialIndex;
  final BuildContext? context;

  /* ----------------------------- LIFECYCLE API'S ---------------------------- */
  @override
  void dependencies() {
    final arguments = Get.arguments;
    if (arguments != null) {
      initialIndex = arguments['initialIndex'];
    }
    Get.lazyPut<SwitchViewController>(() => SwitchViewController(initialIndex: initialIndex, context: context));
    Get.lazyPut<ForYouFeedController>(() => ForYouFeedController(), fenix: true);
    Get.lazyPut<FeedPageViewController>(() => FeedPageViewController(), fenix: true);
    Get.lazyPut<AIMatchesController>(() => AIMatchesController(), fenix: true);
    Get.lazyPut(() => HomeFeedUserCommunities(), fenix: true);
  }
}
