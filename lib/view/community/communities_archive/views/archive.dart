import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/refresh_builder_utils.dart';
import 'package:gaya/view/community/communities_archive/controllers/archive_controller.dart';
import 'package:gaya/view/profile/view/my_communities_search_view.dart';
import 'package:get/get.dart';

import '../../../../utils/language/translation.dart';
import '../../../../utils/textstyles.dart';
import '../../../../widgets/community_view_widgets/community.widget.dart';
import '../../../../widgets/profile.widgets/button.widget.dart';
import '../../communities/components/loading_communities_skeleton_gridview.dart';

typedef CommunityReference = DocumentReference<Map<String, dynamic>> Function(String communityId);

class SeeArchivedCommunities extends StatelessWidget {
  SeeArchivedCommunities({super.key});

  final Widget emptyStateWidget = Center(child: Text(GayaStrings.no_archive_communities_found.tr));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: kTransparentColor,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: kBaseGrey)),
        centerTitle: true,
        title: Text(GayaStrings.communities_archive.tr, style: CustomTypography.bodyStyle),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 4).r,
              child: CupertinoIconButton(
                icon: SvgIcons.searchIcon,
                onPressed: () => Get.to(
                  () => const MyCommunitiesViewSearch(),
                ),
              ))
        ],
      ),
      body: GetBuilder<ArchiveController>(
        init: ArchiveController(),
        builder: (controller) {
          if (controller.isLoading) {
            return const LoadingCommunitiesSkeletonGridView();
          }
          return EasyRefresh(
            simultaneously: true,
            controller: controller.refreshController,
            header: RefreshBuilderUtils.headerAbove,
            //hidden
            footer: const CupertinoFooter(
              position: IndicatorPosition.locator,
              userWaterDrop: false,
              emptyWidget: SizedBox(),
            ),
            onLoad: () async {
              bool isFetched = await controller.loadMore();
              if (!isFetched) {
                return IndicatorResult.noMore;
              }
            },
            onRefresh: () => controller.onRefresh(),
            child: controller.isEmpty
                ? emptyStateWidget
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10).r,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: controller.communities.length,
                    itemBuilder: (context, index) {
                      final community = controller.communities[index];
                      final totalMembersCount = community.communityMembers ?? 0;
                      return Padding(
                        padding: const EdgeInsets.all(8.0).r,
                        child: CommunityWidget(
                          isGridView: true,
                          onLongTap: () {
                            Methods.showCommunityOperationModalSheet(
                              communityModel: community,
                              context: context,
                              showPin: false,
                              onHideUnhide: () {
                                controller.hideACommunity(id: community.communityId ?? "");
                                DefaultSnackBar.hideOrUnHideCommunity(context: context);
                              },
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
                      );
                    }),
          );
        },
      ),
    );
  }
}
