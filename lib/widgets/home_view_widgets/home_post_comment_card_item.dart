import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/gaya_text_widget.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:get/get.dart';

import '../../components/profile_image_widget.dart';
import '../../utils/app_data.dart';
import '../../utils/language/translation.dart';
import '../../utils/strings.dart';
import '../../utils/textstyles.dart';

/// Used In Horizontal List of Comments in PostCardItem [ HomePostWidget ]
class CommentCardItem extends StatelessWidget {
  final CommentCustomModel comment;
  final bool isAnonymous;
  final Color? communityThemeColor;

  const CommentCardItem({super.key, required this.comment, required this.isAnonymous, required this.communityThemeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8).r,
      margin: const EdgeInsets.only(right: 10).r,
      decoration: BoxDecoration(color: communityThemeColor ?? AppColors.primary5, borderRadius: BorderRadius.circular(8).r),
      child: Column(
        /// to have text in end or center according to data.
        crossAxisAlignment: comment.isRTLText ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: AppColors.white, //isFeedView ? kBaseGrey : Colors.white,
                  child: isAnonymous
                      ? AnonymousProfilePictureWidget(gender: comment.user.gender)
                      : ProfileImageWidget(
                          url: comment.user.profilePicture ?? '',
                          size: const Size(24, 24),
                          onError: AppData.defaultUserProfileWidget(),
                        ),
                ),
                SizedBox(width: 4.r),
                Expanded(
                  child: Text(
                    isAnonymous
                        ? comment.user.gender == 'male'
                            ? anonymousBoy
                            : comment.user.gender == 'female'
                                ? anonymousGirl
                                : anonymousUser
                        : comment.user.userName,
                    textAlign: TextAlign.left,
                    style: CustomTypography.dark12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.r),
          Expanded(
            flex: 3,
            child: GayaTextWidget(
              getCommentText(comment),
              isReadMore: true,
              isEllipsis: true,
              shouldIgnoreSelectableText: true,
              mentionedUsers: comment.mentionedUsers ?? [],
              trimLength: 35,
              style: CustomTypography.body4StyleLessWeight,
            ),
          ),
          SizedBox(height: 4.r),
        ],
      ),
    );
  }

  String getCommentText(CommentCustomModel comment) {
    if (comment.comment.isNotEmpty) {
      return comment.comment;
    } else if (comment.photoUrl != null) {
      return '📷 ${GayaStrings.image.tr}';
    } else if (comment.videoUrl != null) {
      return '📹 ${GayaStrings.video.tr}';
    } else if (comment.pdfFiles != null && comment.pdfFiles?.isNotEmpty == true) {
      return '📜 ${GayaStrings.document.tr}';
    } else {
      return GayaStrings.new_comment.tr;
    }
  }
}
