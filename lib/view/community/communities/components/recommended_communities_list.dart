import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/community/communities/controllers/recommended_communities_controller.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:get/get.dart';

import '../../../../controller/app_config_controller.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../shared/view/widget/gaya_snackbar.dart';
import '../../../../widgets/community_view_widgets/community.row.widget.dart';
import '../models/topic_communties.dart';
import 'community_item.dart';

class RecommendedCommunities extends StatelessWidget {
  const RecommendedCommunities({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recommendedTitle = Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20).r,
      child: Text(
        GayaStrings.recommended.tr,
        style: TextStyle(color: AppColors.primary, fontSize: 20.sp, fontFamily: GayaFontTheme.primaryFont),
      ),
    );
    return GetBuilder<RecommendedCommunitiesController>(
        autoRemove: false,
        init: RecommendedCommunitiesController(),
        builder: (controller) {
          if (controller.isLoading) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  recommendedTitle,
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
              recommendedTitle,
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
                                AppConfigurationController.to
                                    .hideOrUnHideCommunity(communityId: topicCommunities.communities[index].communityId ?? "");
                                DefaultSnackBar.hideOrUnHideCommunity(context: context);
                                controller.hideOrUnHideACommunity(id: topicCommunities.communities[index].communityId ?? "");
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

enum LoadingStatus { LOADING, STABLE }

/// Signature for EndOfPageListeners
typedef EndOfPageListenerCallback = void Function();

/// A widget that wraps a [Widget] and will trigger [onEndOfPage] when it
/// reaches the bottom of the list
class LazyLoadScrollView extends StatefulWidget {
  /// The [Widget] that this widget watches for changes on
  final Widget child;

  /// Called when the [child] reaches the end of the list
  final EndOfPageListenerCallback onEndOfPage;

  /// The offset to take into account when triggering [onEndOfPage] in pixels
  final int scrollOffset;

  /// Used to determine if loading of new data has finished. You should use set this if you aren't using a FutureBuilder or StreamBuilder
  final bool isLoading;

  /// Prevented update nested listview with other axis direction
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() => LazyLoadScrollViewState();

  const LazyLoadScrollView({
    Key? key,
    required this.child,
    required this.onEndOfPage,
    this.scrollDirection = Axis.vertical,
    this.isLoading = false,
    this.scrollOffset = 100,
  }) : super(key: key);
}

class LazyLoadScrollViewState extends State<LazyLoadScrollView> {
  LoadingStatus loadMoreStatus = LoadingStatus.STABLE;

  @override
  void didUpdateWidget(LazyLoadScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading) {
      loadMoreStatus = LoadingStatus.STABLE;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      child: widget.child,
      onNotification: (notification) => _onNotification(notification, context),
    );
  }

  bool _onNotification(ScrollNotification notification, BuildContext context) {
    if (widget.scrollDirection == notification.metrics.axis) {
      if (notification is ScrollUpdateNotification) {
        if (notification.metrics.maxScrollExtent > notification.metrics.pixels &&
            notification.metrics.maxScrollExtent - notification.metrics.pixels <= widget.scrollOffset) {
          _loadMore();
        }
        return true;
      }

      if (notification is OverscrollNotification) {
        if (notification.overscroll > 0) {
          _loadMore();
        }
        return true;
      }
    }
    return false;
  }

  void _loadMore() {
    if (loadMoreStatus == LoadingStatus.STABLE) {
      loadMoreStatus = LoadingStatus.LOADING;
      widget.onEndOfPage();
    }
  }
}
