import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/gaya_text_widget.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:jiffy/jiffy.dart';

class ReplyCommentPostWidget extends StatelessWidget {
  const ReplyCommentPostWidget({super.key, required this.commentData, this.onTap, required this.communityColor});

  final VoidCallback? onTap;
  final Color? communityColor;

  final PostReplyDataType? commentData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0.r, top: 10.0.r),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 180.r,
            padding: EdgeInsets.symmetric(vertical: 15.r, horizontal: 20.r),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: communityColor),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    commentData?.isAnonymousPost == true &&
                            commentData?.postAuthorId != null &&
                            commentData?.commentAuthorId == commentData?.postAuthorId
                        ? GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: kBaseGrey,
                              backgroundImage: AssetImage((commentData?.profilePic == null || commentData!.profilePic!.trim().isEmpty)
                                  ? Assets.assets.images.userDefault
                                  : commentData?.profilePic ?? Assets.assets.images.userDefault),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: kBaseGrey,
                              child: (commentData?.profilePic?.contains('http') ?? false)
                                  ? CachedNetworkImage(
                                      memCacheHeight: 50,
                                      memCacheWidth: 50,
                                      imageUrl: commentData?.profilePic ?? '',
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                        );
                                      },
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Image.asset(Assets.assets.images.userDefault),
                                      placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
                                    )
                                  : Image.asset((commentData?.profilePic == null || (commentData?.profilePic?.trim().isEmpty ?? false))
                                      ? Assets.assets.images.userDefault
                                      : commentData?.profilePic ?? Assets.assets.images.userDefault),
                            ),
                          ),
                    SizedBox(width: 5.r),
                    Flexible(
                      child: Text(
                        commentData?.commentUserName ?? '',
                        style: GayaTypography.caption2Medium.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 6.r),
                (commentData?.mentionedUsersList != null)
                    ? GayaTextWidget(
                        commentData?.content,
                        mentionedUsers: commentData?.mentionedUsersList,
                      )
                    : commentData?.content != null
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  commentData?.content ?? "",
                                  textAlign: TextAlign.center,
                                  style: GayaTypography.subtitleMedium.copyWith(fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                SizedBox(height: 8.r),
                Text(
                  Jiffy(commentData?.commentTimeFromNow).fromNow(),
                  style: GayaTypography.captionMedium.copyWith(color: Colors.grey[600]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
