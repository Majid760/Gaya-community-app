import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedPageViewController extends GetxController {
  // late TabController _tabController;

  // @override
  // void onInit() {
  //   super.onInit();
  //   // _tabController = TabController(length: 2, vsync: this);
  // }

  // int currentIndex = 0;
  // TabController get tabController => _tabController;

  final scrollController = ScrollController();

  void scrollToTop() {
    try {
      if (scrollController.hasClients == false) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.bounceIn,
        );
      });
    } catch (_) {}
  }

// onTabTap(int index) {
//   currentIndex = index;
//   _tabController.animateTo(index);
//   update();
//   HapticFeedback.mediumImpact();
// }
}
