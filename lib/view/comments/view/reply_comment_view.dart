// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feed_reaction/flutter_feed_reaction.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/report_controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/controller/mentioned_user_controller.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_report_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_upload_document_madalsheet.dart';
import 'package:gaya/shared/view/widget/mentions_user_field_view.dart';
import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/comments/controller/comments_controller.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../controller/app_config_controller.dart';
import '../../../utils/strings.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../widgets/post.with.comments.widgets/actionrow.widget.dart';
import '../../../widgets/post.with.comments.widgets/comments.dart';
import '../components/speed_dial_button.dart';
import '../controller/post_with_comment_controller.dart';
import '../models/comment_custom_model.dart';
import 'comment_with_mediaview.dart';

class ReplyCommentView extends StatefulWidget {
  final Post postModel;
  final UserModel userModel;
  final int indexForComment;

  const ReplyCommentView({
    Key? key,
    required this.postModel,
    required this.userModel,
    required this.indexForComment,
  }) : super(key: key);

  @override
  State<ReplyCommentView> createState() => _ReplyCommentViewState();
}

class _ReplyCommentViewState extends State<ReplyCommentView> {
  final _replyCommentC = TextEditingController();
  final focusReplyC = FocusNode();
  late ScrollController repliesScroll;
  GlobalKey<FlutterMentionsState> textFormFieldKey = GlobalKey<FlutterMentionsState>();

  @override
  void dispose() {
    super.dispose();
    _replyCommentC.dispose();
    focusReplyC.dispose();
    repliesScroll.dispose();
    textFormFieldKey.currentState?.controller?.dispose();
  }

  @override
  void initState() {
    super.initState();
    repliesScroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (repliesScroll.hasClients) {
        repliesScroll.jumpTo(repliesScroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final PostWithCommentController postWithCommentController = PostWithCommentController.to(tag: widget.postModel.postid);
    final bodyReactionStyle = GayaTypography.caption.copyWith(color: AppColors.secondary);
    final primaryReactionStyle = GayaTypography.caption.copyWith(color: AppColors.primary);
    final yellowReactionStyle = GayaTypography.caption.copyWith(color: AppColors.warning);

    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: kBlackColor),
        title: Text(GayaStrings.comment_replies.tr, style: CustomTypography.bodyStyle),
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.25))),
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: repliesScroll,
              child: GetBuilder<CommentsController>(
                autoRemove: false,
                init: Get.find<CommentsController>(tag: widget.postModel.postid),
                builder: (controller) {
                  try {
                    MultiCommentModel comments = controller.allComments[widget.indexForComment];
                    UserModel commentBy = comments.comment.user;
                    //replies
                    List<CommentCustomModel> allReplies = comments.replies;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_10).r,
                      child: Column(
                        children: [
                          // parent comment
                          Column(
                            children: [
                              CommentSection(
                                showDialogBox: () {
                                  String? userUid = FirebaseAuth.instance.currentUser?.uid;
                                  bool isMyComment = comments.comment.user.uId == userUid ||
                                      widget.postModel.community.adminUid == userUid ||
                                      AppConfigurationController.to.isSuperAdmin;
                                  Methods.showModalSheetComment(context, () {
                                    reportTextFieldBottomModal(
                                      context,
                                      onSubmit: (String reportMsg) async {
                                        await ReportController.to.reportAComment(
                                          content: comments.comment.comment.toString(),
                                          reportedCommentId: comments.comment.id,
                                          context: context,
                                          reportMsg: reportMsg,
                                          postId: postWithCommentController.post.postid ?? "",
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                      commentId: comments.comment.id,
                                      postId: widget.postModel.postid ?? '',
                                      showReportOption: !isMyComment,
                                      onCommentDelete: isMyComment ? () => controller.deleteComment(comments.comment.id) : null);
                                },
                                nameOnTap: () {
                                  Routes.viewProfile(uid: comments.comment.user.uId, model: comments.comment.user);
                                },
                                userOntap: () {
                                  Routes.viewProfile(uid: commentBy.uId, model: commentBy);
                                },
                                anonymousPic: postWithCommentController.post.isPostedAnonymously,
                                userUid: commentBy.uId!,
                                uId: postWithCommentController.post.postedBy.uId,
                                profilepic: commentBy.profilePicture,
                                content: comments.comment.comment.toString(),
                                name: commentBy.name,
                                time: Jiffy(comments.comment.createdAt).fromNow(),
                                videoFile: comments.comment.videoFile,
                                photoFile: comments.comment.photoFile,
                                videoUrl: comments.comment.videoUrl,
                                photoUrl: comments.comment.photoUrl,
                                mentionedListUsers: comments.comment.mentionedUsers,
                                documentFile: comments.comment.documentFile,
                                gender: postWithCommentController.post.postedBy.gender,
                                pdfFiles: comments.comment.pdfFiles,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: distance_50),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: ActionRow(
                                    likeWidget: Row(
                                      children: [
                                        // like reaction button
                                        Builder(builder: (context) {
                                          Widget prefixWidget = Methods.getMyReactionIcon(comments.comment.reactionModel?.reaction,
                                              postReactionData: comments.comment.commentReactionData,
                                              iconSize: 13.r,
                                              shouldShowIcon: false);
                                          Widget suffixWidget = Methods.getMyReactionText(comments.comment.reactionModel?.reaction,
                                              postReactionData: comments.comment.commentReactionData,
                                              fontSize: 12.5.r,
                                              shouldShowNumbers: false);
                                          List<int>? reactionsCountList =
                                              Methods.getReactionsCountsList(postReactionData: comments.comment.commentReactionData);
                                          return FlutterFeedReaction(
                                            reactions: Methods.reactions,
                                            dragSpace: 30.0.r,
                                            dragStart: 90.0.r,
                                            reactionsCountList: reactionsCountList,
                                            onReactionSelected: (val) {
                                              if (comments.comment.reactionModel == null) {
                                                likeReactionOnParentCommentOnTap(
                                                    comments.comment.id, val.name, true, controller, postWithCommentController);
                                              } else if (comments.comment.reactionModel?.reaction == val.name) {
                                                likeReactionOnParentCommentOnTap(
                                                    comments.comment.id, val.name, false, controller, postWithCommentController);
                                              } else {
                                                likeReactionOnParentCommentOnTap(
                                                    comments.comment.id, val.name, true, controller, postWithCommentController);
                                              }
                                            },
                                            onPressed: () {
                                              if (comments.comment.reactionModel == null) {
                                                likeReactionOnParentCommentOnTap(
                                                    comments.comment.id, 'Like', true, controller, postWithCommentController);
                                              } else {
                                                likeReactionOnParentCommentOnTap(comments.comment.id,
                                                    comments.comment.reactionModel?.reaction, false, controller, postWithCommentController);
                                              }
                                            },
                                            prefix: prefixWidget,
                                            suffix: Padding(padding: const EdgeInsets.only(top: 1).r, child: suffixWidget),
                                            containerWidth: 195.r,
                                            spacing: 6.r,
                                          );
                                        }),
                                      ],
                                    ),
                                    flowerWidget: comments.comment.totalCrowns < 1
                                        ? Text(GayaStrings.crown_txt.tr, style: bodyReactionStyle)
                                        : Row(
                                            children: [
                                              Text(GayaStrings.crown_txt.tr,
                                                  style:
                                                      (comments.comment.isCrown) ? CustomTypography.yellowebodyStyle : bodyReactionStyle),
                                              const SizedBox(width: distance_5),
                                              CircleAvatar(
                                                  radius: 1, backgroundColor: (comments.comment.isCrown) ? kYellowColor : kBaseGrey),

                                              /// show icon if crownBy myself
                                              if (comments.comment.isCrown) ...[
                                                const SizedBox(width: distance_5),
                                                SvgIconWidget.crownFilledd(color: kYellowColor, height: 12.h, width: 14.h),
                                                const SizedBox(width: distance_5),
                                              ],
                                              Text(comments.comment.totalCrowns.toString(),
                                                  style: (comments.comment.isCrown)
                                                      ? CustomTypography.yellowebodyStyle
                                                      : CustomTypography.body3MStyle),
                                            ],
                                          ),
                                    likeOnTap: () {
                                      if (comments.comment.reactionModel == null) {
                                        likeReactionOnParentCommentOnTap(
                                            comments.comment.id, 'Like', true, controller, postWithCommentController);
                                      } else {
                                        likeReactionOnParentCommentOnTap(comments.comment.id, comments.comment.reactionModel?.reaction,
                                            false, controller, postWithCommentController);
                                      }
                                    },
                                    flowerOnTap: () async {
                                      if (comments.comment.isCrown) {
                                      } else if (comments.comment.user.uId == UserModel.to.uId) {
                                      } else if (UserModel.to.userDailyCrowns == 0) {
                                        Methods.showCrownsTotalModalSheet(ctx: Get.context);
                                      } else {
                                        controller.crownAComment(commentId: comments.comment.id, receiverUser: commentBy);
                                      }
                                    },
                                    replyOnTap: () {},
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
                          const SizedBox(height: distance_10),
                          // all replies
                          Padding(
                            padding: const EdgeInsets.only(left: distance_50),
                            child: ListView.separated(
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: allReplies.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, repliesIndex) {
                                UserModel replyBy = allReplies[repliesIndex].user;
                                CommentCustomModel reply = allReplies[repliesIndex];

                                return Column(
                                  children: [
                                    CommentSection(
                                      showDialogBox: () {
                                        String? userUid = FirebaseAuth.instance.currentUser?.uid;
                                        bool isMyComment = replyBy.uId == userUid ||
                                            widget.postModel.community.adminUid == userUid ||
                                            AppConfigurationController.to.isSuperAdmin;
                                        Methods.showModalSheetComment(context, () {
                                          reportTextFieldBottomModal(context, onSubmit: (String reportMsg) async {
                                            await ReportController.to.reportACommentReply(
                                              content: reply.comment.toString(),
                                              context: context,
                                              reportMsg: reportMsg,
                                              commentId: comments.comment.id,
                                              commentReplyId: reply.id,
                                              postId: widget.postModel.postid ?? "",
                                            );
                                            Navigator.pop(context);
                                          });
                                        },
                                            commentId: comments.comment.id,
                                            commentReplyId: reply.id,
                                            isReply: reply.id != null,
                                            postId: widget.postModel.postid ?? "",
                                            showReportOption: !isMyComment,
                                            onCommentDelete:
                                                isMyComment ? () => controller.deleteChildComment(comments.comment.id, reply.id) : null);
                                      },
                                      nameOnTap: () {
                                        Routes.viewProfile(uid: replyBy.uId, model: replyBy);
                                      },
                                      userOntap: () {
                                        Routes.viewProfile(uid: replyBy.uId, model: replyBy);
                                      },
                                      anonymousPic: widget.postModel.isPostedAnonymously ?? false,
                                      userUid: replyBy.uId ?? "",
                                      uId: widget.userModel.uId,
                                      profilepic: replyBy.profilePicture,
                                      content: reply.comment,
                                      name: (widget.postModel.isPostedAnonymously == true && widget.userModel.uId == reply.user.uId)
                                          ? replyBy.gender == null
                                              ? anonymousUser
                                              : replyBy.gender == 'male'
                                                  ? anonymousBoy
                                                  : replyBy.gender == 'female'
                                                      ? anonymousGirl
                                                      : anonymousUser
                                          : reply.user.name,
                                      time: Jiffy(reply.createdAt).fromNow(),
                                      videoFile: reply.videoFile,
                                      photoFile: reply.photoFile,
                                      videoUrl: reply.videoUrl,
                                      photoUrl: reply.photoUrl,
                                      mentionedListUsers: comments.comment.mentionedUsers,
                                      gender: replyBy.gender,
                                      documentFile: reply.documentFile,
                                      pdfFiles: reply.pdfFiles,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: distance_50),
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: ActionRow(
                                          likeWidget: Row(
                                            children: [
                                              // like reaction button
                                              Builder(builder: (context) {
                                                Widget prefixWidget = Methods.getMyReactionIcon(reply.reactionModel?.reaction,
                                                    postReactionData: reply.commentReactionData, iconSize: 13.r, shouldShowIcon: false);
                                                Widget suffixWidget = Methods.getMyReactionText(reply.reactionModel?.reaction,
                                                    fontSize: 12.5.sp,
                                                    postReactionData: reply.commentReactionData,
                                                    shouldShowNumbers: false);
                                                List<int>? reactionsCountList =
                                                    Methods.getReactionsCountsList(postReactionData: reply.commentReactionData);
                                                return FlutterFeedReaction(
                                                  reactions: Methods.reactions,
                                                  dragSpace: 30.0.r,
                                                  dragStart: 150.0.r,
                                                  reactionsCountList: reactionsCountList,
                                                  onReactionSelected: (val) {
                                                    if (reply.reactionModel == null) {
                                                      likeReactionOnReplyOnTap(comments.comment.id, reply.id, val.name, true, controller,
                                                          postWithCommentController);
                                                    } else if (reply.reactionModel?.reaction == val.name) {
                                                      likeReactionOnReplyOnTap(comments.comment.id, reply.id, val.name, false, controller,
                                                          postWithCommentController);
                                                    } else {
                                                      likeReactionOnReplyOnTap(comments.comment.id, reply.id, val.name, true, controller,
                                                          postWithCommentController);
                                                    }
                                                  },
                                                  onPressed: () {
                                                    if (reply.reactionModel == null) {
                                                      likeReactionOnReplyOnTap(comments.comment.id, reply.id, 'Like', true, controller,
                                                          postWithCommentController);
                                                    } else {
                                                      likeReactionOnReplyOnTap(comments.comment.id, reply.id, reply.reactionModel?.reaction,
                                                          false, controller, postWithCommentController);
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
                                                    Text(GayaStrings.crown_txt.tr,
                                                        style: (reply.isCrown) ? yellowReactionStyle : bodyReactionStyle),
                                                    const SizedBox(width: distance_5),
                                                    CircleAvatar(radius: 1, backgroundColor: (reply.isCrown) ? kYellowColor : kBaseGrey),

                                                    /// show icon if crownBy myself
                                                    if (reply.isCrown) ...[
                                                      const SizedBox(width: distance_5),
                                                      SvgIconWidget.crownFilledd(color: kYellowColor, height: 12.h, width: 14.h),
                                                      const SizedBox(width: distance_5),
                                                    ],
                                                    Text(reply.totalCrowns.toString(),
                                                        style: (reply.isCrown) ? yellowReactionStyle : bodyReactionStyle),
                                                  ],
                                                ),
                                          likeOnTap: () {
                                            if (reply.reactionModel == null) {
                                              likeReactionOnReplyOnTap(
                                                  comments.comment.id, reply.id, 'Like', true, controller, postWithCommentController);
                                            } else {
                                              likeReactionOnReplyOnTap(comments.comment.id, reply.id, reply.reactionModel?.reaction, false,
                                                  controller, postWithCommentController);
                                            }
                                          },
                                          flowerOnTap: () async {
                                            if (reply.isCrown) {
                                            } else if (reply.user.uId == UserModel.to.uId) {
                                            } else if (UserModel.to.userDailyCrowns == 0) {
                                              Methods.showCrownsTotalModalSheet(ctx: Get.context);
                                            } else {
                                              controller.crownAReplyComment(
                                                  commentId: comments.comment.id, replyCommentId: reply.id, receiverUser: reply.user);
                                            }
                                          },
                                          postReplyTap: () => Routes.createPost(
                                              community: postWithCommentController.post.community,
                                              from: PostCreationFrom.Community,
                                              commentData: PostReplyDataType(
                                                  postAuthorId: postWithCommentController.post.memberId,
                                                  commentAuthorId: reply.user.uId,
                                                  isAnonymousPost: postWithCommentController.post.isPostedAnonymously,
                                                  postType: PostCreationFrom.postReply.name,
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
                                                  commentTimeFromNow: reply.createdAt)
                                              // {
                                              //   // TODO
                                              //   'postType': PostCreationFrom.postReply.name,
                                              //   'comment': reply.mentionedUsers,
                                              //   'content': reply.comment,
                                              //   'profilePic': postWithCommentController.post.isPostedAnonymously == true
                                              //       ? postWithCommentController.post.postedBy.uId == reply.user.uId
                                              //           ? anonymousUser
                                              //           : replyBy.profilePicture
                                              //       : replyBy.profilePicture,
                                              //   'commentUserName': postWithCommentController.post.isPostedAnonymously == true
                                              //       ? postWithCommentController.post.postedBy.uId == reply.user.uId
                                              //           ? anonymousUser
                                              //           : reply.user.name
                                              //       : reply.user.name,
                                              //   'commentTime': Jiffy(reply.createdAt).fromNow(),
                                              //   'postId': postWithCommentController.post.postid,
                                              //   'commentId': reply.id
                                              // }
                                              ),
                                          postReplyWidget: Text(GayaStrings.post_reply.tr, style: bodyReactionStyle),
                                          textContent: reply.comment.toString(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: distance_20);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } catch (_) {
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * .79,
                      child: Center(child: Text(GayaStrings.no_comments_replies.tr)),
                    );
                  }
                },
              ),
            ),
          ),

          //textfield
          GetBuilder<CommentsController>(
              autoRemove: false,
              init: Get.find<CommentsController>(tag: widget.postModel.postid),
              builder: (controller) {
                return SafeArea(
                    child: //textfield
                        Container(
                  color: kWhiteColor,
                  padding: const EdgeInsets.symmetric(vertical: distance_15) + const EdgeInsets.only(left: distance_10),
                  child: Column(
                    children: [
                      // image and video showing area
                      if (controller.commentsMedia != null && controller.isVideo)
                        CommentMediaView(
                          mediaFile: controller.commentsMedia!,
                          isVideo: true,
                          tapOnImageRemove: () {
                            controller.removeSelectedCommentsMedia();
                          },
                        ),
                      if (controller.commentsMedia != null && !controller.isVideo)
                        CommentMediaView(
                          mediaFile: controller.commentsMedia!,
                          tapOnImageRemove: () {
                            controller.removeSelectedCommentsMedia();
                          },
                        ),
                      if (controller.isPdf && controller.pdfFiles.isNotEmpty)
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8).r,
                              child: LocalCommentPdfviewWidget(
                                path: controller.pdfFiles.first.path,
                                postId: widget.postModel.postid ?? '',
                                tapOnImageRemove: () {
                                  controller.removeSelectedCommentsMedia();
                                },
                              ),
                            )),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SpeedDialView(
                            tapOnPhoto: () async {
                              final commentController = Get.find<CommentsController>(tag: widget.postModel.postid);
                              await commentController.pickPhoto(context: context);
                            },
                            tapOnVideo: () async {
                              final commentController = Get.find<CommentsController>(tag: widget.postModel.postid);
                              await commentController.pickVideo(context: context);
                            },
                            tapOnDocument: () async {
                              final commentController = Get.find<CommentsController>(tag: widget.postModel.postid);
                              await commentController.getPdfDocument(context);
                              // ignore: use_build_context_synchronously
                              uploadDocumentModelSheet(context, isPost: false, postId: widget.postModel.postid ?? '',
                                  onSubmit: (String msg) async {
                                // Navigator.pop(context);
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GayaMentionedField(
                                autoFocus: true,
                                textFormFieldKey: textFormFieldKey,
                                fillColor: borderColor.withOpacity(0.50),
                                isFilled: true,
                                isPassword: false,
                                inputType: TextInputType.multiline,
                                hintText: GayaStrings.type_comment.tr,
                                borderColor: borderColor),
                          ),
                          // Expanded(
                          //   child: TextFormFieldComment(
                          //     fillColor: borderColor.withOpacity(0.50),
                          //     isFilled: true,
                          //     isPassword: false,
                          //     inputType: TextInputType.multiline,
                          //     hintText: 'Type your comment',
                          //     controller: _replyCommentC,
                          //     borderColor: borderColor,
                          //   ),
                          // ),
                          const SizedBox(width: distance_10),
                          TextButton(
                              onPressed: () async {
                                final commentController = Get.find<CommentsController>(tag: widget.postModel.postid);
                                final mentionedCntrl = Get.find<MentionedUserController>();

                                //increament the post

                                if (textFormFieldKey.currentState!.controller!.text.trim().isNotEmpty ||
                                    commentController.commentsMedia != null ||
                                    commentController.pdfFiles.isNotEmpty) {
                                  PostWithCommentController.to(tag: widget.postModel.postid).incrementCommentCount();
                                  commentController.postNewReply(
                                      myNewComment: textFormFieldKey.currentState!.controller!.text,
                                      commentIndex: widget.indexForComment,
                                      postModel: widget.postModel,
                                      mentionedUser: mentionedCntrl.mentionedUsers);
                                  _replyCommentC.clear();
                                  textFormFieldKey.currentState!.controller!.clear();
                                  mentionedCntrl.resetMentionedUser();

                                  FocusScope.of(context).unfocus();
                                }

                                // Function Ended
                              },
                              child: Text(GayaStrings.post_txt.tr, style: CustomTypography.body4KStylePrimary)),
                          SizedBox(
                            width: distance_10,
                            height: DeviceCheck.isIOS == true ? distance_5 : 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
              })
        ],
      ),
    );
  }

  // reaction/vibe on parent comments
  likeReactionOnParentCommentOnTap(String commentId, String? reaction, bool isChecked, CommentsController commentController,
      PostWithCommentController postWithCommentController) {
    if (reaction != null && isChecked) {
      commentController.likeReactionAComment(
          commentId: commentId, communityId: postWithCommentController.post.communityId ?? '', reaction: reaction, isChecked: isChecked);
    } else if (isChecked == false) {
      commentController.unlikeReactionAComment(commentId: commentId, reaction: reaction, isChecked: isChecked);
    } else {
      print('Else case occured while reaction is: $reaction and value is: $isChecked');
    }
  }

  // reaction/vibe on replies
  likeReactionOnReplyOnTap(String commentId, String replyId, String? reaction, bool isChecked, CommentsController commentController,
      PostWithCommentController postWithCommentController) {
    if (reaction != null && isChecked) {
      commentController.likeReactionACommentReply(
          commentId: commentId,
          replyId: replyId,
          communityId: postWithCommentController.post.communityId ?? '',
          reaction: reaction,
          isChecked: isChecked);
    } else if (isChecked == false) {
      commentController.unlikeReactionACommentReply(
          commentId: commentId,
          replyId: replyId,
          communityId: postWithCommentController.post.communityId ?? '',
          reaction: reaction,
          isChecked: isChecked);
    } else {
      print('Else case occured while reaction is: $reaction and value is: $isChecked');
    }
  }
}
