import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/animation.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/community/communities/controllers/hottopic_communities_controller.dart';
import 'package:get/get.dart';

import '../../../../switch_view/controllers/switch_view_controller.dart';
import 'explore_more_communities_widget.dart';

exploreMoreCommunitiesBottomSheet(BuildContext context) {
  return Methods.showCircularModalSheet(
      context,
      GetBuilder<HotTopicCommunitiesController>(
          autoRemove: false,
          init: HotTopicCommunitiesController(),
          builder: (controller) {
            return FutureBuilder<List<Community>>(
                future: controller.getExploreMoreHotCommunities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(height: 0.9.sh, child: const ShowHotCommunityShimmer());
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final data = snapshot.data ?? [];
                      return data.isEmpty
                          ? const AnimationLottie()
                          : SizedBox(
                              height: 0.9.sh,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20).r,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                GayaStrings.suggested_communities_join.tr,
                                                style: GayaTypography.titleSemiBold,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  GayaStrings.done.tr,
                                                  style: GayaTypography.titleSemiBold.copyWith(color: AppColors.primary),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Wrap(
                                          children: data.map((community) {
                                            final totalMembersCount = community.communityMembers ?? 0;
                                            if (AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? "")) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 20).r,
                                              child: ExploreMoreCommunityWidget(
                                                communityId: community.communityId ?? "",
                                                communityName: community.communityName.toString(),
                                                numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
                                                opacity: 0.81,
                                                image: community.CommunityPic.toString(),
                                                coverImage: community.coverPicture.toString(),
                                                communityDes: community.communityDescription.toString(),
                                                onTap: () => Methods.showModalSheetToJoinCommunity(
                                                  communityId: community.communityId,
                                                  ctx: context,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        // extra space
                                        SizedBox(height: 20.h),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: GestureDetector(
                                      onTap: () {

                                        if(Get.currentRoute=='/CommunityUserFeedView') {
                                          Navigator.pop(context);
                                        }
                                        Navigator.pop(context);
                                        final controller = Get.find<SwitchViewController>();
                                        controller.setIndex(2, context);
                                      },
                                      child: Text(
                                        GayaStrings.explore_more_communities.tr,
                                        style: GayaTypography.titleSemiBold.copyWith(color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MySpaces.gap7.h,
                                  )
                                ],
                              ),
                            );
                    }
                  }
                  return const AnimationLottie();
                });
          }));
}

class ShowHotCommunityShimmer extends StatelessWidget {
  final bool isGridView;

  const ShowHotCommunityShimmer({Key? key, this.isGridView = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(3, (index) {
            return Row(
                children: List.generate(2, (index) {
              return Stack(clipBehavior: Clip.none, children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: isGridView ? null : 154.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12).r, color: AppColors.white, border: Border.all(color: AppColors.divider)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: isGridView ? null : 154.w,
                          height: isGridView ? null : 76.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12).r,
                            color: AppColors.divider,
                          ),
                        ),
                        SizedBox(
                          height: MySpaces.gap4.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0).r,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "",
                                style: GayaTypography.titleSemiBold.copyWith(
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.fade,
                                maxLines: 2,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 5.33.w,
                                  ),
                                  Text(
                                    "",
                                    style: GayaTypography.subtitleRegular.copyWith(fontSize: 14.sp, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                              Text(
                                "",
                                style: GayaTypography.subtitleRegular.copyWith(fontSize: 14.sp),
                                overflow: TextOverflow.fade,
                                maxLines: 2,
                              ),
                              SizedBox(
                                height: MySpaces.gap2.h,
                              ),
                              GayaButton(
                                  primaryColor: AppColors.divider,
                                  title: "",
                                  height: 30.h,
                                  width: 147.w,
                                  textStyle: GayaTypography.captionMedium.copyWith(color: AppColors.divider))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: 38,
                    left: 8,
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.divider),
                    )),
              ]);
            }));
          }),
        ),
      ),
    );
  }
}
