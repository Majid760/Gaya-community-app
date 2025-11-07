import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feed_reaction/flutter_feed_reaction.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/utils/enum.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../controller/firebase_analytics_controller.dart';
import '../../../controller/report_controller.dart';
import '../../../model/create.post.model.dart';
import '../../../model/user.model.dart';
import '../../../routing/getx_route_methods.dart';
import '../../../shared/view/widget/gaya_report_dialog.dart';
import '../../../utils/assets_icons.dart';
import '../../../utils/const.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/methods.dart';
import '../../../utils/strings.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';
import '../../../widgets/post.with.comments.widgets/actionrow.widget.dart';
import '../../../widgets/post.with.comments.widgets/comments.dart';
import '../controller/comments_controller.dart';
import '../controller/post_with_comment_controller.dart';
import '../models/comment_custom_model.dart';
import '../view/reply_comment_view.dart';

/// This is the replies listview that is used in the [ParentCommentsListView]
class RepliesListView extends StatelessWidget {
  final String? postId;
  final CommentsController controller;
  final PostWithCommentController postWithCommentController;
  final UserModel replyBy;
  final CommentCustomModel reply;
  final MultiCommentModel comments;
  final int index;
  final Post post;
  final String? parentCommentId;
  final double? actionRowChildPadding;

  const RepliesListView(
      {Key? key,
      required this.controller,
      required this.postWithCommentController,
      this.postId,
      required this.replyBy,
      required this.reply,
      required this.comments,
      required this.index,
      this.parentCommentId,
      required this.post,
      this.actionRowChildPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyReactionStyle = GayaTypography.caption.copyWith(color: AppColors.secondary);
    final yellowReactionStyle = GayaTypography.caption.copyWith(color: AppColors.warning);

    return Column(
      children: [
        CommentSection(
          showDialogBox: () {
            String? userUid = FirebaseAuth.instance.currentUser?.uid;
            bool isMyComment = replyBy.uId == userUid || post.community.adminUid == userUid || AppConfigurationController.to.isSuperAdmin;
            Methods.showModalSheetComment(context, () {
              reportTextFieldBottomModal(
                context,
                onSubmit: (String reportMsg) async {
                  Navigator.pop(context);
                  await ReportController.to.reportACommentReply(
                      content: reply.comment.toString(),
                      reportMsg: reportMsg,
                      commentId: parentCommentId ?? '',
                      commentReplyId: reply.id,
                      context: context,
                      postId: postWithCommentController.post.postid ?? "");

                  // Logging comment reply report analytics event
                  AnalyticsController.to.instance.logReportCommentReply(
                    communityId: postWithCommentController.communityId,
                    postId: postWithCommentController.post.postid ?? '',
                    reportMessage: reportMsg,
                    userId: UserModel.to.uId ?? '',
                    replyId: reply.id,
                    commentId: parentCommentId ?? '',
                  );
                },
              );
            },
                commentId: parentCommentId ?? '',
                commentReplyId: reply.id,
                isReply: parentCommentId != null,
                postId: post.postid ?? "",
                showReportOption: !isMyComment,
                onCommentDelete: isMyComment ? () => controller.deleteChildComment(comments.comment.id, reply.id) : null);
          },
          nameOnTap: () {
            Routes.viewProfile(uid: replyBy.uId, model: replyBy);
          },
          userOntap: () {
            Routes.viewProfile(uid: replyBy.uId, model: replyBy);
          },
          anonymousPic: postWithCommentController.post.isPostedAnonymously ?? false,
          userUid: replyBy.uId!,
          uId: postWithCommentController.post.postedBy.uId,
          profilepic: postWithCommentController.post.isPostedAnonymously == true
              ? postWithCommentController.post.postedBy.uId == reply.user.uId
                  ? reply.user.gender == null
                      ? "Assets/images/anonymous_user.png"
                      : reply.user.gender == 'male'
                          ? "Assets/images/anonymous_boy.png"
                          : reply.user.gender == 'female'
                              ? "Assets/images/anonymous_girl.png"
                              : "Assets/images/anonymous_user.png"
                  : replyBy.profilePicture
              : replyBy.profilePicture,
          content: reply.comment,
          name: postWithCommentController.post.isPostedAnonymously == true
              ? postWithCommentController.post.postedBy.uId == reply.user.uId
                  ? reply.user.gender == null
                      ? anonymousUser
                      : reply.user.gender == 'male'
                          ? anonymousBoy
                          : reply.user.gender == 'female'
                              ? anonymousGirl
                              : anonymousUser
                  : reply.user.name
              : reply.user.name,
          time: Jiffy(reply.createdAt).fromNow(),
          videoFile: reply.videoFile,
          photoFile: reply.photoFile,
          videoUrl: reply.videoUrl,
          gender: reply.user.gender,
          photoUrl: reply.photoUrl,
          mentionedListUsers: reply.mentionedUsers,
          documentFile: reply.documentFile,
          pdfFiles: reply.pdfFiles,
          postId: post.postid ?? '',
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: ActionRow(
              childPadding: actionRowChildPadding,
              likeWidget: Row(
                children: [
                  // like reaction button
                  Builder(builder: (context) {
                    Widget prefixWidget = Methods.getMyReactionIcon(reply.reactionModel?.reaction,
                        postReactionData: reply.commentReactionData, iconSize: 13.r, shouldShowIcon: false);
                    Widget suffixWidget = Methods.getMyReactionText(reply.reactionModel?.reaction,
                        postReactionData: reply.commentReactionData, fontSize: 12.5.r, shouldShowNumbers: false);
                    List<int>? reactionsCountList = Methods.getReactionsCountsList(postReactionData: reply.commentReactionData);
                    return FlutterFeedReaction(
                      reactions: Methods.reactions,
                      dragSpace: 30.0.r,
                      dragStart: 150.0.r,
                      reactionsCountList: reactionsCountList,
                      onReactionSelected: (val) {
                        if (reply.reactionModel == null) {
                          likeReactionOnTap(val.name, true);
                        } else if (reply.reactionModel?.reaction == val.name) {
                          likeReactionOnTap(val.name, false);
                        } else {
                          likeReactionOnTap(val.name, true);
                        }
                      },
                      onPressed: () {
                        if (reply.reactionModel == null) {
                          likeReactionOnTap('Like', true);
                        } else {
                          likeReactionOnTap(reply.reactionModel?.reaction, false);
                        }
                      },
                      prefix: prefixWidget,
                      suffix: Padding(padding: const EdgeInsets.only(top: 1).r, child: suffixWidget),
                      containerWidth: 195.0.r,
                      spacing: 6.r,
                    );
                  }),
                ],
              ),
              flowerWidget: reply.totalCrowns < 1
                  ? Text(GayaStrings.crown_txt.tr, style: bodyReactionStyle)
                  : Row(
                      children: [
                        Text(GayaStrings.crown_txt.tr, style: (reply.isCrown) ? yellowReactionStyle : bodyReactionStyle),
                        const SizedBox(width: distance_5),
                        CircleAvatar(radius: 1, backgroundColor: (reply.isCrown) ? kYellowColor : kBaseGrey),

                        /// show icon if crownBy myself
                        if (reply.isCrown) ...[
                          const SizedBox(width: distance_5),
                          SvgIconWidget.crownFilledd(color: kYellowColor, height: 12.h, width: 14.h),
                          const SizedBox(width: distance_5),
                        ],
                        Text(reply.totalCrowns.toString(), style: (reply.isCrown) ? yellowReactionStyle : bodyReactionStyle),
                      ],
                    ),
              likeOnTap: () {
                if (reply.reactionModel == null) {
                  likeReactionOnTap('Like', true);
                } else {
                  likeReactionOnTap(reply.reactionModel?.reaction, false);
                }
              },
              flowerOnTap: () async {
                if (reply.isCrown) {
                } else if (reply.user.uId == UserModel.to.uId) {
                } else if (UserModel.to.userDailyCrowns == 0) {
                  Methods.showCrownsTotalModalSheet(ctx: Get.context);
                } else {
                  controller.crownAReplyComment(
                    commentId: comments.comment.id,
                    replyCommentId: reply.id,
                    receiverUser: reply.user,
                    communityId: postWithCommentController.post.communityId,
                  );
                }
              },
              replyOnTap: () {
                Get.to(ReplyCommentView(
                    postModel: postWithCommentController.post, userModel: postWithCommentController.post.postedBy, indexForComment: index));
              },
              postReplyTap: () => Routes.createPost(
                  community: postWithCommentController.post.community,
                  from: PostCreationFrom.Community,
                  commentData: PostReplyDataType(
                      postAuthorId: postWithCommentController.post.memberId,
                      commentAuthorId: reply.user.uId,
                      isAnonymousPost: postWithCommentController.post.isPostedAnonymously,
                      postType: PostCreationFrom.postReply.name,
                      /*     profilePic: postWithCommentController.post.isPostedAnonymously == true
                          ? postWithCommentController.post.postedBy.uId == reply.user.uId
                              ? anonymousUser
                              : replyBy.profilePicture
                          : replyBy.profilePicture, */
                      profilePic: postWithCommentController.post.isPostedAnonymously == true
                          ? postWithCommentController.post.postedBy.uId == replyBy.uId
                              ? replyBy.gender == null
                                  ? "Assets/images/anonymous_user.png"
                                  : replyBy.gender == 'male'
                                      ? "Assets/images/anonymous_boy.png"
                                      : replyBy.gender == 'female'
                                          ? "Assets/images/anonymous_girl.png"
                                          : "Assets/images/anonymous_user.png"
                              : replyBy.profilePicture
                          : replyBy.profilePicture,
                      commentUserName: postWithCommentController.post.isPostedAnonymously == true
                          ? postWithCommentController.post.postedBy.uId == replyBy.uId
                              ? replyBy.gender == null
                                  ? anonymousUser
                                  : replyBy.gender == 'male'
                                      ? anonymousBoy
                                      : replyBy.gender == 'female'
                                          ? anonymousGirl
                                          : anonymousUser
                              : replyBy.name
                          : replyBy.name,
                      commentId: reply.id,
                      mentionedUsersList: reply.mentionedUsers,
                      postId: postWithCommentController.post.postid,
                      content: reply.comment,
                      commentTime: reply.createdAt.toString(),
                      commentTimeFromNow: reply.createdAt)),
              postReplyWidget: Text(GayaStrings.post_reply.tr, style: bodyReactionStyle),
              textContent: reply.comment.toString(),
            ),
          ),
        ),
      ],
    );
  }

  likeReactionOnTap(String? reaction, bool isChecked) {
    print('reaction is: $reaction and value is: $isChecked');
    if (reaction != null && isChecked) {
      controller.likeReactionACommentReply(
          commentId: comments.comment.id,
          replyId: reply.id,
          communityId: postWithCommentController.post.communityId ?? '',
          reaction: reaction,
          isChecked: isChecked);
    } else if (isChecked == false) {
      controller.unlikeReactionACommentReply(
          commentId: comments.comment.id,
          replyId: reply.id,
          communityId: postWithCommentController.post.communityId ?? '',
          reaction: reaction,
          isChecked: isChecked);
    } else {
      print('Else case occured while reaction is: $reaction and value is: $isChecked');
    }
  }
}
