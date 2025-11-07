import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/feed/view/community_user_feed/controller/home_feed_user_communities_controller.dart';
import 'package:get/get.dart';
class HomeCommunityWidget extends StatelessWidget {
  const HomeCommunityWidget({
    Key? key,
    required this.communityId,
    this.linearGradient,
    required this.opacity,
    required this.communityName,
    required this.numberOfMemebers,
    this.numberOfNewPosts,
    this.onLongTap,
    required this.image,
    required this.onTap,
    this.isPinned = false,
    this.badge,
    this.isGridView = false,
    required this.isHomeFeed,
    required this.community,
  }) : super(key: key);

  final String communityId;
  final VoidCallback onTap;
  final VoidCallback? onLongTap;
  final Shader? linearGradient;
  final double opacity;
  final String communityName, numberOfMemebers, image;
  final int? numberOfNewPosts;
  final Widget? badge;
  final bool isPinned;
  final bool isGridView;
  final bool isHomeFeed;
  final Community community;

  @override
  Widget build(BuildContext context) {
    final controller = HomeFeedUserCommunities.to;
    return GestureDetector(
        onTap: onTap,
        onLongPress: onLongTap,
        child: Obx(() {
          final isSelected = controller.selectedCommunity.communityId == communityId;
          return Container(
            color: isHomeFeed
                ? AppColors.transparrent
                : isSelected
                    ? AppColors.primary6
                    : null,
            child: Stack(
              clipBehavior:Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10).r,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius_8),
                            color: AppColors.transparrent,
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
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 65.r,
                        child: Text(
                          communityName,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GayaTypography.body2.copyWith(fontSize: 12, height: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((numberOfNewPosts ?? 0) > 0)
                  Positioned(
                    top: 42,
                    left: 40,
                    child: Container(
                      width: 25.w,
                      height: 25.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        numberOfNewPosts?.toCount99Plus ?? "",
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: GayaTypography.titleSemiBold.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                if (!isSelected && !isHomeFeed)
                  Positioned.fill(
                      child: Container(
                    color: AppColors.white.withOpacity(0.6),
                  )),
              ],
            ),
          );
        }));
  }
}