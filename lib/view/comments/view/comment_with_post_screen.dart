// ignore_for_file: use_build_context_synchronously

import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/app.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/report_controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/controller/mentioned_user_controller.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_upload_document_madalsheet.dart';
import 'package:gaya/shared/view/widget/mentions_user_field_view.dart';
import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/comments/bindings/comments_bindings.dart';
import 'package:gaya/view/comments/controller/comments_controller.dart';
import 'package:gaya/view/comments/controller/post_with_comment_controller.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/not_found_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/skeleton.post.component.dart';
import '../../../controller/app_config_controller.dart';
import '../../../controller/create.post.controller.dart';
import '../../../controller/group.controller.dart';
import '../../../controller/homepage.controller.dart';
import '../../../model/community.model.dart';
import '../../../shared/service/message_service/message_service.dart';
import '../../../shared/view/widget/gaya_snackbar.dart';
import '../../../utils/refresh_builder_utils.dart';
import '../../../widgets/home_view_widgets/home.post.widget.dart';
import '../components/comments_listview.dart';
import '../components/speed_dial_button.dart';
import 'comment_with_mediaview.dart';

/// A Parent Screen for comments and post
class CommentWithPostIOSScreen extends StatefulWidget {
  const CommentWithPostIOSScreen({Key? key}) : super(key: key);

  @override
  State<CommentWithPostIOSScreen> createState() => _CommentWithPostIOSScreenState();
}

class _CommentWithPostIOSScreenState extends State<CommentWithPostIOSScreen> {
  final TextEditingController _commentC = TextEditingController();
  GlobalKey<FlutterMentionsState> textFormFieldKey = GlobalKey<FlutterMentionsState>();

  /// getting postID from get arguments
  /// this is the postID of the post that is being commented on
  late String? postId;
  bool autoFocus = true;

  @override
  void initState() {
    super.initState();
    postId = (Get.arguments["post"] as Post).postid;
  }

  @override
  void dispose() {
    super.dispose();
    _commentC.dispose();
    textFormFieldKey.currentState?.controller?.dispose();
    CommentBindings.deleteControllers(postId);
  }

  Future<bool> _onBackPressed() {
    try {
      final postWithCommentController = PostWithCommentController.to(tag: postId);
      debugPrint("postWithCommentController.post: ${postWithCommentController.post}");
      Get.back(result: postWithCommentController.post);
    } catch (_, s) {
      Get.back();
    }
    return Future.value(true);
  }

  double dragStartX = 0;

  void handleDragEnd(DragEndDetails details) {
    if (dragStartX < 100) {
      _onBackPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final PostWithCommentController postWithCommentController = PostWithCommentController.to(tag: postId);
    final CommentsController commentsController = CommentsController.to(tag: postId);
    final mentionedCntrl = Get.find<MentionedUserController>();
    debugPrint("build comment_with_post_screen.dart");

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          HapticFeedback.mediumImpact();
          dragStartX = details.localPosition.dx;
        },
        onHorizontalDragEnd: handleDragEnd,
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              iconTheme: const IconThemeData(color: kBlackColor),
              shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.25))),
              automaticallyImplyLeading: false,
              leading: GayaBackButton(onPop: () => _onBackPressed()),
              backgroundColor: kTransparentColor,
              elevation: 0),
          body: Column(
            children: [
              /// Post Tile
              Expanded(
                child: GetBuilder<PostWithCommentController>(
                  init: postWithCommentController,
                  tag: postId,
                  autoRemove: false,
                  builder: (controller) {
                    if (postWithCommentController.isLoading) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
                        child: Column(
                          children: [
                            const PostsSkeleton(),
                            SizedBox(
                              height: 20.r,
                            ),
                            const Expanded(child: CommentsSkeleton()),
                          ],
                        ),
                      );
                    }

                    // if post is null that means the post is deleted
                    if (postWithCommentController.post.postCreatedOn == null && postWithCommentController.post.postDescription == null ||
                        postWithCommentController.post.postid == null) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NotFoundView.noScaffold(),
                      );
                    }

                    /// if user is not member of community then show no found view.
                    /// if community is not public then show this no found view aswell.
                    else if (postWithCommentController.post.isDeleted == true ||
                        !(postWithCommentController.isMemberOfCommunity) && !postWithCommentController.isCommunityPublic) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NotFoundView.noScaffold(),
                      );
                    }

                    Post createPostModel = controller.post;
                    double totalCommentsCount = double.parse(createPostModel.totalCommentsCount ?? "0");

                    return totalCommentsCount == 0
                        ? PostWithNoCommentsWidget(
                            post: createPostModel,
                            commentC: _commentC,
                            postController: controller,
                            commentController: commentsController,
                            mentionedCntrl: mentionedCntrl,
                          )
                        : PostWithCommentWidget(
                            post: createPostModel,
                            commentController: commentsController,
                            commentC: _commentC,
                            postController: controller,
                            mentionedCntrl: mentionedCntrl,
                          );
                  },
                ),
              ),

              /// Comment field
              SafeArea(
                child: _CommentField(
                  postId: postId ?? "",
                  postWithCommentController: postWithCommentController,
                  commentsController: commentsController,
                  mentionedCntrl: mentionedCntrl,
                ),
              ),
            ],
          ),
          /*   bottomNavigationBar: _CommentField(
            postId: postId ?? "",
            postWithCommentController: postWithCommentController,
            commentsController: commentsController,
            mentionedCntrl: mentionedCntrl,
          ),*/
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// PRIVATE WIDGETS /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///  PostWithNoCommentWidget - used as scaff body
class PostWithNoCommentsWidget extends StatelessWidget {
  final Post post;
  final PostWithCommentController postController;
  final CommentsController commentController;
  final TextEditingController commentC;
  final GlobalKey<FlutterMentionsState> textFormFieldKey = GlobalKey<FlutterMentionsState>();
  final MentionedUserController mentionedCntrl;

  PostWithNoCommentsWidget(
      {Key? key,
      required this.post,
      required this.commentController,
      required this.commentC,
      required this.postController,
      required this.mentionedCntrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight), child: _PostTileForComment(controller: postController)),
        );
      },
    );
  }
}

class PostWithCommentWidget extends StatelessWidget {
  final Post post;
  final PostWithCommentController postController;
  final CommentsController commentController;
  final TextEditingController commentC;
  final GlobalKey<FlutterMentionsState> textFormFieldKey = GlobalKey<FlutterMentionsState>();
  final MentionedUserController mentionedCntrl;

  PostWithCommentWidget(
      {Key? key,
      required this.post,
      required this.commentController,
      required this.commentC,
      required this.postController,
      required this.mentionedCntrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalCommentsCount = double.parse(post.totalCommentsCount ?? "0");
    return GetBuilder<CommentsController>(
        tag: post.postid,
        autoRemove: false,
        init: commentController,
        builder: (controller) {
          return AbsorbPointer(
            absorbing: controller.isLoading,
            child: NestedScrollView(
                physics: totalCommentsCount > 2 ? null : const NeverScrollableScrollPhysics(),
                headerSliverBuilder: (_, __) {
                  return [
                    SliverToBoxAdapter(
                      child: AppConfigurationController.to.isUserBlockedAlready(userId: post.postedBy.uId ?? "")
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                _PostTileForComment(controller: postController),
                                const Divider(color: kSecondaryLightColor, thickness: 1.0, height: 1),
                                const SizedBox(height: MySpaces.gap3),
                              ],
                            ),
                    )
                  ];
                },
                body: controller.isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: distance_15, vertical: distance_10),
                        child: CommentsSkeleton(),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: EasyRefresh.builder(
                              key: ValueKey("postWithComment_${controller.post.postid}"),
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
                                        physics: totalCommentsCount > 2 ? physics : const NeverScrollableScrollPhysics(),
                                        itemCount: controller.allComments.length,
                                        padding: const EdgeInsets.symmetric(horizontal: distance_20).r,
                                        itemBuilder: (context, index) {
                                          MultiCommentModel comments = controller.allComments[index];
                                          UserModel commentBy = comments.comment.user;
                                          //replies
                                          List<CommentCustomModel> allReplies = comments.replies;
                                          return ParentCommentsListView(
                                            comments: comments,
                                            commentBy: commentBy,
                                            allReplies: allReplies,
                                            index: index,
                                            postWithCommentController: postController,
                                            commentController: commentController,
                                            post: post,
                                          );
                                        },
                                        separatorBuilder: (context, index) => const SizedBox(height: distance_5),
                                      );
                              },
                            ),
                          ),
                        ],
                      )),
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
          // if post is null that means the post is deleted
          if (postWithCommentController.post.postCreatedOn == null && postWithCommentController.post.postDescription == null ||
              postWithCommentController.post.postid == null) {
            return const SizedBox.shrink();
          }

          /// if user is not member of community then show no found view.
          /// if community is not public then show this no found view aswell.
          else if (postWithCommentController.post.isDeleted == true ||
              !(postWithCommentController.isMemberOfCommunity) && !postWithCommentController.isCommunityPublic) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Container(
                color: kWhiteColor,
                padding: const EdgeInsets.only(
                  top: distance_8,
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
                        const SizedBox(width: distance_10),
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
                                  style: GayaButtonStyles.actionRowTextButtonStyle2,
                                  onPressed:
                                      //
                                      toggleDM
                                          ? () async {
                                              if (textFormFieldKey.currentState!.controller!.text.isEmpty || showProgressindicator) {
                                                return;
                                              }
                                              final mentionedCntrl = Get.find<MentionedUserController>();
                                              setState(() {
                                                showProgressindicator = true;
                                              });
                                              if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
                                                final canSend = await _canSendMessage(userModel, context);

                                                /// if cant, return the loader to default and stop
                                                if (!canSend) {
                                                  setState(() {
                                                    showProgressindicator = false;
                                                  });

                                                  /// stop it here~~
                                                  return;
                                                }

                                                /// if can, continue

                                                String type = 'post';

                                                ChatController.to().helperFunc.createNewChatAndSendMessage(
                                                    context, userModel.uId ?? '', createPostModel.postid ?? '', type,
                                                    attachmentData: createPostModel.postid ?? '',
                                                    post: createPostModel,
                                                    simplePostTextMessage: textFormFieldKey.currentState!.controller!.text);
                                              }
                                              Future.delayed(const Duration(seconds: 3)).then((value) => setState(() {
                                                    showProgressindicator = false;
                                                    _commentC.clear();
                                                    toggleDM = false;
                                                    mentionedCntrl.resetMentionedUser();
                                                    textFormFieldKey.currentState!.controller!.clear();
                                                    FocusScope.of(context).unfocus();
                                                  }));
                                            }
                                          : () async {
                                              //increament the post
                                              final newCommentId = uuid.v1();

                                              if (textFormFieldKey.currentState!.controller!.text.trim().isNotEmpty ||
                                                  widget.commentsController.commentsMedia != null ||
                                                  widget.commentsController.pdfFiles.isNotEmpty) {
                                                await widget.mentionedCntrl.getMentionedUserAndCommunity().then((value) {
                                                  PostWithCommentController.to(tag: widget.postId)
                                                      .incrementCommentCountAndUpdateRecentCommentsList(
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
                                              }
                                            },
                                  child: showProgressindicator
                                      ? const CupertinoActivityIndicator()
                                      : Text(toggleDM ? GayaStrings.send_txt.tr : GayaStrings.post_txt.tr,
                                          style: CustomTypography.body4KStylePrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MySpaces.gap2),
                    Visibility(
                      visible: widget.commentsController.isPostDMEnabled &&
                          !postWithCommentController.post.isPostedAnonymously! &&
                          UserModel.to.uId != userModel.uId,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              GayaStrings.send_msg_dm.tr,
                              style: TextStyle(fontSize: 14.sp, fontFamily: GayaFontTheme.primaryFont, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 30.r,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch.adaptive(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  activeColor: kprimaryColor,
                                  value: toggleDM,
                                  onChanged: (value) => setState(() => toggleDM = value),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }

  /// returns true if user can send a message
  ///
  /// A Gateway to check if user can send a message or not
  Future<bool> _canSendMessage(UserModel user, BuildContext ctx) async {
    try {
      final error = await MessageUtils.canSendAMessage(user: user);
      if (error != null) {
        GayaSnackBar.show(context: ctx, text: error, type: GayaSnackBarType.error);
        return false;
      }
      return true;
    } catch (e) {
      GayaSnackBar.show(context: ctx, text: e.toString(), type: GayaSnackBarType.error);
      return false;
    }
  }
}

class _PostTileForComment extends StatelessWidget {
  final PostWithCommentController controller;

  const _PostTileForComment({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Post createPostModel = controller.post;
    Community createCommunityModel = createPostModel.community;
    UserModel userModel = createPostModel.postedBy;

    return HomePostWidget(
      /// COMMENTED For INFLUENCE BAR
      // influence points widget based on Influence Points
      // influenceIcon: (userModel.isUserInfluencePointsValid) ? userModel.getUserInfluencePointsIndicator : null,
      // isModerator:
      //     AppConfigurationController.to.isAdminOrModerator(communityId: createPostModel.communityId),
      pdfFiles: createPostModel.pdfFiles,
      onDeleteTap: () async {
        Navigator.pop(context);
        await context.read<GroupController>().deleteYourPost(
              createPostModel.postid!,
              context,
              createCommunityModel.communityId,
            );
        controller.deletePostFromFeeds(post: createPostModel);
        Navigator.pop(context);
      },
      postModel: createPostModel,
      createdAt: createPostModel.approvedAt,
      anonymousPost: createPostModel.isPostedAnonymously,
      currentUserPost: createPostModel.memberId == FirebaseAuth.instance.currentUser?.uid ? true : false,
      hasVideo: (createPostModel.video == null || createPostModel.video == '') ? false : true,
      videoLink: createPostModel.video,
      onTap: null,
      crossAxis: createPostModel.multipleImages == null
          ? 1
          : createPostModel.multipleImages!.length < 2
              ? 1
              : 2,
      imageTap: (createPostModel.multipleImages?.isEmpty ?? true)
          ? null
          : () {
              Routes.openMultipleImages(urls: createPostModel.multipleImages ?? []);
            },
      onUserTap: () {
        Methods.showModalSheetToJoinCommunity(
            communityModel: createCommunityModel, communityId: createCommunityModel.communityId, ctx: context);
      },
      //=> Methods.routeToGroup(community: createCommunityModel),
      // Routes.groupView(community: createCommunityModel),
      approvalShow: false,
      doNotshowBottomrow: false,
      isPostHasImage: createPostModel.multipleImages == null
          ? false
          : createPostModel.multipleImages!.isEmpty == true
              ? false
              : true,
      savePostColor: kSecondaryColor,
      totalLikesCount: createPostModel.likedBy?.length.toString() ?? "0",
      totalCommentsCount: createPostModel.totalCommentsCount ?? "0",
      overlapImage: GestureDetector(
        onTap: () {
          if (createPostModel.isPostedAnonymously == true) {
          } else {
            Routes.viewProfile(uid: userModel.uId ?? "", model: userModel);
          }
        },
        child: createPostModel.isPostedAnonymously == true
            ? CircleAvatar(
                radius: 17.r,
                backgroundImage: AssetImage(
                  createPostModel.postedBy.gender == null
                      ? "Assets/images/anonymous_user.png"
                      : createPostModel.postedBy.gender == 'male'
                          ? "Assets/images/anonymous_boy.png"
                          : createPostModel.postedBy.gender == 'female'
                              ? "Assets/images/anonymous_girl.png"
                              : "Assets/images/anonymous_user.png",
                ),
                backgroundColor: kBaseGrey,
              )
            : userModel.profilePicture == ''
                ? CircleAvatar(
                    radius: 17.r,
                    backgroundColor: kBaseGrey,
                    backgroundImage: const AssetImage('Assets/images/user.png'),
                  )
                : CircleAvatar(
                    backgroundColor: kWhiteColor,
                    radius: 17.r,
                    child: ProfileImageWidget(
                      url: userModel.profilePicture,
                      size: const Size(48, 48),
                    ),
                  ),
      ),
      postId: createPostModel.postid,
      likeIconColor: createPostModel.likedBy?.contains(UserModel.to.uId) == true ? kRedColor : kSecondaryColor,

      groupImage: createCommunityModel.CommunityPic.toString(),
      title: createCommunityModel.communityName.toString(),
      content: createPostModel.postDescription.toString(),
      postImage: createPostModel.multipleImages ?? [],
      subtitle: createPostModel.isPostedAnonymously == true
          ? createPostModel.postedBy.gender == null
              ? anonymousUser
              : createPostModel.postedBy.gender == 'male'
                  ? anonymousBoy
                  : createPostModel.postedBy.gender == 'female'
                      ? anonymousGirl
                      : anonymousUser
          : userModel.name.toString(),
      profileImage: userModel.profilePicture,
      commentOntap: null,
      report: () {
        if (createPostModel.postid == null) return;
        Navigator.of(context).pop();
        ReportController.to.reportPost(createPostModel.postid ?? "", context, createPostModel.community.adminUid,
            communityId: createPostModel.community.communityId ?? "");
      },
      onTapSaved: () async {
        if (AppConfigurationController.to.savedPostsID.contains(createPostModel.postid) == true) {
          Navigator.pop(context);
          AppConfigurationController.to.savedPostsID.remove(createPostModel.postid);
          await context.read<HomePageController>().deleteUserSaveDocFromPostCollection(createPostModel.postid!, context);

          // Logging un-save post analytics event
          AnalyticsController.to.instance.logSaveOrUnSavePost(
            eventType: 'un_save',
            userId: UserModel.to.uId ?? '',
            communityId: createPostModel.communityId ?? '',
            postId: createPostModel.postid ?? '',
          );
          await context.read<HomePageController>().deletePostFromUserCollection(createPostModel.postid!);
        } else {
          Navigator.pop(context);
          AppConfigurationController.to.savedPostsID.add(createPostModel.postid ?? "");
          await context.read<CreatePostController>().savePost(createPostModel.postid!);

          // Logging save post analytics event
          AnalyticsController.to.instance.logSaveOrUnSavePost(
            eventType: 'save',
            userId: UserModel.to.uId ?? '',
            communityId: createPostModel.community.communityId ?? '',
            postId: createPostModel.postid ?? '',
          );
          await context.read<HomePageController>().setSavePostInUSerCollection({
            'postId': createPostModel.postid,
            'communityId': createCommunityModel.communityId,
            'userUid': UserModel.to.uId,
          }, context);
        }
      },

      //void call back on flower on tap
      // likeOnTap: () async {
      //   if (createPostModel.likedBy?.contains(UserModel.to.uId) == false) {
      //     controller.likePost();
      //   } else {
      //     controller.unlikePost();
      //   }
      // },
      // like reaction on tap
      likeReactionOnTap: (reaction, isChecked) async {
        if (isChecked) {
          controller.likeReactionOnPost(reaction: reaction, isChecked: isChecked);
        } else {
          controller.unlikeReactionOnPost(reaction: reaction, isChecked: isChecked);
        }
      },

      totalCrownsCount: createPostModel.crownsBy?.length.toString() ?? "0",
      posterCrownsCount: userModel.userTotalCrowns?.toString() ?? "0",

      isCrowned: createPostModel.crownsBy?.contains(UserModel.to.uId) == true ? true : false,
      //void call back on crown on tap
      crownOnTap: () async {
        if (UserModel.to.userDailyCrowns == null &&
                createPostModel.crownsBy?.contains(UserModel.to.uId) == false &&
                userModel.uId != UserModel.to.uId ||
            UserModel.to.userDailyCrowns == 0 &&
                createPostModel.crownsBy?.contains(UserModel.to.uId) == false &&
                userModel.uId != UserModel.to.uId) {
          Methods.showCrownsTotalModalSheet(ctx: Get.context);
          return;
        }
        if (createPostModel.crownsBy == null && userModel.uId != UserModel.to.uId) {
          controller.crownPost(createPostModel.postid, receiverUser: createPostModel.postedBy);
        } else if (createPostModel.crownsBy!.contains(UserModel.to.uId) || userModel.uId == UserModel.to.uId) {
        } else {
          controller.crownPost(createPostModel.postid, receiverUser: createPostModel.postedBy);
        }
      },
      onManageTopics: () {
        Navigator.pop(context);
        Methods.showTopicPostUpdateModalSheet(
            community: createCommunityModel,
            post: createPostModel,
            context: context,
            onDoneButtonPressed: (updatedPost) => controller.updatePostTopicsFirebase(updatedPost));
      },
    );
  }
}
