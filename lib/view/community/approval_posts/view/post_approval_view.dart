import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/animation.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/refresh_builder_utils.dart';
import 'package:gaya/view/community/approval_posts/controller/post_approval_controller.dart';
import 'package:gaya/view/community/controllers/community_feed_controller.dart';
import 'package:get/get.dart';

import '../../../../components/skeleton.post.component.dart';
import '../../../../shared/view/widget/gaya_back_button.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/textstyles.dart';
import '../../../../utils/theme/app_spaces.dart';
import '../components/post_approval_tile.dart';

class PostApprovalView extends StatelessWidget {
  final String communityId;

  const PostApprovalView({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyLoggerServices.to.print("PrivateUserFeed built");
    final header = RefreshBuilderUtils.headerAbove;
    final footer = RefreshBuilderUtils.footerAbove;
    final skeletonList = Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_16).r,
      child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: const [PostsSkeleton(isTextOnly: true), PostsSkeleton(), PostsSkeleton()]),
    );
    const feedEmptyAnimation = [AnimationLottie()];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
        iconTheme: const IconThemeData(color: kBlackColor),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Text(GayaStrings.approve_post.tr, style: CustomTypography.bodyStyle),
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
      ),
      body: GetBuilder<PostApprovalController>(
          init: PostApprovalController(communityId: communityId),
          builder: (controller) {
            return EasyRefresh.builder(
              simultaneously: true,
              controller: controller.refreshController,
              header: header,
              footer: footer,
              onRefresh: () async => controller.onPullRefresh(),
              onLoad: controller.posts.isEmpty
                  ? () => controller.refreshController.finishLoad(IndicatorResult.noMore)
                  : () async {
                      int newPostsCount = await controller.onLoadMore();
                      if (newPostsCount == 0) {
                        controller.refreshController.finishLoad(IndicatorResult.noMore);
                      } else {
                        controller.refreshController.finishLoad(IndicatorResult.success);
                      }
                    },
              childBuilder: (context, physics) {
                if (controller.isLoading) {
                  return skeletonList;
                }
                if (controller.isFeedEmpty) {
                  return ListView(physics: physics, children: feedEmptyAnimation);
                }
                return ListView.separated(
                  separatorBuilder: (ctx, index) => Padding(
                    padding: const EdgeInsets.only(top: 8).r,
                    child: MyDividers.postFeed,
                  ),
                  itemCount: controller.posts.length,
                  physics: physics,
                  itemBuilder: (ctx, index) {
                    return ApprovalPostTile(
                      post: controller.posts[index],
                      onApprove: () async {
                        final postId = controller.posts[index].postid ?? "";
                        final authorUserId = controller.posts[index].postedBy.uId ?? "";
                        final communityId = controller.posts[index].communityId ?? "";
                        final communityName = controller.posts[index].community.communityName ?? "";
                        await controller.approvePost(
                            userId: authorUserId, postId: postId, communityId: communityId, communityName: communityName);
                        CommunityFeedController.to(tag: communityId).resetController();
                        GayaSnackBar.show(context: context, type: GayaSnackBarType.communities, text: GayaStrings.post_approved_success.tr);
                      },
                      onDecline: () async {
                        final postId = controller.posts[index].postid ?? "";
                        final authorUserId = controller.posts[index].postedBy.uId ?? "";
                        final communityId = controller.posts[index].communityId ?? "";
                        final communityName = controller.posts[index].community.communityName ?? "";
                        await controller.rejectPost(
                            userId: authorUserId, postId: postId, communityId: communityId, communityName: communityName);
                        GayaSnackBar.show(context: context, type: GayaSnackBarType.communities, text: GayaStrings.post_reject_success.tr);
                      },
                    );
                  },
                );
              },
            );
          }),
    );
  }
}
