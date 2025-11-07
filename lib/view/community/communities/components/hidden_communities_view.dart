import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../../../../utils/methods.dart';
import '../../../../widgets/community_view_widgets/community.widget.dart';
import '../controllers/hidden_communities_controller.dart';
import 'loading_communities_skeleton_gridview.dart';

class HiddenCommunitiesView extends StatelessWidget {
  const HiddenCommunitiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        middle:  Text(GayaStrings.hidden_communities.tr),
        leading: const GayaBackButton(),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10).r,
          child: GetBuilder<HiddenCommunitiesController>(
            init: HiddenCommunitiesController(),
            global: false,
            builder: (controller) {
              if (controller.isLoading) {
                return const LoadingCommunitiesSkeletonGridView();
              }

              if (controller.communities.isEmpty) {
                return Card(
                  child: Center(
                    child: Text(
                      GayaStrings.no_hidden_communities.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                );
              }
              return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: controller.communities.length,
                  itemBuilder: (context, index) {
                    final community = controller.communities[index];
                    final totalMembersCount = community.communityMembers ?? 0;
                    return Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0).r,
                        child: CommunityWidget(
                          isGridView: true,
                          onLongTap: () {
                            Methods.showCommunityOperationModalSheet(
                              communityModel: community,
                              context: context,
                              isHidden: true,
                              showLeave: false,
                              showNotification: false,
                              showReport: false,
                              showPin: false,
                              onHideUnhide: () => controller.onUnHide(id: community.communityId ?? ""),
                            );
                          },
                          communityId: community.communityId ?? "",
                          onTap: () => Methods.routeToGroup(community: community),
                          communityName: community.communityName.toString(),
                          numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
                          numberOfNewPosts: '',
                          opacity: 0.81,
                          image: community.CommunityPic.toString(),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}
