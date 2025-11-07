import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/asset_images.dart';
import '../../../../utils/const.dart';
import '../../../../utils/strings.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../../utils/theme/app_typography.dart';
import '../../models/post_insta_share.dart';
import 'community_image.dart';
import 'post_content_description.dart';
import 'post_image.dart';
import 'post_posted_user_image.dart';

class PostContentContainer extends StatelessWidget {
  const PostContentContainer({
    super.key,
    required this.postInstaShare,
  });

  final PostInstaShare postInstaShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(33.0.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 8.0.w,
              right: 8.0.w,
              top: 8.0.w,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /* ----------------- COMMUNITY IMAGE AND USER PROFILE IMAGE ----------------- */
                Stack(
                  children: [
                    /* ----------------------------- community image ---------------------------- */
                    CommunityImage(communityImage: postInstaShare.communityImage),
                    /* ------------------------------- user image ------------------------------- */
                    PostPostedUserImage(
                      postPostedUserImage: postInstaShare.post?.postedBy.gender == null
                          ? "Assets/images/anonymous_user.png"
                          : postInstaShare.post?.postedBy.gender == 'male'
                              ? "Assets/images/anonymous_boy.png"
                              : postInstaShare.post?.postedBy.gender == 'female'
                                  ? "Assets/images/anonymous_girl.png"
                                  : "Assets/images/anonymous_user.png",
                    )
                  ],
                ),
                SizedBox(width: distance_8.w),
                /* ------------- COMMUNITY NAME | USERNAME | USER EARNED CROWNS ------------- */
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* ----------------------------- community name ----------------------------- */
                    Text(
                      postInstaShare.communityName ?? '',
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                      style: GayaTypography.titleMedium.copyWith(overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(height: distance_5.w),
                    if (!postInstaShare.isAnonymousPost!)
                      Row(
                        children: [
                          /* -------------------------- post posted user name ------------------------- */
                          Text(
                            postInstaShare.postPostedUsername == null
                                ? ""
                                : postInstaShare.post?.isPostedAnonymously == true
                                    ? postInstaShare.post?.postedBy.gender == null
                                        ? anonymousUser
                                        : postInstaShare.post?.postedBy.gender == 'male'
                                            ? anonymousBoy
                                            : postInstaShare.post?.postedBy.gender == 'female'
                                                ? anonymousGirl
                                                : anonymousUser
                                    : postInstaShare.postPostedUsername!.length > 20
                                        ? "${postInstaShare.postPostedUsername!.substring(0, 20)}..."
                                        : postInstaShare.postPostedUsername!,
                            style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
                          ),
                          const SizedBox(width: 12.0),
                          /* ------------------------------- crown icon ------------------------------- */
                          SvgIcons.crownFilledSmall,
                          const SizedBox(width: 6),
                          /* --------------------------- user earned crowns --------------------------- */
                          Text(
                            postInstaShare.postPostedUserReceivedCrowns.toString(),
                            style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
                          ),
                        ],
                      )
                    else
                      Text(
                        postInstaShare.postPostedUsername == null
                            ? ""
                            : postInstaShare.post?.isPostedAnonymously == true
                                ? postInstaShare.post?.postedBy.gender == null
                                    ? anonymousUser
                                    : postInstaShare.post?.postedBy.gender == 'male'
                                        ? anonymousBoy
                                        : postInstaShare.post?.postedBy.gender == 'female'
                                            ? anonymousGirl
                                            : anonymousUser
                                : postInstaShare.postPostedUsername!.length > 20
                                    ? "${postInstaShare.postPostedUsername!.substring(0, 20)}..."
                                    : postInstaShare.postPostedUsername!,
                        style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
                      )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: distance_18.w),
          if (postInstaShare.postDescription != null && postInstaShare.postDescription!.isNotEmpty)
            /* ----------------------- post content / description ----------------------- */
            PostContent(postInstaShare: postInstaShare),
          if (postInstaShare.postImage != null)
            /* ------------------------------- POST IMAGE ------------------------------- */
            PostImage(postImage: postInstaShare.postImage),
        ],
      ),
    );
  }
}
