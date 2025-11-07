import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/skeleton.post.component.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/ai_daily_user_matches/controller/ai_matches_controller.dart';
import 'package:gaya/view/ai_daily_user_matches/view/widgets/expandable_tile_widget.dart';
import 'package:gaya/view/feed/controller/for_you_controller.dart';
import 'package:gaya/view/feed/view/community_user_feed/controller/home_feed_user_communities_controller.dart';
import 'package:gaya/view/feed/view/community_user_feed/widgets/home_cmmunities_widget_builder.dart';
import 'package:gaya/view/feed/view/community_user_feed/widgets/user_communities_empty.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:get/get.dart';
import '../../../../utils/asset_images.dart';
import '../../../../utils/const.dart';
import '../../../../utils/refresh_builder_utils.dart';
import '../../../../utils/theme/app_typography.dart';
import '../../components/post_tile.dart';
import '../../components/suggested_communities_section.dart';
import '../../controller/feeds_view_controller.dart';
import '../community_user_feed/widgets/explore_more_communities_bottom_sheet.dart';

class FeedsView extends StatelessWidget {
  const FeedsView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).scaffoldBackgroundColor;
    return GetBuilder<FeedPageViewController>(
      init: Get.find<FeedPageViewController>(),
      builder: (pageController) {
        return ExtendedNestedScrollView(
          controller: pageController.scrollController,
          onlyOneScrollInBody: true,
          headerSliverBuilder: (context, _) {
            return [
              /// Round Communities
              SliverAppBar(
                backgroundColor: color,
                floating: true,
                pinned: true,
                toolbarHeight: 100,
                elevation: 0,
                title: const MyCommunitiesUserFeed(isHomeFeed: true),
              ),

              /// AI Match Bar.
              GetBuilder<AIMatchesController>(
                  init: AIMatchesController.to,
                  builder: (matchController) {
                    return SliverAppBar(
                      toolbarHeight: matchController.isExpanded ? 335.h : 66.h,
                      backgroundColor: AppColors.divider,
                      floating: false,
                      pinned: false,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Container(color: AppColors.divider, height: 6.h),
                            const ExpandableTile(),
                            Container(color: AppColors.divider, height: 6.h),
                          ],
                        ),
                      ),
                      //flexibleSpace: const FlexibleSpaceBar(background: CrownTotalCountHomeWidget()),
                    );
                  })
            ];
          },
          body: const ForYouFeedWidget(),
        );
      },
    );
  }
}

/// A Widget that is on home feed with ciruclar communtiy
class MyCommunitiesUserFeed extends StatelessWidget {
  final bool isHomeFeed;

  const MyCommunitiesUserFeed({Key? key, required this.isHomeFeed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = HomeFeedUserCommunities.to;
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 93.h,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                6,
                (index) {
                  return const CircleCommunitySkeleton();
                },
              )),
        );
      }
      if (controller.communities.value.isEmpty) {
        return const UserNoCommunities();
      }
      return SizedBox(
        height: 93.h,
        child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemCount: controller.communities.value.length,
            itemBuilder: (context, index) {
              final community = controller.communities.value[index];
              return Row(
                children: [
                  MyCommunitiesFeedWidget(community: community, isHomeFeed: isHomeFeed),
                  if (index == controller.communities.value.length - 1)
                    GestureDetector(
                      onTap: () {
                        exploreMoreCommunitiesBottomSheet(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10).r,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: 56.r,
                                height: 56.r,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: SvgIcons.plusOutline(),
                              ),
                            ),
                            SizedBox(
                              width: 65.r,
                              child: Text(
                                GayaStrings.explore_new.tr,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GayaTypography.body2.copyWith(fontSize: 12, height: 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              );
            }),
      );
    });
  }
}

class ForYouFeedWidget extends StatelessWidget {
  const ForYouFeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final header = RefreshBuilderUtils.header;
    final footer = RefreshBuilderUtils.footer;
    final loadingSkeleton = SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: distance_16).r,
      sliver: const SliverToBoxAdapter(
        child: Column(
          children: [
            PostsSkeleton(isTextOnly: true),
            PostsSkeleton(),
            PostsSkeleton(),
          ],
        ),
      ),
    );

    return GetBuilder<ForYouFeedController>(
        init: Get.find<ForYouFeedController>(),
        autoRemove: false,
        builder: (controller) {
          return EasyRefresh(
            header: header,
            onRefresh: () async {
              controller.resetController();
              HomeFeedUserCommunities.to.fetchCommunities();
            },
            onLoad: controller.posts.isEmpty
                ? null
                : () async {
                    await controller.requestMoreData();
                    return IndicatorMode.processing;
                  },
            footer: footer,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const HeaderLocator.sliver(),
                controller.isLoading
                    ? loadingSkeleton
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Column(
                            children: [
                              if (controller.shouldShowSuggestedCommunities(index))
                                SuggestedCommunitiesSection(suggestedCommunities: controller.suggestedCommunities)
                              else
                                controller.featureCard(index),
                              if (index != 0) Container(color: AppColors.divider, height: 6.h),
                              PostTile(postModel: controller.posts[index]),
                            ],
                          );
                        }, childCount: controller.posts.length),
                      ),
                const FooterLocator.sliver(),
              ],
            ),
          );
        });
  }
}

@Deprecated('Use [MyCommunitiesUserFeed] instead')
class TabBarWidget extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabTap;

  const TabBarWidget({Key? key, required this.tabController, required this.onTabTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorSize: TabBarIndicatorSize.tab,
      controller: tabController,
      indicatorWeight: 3,
      unselectedLabelColor: kSecondaryColor,
      overlayColor: MaterialStateProperty.all<Color>(kTransparentColor),
      unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
      indicatorColor: kprimaryColor,
      labelPadding: const EdgeInsets.only(bottom: 12),
      labelColor: kBlackColor,
      labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: kBlackColor),
      onTap: onTabTap,
      tabs: [
        Text(GayaStrings.home_txt.tr, style: GayaTypography.titleMedium),
        Text((GayaStrings.my_communities.tr).capitalize ?? "", style: GayaTypography.titleMedium),
      ],
    );
  }
}
