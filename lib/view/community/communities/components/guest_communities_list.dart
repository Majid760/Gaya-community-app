import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:get/get.dart';

import '../../../../routing/getx_route_methods.dart';
import '../../../../widgets/community_view_widgets/community.row.widget.dart';
import '../controllers/guest_communities_controller.dart';
import '../models/topic_communties.dart';
import 'community_item.dart';

class GuestCommunities extends StatelessWidget {
  const GuestCommunities({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<GuestCommunitiesController>(
        autoRemove: false,
        init: GuestCommunitiesController(),
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          onTap: ()=>Routes.requiredLoginView(),
                          style: CustomTypography.bodyStyle,
                          typeOfCommunity: topicCommunities.topicName,
                        ),

                        SizedBox(
                          height: 112.h,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(right: 20),
                              itemCount: topicCommunities.communities.length,
                              itemBuilder: (context, index) => CommunityItem(community: topicCommunities.communities[index], onHideCommunity: (){})),
                        ),
                      ],
                    );
                  }),
            ],
          );
        });
  }
}