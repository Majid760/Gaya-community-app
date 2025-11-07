import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:get/get.dart';

import '../../../../components/skeleton.post.component.dart';
import '../../../../shared/view/widget/gaya_back_button.dart';
import '../../../../utils/animation.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/refresh_builder_utils.dart';
import '../../../../utils/textstyles.dart';
import '../components/approve_user_tile.dart';
import '../controller/approve_user_controller.dart';

class ApproveUserView extends StatelessWidget {
  final String communityId;
  final String communityName;

  const ApproveUserView({Key? key, required this.communityId, required this.communityName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final header = RefreshBuilderUtils.headerAbove;
    final footer = RefreshBuilderUtils.footerAbove;
    const feedEmptyAnimation = [AnimationLottie()];
    final skeletonList = Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_16).r,
      child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: const [PostsSkeleton(isTextOnly: true), PostsSkeleton(), PostsSkeleton()]),
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        backgroundColor: kTransparentColor,
        iconTheme: const IconThemeData(color: kBlackColor),
        centerTitle: true,
        title: Text(GayaStrings.waiting_confirmation.tr, style: CustomTypography.bodyStyle),
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20).r,
        child: GetBuilder<MembershipApprovalController>(
            init: MembershipApprovalController(communityId: communityId),
            builder: (controller) {
              return EasyRefresh.builder(
                simultaneously: true,
                controller: controller.refreshController,
                header: header,
                footer: footer,
                onRefresh: () async => controller.onPullRefresh(),
                onLoad: controller.members.isEmpty
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
                  if (controller.isApprovalsEmpty) {
                    return ListView(physics: physics, children: feedEmptyAnimation);
                  }
                  return ListView.separated(
                    separatorBuilder: (ctx, index) => MyDividers.postFeed,
                    itemCount: controller.members.length,
                    physics: physics,
                    itemBuilder: (ctx, index) {
                      final member = controller.members[index];
                      return Column(
                        children: [
                          SizedBox(height: 20.r),
                          ApproveUserTile(
                            user: member,
                            joinedAt: member.communityMembership.createdOn,
                            onAccept: () {
                              controller.approveUser(
                                user: member.user,
                                communityId: communityId,
                                communityName: communityName,
                              );
                            },
                            onReject: () {
                              controller.rejectUser(
                                user: member,
                                communityId: communityId,
                                communityName: communityName,
                              );
                            },
                            onViewForm: () => controller.onViewForm(membership: member, ctx: ctx),
                          ),
                          SizedBox(height: 20.r),
                        ],
                      );
                    },
                  );
                },
              );
            }),
      ),
    );
  }
}
