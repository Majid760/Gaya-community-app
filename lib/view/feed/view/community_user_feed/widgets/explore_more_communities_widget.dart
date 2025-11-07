import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

class ExploreMoreCommunityWidget extends StatefulWidget {
  const ExploreMoreCommunityWidget({
    Key? key,
    required this.communityId,
    this.linearGradient,
    required this.opacity,
    required this.communityName,
    required this.numberOfMemebers,
    this.numberOfNewPosts,
    this.onLongTap,
    required this.image,
    required this.communityDes,
    required this.coverImage,
    required this.onTap,
    this.isPinned = false,
    this.badge,
    this.isGridView = false,
  }) : super(key: key);

  final String communityId;
  final VoidCallback onTap;
  final VoidCallback? onLongTap;
  final Shader? linearGradient;
  final double opacity;
  final String communityName, numberOfMemebers, image;
  final String communityDes;
  final String coverImage;
  final String? numberOfNewPosts;
  final Widget? badge;
  final bool isPinned;
  final bool isGridView;

  @override
  State<ExploreMoreCommunityWidget> createState() => _ExploreMoreCommunityWidgetState();
}

class _ExploreMoreCommunityWidgetState extends State<ExploreMoreCommunityWidget> {
  String isJoinedCommunity = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMemberStatus();
  }

  getMemberStatus() async {
    isJoinedCommunity = await AppConfigurationController.to.getUserMembershipByCommunityId(communityId: widget.communityId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.isGridView ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 20).r,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongTap,
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            // margin:isGridView?null: const EdgeInsets.only(left: distance_20).r,
            width: widget.isGridView ? null : 154.w,
            height: widget.isGridView ? null : 220.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12).r, color: AppColors.white, border: Border.all(color: AppColors.divider)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: widget.isGridView ? null : 154.w,
                  height: widget.isGridView ? null : 76.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12).r,
                    color: kTransparentColor,
                  ),
                  child: CachedNetworkImage(
                    memCacheHeight: 30,
                    memCacheWidth: 30,
                    maxHeightDiskCache: 240,
                    maxWidthDiskCache: 240,
                    imageUrl: widget.coverImage,
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: const Radius.circular(12).r, topRight: const Radius.circular(12).r),
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      );
                    },
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200)),
                  ),
                ),
                SizedBox(
                  height: MySpaces.gap2.h,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.communityName.tr,
                        style: GayaTypography.titleSemiBold.copyWith(
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgIconWidget.usersOutline(width: 13.33.w, height: 12.h, color: AppColors.secondary),
                            SizedBox(
                              width: 5.33.w,
                            ),
                            Text(
                              widget.numberOfMemebers.toString(),
                              style: GayaTypography.subtitleRegular.copyWith(fontSize: 14.sp, color: AppColors.secondary, height: 1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.communityDes.toString(),
                        style: GayaTypography.subtitleRegular.copyWith(fontSize: 14.sp),
                        overflow: TextOverflow.fade,
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: MySpaces.gap2.h,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: 38,
              left: 8,
              child: Card(
                elevation: 0.1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28).r,
                ),
                child: SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: CachedNetworkImage(
                    memCacheHeight: 30,
                    memCacheWidth: 30,
                    maxHeightDiskCache: 50,
                    maxWidthDiskCache: 50,
                    imageUrl: widget.image,
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
                ),
              )),
          Positioned(
              left: 8,
              right: 8,
              bottom: 4,
              child: GayaButton(
                  onPressed: widget.onTap,
                  primaryColor: isJoinedCommunity == "member" || isJoinedCommunity == "waiting" ? AppColors.white : AppColors.primary,
                  title: isJoinedCommunity == "member"
                      ? GayaStrings.joined.tr
                      : isJoinedCommunity == "waiting"
                          ? GayaStrings.request_sent.tr
                          : GayaStrings.join.tr,
                  height: 30.h,
                  width: 147.w,
                  borderColor: isJoinedCommunity == "member" || isJoinedCommunity == "waiting" ? AppColors.borderColor : AppColors.primary,
                  textStyle: GayaTypography.captionMedium.copyWith(color: isJoinedCommunity == "member" || isJoinedCommunity == "waiting" ? AppColors.primary : AppColors.white))),
        ]),
      ),
    );
  }
}
