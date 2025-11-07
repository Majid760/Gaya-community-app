// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/helper/pick.image.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/view/create_post/widgets/draggable_bottom_sheet.dart';
import 'package:gaya/view/create_post/widgets/post_poll_widgets/poll_tile_widget.dart';
import 'package:gaya/view/create_post/widgets/post_with_vibes_widgets/post_type_card_builder_widget.dart';
import 'package:gaya/view/create_post/widgets/post_with_vibes_widgets/post_with_vibes_widget.dart';
import 'package:gaya/widgets/create_recipe_widgets/choose.group.sheet.dart';
import 'package:gaya/widgets/create_recipe_widgets/multiple_files_post.dart';
import 'package:gaya/widgets/create_recipe_widgets/pick.button.dart';
import 'package:gaya/widgets/create_recipe_widgets/picked.video.widget.dart';
import 'package:gaya/widgets/post.with.comments.widgets/reply_comment_post_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../components/gradient_text_widget.dart';
import '../../controller/app_config_controller.dart';
import '../../controller/create.post.controller.dart';
import '../../model/communities.memebers.model.dart';
import '../../widgets/create_recipe_widgets/show.groups.dart';
import 'controller/new_post_creation_controller.dart';

class CreatePostView extends StatefulWidget {
  final Community? communityModel;
  final PostCreationFrom from;
  final PostReplyDataType? commentData;

  const CreatePostView({Key? key, this.communityModel, this.commentData, required this.from}) : super(key: key);

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  late CreatePostController createPostController;
  final user = FirebaseAuth.instance.currentUser;
  late Future<List<Community>> joinedCommunitiesQuery;

  List<Map<String, dynamic>> emojis = [
    {'postType': 'vibe', 'name': 'surprise', 'emoji': '😍'},
    {'postType': 'vibe', 'name': 'sad', 'emoji': '😥'},
    {'postType': 'vibe', 'name': 'happy', 'emoji': '😂'},
    {'postType': 'vibe', 'name': 'wow', 'emoji': '😮'},
    {'postType': 'vibe', 'name': 'angry', 'emoji': '😡'},
  ];

  @override
  void initState() {
    Get.lazyPut<PostWithVibeController>(() => PostWithVibeController(), fenix: true);
    joinedCommunitiesQuery = AppConfigurationController.to.getMyJoinedCommunities();
    createPostController = Provider.of<CreatePostController>(context, listen: false);
    context.read<CreatePostController>().indexe = 0;
    context.read<CreatePostController>().selectedCommunity.clear();
    context.read<CreatePostController>().getAllUserCommunities();
    context.read<CreatePostController>().userDetails();
    context.read<CreatePostController>().userCommuniteis;
    context.read<CreatePostController>().getAdmin(widget.communityModel?.communityId);

    /// reset state to default to remove
    /// all previous data from create post screen
    /// ie: when user comes from home screen to create post screen etc.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreatePostController>().resetState();
    });
    super.initState();
  }

  @override
  void dispose() {
    /// close keyboard before going from this screen
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  final ImagePickerHelper imagePickerHelper = ImagePickerHelper();

  // checking changes while creating new post and resetting its state
  void checkCreatePostChanges(context) async {
    bool shouldPop = Provider.of<CreatePostController>(context, listen: false).isOldState;
    if (shouldPop) {
      Navigator.pop(context);
    } else {
      showGayaAlertDialogButton(
        context: context,
        actionText: GayaStrings.discard_changes.tr,
        tapOnYes: () async {
          Navigator.pop(context);
          await Provider.of<CreatePostController>(context, listen: false).resetState();
          Navigator.pop(context);
        },
        tapOnNo: () {
          Navigator.pop(context);
        },
      );
    }
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final createPostController = Provider.of<CreatePostController>(context, listen: true);

    return WillPopScope(
        onWillPop: () async {
          bool shouldPop = context.read<CreatePostController>().isOldState;
          if (shouldPop) return shouldPop;
          // ignore: use_build_context_synchronously
          showGayaAlertDialogButton(
            context: context,
            actionText: GayaStrings.discard_changes.tr,
            tapOnYes: () async {
              Navigator.pop(context);
              await context.read<CreatePostController>().resetState();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            tapOnNo: () {
              Navigator.pop(context);
            },
          );
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
              automaticallyImplyLeading: false,
              leading: GayaBackButton(onPop: () => checkCreatePostChanges(context)),
              iconTheme: const IconThemeData(color: kBlackColor),
              actions: [
                Consumer<CreatePostController>(builder: (context, controller, _) {
                  return createPostController.isloadingPost == true
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: CircularProgressIndicator.adaptive(backgroundColor: kprimaryColor),
                          ),
                        )
                      : TextButton(
                          onPressed: (controller.aboutPostController.text.isNotEmpty)
                              ? () async {
                                  ///this check is for when post with poll is true and the poll tile title is empty it will return the alert message other wise it will be skipped.
                                  if (createPostController.postWithPoll == true) {
                                    if (createPostController.isAnyControllerEmpty()) {
                                      GayaSnackBar.show(
                                          context: context, type: GayaSnackBarType.error, text: GayaStrings.alert_message_post_poll.tr);
                                      return;
                                    }
                                  }
                                  Map<String, dynamic>? repliedCommentData;
                                  PostWithVibes? vibePost;
                                  PostWithPoll? pollPost;
                                  PostReplyDataType? postReply;
                                  if (createPostController.selectedCommunity.isEmpty && widget.from == PostCreationFrom.Home) {
                                    snackBar(context, GayaStrings.select_community.tr, kprimaryColor);
                                  } else {
                                    if (widget.from == PostCreationFrom.Home) {
                                      await FirebaseFirestore.instance
                                          .collection("communities")
                                          .doc(createPostController.selectedCommunity[0].communityId)
                                          .collection("communityMembers")
                                          .where("isAdmin", isEqualTo: true)
                                          .get()
                                          .then((value) {
                                        if (value.docs.isEmpty) return;
                                        CommunityMembership communitiesMembers = CommunityMembership.fromMap(
                                          value.docs[0].data(),
                                        );
                                        controller.communityAdmin = communitiesMembers.userUid;
                                      });
                                    }
                                    if (widget.commentData != null) {
                                      postReply = PostReplyDataType(
                                          postAuthorId: widget.commentData?.postAuthorId,
                                          commentAuthorId: widget.commentData?.commentAuthorId,
                                          isAnonymousPost: widget.commentData?.isAnonymousPost,
                                          postType: widget.commentData?.typeOfPost.name,
                                          profilePic: widget.commentData?.profilePic.toString(),
                                          commentUserName: widget.commentData?.commentUserName.toString(),
                                          commentId: widget.commentData?.commentId.toString(),
                                          mentionedUsersList: widget.commentData?.mentionedUsersList,
                                          postId: widget.commentData?.postId.toString(),
                                          commentTime: widget.commentData?.commentTime,
                                          content: widget.commentData?.content.toString(),
                                          commentTimeFromNow:
                                              widget.commentData?.commentTimeFromNow); // Call the toJson method on the instance
                                      repliedCommentData = postReply.toJson();
                                    }
                                    if (createPostController.postType.isNotEmpty) {
                                      vibePost = PostWithVibes(createPostController.postType['postType'],
                                          createPostController.postType['name'], createPostController.postType['emoji']);
                                    }
                                    if (createPostController.postWithPoll == true) {
                                      pollPost = createPostController.postWithPollCreation();
                                    }
                                    // ignore: use_build_context_synchronously
                                    await createPostController.postInCommunity(
                                      context,
                                      widget.from != PostCreationFrom.Home
                                          ? widget.communityModel!
                                          : createPostController.selectedCommunity[0],

                                      from: widget.from,
                                      // here send the map not class
                                      mapPostTypeData: createPostController.postType.isNotEmpty
                                          ? createPostController.postType
                                          : createPostController.postWithPoll == true
                                              ? pollPost?.toJson()
                                              : repliedCommentData,
                                      postTypeData: createPostController.postType.isNotEmpty
                                          ? vibePost
                                          : createPostController.postWithPoll == true
                                              ? pollPost
                                              : postReply,
                                    );

                                    createPostController.aboutPostController.clear();
                                    createPostController.pollController.clear();
                                    createPostController.postType = {};
                                    createPostController.postWithVibes = false;
                                    createPostController.postWithPoll = false;
                                  }
                                }
                              : () {
                                  snackBar(context, GayaStrings.write_something.tr, kprimaryColor);
                                },
                          child: createPostController.isOldState
                              ? Text(GayaStrings.post_done.tr,
                                  style: CustomTypography.body2StyleWeightkPrimary.copyWith(color: AppColors.secondary))
                              : GradientTextWidget(
                                  GayaStrings.post_done.tr,
                                  style: CustomTypography.body2StyleWeightkPrimary,
                                  gradient: AppColors.textGradient,
                                ));
                })
              ],
              title: Text(GayaStrings.create_post.tr, style: CustomTypography.bodyStyle),
              centerTitle: true,
              backgroundColor: kTransparentColor,
              elevation: 0,
            ),
            body: widget.commentData?.postType != PostCreationFrom.postReply.name
                ? DraggableBottomSheet(
                    minExtent: 60,
                    barrierColor: AppColors.transparrent,
                    useSafeArea: true,
                    curve: Curves.easeIn,
                    previewWidget: previewWidget(),
                    expandedWidget: expandedWidget(),
                    backgroundWidget: backgroundWidget(),
                    maxExtent: MediaQuery.sizeOf(context).height * 0.42,
                    onDragging: (_) {},
                  )
                : backgroundWidget(),
            floatingActionButton:
                widget.commentData?.postType == PostCreationFrom.postReply.name ? floatingPickButton(createPostController) : Container()));
  }

// FLOATING BUTTON TO PICK this action is implemented on postTypeCardBuilder class
  Widget floatingPickButton(CreatePostController createPostController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_40),
      child: Row(
        children: [
          PickImageButtonWidget(onTap: () {
            HapticFeedback.mediumImpact();

            DeviceCheck.isIOS ? showIosStyleSheet(context, createPostController) : showAndroidSheet(context, createPostController);
          }),
          const SizedBox(
            width: distance_10,
          ),
        ],
      ),
    );
  }

  Widget backgroundWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0).r,
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: distance_20),

            /// post anonymously
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(GayaStrings.post_anonymously.tr, style: CustomTypography.body4StyleHeight),
                  Consumer<CreatePostController>(builder: (context, switchController, _) {
                    return Switch.adaptive(
                      activeColor: kprimaryColor,
                      value: switchController.switchAnon,
                      onChanged: (isSwitched) {
                        if (isSwitched) {
                          showConfirmationModalSheetAnonymouslyPost(
                              context: context,
                              onSubmit: () {
                                Navigator.pop(context);
                                switchController.toggleSwitch(isSwitched);
                              });
                        } else {
                          switchController.toggleSwitch(isSwitched);
                        }
                      },
                    );
                  })
                ],
              ),
            ),
            const Divider(),

            /// topics horizontal list
            Consumer<CreatePostController>(builder: (context, controller, _) {
              /// if topics are available and community is selected
              /// then show the topics of that community
              if ((widget.communityModel?.communityTopicList?.isNotEmpty ?? false)) {
                return Row(
                  children: [
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.05),
                    SizedBox(
                        width: (MediaQuery.sizeOf(context).width * 0.13),
                        child: Text(GayaStrings.topic.tr, style: GayaTypography.subtitleMedium)),
                    SizedBox(
                      height: 40.h,
                      width: (MediaQuery.sizeOf(context).width * 0.82),
                      child: ListView.builder(
                          itemCount: widget.communityModel?.communityTopicList?.length ?? 0,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            final topicName = widget.communityModel?.communityTopicList?[index] ?? "";
                            bool isCurrentTopicSelected = createPostController.preSelectedTopics.contains(topicName);
                            return CommunityTopicListTile(
                                onPressed: (_) {
                                  /// if already contains, remove it
                                  if (createPostController.preSelectedTopics.contains(topicName)) {
                                    createPostController.preSelectedTopics.remove(topicName);
                                    setState(() {});
                                    return;
                                  }

                                  /// otherwise add it, clear list and add it
                                  createPostController.preSelectedTopics.clear();
                                  setState(() => createPostController.preSelectedTopics.add(topicName));
                                },
                                topicName: topicName,
                                topics: widget.communityModel?.communityTopicList ?? [],
                                isSelected: isCurrentTopicSelected,
                                backgroundColor: widget.communityModel?.communityThemeModel?.toColor);
                          }),
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
              child: Column(
                children: [
                  Row(
                    children: [
                      createPostController.profilePicture?.toString().trim().isBlank ?? true
                          ? CircleAvatar(backgroundColor: kBaseGrey, radius: 24, child: AppData.defaultUserProfileWidget())
                          : CircleAvatar(
                              backgroundColor: kBaseGrey,
                              radius: 24,
                              child: CachedNetworkImage(
                                memCacheHeight: 200,
                                memCacheWidth: 200,
                                imageUrl: createPostController.profilePicture ?? '',
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                  );
                                },
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => AppData.defaultUserProfileWidget(),
                                placeholder: (context, url) => AppData.defaultUserProfileWidget(),
                              ),
                            ),
                      const SizedBox(width: distance_10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0).r,
                            child: Text(createPostController.name ?? '', style: CustomTypography.bodyStyle),
                          ),
                          if (widget.from != PostCreationFrom.Home)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0).r,
                              child: Text("• ${widget.communityModel?.communityName}", style: CustomTypography.body1Style),
                            ),
                          const SizedBox(height: 5),
                          widget.from != PostCreationFrom.Home
                              ? const SizedBox.shrink()
                              : FutureBuilder<List<Community>?>(
                                  future: joinedCommunitiesQuery,
                                  builder: (ctx, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        height: 40.h,
                                        width: 150.w,
                                        decoration: BoxDecoration(
                                          color: kBaseGrey,
                                          borderRadius: BorderRadius.circular(12).r,
                                        ),
                                        child: const Center(child: CupertinoActivityIndicator()),
                                      );
                                    }
                                    final joinedCommunities = snap.data ?? [];
                                    return InkWell(
                                      onTap: () {
                                        if (joinedCommunities.isEmpty) {
                                          snackBar(context, GayaStrings.not_community_member.tr, kprimaryColor);
                                          return;
                                        }
                                        chooseGroup(
                                          context,
                                          createPostController,
                                          communities: joinedCommunities,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).r,
                                        decoration: BoxDecoration(
                                          color: kBaseGrey,
                                          borderRadius: BorderRadius.circular(12).r,
                                        ),
                                        child: Row(
                                          children: [
                                            SvgIconWidget.usersFilled(height: 16, width: 16),
                                            // SvgPicture.asset(Assets.assets.icons.user_solid),
                                            const SizedBox(width: 15),
                                            Text(createPostController.selectedCommunity.isEmpty
                                                ? GayaStrings.select_community_txt.tr
                                                : createPostController.selectedCommunity[0].communityName ?? ""),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: distance_10,
                  ),
                  if (createPostController.postWithVibes == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(GayaStrings.feeling.tr, style: GayaTypography.titleMedium.copyWith(height: 1.2)),
                        SizedBox(height: MySpaces.gap2.h),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: emojis.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      createPostController.setPostVibeType(emojis[index]);
                                    },
                                    child: Stack(
                                      children: [
                                        Text(
                                          emojis[index]['emoji'] ?? '',
                                          style: const TextStyle(fontSize: 25),
                                        ),
                                        if (createPostController.postType != emojis[index])
                                          Positioned(
                                            child: Container(
                                              height: 50.h,
                                              width: 30.w,
                                              color: Colors.white.withOpacity(0.5),
                                            ),
                                          )
                                      ],
                                    ));
                              }),
                        ),
                      ],
                    ),
                  if (createPostController.postType.isNotEmpty)
                    PostWithVibesWidget(
                      isEditable: true,
                      postEmoji: PostWithVibes(
                        createPostController.postType['postType'],
                        createPostController.postType['name'],
                        createPostController.postType['emoji'],
                      ),
                      themeColor: createPostController.currentSelectedCommunity?.communityThemeModel?.toColor ??
                          widget.communityModel?.communityThemeModel?.toColor,
                      postTitle: createPostController.aboutPostController.text,
                    ),
                  if (createPostController.postType.isEmpty)
                    TextFormField(
                      autofocus: false,
                      autocorrect: false,
                      enableSuggestions: true,
                      textDirection: Methods.isRTL(createPostController.aboutPostController.text) ? TextDirection.rtl : TextDirection.ltr,
                      onChanged: (String value) {
                        createPostController.onChanged(value);
                      },
                      controller: createPostController.aboutPostController,
                      maxLines: null,
                      style: createPostController.aboutPostController.text.length > 120
                          ? CustomTypography.bodyStyle.copyWith(
                              fontSize: 14.sp,
                            )
                          : CustomTypography.bodyStyle.copyWith(
                              fontSize: 18.sp,
                            ),
                      decoration: InputDecoration(
                          hintStyle: CustomTypography.bodyStyle.copyWith(color: AppColors.secondary),
                          hintText: (widget.commentData != null && widget.commentData?.postType == PostCreationFrom.postReply.name)
                              ? GayaStrings.add_comment.tr
                              : GayaStrings.talk_to.tr,
                          border: const OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                  const SizedBox(
                    height: distance_10,
                  ),
                  if (createPostController.postWithPoll == true) const PostPollBuilderWidget(),
                  createPostController.images.isEmpty
                      ? const SizedBox.shrink()
                      : MultipleImageShow(
                          controller: createPostController,
                        ),
                  Consumer<CreatePostController>(builder: (_, controller, __) {
                    return (controller.videoPlayerController != null && controller.videoFile != null)
                        ? VideoPlayerWidget(
                            controller: createPostController,
                          )
                        : const SizedBox.shrink();
                  }),
                  Consumer<CreatePostController>(builder: (_, controller, __) {
                    return (controller.pdfFiles.isNotEmpty && controller.documentUploadStatus == true)
                        ? LocalPdfviewWidget(
                            path: controller.pdfFiles.first.path,
                          )
                        : const SizedBox.shrink();
                  }), // ],
                  const SizedBox(
                    height: distance_20,
                  ),
                  createPostController.videoUploadingPercentage == null
                      ? const SizedBox.shrink()
                      : LinearProgressIndicator(value: createPostController.videoUploadingPercentage),
                ],
              ),
            ),
            widget.commentData != null
                ? ReplyCommentPostWidget(
                    commentData: widget.commentData,
                    communityColor: getColorFromHex(widget.communityModel?.communityThemeModel?.color ?? 'FFD28AFF'),
                  )
                : const SizedBox.shrink()
          ],
        )),
      ),
    );
  }

  Widget previewWidget() {
    return Container(
      width: 1.sw,
      padding: const EdgeInsets.only(top: 16).r,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: const Offset(0, -8), // changes the position of the shadow
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16).r,
          topRight: const Radius.circular(16).r,
        ),
      ),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
    );
  }

  Widget expandedWidget() {
    return Container(
      padding: const EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: const Offset(0, -8), // changes the position of the shadow
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16).r,
          topRight: const Radius.circular(16).r,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(10).r,
            ),
          ),
          SizedBox(height: MySpaces.gap2.h),
          PostWidgetCardBuilderWidget(
            postContext: context,
            postControllerText: createPostController.aboutPostController.text.trim().toString(),
          )
        ],
      ),
    );
  }
}

showConfirmationModalSheetAnonymouslyPost({
  required BuildContext context,
  required VoidCallback onSubmit,
}) {
  final gap = SizedBox(height: MySpaces.gap3.h);
  return Methods.showCircularModalSheet(
    context,
    SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
            child: Text(GayaStrings.anonymous_post.tr, style: GayaTypography.h4),
          ),
          gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
            child: Text(
              GayaStrings.anonymous_post_desc.tr,
              textAlign: TextAlign.center,
              style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
            ),
          ),
          gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgIconWidget.lockOutline1(),
                SizedBox(width: MySpaces.gap3.w),
                Flexible(
                  child: Text(
                    GayaStrings.anonymous_post_desc_2.tr,
                    style: GayaTypography.subtitleRegular.copyWith(color: AppColors.black),
                  ),
                ),
              ],
            ),
          ),
          gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
            child: GayaButton(
                height: 40.h,
                borderColor: kTransparentColor,
                // textStyle: loginController.styleEmail,
                textStyle: GayaTypography.titleMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 14.sp,
                ),
                title: GayaStrings.i_want_to_post_anonymously.tr,
                onPressed: onSubmit,
                primaryColor: AppColors.primary),
          ),
          SizedBox(
            height: 20.h,
          )
        ],
      ),
    ),
  );
}
