import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:get/get.dart';

import '../../../../controller/app_config_controller.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../shared/view/widget/gaya_snackbar.dart';
import '../../../../widgets/community_view_widgets/community.row.widget.dart';
import '../controllers/interest_communities_controller.dart';
import '../models/topic_communties.dart';
import 'community_item.dart';

class UserInterestCommunities extends StatelessWidget {
  const UserInterestCommunities({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interestTitle = Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20).r,
      child: Text(
        GayaStrings.interests_txt.tr,
        style: TextStyle(color: AppColors.primary, fontSize: 20.sp, fontFamily: GayaFontTheme.primaryFont),
      ),
    );
    return GetBuilder<InterestCommunitiesController>(
        autoRemove: false,
        init: InterestCommunitiesController(),
        builder: (controller) {
          /// if user has no interests, then skip this widget
          if (!controller.isInterestsAvailable) {
            debugPrint("Interests are available");
            return const SizedBox(height: 20);
          }
          if (controller.isLoading) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  interestTitle,
                  SizedBox(height: 20.r),
                  SizedBox(height: 20.r),
                  const ShowCommunityShimmer(),
                ],
              ),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interestTitle,
              ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.communities.length,
                  itemBuilder: (context, index) {
                    TopicCommunities topicCommunities = controller.communities[index];
                    return Column(
                      children: [
                        SizedBox(height: 10.r),
                        CommunityRow(
                          onTap: () => Routes.seeAllInterestCommunitiesView(communityName: topicCommunities.topicName),
                          style: CustomTypography.bodyStyle,
                          typeOfCommunity: topicCommunities.topicName,
                        ),
                        SizedBox(
                          height: 112.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(right: 20),
                            itemCount: topicCommunities.communities.length,
                            itemBuilder: (context, index) => CommunityItem(
                              community: topicCommunities.communities[index],
                              onHideCommunity: () {
                                final id = topicCommunities.communities[index].communityId ?? "";
                                AppConfigurationController.to.hideOrUnHideCommunity(communityId: id);
                                DefaultSnackBar.hideOrUnHideCommunity(context: context);
                                controller.hideOrUnHideACommunity(id: id);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ],
          );
        });
  }
}
