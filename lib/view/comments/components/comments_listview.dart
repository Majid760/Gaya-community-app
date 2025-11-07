import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feed_reaction/flutter_feed_reaction.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/report_controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_report_dialog.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/comments/components/replies_listview.dart';
import 'package:gaya/view/comments/controller/comments_controller.dart';
import 'package:gaya/view/comments/controller/post_with_comment_controller.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/comments/view/reply_comment_view.dart';
import 'package:gaya/widgets/post.with.comments.widgets/actionrow.widget.dart';
import 'package:gaya/widgets/post.with.comments.widgets/comments.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../controller/app_config_controller.dart';

/// Parent Comments List View
class ParentCommentsListView extends StatelessWidget {
  final MultiCommentModel comments;
  final UserModel commentBy;
  final List<CommentCustomModel> allReplies;
  final int index;
  final Post post;
  final CommentsController commentController;
  final PostWithCommentController postWithCommentController;
  final double? actionRowChildPadding;

  const ParentCommentsListView(
      {Key? key,
      required this.comments,
      required this.commentBy,
      required this.allReplies,
      required this.index,
      required this.post,
      required this.commentController,
      required this.postWithCommentController,
      this.actionRowChildPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyReactionStyle = GayaTypography.caption.copyWith(color: AppColors.secondary);
    final yellowReactionStyle = GayaTypography.caption.copyWith(color: AppColors.warning);

    return Column(
      children: [
        //parent comments
        Column(
          children: [
            CommentSection(
              showDialogBox: () {
                String? userId = FirebaseAuth.instance.currentUser?.uid;
                bool isMyComment =
                    comments.comment.user.uId == userId || post.community.adminUid == userId || AppConfigurationController.to.isSuperAdmin;
                Methods.showModalSheetComment(
                    context,
                    () {
                      reportTextFieldBottomModal(
                        context,
                        onSubmit: (String reportMsg) async {
                          await ReportController.to.reportAComment(
                            content: comments.comment.comment.toString(),
                            reportedCommentId: comments.comment.id,
                            context: context,
                            reportMsg: reportMsg,
                            postId: postWithCommentController.post.postid ?? "",
                            userId: comments.comment.user.uId,
                          );

                          // Logging report comment to analytics
                          AnalyticsController.to.instance.logReportComment(
                            commentId: comments.comment.id,
                            postId: postWithCommentController.post.postid ?? "",
                            reportMessage: reportMsg,
                            userId: UserModel.to.uId ?? '',
                            communityId: postWithCommentController.communityId,
                          );

                          Navigator.pop(context);
                        },
                      );
                    },
                    onCommentDelete: isMyComment ? () => commentController.deleteComment(comments.comment.id) : null,
                    commentId: comments.comment.id,
                    postId: postWithCommentController.post.postid ?? "",
                    showReportOption: !isMyComment,
                    onReply: () {
                      try {
                        Get.to(ReplyCommentView(
                            postModel: postWithCommentController.post,
                            userModel: postWithCommentController.post.postedBy,
                            indexForComment: index));
                      } catch (_) {}
                    });
              },
              mentionedListUsers: comments.comment.mentionedUsers,
              nameOnTap: () => Routes.viewProfile(uid: comments.comment.user.uId, model: comments.comment.user),
              userOntap: () => Routes.viewProfile(uid: commentBy.uId, model: commentBy),
              anonymousPic: postWithCommentController.post.isPostedAnonymously ?? false,
              userUid: commentBy.uId ?? '',
              uId: postWithCommentController.post.postedBy.uId,
              profilepic: commentBy.profilePicture,
              content: comments.comment.comment.toString(),
              name: commentBy.name,
              videoFile: comments.comment.videoFile,
              photoFile: comments.comment.photoFile,
              documentFile: comments.comment.documentFile,
              videoUrl: comments.comment.videoUrl,
              photoUrl: comments.comment.photoUrl,
              time: Jiffy(comments.comment.createdAt).fromNow(),
              pdfFiles: comments.comment.pdfFiles,
              postId: post.postid ?? '',
              gender: post.postedBy.gender,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: ActionRow(
                  childPadding: actionRowChildPadding,
                  likeWidget: Builder(builder: (context) {
                    Widget prefixWidget = Methods.getMyReactionIcon(comments.comment.reactionModel?.reaction,
                        postReactionData: comments.comment.commentReactionData, iconSize: 13.r, shouldShowIcon: false);
                    Widget suffixWidget = Methods.getMyReactionText(comments.comment.reactionModel?.reaction,
                        postReactionData: comments.comment.commentReactionData, fontSize: 12.5.sp, shouldShowNumbers: false);
                    List<int>? reactionsCountList = Methods.getReactionsCountsList(postReactionData: comments.comment.commentReactionData);

                    return FlutterFeedReaction(
                      reactions: Methods.reactions,
                      dragSpace: 30.0.r,
                      dragStart: 100.0.r,
                      reactionsCountList: reactionsCountList,
                      onReactionSelected: (val) {
                        if (comments.comment.reactionModel == null) {
                          likeReactionOnTap(val.name, true);
                        } else if (comments.comment.reactionModel?.reaction == val.name) {
                          likeReactionOnTap(val.name, false);
                        } else {
                          likeReactionOnTap(val.name, true);
                        }
                      },
                      onPressed: () {
                        if (comments.comment.reactionModel == null) {
                          likeReactionOnTap('Like', true);
                        } else {
                          likeReactionOnTap(comments.comment.reactionModel?.reaction, false);
                        }
                      },
                      prefix: prefixWidget,
                      suffix: Padding(
                        padding: const EdgeInsets.only(top: 1).r,
                        child: suffixWidget,
                      ),
                      containerWidth: 195.r,
                      spacing: 6.r,
                      childAnchor: Alignment.topLeft,
                      portalAnchor: Alignment.bottomLeft,
                    );
                  }),
                  flowerWidget: comments.comment.totalCrowns < 1
                      ? Text(GayaStrings.crown_txt.tr, style: bodyReactionStyle)
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(GayaStrings.crown_txt.tr, style: (comments.comment.isCrown) ? yellowReactionStyle : bodyReactionStyle),
                            const SizedBox(width: distance_5),
                            CircleAvatar(radius: 1, backgroundColor: (comments.comment.isCrown) ? kYellowColor : kBaseGrey),

                            /// show icon if crownBy myself
                            if (comments.comment.isCrown) ...[
                              const SizedBox(width: distance_5),
                              SvgIconWidget.crownFilledd(color: kYellowColor, height: 12.h, width: 14.h),
                              const SizedBox(width: distance_5),
                            ],
                            Text(comments.comment.totalCrowns.toString(),
                                style: (comments.comment.isCrown) ? yellowReactionStyle : bodyReactionStyle),
                          ],
                        ),
                  likeOnTap: () {
                    if (comments.comment.reactionModel == null) {
                      likeReactionOnTap('Like', true);
                    } else {
                      likeReactionOnTap(comments.comment.reactionModel?.reaction, false);
                    }
                  },
                  flowerOnTap: () async {
                    if (comments.comment.isCrown) {
                    } else if (comments.comment.user.uId == UserModel.to.uId) {
                      //TODO: add alert dialog
                    } else if (UserModel.to.userDailyCrowns == 0) {
                      Methods.showCrownsTotalModalSheet(ctx: Get.context);
                    } else {
                      commentController.crownAComment(
                        commentId: comments.comment.id,
                        receiverUser: commentBy,
                        communityId: postWithCommentController.post.communityId,
                      );
                    }
                  },
                  replyOnTap: () {
                    Get.to(ReplyCommentView(
                        postModel: postWithCommentController.post,
                        userModel: postWithCommentController.post.postedBy,
                        indexForComment: index));
                  },
                  postReplyTap: () => Routes.createPost(
                      community: postWithCommentController.post.community,
                      from: PostCreationFrom.Community,
                      commentData: PostReplyDataType(
                        postAuthorId: postWithCommentController.post.memberId,
                        commentAuthorId: commentBy.uId,
                        postType: PostCreationFrom.postReply.name,
                        isAnonymousPost: postWithCommentController.post.isPostedAnonymously ?? false,
                        // profilePic: (postWithCommentController.post.isPostedAnonymously ?? false) ? anonymousUser : commentBy.profilePicture,
                        profilePic: postWithCommentController.post.isPostedAnonymously == true
                            ? postWithCommentController.post.postedBy.uId == commentBy.uId
                                ? commentBy.gender == null
                                    ? "Assets/images/anonymous_user.png"
                                    : commentBy.gender == 'male'
                                        ? "Assets/images/anonymous_boy.png"
                                        : commentBy.gender == 'female'
                                            ? "Assets/images/anonymous_girl.png"
                                            : "Assets/images/anonymous_user.png"
                                : commentBy.profilePicture
                            : commentBy.profilePicture,

                        commentUserName: postWithCommentController.post.isPostedAnonymously == true
                            ? postWithCommentController.post.postedBy.uId == commentBy.uId
                                ? commentBy.gender == null
                                    ? anonymousUser
                                    : commentBy.gender == 'male'
                                        ? anonymousBoy
                                        : commentBy.gender == 'female'
                                            ? anonymousGirl
                                            : anonymousUser
                                : commentBy.name
                            : commentBy.name,
                        commentId: comments.comment.id,
                        mentionedUsersList: comments.comment.mentionedUsers,
                        postId: postWithCommentController.post.postid,
                        commentTimeFromNow: comments.comment.createdAt,
                        commentTime: Jiffy(comments.comment.createdAt).fromNow(),
                        content: comments.comment.comment.toString(),
                      )),
                  postReplyWidget: Text(GayaStrings.post_reply.tr, style: bodyReactionStyle),
                  textContent: comments.comment.comment.toString(),
                ),
              ),
            ),
          ],
        ),
        // SizedBox(height: distance_10.r),
        //replies comment
        Padding(
          padding: EdgeInsets.only(left: 45, bottom: distance_10.r, top: (allReplies.isNotEmpty) ? distance_10.r : 0),
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: allReplies.length,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (context, repliesIndex) {
              UserModel replyBy = allReplies[repliesIndex].user;
              CommentCustomModel reply = allReplies[repliesIndex];
              return RepliesListView(
                postWithCommentController: postWithCommentController,
                controller: commentController,
                replyBy: replyBy,
                reply: reply,
                comments: comments,
                index: index,
                parentCommentId: comments.comment.id,
                post: post,
                actionRowChildPadding: 0,
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: distance_10.r),
          ),
        ),
      ],
    );
  }

  likeReactionOnTap(String? reaction, bool isChecked) {
    print('reaction is: $reaction and value is: $isChecked');
    if (reaction != null && isChecked) {
      commentController.likeReactionAComment(
          commentId: comments.comment.id,
          communityId: postWithCommentController.post.communityId ?? '',
          reaction: reaction,
          isChecked: isChecked);
    } else if (isChecked == false) {
      commentController.unlikeReactionAComment(commentId: comments.comment.id, reaction: reaction, isChecked: isChecked);
    } else {
      print('Else case occured while reaction is: $reaction and value is: $isChecked');
    }
  }
}
