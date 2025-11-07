import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/refresh_builder_utils.dart';
import '../../../../utils/theme/app_spaces.dart';
import '../controllers/community_analytics_controller.dart';
import 'empty_structure.dart';
import 'tiles/comments_tile.dart';
import 'tiles/common_keywords_tile.dart';
import 'tiles/crowns_tile.dart';
import 'tiles/likes_tile.dart';
import 'tiles/members_tile.dart';
import 'tiles/posts_tile.dart';
import 'tiles/views_tile.dart';
import 'timeline_tab_bar.dart';

class CommunityAnalyticsScreenBody extends StatefulWidget {
  const CommunityAnalyticsScreenBody({
    super.key,
    required this.communityId,
  });

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final String communityId;

  @override
  State<CommunityAnalyticsScreenBody> createState() => _CommunityAnalyticsScreenBodyState();
}

class _CommunityAnalyticsScreenBodyState extends State<CommunityAnalyticsScreenBody> {
  @override
  void initState() {
    super.initState();
    // setting community id
    CommunityAnalyticsController.instance.communityId = widget.communityId;
    // invoking fetch community analytics
    CommunityAnalyticsController.instance.fetchCommunityAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                   main easy refresh widget [EasyRefresh]                   */
    /* -------------------------------------------------------------------------- */
    return EasyRefresh(
      simultaneously: true,
      // noMoreLoad: false,
      header: RefreshBuilderUtils.headerAbove,
      footer: const CupertinoFooter(
        position: IndicatorPosition.locator,
        userWaterDrop: false,
        emptyWidget: SizedBox(),
      ),
      onRefresh: () => CommunityAnalyticsController.instance.fetchCommunityAnalytics(),
      /* ------------------ parent scrolling list view [ListView] ----------------- */
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          MySpaces.gap3y,
          /* ---------------- screen tab bar for time [TimelineTabBar] ---------------- */
          const TimelineTabBar(),
          MySpaces.gap3y,
          Padding(
            padding: EdgeInsets.only(
              left: 20.0.w,
              right: 20.0.w,
              bottom: 20.0.w,
            ),
            /* --------- get builder [GetBuilder<CommunityAnalyticsController>] --------- */
            child: GetBuilder<CommunityAnalyticsController>(
              builder: (analyticsController) {
                return analyticsController.isLoading
                    ? const EmptyStructure()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                /* ------------------------ member tile [MembersTile] ----------------------- */
                                MembersTile(
                                  members: analyticsController.communityAnalytics?.members ?? 0,
                                ),
                                MySpaces.gap3y,
                                /* ------------------------- posts tile [PostsTile] ------------------------- */
                                PostsTile(
                                  posts: analyticsController.communityAnalytics?.posts ?? 0,
                                  fromTimeDuration: analyticsController.getTimeDuration(),
                                  percentage: analyticsController.communityAnalytics?.postsComparisonPercentage ?? 0.0,
                                ),
                                MySpaces.gap3y,
                                /* ------------------------ crowns tile [CrownsTile] ------------------------ */
                                CrownsTile(
                                  crowns: analyticsController.communityAnalytics?.crowns ?? 0,
                                  fromTimeDuration: analyticsController.getTimeDuration(),
                                  percentage: analyticsController.communityAnalytics?.crownsComparisonPercentage ?? 0.0,
                                ),
                                MySpaces.gap3y,
                                /* ------------------------- views tile [ViewsTile] ------------------------- */
                                ViewsTile(
                                  views: analyticsController.communityAnalytics?.views ?? 0,
                                  fromTimeDuration: analyticsController.getTimeDuration(),
                                  percentage: analyticsController.communityAnalytics?.viewsComparisonPercentage ?? 0.0,
                                ),
                                MySpaces.gap3y,
                                /* --------------- most active user tile [MostActiveUserTile] --------------- */
                                // MostActiveUserTile(
                                //   userName: analyticsController
                                //           .communityAnalytics
                                //           ?.mostActiveUser
                                //           ?.name ??
                                //       "",
                                //   profileImagePath: analyticsController
                                //           .communityAnalytics
                                //           ?.mostActiveUser
                                //           ?.profilePicture ??
                                //       '',
                                // ),
                              ],
                            ),
                          ),
                          MySpaces.gap3x,
                          Expanded(
                            child: Column(
                              children: [
                                /* ------------------------- likes tile [LikesTile] ------------------------- */
                                LikesTile(
                                  likes: analyticsController.communityAnalytics?.likes ?? 0,
                                  fromTimeDuration: analyticsController.getTimeDuration(),
                                  percentage: analyticsController.communityAnalytics?.likesComparisonPercentage ?? 0.0,
                                ),
                                MySpaces.gap3y,
                                /* ---------------- common keywords tile [CommonKeywordsTile] --------------- */
                                CommonKeywordsTile(
                                  keywords: analyticsController.communityAnalytics?.commonKeywords ?? [],
                                ),
                                MySpaces.gap3y,
                                /* ---------------------- comments tile [CommentsTile] ---------------------- */
                                CommentsTile(
                                  comments: analyticsController.communityAnalytics?.comments ?? 0,
                                  fromTimeDuration: analyticsController.getTimeDuration(),
                                  percentage: analyticsController.communityAnalytics?.commentsComparisonPercentage ?? 0.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
          MySpaces.gap3y,
        ],
      ),
    );
  }
}
