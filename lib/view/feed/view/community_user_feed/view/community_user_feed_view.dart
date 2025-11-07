import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/feed/view/private/feeds_view.dart';
import 'package:get/get.dart';

import '../../../../../routing/getx_route_methods.dart';
import '../../../../../utils/assets_icons.dart';
import '../../../../../utils/methods.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_typography.dart';
import '../../../../community/views/community_view_feed.dart';
import '../../../../search.communities.view.dart';
import '../controller/home_feed_user_communities_controller.dart';

class CommunityUserFeedView extends StatelessWidget {
  final Community communityModel;

  const CommunityUserFeedView({
    Key? key,
    required this.communityModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).scaffoldBackgroundColor;

    final controller = HomeFeedUserCommunities.to;
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        final community = controller.selectedCommunity;
        return IgnorePointer(
          ignoring: controller.isCommunityLoading.value,
          child: Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: kBlackColor),
              elevation: 0,
              backgroundColor: kWhiteColor,
              automaticallyImplyLeading: false,
              leading: const GayaBackButton(),
              title: 
              
              GestureDetector(
              onTap: () {
                if (community.communityId != null) {
                  Routes.groupView(community: community);
                }
              },
              child: Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      child: Text(
                        community.communityName ?? "",
                        style: CustomTypography.bodyStyle.copyWith(fontSize: 20),
                        textDirection: Methods.isRTL(community.communityName ?? "") ? TextDirection.rtl : TextDirection.ltr,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            )
            ,
              actions: [
                IconButton(
                  icon: SvgIconWidget.searchLgOutline(height: 20.h),
                  // icon: const Icon(Icons.search),
                  color: kBlackColor,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (_) => SearchCommunities(isCommunityUsersSearch: true, communityId: community.communityId ?? ''),
                    );
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: ExtendedNestedScrollView(
              onlyOneScrollInBody: true,
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  backgroundColor: color,
                  floating: false,
                  pinned: true,
                  toolbarHeight: 100,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  title: const MyCommunitiesUserFeed(isHomeFeed: false),
                ),
              ],
              body: CommunityFeedViewV2(
                /// avoid rebuilding the widget when the community changes
                key: ValueKey("community_feed_${community.communityId ?? ""}"),
                homeUserController: controller,
              ),
            ),
            floatingActionButton: GestureDetector(
              onTap: () {
                if (community.communityId != null) {
                  Routes.createPost(community: community, from: PostCreationFrom.FeedDetail);
                }

                HapticFeedback.mediumImpact();
              },
              child: Container(
                margin: !DeviceCheck.isIOS ? const EdgeInsets.only(bottom: 20).r : null,
                padding: const EdgeInsets.all(12).r,
                height: 48.r,
                width: 48.r,
                decoration: BoxDecoration(
                    color: community.communityThemeModel?.color != null ? community.getThemeColor() : AppColors.primary4,
                    borderRadius: BorderRadius.circular(borderRadius_4).r),
                child: SvgIconWidget.editOutline(height: 24.r, width: 24.r),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          ),
        );
      },
    );
  }
}
