import 'package:flutter/cupertino.dart';
import 'package:gaya/utils/language/translation.dart';

import '../../../../utils/const.dart';
import '../controllers/community_analytics_controller.dart';
import 'package:get/get.dart';
import 'timeline_tab_bar_title.dart';

class TimelineTabBar extends StatelessWidget {
  const TimelineTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*     main get builder widget [GetBuilder<CommunityAnalyticsController>]     */
    /* -------------------------------------------------------------------------- */
    return GetBuilder<CommunityAnalyticsController>(
      builder: (communityAnalyticsController) {
        return Container(
          padding: const EdgeInsets.only(
            left: distance_20,
            right: distance_20,
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            backgroundColor: kBaseGrey.withOpacity(0.5),
            thumbColor: kprimaryColor,
            padding: const EdgeInsets.all(4),
            groupValue: communityAnalyticsController.tabIndex,
            children: {
              /* ------------------- day bar title [TimelineTabBarTitle] ------------------ */
              0: TimelineTabBarTitle(
                selected: communityAnalyticsController.tabIndex == 0,
                text: GayaStrings.day.tr,
              ),
              /* ------------------ week bar title [TimelineTabBarTitle] ------------------ */
              1: TimelineTabBarTitle(
                selected: communityAnalyticsController.tabIndex == 1,
                text: GayaStrings.week.tr,
              ),
              /* ------------------ month bar title [TimelineTabBarTitle] ----------------- */
              2: TimelineTabBarTitle(
                selected: communityAnalyticsController.tabIndex == 2,
                text: GayaStrings.month.tr,
              ),
              /* ------------------ year bar title [TimelineTabBarTitle] ------------------ */
              3: TimelineTabBarTitle(
                selected: communityAnalyticsController.tabIndex == 3,
                text: GayaStrings.year.tr,
              ),
            },
            onValueChanged:
                communityAnalyticsController.changeTimelineTabBarTab,
          ),
        );
      },
    );
  }
}
