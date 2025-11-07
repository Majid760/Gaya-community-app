import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:get/get.dart';

import '../../../../controller/app_config_controller.dart';
import '../../../../shared/view/widget/gaya_snackbar.dart';
import '../../../../widgets/community_view_widgets/community.row.widget.dart';
import '../../../seeall.interestcommunities.dart';
import '../controllers/top_private_communities_controller.dart';
import 'community_item.dart';

class TopPrivateCommunities extends StatelessWidget {
  const TopPrivateCommunities({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopPrivateCommunitiesController>(
        autoRemove: false,
        init: TopPrivateCommunitiesController(),
        builder: (controller) {
          if (controller.isLoading) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.r),
                  SizedBox(height: 20.r),
                  const ShowCommunityShimmer(),
                ],
              ),
            );
          }
          if (controller.communities.isEmpty) {
            return Container();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.r),
              CommunityRow(
                onTap: () => Get.to(SeeAllByQueryCommunities(
                    query: controller.getTopPrivateCommunities, title: GayaStrings.top_private_communities_emoji.tr)),
                style: CustomTypography.bodyStyle,
                typeOfCommunity: GayaStrings.top_private_communities_emoji.tr,
              ),
              SizedBox(
                height: 112.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 20),
                  itemCount: controller.communities.length,
                  itemBuilder: (context, index) => CommunityItem(
                    community: controller.communities[index],
                    onHideCommunity: () {
                      AppConfigurationController.to.hideOrUnHideCommunity(communityId: controller.communities[index].communityId);
                      DefaultSnackBar.hideOrUnHideCommunity(context: context);
                      controller.hideOrUnHideACommunity(id: controller.communities[index].communityId ?? "");
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }
}
