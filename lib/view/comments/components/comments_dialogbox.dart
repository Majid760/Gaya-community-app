import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/app.dart';
import 'package:gaya/components/skeleton.post.component.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/controller/mentioned_user_controller.dart';
import 'package:gaya/shared/view/widget/gaya_upload_document_madalsheet.dart';
import 'package:gaya/shared/view/widget/mentions_user_field_view.dart';
import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/refresh_builder_utils.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/comments/components/comments_listview.dart';
import 'package:gaya/view/comments/components/speed_dial_button.dart';
import 'package:gaya/view/comments/controller/comments_controller.dart';
import 'package:gaya/view/comments/controller/post_with_comment_controller.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/comments/view/comment_with_mediaview.dart';
import 'package:get/get.dart';

import '../bindings/comments_bindings.dart';

class CommentsDialogBox extends StatefulWidget {
  const CommentsDialogBox({Key? key, required this.postModel}) : super(key: key);
  final Post postModel;

  @override
  State<CommentsDialogBox> createState() => _CommentsDialogBoxState();
}

class _CommentsDialogBoxState extends State<CommentsDialogBox> {
  late CommentsController commentController;
  late PostWithCommentController postController;
  late MentionedUserController mentionedCntrl;

  @override
  void initState() {
    final postId = widget.postModel.postid;
    CommentBindings.initControllers(widget.postModel);
    commentController =
        CommentsController.to(tag: postId); //Get.put(CommentsController(post: widget.postModel), tag: widget.postModel.postid ?? "");
    postController = PostWithCommentController.to(
        tag: postId); // Get.put(PostWithCommentController(post: widget.postModel), tag: widget.postModel.postid ?? "");
    mentionedCntrl = Get.put(MentionedUserController());

    super.initState();
  }

  @override
  void dispose() {
    CommentBindings.deleteControllers(widget.postModel.postid);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentsController>(
        autoRemove: false,
        tag: widget.postModel.postid ?? "",
        init: commentController,
        builder: (controller) {
          return controller.isLoading
              ? SizedBox(height: 625.r, width: 353.r, child: const CommentsSkeleton())
              : Container(
                  color: AppColors.white,
                  height: 625.r,
                  width: 353.r,
                  child: Column(
                    children: [
                      Expanded(
                        child: EasyRefresh.builder(
                          key: ValueKey("postWithComments_${controller.post.postid}"),
                          simultaneously: true,
                          controller: controller.refreshController,
                          header: RefreshBuilderUtils.headerAbove,
                          footer: RefreshBuilderUtils.footerAbove,
                          onLoad: () async {
                            final isCommentsFetched = await controller.requestMoreComments();
                            if (isCommentsFetched == false) {
                              return IndicatorResult.noMore;
                            }
                          },
                          childBuilder: (context, physics) {
                            return controller.allComments.isEmpty
                                ? const SizedBox.shrink()
                                : ListView.separated(
                                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                    physics: physics,
                                    itemCount: controller.allComments.length,
                                    itemBuilder: (context, index) {
                                      MultiCommentModel comments = controller.allComments[index];
                                      UserModel commentBy = comments.comment.user;
                                      List<CommentCustomModel> allReplies = comments.replies;
                                      return ParentCommentsListView(
                                        comments: comments,
                                        commentBy: commentBy,
                                        allReplies: allReplies,
                                        index: index,
                                        postWithCommentController: postController,
                                        commentController: commentController,
                                        post: widget.postModel,
                                        actionRowChildPadding: 3.r,
                                      );
                                    },
                                    separatorBuilder: (context, index) => const SizedBox(height: distance_5),
                                  );
                          },
                        ),
                      ),

                      /// Comment field
                      SafeArea(
                        child: _CommentField(
                          postId: widget.postModel.postid ?? "",
                          postWithCommentController: postController,
                          commentsController: commentController,
                          mentionedCntrl: mentionedCntrl,
                        ),
                      ),
                    ],
                  ),
                );
        });
  }
}

/// A comment Field for Post with > 0 comments
class _CommentField extends StatefulWidget {
  final String postId;
  final MentionedUserController mentionedCntrl;
  final PostWithCommentController postWithCommentController;
  final CommentsController commentsController;

  const _CommentField({
    Key? key,
    required this.postId,
    required this.postWithCommentController,
    required this.commentsController,
    required this.mentionedCntrl,
  }) : super(key: key);

  @override
  State<_CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<_CommentField> {
  final GlobalKey<FlutterMentionsState> textFormFieldKey = GlobalKey<FlutterMentionsState>();
  final TextEditingController _commentC = TextEditingController();
  bool showProgressindicator = false;

  bool toggleDM = false;

  @override
  Widget build(BuildContext context) {
    Post createPostModel = widget.postWithCommentController.post;
    UserModel userModel = createPostModel.postedBy;
    return GetBuilder<PostWithCommentController>(
        autoRemove: false,
        tag: widget.postId,
        init: widget.postWithCommentController,
        builder: (postWithCommentController) {
          if (postWithCommentController.isLoading || postWithCommentController.post.postid == null) {
            return const SizedBox.shrink();
          }

          // if post is null or user is not a member of the community
          if (postWithCommentController.post.postid == null) {
            return const SizedBox.shrink();
          }

          /// if user is not member of community then show no found view.
          /// if community is not public then show this no found view aswell.
          else if (!(postWithCommentController.isMemberOfCommunity) && !postWithCommentController.isCommunityPublic) {
            /// Register crashlytics error for page not found error
            /// this error is thrown when the post is null or user is not a member of the community
            CrashlyticsController.to.instance.recordError(
              "page_not_found",
              reason:
                  "postId=${widget.postId}/communityId=${postWithCommentController.post.communityId}/userId=${UserModel.to.uId} => post is null or user is not a member of the community",
            );
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Container(
                color: kWhiteColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                ).r,
                child: Column(
                  children: [
                    // image and video showing area
                    GetBuilder<CommentsController>(
                        autoRemove: false,
                        tag: widget.postId,
                        init: widget.commentsController,
                        builder: (CommentsController controller) {
                          if (controller.commentsMedia != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CommentMediaView(
                                mediaFile: controller.commentsMedia!,
                                isVideo: controller.isVideo,
                                tapOnImageRemove: () => controller.removeSelectedCommentsMedia(),
                              ),
                            );
                          } else if (controller.isPdf && controller.pdfFiles.isNotEmpty) {
                            return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8).r,
                                  child: LocalCommentPdfviewWidget(
                                    path: controller.pdfFiles.first.path,
                                    postId: widget.postId,
                                    tapOnImageRemove: () {
                                      controller.removeSelectedCommentsMedia();
                                    },
                                  ),
                                ));
                          }
                          return const SizedBox.shrink();
                        }),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // const SizedBox(width: distance_5),
                        // const SizedBox(width: distance_10),
                        SpeedDialView(
                          tapOnPhoto: () async {
                            await widget.commentsController.pickPhoto(context: context);
                          },
                          tapOnVideo: () async {
                            await widget.commentsController.pickVideo(context: context);
                          },
                          tapOnDocument: () async {
                            final docFile = await widget.commentsController.getPdfDocument(context);
                            if (docFile == null) return;
                            // ignore: use_build_context_synchronously
                            uploadDocumentModelSheet(
                              context,
                              isPost: false,
                              postId: widget.postId,
                              onSubmit: (String msg) async {
                                // Navigator.pop(context);
                              },
                            );
                          },
                        ),
                        const SizedBox(width: distance_10),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40.h,
                                  child: GayaMentionedField(
                                      autoFocus: postWithCommentController.shouldFocusKeyboard,
                                      textFormFieldKey: textFormFieldKey,
                                      fillColor: borderColor.withOpacity(0.50),
                                      isFilled: true,
                                      isPassword: false,
                                      inputType: TextInputType.multiline,
                                      hintText: toggleDM ? GayaStrings.type_message.tr : GayaStrings.type_comment.tr,
                                      borderColor: borderColor),
                                ),
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: kSecondaryColor,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                  ),
                                  onPressed: () async {
                                    //increament the post
                                    final newCommentId = uuid.v1();

                                    if (textFormFieldKey.currentState!.controller!.text.trim().isNotEmpty ||
                                        widget.commentsController.commentsMedia != null ||
                                        widget.commentsController.pdfFiles.isNotEmpty) {
                                      await widget.mentionedCntrl.getMentionedUserAndCommunity().then((value) {
                                        PostWithCommentController.to(tag: widget.postId).incrementCommentCountAndUpdateRecentCommentsList(
                                            newCommentId,
                                            widget.mentionedCntrl.commentData,
                                            (widget.commentsController.pdfFiles.isNotEmpty)
                                                ? 4
                                                : (widget.commentsController.isVideo == true)
                                                    ? 3
                                                    : (widget.commentsController.commentsMedia != null &&
                                                            !widget.commentsController.isVideo &&
                                                            !widget.commentsController.isPdf == true)
                                                        ? 2
                                                        : 1,
                                            widget.mentionedCntrl.mentionedUsers);
                                        widget.commentsController.postNewComment(
                                            newCommentId: newCommentId,
                                            myNewComment: widget.mentionedCntrl.commentData,
                                            // myNewComment: textFormFieldKey.currentState!.controller!.text,
                                            mentionedUser: widget.mentionedCntrl.mentionedUsers);
                                        textFormFieldKey.currentState!.controller!.clear();
                                        widget.mentionedCntrl.resetMentionedUser();
                                        _commentC.clear();
                                      });
                                      FocusScope.of(context).unfocus();
                                      // _commentsParentScrollController.animateTo(
                                      //   _commentsParentScrollController.position.maxScrollExtent,
                                      //   duration: const Duration(milliseconds: 500),
                                      //   curve: Curves.easeOut,
                                      // );
                                    }
                                    // Function Ended
                                  },
                                  child: showProgressindicator
                                      ? const CircularProgressIndicator()
                                      : Text(toggleDM ? GayaStrings.send_txt.tr : GayaStrings.post_txt.tr,
                                          style: CustomTypography.body4KStylePrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}
