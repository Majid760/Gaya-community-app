import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/community/communities/controllers/hottopic_communities_controller.dart';
import 'package:gaya/view/switch_view/controllers/switch_view_controller.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:get/get.dart';
class UserNoCommunities extends StatelessWidget {
  const UserNoCommunities({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HotTopicCommunitiesController>(
        autoRemove: false,
        init: HotTopicCommunitiesController(),
        builder: (controller) {
          if (controller.isLoading) {
            return const ShowHomeCommunityShimmer();
          }
          if (controller.communities.isEmpty) {
            return Container();
          }
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: 1.sw,
              ),
              communityWidget(image: controller.communities[0].CommunityPic ?? ""),
              Positioned(left: 34, child: communityWidget(image: controller.communities[1].CommunityPic ?? "")),
              Positioned(
                left: 68,
                child: communityWidget(image: controller.communities[2].CommunityPic ?? ""),
              ),
              Positioned(
                left: 102,
                right: 0.0,
                child: GestureDetector(
                  onTap: () {
                    final controller = Get.find<SwitchViewController>();
                    controller.setIndex(2, context);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(color: AppColors.primary, width: 1),
                        ),
                        child: SvgIcons.plusOutline(color: AppColors.primary),
                      ),
                      SizedBox(
                        width: MySpaces.gap2.w,
                      ),
                      Expanded(
                        child: FittedBox(
                          child: Text(
                            GayaStrings.explore_new_communities_to_join.tr,
                            style: GayaTypography.captionMedium,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
communityWidget({required String image}) {
  return Container(
    width: 56,
    height: 56,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: kTransparentColor,
    ),
    child: CachedNetworkImage(
      memCacheHeight: 200,
      memCacheWidth: 200,
      maxHeightDiskCache: 200,
      maxWidthDiskCache: 200,
      imageUrl: image,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200)),
    ),
  );
}