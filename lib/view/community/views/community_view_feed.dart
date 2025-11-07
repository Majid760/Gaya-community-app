import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/skeleton.post.component.dart';
import '../../../model/community.model.dart';
import '../../../model/create.post.model.dart';
import '../../../utils/enum.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/refresh_builder_utils.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';
import '../../feed/view/community_user_feed/controller/home_feed_user_communities_controller.dart';
import '../components/community_feed_post_tile.dart';
import '../components/no_posts.dart';
import '../controllers/community_feed_controller.dart';

/// [Replacement of group discussion widget] - Inside a group view.dart
class CommunityFeedView extends StatelessWidget {
  final Community communityModel;
  final CommunityFeedController controller;

  const CommunityFeedView({Key? key, required this.communityModel, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: GetBuilder<CommunityFeedController>(
          init: CommunityFeedController.to(tag: communityModel.communityId),
          tag: communityModel.communityId,
          autoRemove: false,
          builder: (controller) {
            return EasyRefresh.builder(
              simultaneously: true,
              controller: controller.refreshController,
              header: const CupertinoHeader(
                position: IndicatorPosition.locator,
                userWaterDrop: false,
                safeArea: true,
                triggerOffset: 40,
                hapticFeedback: true,
                emptyWidget: SizedBox(),
              ),
              footer: RefreshBuilderUtils.footer,
              onRefresh: () async {
                await controller.resetController(context: context, communityModel: communityModel);
                return IndicatorResult.success;
              },
              onLoad: !controller.isFeedEmpty
                  ? () async {
                      final isFetched = await controller.requestMoreData(topic: controller.selectedTopic);
                      if (!isFetched) {
                        controller.refreshController.finishLoad(IndicatorResult.noMore);
                      } else {
                        controller.refreshController.finishLoad(IndicatorResult.success);
                      }
                    }
                  : null,
              childBuilder: (context, physics) {
                if (controller.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0).r,
                    child: ListView(physics: const NeverScrollableScrollPhysics(), children: const [
                      PostsSkeleton(showTopDivider: false),
                      PostsSkeleton(),
                      PostsSkeleton(),
                    ]),
                  );
                }
                if (controller.isFeedEmpty) {
                  return FutureBuilder<Community?>(
                      future: controller.fetchCommunityFromServer(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0).r,
                            child: ListView(
                              physics: physics,
                              children: [
                                NoPostsWidget(
                                  community: snapshot.data?.communityId == null ? communityModel : snapshot.data!,
                                  postCreationFrom: PostCreationFrom.Community,
                                ),
                              ],
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator.adaptive());
                      });
                }
                return CustomScrollView(
                  physics: physics,
                  slivers: [
                    const HeaderLocator.sliver(),
                    SliverToBoxAdapter(
                      child: ListView.separated(
                          shrinkWrap: true,
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          separatorBuilder: (ctx, index) => Container(color: AppColors.divider, height: 6.h),
                          itemCount: controller.posts.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            Post postModel = controller.posts[index];
                            // postModel.community = communityModel;

                            return CommunityFeedPostTile(postModel: postModel, controller: controller, community: communityModel);
                          }),
                    ),
                    const FooterLocator.sliver(),
                  ],
                );
              },
            );
          }),
    );
  }
}

/// [Replacement of group discussion widget] - Specifically designed for HOME FEED
class CommunityFeedViewV2 extends StatelessWidget {
  final HomeFeedUserCommunities homeUserController;

  // final Community communityModel;
  const CommunityFeedViewV2({Key? key, required this.homeUserController}) : super(key: key);

  // const CommunityFeedViewV2({Key? key, required this.communityModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeUserCommunities = homeUserController;
    separator(ctx, index) => Container(color: AppColors.divider, height: 6.h);
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Obx(() {
        if (homeUserCommunities.isLoading.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        final communityModel = homeUserCommunities.selectedCommunity;
        return GetBuilder<CommunityFeedController>(
            init:
                CommunityFeedController(communityId: communityModel.communityId ?? "", community: communityModel, shouldHaveSeenPost: true),
            tag: communityModel.communityId,
            autoRemove: false,
            builder: (controller) {
              return EasyRefresh.builder(
                simultaneously: true,
                controller: controller.refreshController,
                header: const CupertinoHeader(
                  position: IndicatorPosition.locator,
                  userWaterDrop: false,
                  safeArea: true,
                  triggerOffset: 40,
                  hapticFeedback: true,
                  emptyWidget: SizedBox(),
                ),
                footer: RefreshBuilderUtils.footer,
                onRefresh: () async {
                  await controller.resetV2Controller(context: context, communityModel: communityModel);
                  return IndicatorResult.success;
                },
                onLoad: !controller.isFeedEmpty
                    ? () async {
                        final isFetched = await controller.requestMoreData(topic: controller.selectedTopic);

                        if (!isFetched) {
                          controller.refreshController.finishLoad(IndicatorResult.noMore);
                        } else {
                          controller.refreshController.finishLoad(IndicatorResult.success);
                        }
                      }
                    : null,
                childBuilder: (context, physics) {
                  if (controller.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0).r,
                      child: ListView(physics: const NeverScrollableScrollPhysics(), children: const [
                        PostsSkeleton(showTopDivider: false),
                        PostsSkeleton(),
                        PostsSkeleton(),
                      ]),
                    );
                  }
                  if (controller.isFeedEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0).r,
                      child: Center(
                        child: NoPostsWidget(
                          community: communityModel,
                          postCreationFrom: PostCreationFrom.FeedDetail,
                        ),
                      ),
                    );
                  }

                  final shouldHaveSeenSeenSeparator = controller.newPostsList.isNotEmpty && controller.oldPosts.isNotEmpty;
                  return CustomScrollView(
                    physics: physics,
                    slivers: [
                      const HeaderLocator.sliver(),
                      SliverToBoxAdapter(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (shouldHaveSeenSeenSeparator)
                              _PostSeparator(title: "${GayaStrings.new_posts_in.tr} ${communityModel.communityName}"),
                            if (controller.newPostsList.isNotEmpty)
                              ListView.separated(
                                shrinkWrap: true,
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                separatorBuilder: separator,
                                itemCount: controller.newPostsList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (ctx, index) {
                                  Post postModel = controller.newPostsList[index];
                                  postModel.community = communityModel;

                                  return HomeCommunityFeedPostTile(
                                    postModel: postModel,
                                    controller: controller,
                                    community: communityModel,
                                  );
                                },
                              ),
                            if (shouldHaveSeenSeenSeparator) _PostSeparator(title: GayaStrings.old_posts.tr),
                            if (controller.oldPosts.isNotEmpty)
                              ListView.separated(
                                shrinkWrap: true,
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                separatorBuilder: separator,
                                itemCount: controller.oldPosts.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (ctx, index) {
                                  Post postModel = controller.oldPosts[index];
                                  postModel.community = communityModel;
                                  return HomeCommunityFeedPostTile(postModel: postModel, controller: controller, community: communityModel);
                                },
                              ),
                          ],
                        ),
                      ),
                      const FooterLocator.sliver(),
                    ],
                  );
                },
                // canLoadAfterNoMore: false,
              );
            });
      }),
    );
  }
}

class _PostSeparator extends StatelessWidget {
  final String title;

  const _PostSeparator({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(bottom: 4, left: 10, top: 12, right: 10).r,
      color: AppColors.divider,
      child: Text(
        title,
        style: CustomTypography.postCaptionStyle.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
