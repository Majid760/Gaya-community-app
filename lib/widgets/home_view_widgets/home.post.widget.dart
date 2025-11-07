import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feed_reaction/flutter_feed_reaction.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/controller/gaya_shared_controller.dart';
import 'package:gaya/controller/homepage.controller.dart';
import 'package:gaya/controller/report_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/view/widget/custom_post_options_list_tile.dart';
import 'package:gaya/shared/view/widget/gaya_report_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/gaya_text_widget.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:gaya/view/create_post/widgets/post_poll_widgets/home_feed_poll_widget.dart';
import 'package:gaya/view/create_post/widgets/post_with_vibes_widgets/post_with_vibes_widget.dart';
import 'package:gaya/widgets/home_view_widgets/home_post_comment_card_item.dart';
import 'package:gaya/widgets/home_view_widgets/multiple_files_post.dart';
import 'package:gaya/widgets/post.with.comments.widgets/reply_comment_post_widget.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../../components/profile_image_widget.dart';
import '../../components/show.friends.sheet.dart';
import '../../controller/app_config_controller.dart';
import '../../shared/view/widget/gaya_alert_dialog.dart';
import '../../utils/app_data.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';
import '../../view/Auth/controller/require.sigin.register.dart';
import '../../view/community/controllers/community_feed_controller.dart';
import '../../view/share/controllers/instagram_story_share_controller.dart';
import '../../view/share/models/post_insta_share.dart';
import '../create_recipe_widgets/picked.video.widget.dart';

class HomePostWidget extends StatelessWidget {
  /// @NotInUse - Commented whole module code.
  final Widget? influenceIcon;
  final bool? showModeratorTag, isCrowned;
  final Map<String, dynamic>? moderatorData;
  final String? videoLink;
  final bool? hasVideo;
  final List<Map<String, dynamic>>? pdfFiles;
  final String? postId;
  final Widget? overlapImage;
  final String? profileImage;
  final groupImage;
  final String title, subtitle, content, totalCommentsCount, totalLikesCount, totalCrownsCount, save, posterCrownsCount;
  final Color? savePostColor, likeIconColor;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onManageTopics;
  final VoidCallback? onPinPost;
  final void Function(String? value, bool isChecked)? likeReactionOnTap;

  /// Whether the post is posted by male, female or other
  final String? gender;

  final VoidCallback? flowerOnTap,
      likeOnTap,
      commentOntap,
      crownOnTap,
      imageTap,
      onTapSaved,
      onUserTap,
      approveRequest,
      declineRequest,
      report,
      onTap,
      onHideCommunity;

  final int crossAxis;
  final List<dynamic> postImage;
  final bool isPostHasImage, doNotshowBottomrow, approvalShow;
  final bool? currentUserPost;
  final bool? anonymousPost;
  final DateTime? createdAt;
  final bool isDiscussionView;
  final Post postModel;
  final Color? communityThemeColor;
  final bool isPostPinned;

  /// Passing this param only when I have the community model and I want to check if the user is admin or moderator
  /// if the user is admin or moderator then I will show the delete and pin post option
  final bool? forcefullyAdminOrModerator;

  /// Show Pin community option
  final bool showPinOption;

  const HomePostWidget({
    Key? key,
    this.influenceIcon,
    this.pdfFiles,
    this.showModeratorTag,
    this.isPostPinned = false,
    this.moderatorData,
    this.communityThemeColor,
    this.createdAt,
    this.gender,
    this.anonymousPost,
    this.save = "Save",
    required this.approvalShow,
    this.approveRequest,
    this.declineRequest,
    required this.isPostHasImage,
    this.savePostColor,
    this.postId,
    required this.groupImage,
    this.profileImage,
    required this.title,
    required this.subtitle,
    required this.postImage,
    required this.content,
    this.onDeleteTap,
    this.onManageTopics,
    this.onPinPost,
    this.flowerOnTap,
    this.likeOnTap,
    this.likeReactionOnTap,
    this.imageTap,
    this.commentOntap,
    this.crownOnTap,
    this.overlapImage,
    this.onTapSaved,
    this.likeIconColor,
    this.isCrowned,
    required this.totalCommentsCount,
    required this.totalLikesCount,
    required this.totalCrownsCount,
    required this.posterCrownsCount,
    this.onUserTap,
    required this.doNotshowBottomrow,
    this.report,
    this.currentUserPost,
    this.hasVideo,
    required this.crossAxis,
    this.onTap,
    required this.videoLink,
    this.isDiscussionView = false,
    required this.postModel,
    this.onHideCommunity,
    this.forcefullyAdminOrModerator,
    this.showPinOption = true,
  }) : super(key: key);

  bool get isFeedView => isDiscussionView == false && approvalShow == false;

  bool get isBigText => !(content.length >= 120 || isPostHasImage || hasVideo == true);

  @override
  Widget build(BuildContext context) {
    final isAdminOrModerator =
        forcefullyAdminOrModerator ?? AppConfigurationController.to.isAdminOrModerator(communityId: postModel.communityId);
    final themeColor = postModel.community.getThemeColor();
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPostPinned)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20).r,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'Assets/icons/pin.svg',
                        color: kSecondaryColor,
                        height: 13.5.r,
                        width: 13.5.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(GayaStrings.pinned_post.tr,
                          style: GayaTypography.titleMedium.copyWith(color: kSecondaryColor, fontSize: 12.5.sp)),
                    ],
                  ),
                ),
              // Post Header.
              Container(
                padding: const EdgeInsets.only(top: 8, left: 15, right: 15).r,
                child: SizedBox(
                  height: isFeedView ? null : 60.h,
                  child: Row(
                    crossAxisAlignment: isFeedView ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      // DP
                      Stack(
                        children: [
                          Container(
                            height: 48.r,
                            width: 48.w,
                            margin: const EdgeInsets.only(right: distance_8).r,
                            child: anonymousPost == true && isFeedView == false
                                ? CircleAvatar(
                                    backgroundImage: AssetImage(
                                      gender == null
                                          ? "Assets/images/anonymous_user.png"
                                          : gender == 'male'
                                              ? "Assets/images/anonymous_boy.png"
                                              : gender == 'female'
                                                  ? "Assets/images/anonymous_girl.png"
                                                  : "Assets/images/anonymous_user.png",
                                    ),
                                    backgroundColor: kBaseGrey,
                                    radius: 48.r,
                                  )
                                : GestureDetector(
                                    onTap: onUserTap,
                                    child: CircleAvatar(
                                      radius: 48.r,
                                      backgroundColor: isFeedView ? kBaseGrey : Colors.white,
                                      child: ProfileImageWidget(
                                        url: groupImage,
                                        size: const Size(200, 200),
                                        useHeightWidthForcefully: true,
                                        maxDiskCacheHeight: 200,
                                        maxDiskCacheWidth: 200,
                                        onError: isFeedView ? null : AppData.defaultUserProfileWidget(),
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(bottom: 0, right: 0, child: overlapImage ?? const SizedBox())
                        ],
                      ),
                      SizedBox(width: distance_8.w),
                      //title, subtitle and time
                      Flexible(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: isFeedView ? MainAxisAlignment.start : MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // if (isFeedView) const SizedBox(height: distance_5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      //title
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: onUserTap,
                                          child: Text(
                                            title,
                                            maxLines: 1,
                                            textDirection: TextDirection.ltr,
                                            style: GayaTypography.titleMedium.copyWith(overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                      //time ago
                                      (isFeedView)
                                          ? Padding(
                                              padding: const EdgeInsets.only(left: 8.0, right: 8.0).r,
                                              child: (postModel.forGuestFeed ?? false)
                                                  ? const SizedBox.shrink()
                                                  : Text(" • ${Jiffy(createdAt).fromNow()}",
                                                      style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary)),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (anonymousPost != true)
                                                  Row(
                                                    children: [
                                                      /// COMMENTED For INFLUENCE BAR
                                                      // if (influenceIcon != null) const SizedBox(width: 6),
                                                      // if (influenceIcon != null) influenceIcon!,
                                                      const SizedBox(width: 6),
                                                      SvgIcons.crownFilledSmall,
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        posterCrownsCount,
                                                        style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
                                                      ),
                                                    ],
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0).r,
                                                  child: Text(" • ${Jiffy(createdAt).fromNow()}",
                                                      style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary)),
                                                )
                                              ],
                                            )
                                    ],
                                  ),

                                  //sub title
                                  if (isFeedView)
                                    Column(
                                      children: [
                                        SizedBox(height: distance_5.h),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: anonymousPost == true
                                                  ? null
                                                  : () => Routes.viewProfile(uid: postModel.postedBy.uId, model: postModel.postedBy),
                                              child: Text(
                                                subtitle.toString() == "null"
                                                    ? ""
                                                    : subtitle.length > 20
                                                        ? "${subtitle.substring(0, 20)}..."
                                                        : subtitle,
                                                style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
                                              ),
                                            ),
                                            if (anonymousPost != true)
                                              Row(
                                                children: [
                                                  /// COMMENTED For INFLUENCE BAR
                                                  // if (influenceIcon != null) const SizedBox(width: 6),
                                                  // if (influenceIcon != null) influenceIcon!,
                                                  const SizedBox(width: 6),
                                                  SvgIcons.crownFilledSmall,
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    posterCrownsCount,
                                                    style: GayaTypography.subtitleMedium.copyWith(color: AppColors.secondary),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // //time ago
                                        // Padding(
                                        //   padding: const EdgeInsets.only(top: 5).r,
                                        //   child: Text(
                                        //     Jiffy(createdAt).fromNow(),
                                        //     style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
                                        //   ),
                                        // ),
                                        // const SizedBox(width: distance_20),

                                        // manager or moderator tag widget
                                        if (approvalShow == false &&
                                            postModel.community.adminUid == postModel.postedBy.uId &&
                                            anonymousPost != true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                            margin: const EdgeInsets.only(top: 5).r,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4), color: getColorFromHex(moderatorData?['tagColor'])),
                                            child: Text(
                                              GayaStrings.manager_txt.tr,
                                              style: CustomTypography.dark12,
                                            ),
                                          )
                                        else if (showModeratorTag != null && showModeratorTag == true && anonymousPost != true)
                                          Container(
                                            margin: const EdgeInsets.only(top: 5).r,
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4).r,
                                                color: getColorFromHex(moderatorData?['tagColor'])),
                                            child: Text(
                                              moderatorData?['moderatorTag'],
                                              style: CustomTypography.dark12,
                                            ),
                                          )
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            //share a post & menu icon button
                            Row(
                              children: [
                                //share a post
                                IconButton(
                                  tooltip: GayaStrings.share_post.tr,
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  splashRadius: 20.r,
                                  onPressed: () async {
                                    const String lastMessage = "Shared a post";
                                    context.read<HomePageController>().searchFriendsController.clear();
                                    context.read<HomePageController>().searchFriends.clear();
                                    if (FirebaseAuth.instance.currentUser?.uid == null) {
                                      Get.to(() => const RequireSignRegisterView(userNotSigin: true),
                                          transition: Transition.cupertinoDialog);
                                    } else {
                                      log(context.read<HomePageController>().sentMessageUserIds.toString());
                                      context.read<HomePageController>().sentMessageUserIds.clear();
                                      // created instance of PostInstaShare to share on insta
                                      InstagramStoryShareController.instance.instaShare = PostInstaShare(
                                        communityImage: postModel.community.CommunityPic,
                                        postPostedUserImage: postModel.isPostedAnonymously ?? false
                                            ? gender == null
                                                ? "Assets/images/anonymous_user.png"
                                                : gender == 'male'
                                                    ? "Assets/images/anonymous_boy.png"
                                                    : gender == 'female'
                                                        ? "Assets/images/anonymous_girl.png"
                                                        : "Assets/images/anonymous_user.png"
                                            : profileImage == null || profileImage!.isEmpty
                                                ? 'Assets/images/user.png'
                                                : profileImage,
                                        communityName: title,
                                        postDescription: content,
                                        postPostedUsername: subtitle,
                                        postImage: postImage.isEmpty ? null : postImage[0],
                                        postPostedUserReceivedCrowns: int.parse(posterCrownsCount),
                                        post: postModel,
                                        isAnonymousPost: postModel.isPostedAnonymously ?? false,
                                      );
                                      showModalToSendItem2(
                                        context,
                                        postId!,
                                        lastMessage,
                                        messageType: MessageType.post,
                                        post: postModel,
                                      );
                                      await context.read<HomePageController>().yourFriends();
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  icon: SvgIcons.shareIcon,
                                ),
                                const SizedBox(width: 5),
                                // menu dot button
                                IconButton(
                                    tooltip: GayaStrings.more_txt.tr,
                                    padding: EdgeInsets.zero,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    splashRadius: 20.r,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      final isPostSaved = AppConfigurationController.to.savedPostsID.contains(postId) == true;
                                      User? user = FirebaseAuth.instance.currentUser;
                                      if (user == null) {
                                        Get.to(() => const RequireSignRegisterView(userNotSigin: true),
                                            transition: Transition.cupertinoDialog);
                                      } else {
                                        showModalBottomSheet(
                                          context: context,
                                          clipBehavior: Clip.antiAlias,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
                                          ),
                                          builder: (modalContext) {
                                            return SafeArea(
                                              child: Container(
                                                width: MediaQuery.sizeOf(context).width,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    SizedBox(height: 12.r),
                                                    Container(
                                                      height: 4,
                                                      width: 40,
                                                      alignment: Alignment.topCenter,
                                                      decoration: const ShapeDecoration(color: borderColor, shape: StadiumBorder()),
                                                    ),
                                                    Column(
                                                      children: [
                                                        // Pin post by manager for community view only
                                                        !isFeedView && (isAdminOrModerator == true) && showPinOption
                                                            ? GayaListTileButton(
                                                                title: (isPostPinned ? GayaStrings.unpin_post : GayaStrings.pin_post).tr,
                                                                subtitle: (isPostPinned
                                                                        ? GayaStrings.remove_pin_post_to_top
                                                                        : GayaStrings.pin_post_to_top)
                                                                    .tr,
                                                                onTap: onPinPost,
                                                                leading: SvgIconWidget.pinOutlinee()
                                                                // leading: SvgIcons.pinOutline()
                                                                )
                                                            : const SizedBox.shrink(),
                                                        // save
                                                        GayaListTileButton(
                                                            title: (isPostSaved ? GayaStrings.unsave_txt : GayaStrings.save_post).tr,
                                                            subtitle: (isPostSaved
                                                                    ? GayaStrings.remove_this_from_saved_posts
                                                                    : GayaStrings.add_this_to_save_post)
                                                                .tr,
                                                            onTap: onTapSaved,
                                                            leading: isPostSaved
                                                                ? SvgIconWidget.bookmarkFilled()
                                                                : SvgIconWidget.bookmarkOutline()
                                                            // leading: isPostSaved ? SvgIcons.saveSolid() : SvgIcons.saveOutline()
                                                            ),

                                                        // copy link
                                                        GayaListTileButton(
                                                            title: GayaStrings.copy_link.tr,
                                                            onTap: () async {
                                                              Navigator.pop(modalContext);
                                                              if (postModel == null) {
                                                                GayaSnackBar.show(
                                                                    context: context,
                                                                    type: GayaSnackBarType.error,
                                                                    text: GayaStrings.cannot_share_post.tr);
                                                                return;
                                                              }
                                                              final shareAbleLink = await GayaSharedController.to
                                                                  .createAShareablePostLink(post: postModel, ctx: context);
                                                              if (shareAbleLink != null) {
                                                                Clipboard.setData(ClipboardData(text: shareAbleLink));
                                                                MyLoggerServices.to.print("Shareable link is $shareAbleLink");
                                                                // ignore: use_build_context_synchronously
                                                                GayaSnackBar.show(
                                                                    context: context,
                                                                    type: GayaSnackBarType.link,
                                                                    text: GayaStrings.copied_to_clipboard.tr);
                                                              }
                                                            },
                                                            leading: SvgIconWidget.linkOutline1()
                                                            // leading: SvgIcons.linkOutline()
                                                            ),

                                                        currentUserPost == false && isAdminOrModerator == false || onManageTopics == null
                                                            ? const SizedBox.shrink()
                                                            : GayaListTileButton(
                                                                title: GayaStrings.manage_topic.tr,
                                                                subtitle: GayaStrings.add_remove_topics_for_this_post.tr,
                                                                onTap: onManageTopics,
                                                                leading: SvgIcons.postOutline(),
                                                              ),

                                                        //report
                                                        if (postModel.community.adminUid != UserModel.to.uId && !postModel.isPostedByMe)
                                                          Builder(builder: (ctx) {
                                                            final bool isReported =
                                                                AppConfigurationController.to.isPostReportedAlready(postId: postId!);

                                                            return GayaListTileButton(
                                                              title: isReported ? GayaStrings.post_reported.tr : GayaStrings.report.tr,
                                                              subtitle: GayaStrings.concerned_this_post.tr,
                                                              onTap: isReported
                                                                  ? null
                                                                  : () async {
                                                                      Navigator.pop(modalContext);
                                                                      reportTextFieldBottomModal(context,
                                                                          onSubmit: (String reportMsg) async {
                                                                        await ReportController.to.reportPost(
                                                                          postId ?? "",
                                                                          context,
                                                                          postModel.community.adminUid,
                                                                          reportMsg: reportMsg,
                                                                          communityId: postModel.community.communityId ?? "",
                                                                          userId: postModel.postedBy.uId,
                                                                        );
                                                                      });
                                                                    },
                                                              // leading: SvgIconWidget.bookmarkFilled(),
                                                              leading: SvgIcons.problem(height: 24.r, width: 24.r),
                                                            );
                                                          }),
                                                        if (isFeedView == false && postModel.community.adminUid != UserModel.to.uId)
                                                          GayaListTileButton(
                                                              title:
                                                                  "${GayaStrings.leave_txt.tr} ${postModel.community.communityName ?? ""}",
                                                              subtitle: GayaStrings.request_join_later.tr,
                                                              onTap: () async {
                                                                Methods.showLeaveCommunityAlert(
                                                                    communityModel: postModel.community,
                                                                    context: context,
                                                                    onLeave: () {
                                                                      Navigator.pop(modalContext); //modal sheet
                                                                      Navigator.pop(context); // current view.
                                                                    });
                                                                log('User delete from both sides');
                                                              },
                                                              leading: SvgIconWidget.logoutOutline()
                                                              // leading: SvgIcons.leave(height: 24.r, width: 24.r),
                                                              ),
                                                        currentUserPost == true || isAdminOrModerator == true || showModeratorTag == true
                                                            ? GayaListTileButton(
                                                                title: GayaStrings.delete_post.tr,
                                                                subtitle: GayaStrings.delete_post_in_community.tr,
                                                                onTap: onDeleteTap,
                                                                leading: SvgIconWidget.trash1Outline()
                                                                // leading: SvgIcons.deleteOutline(height: 24.r, width: 24.r),
                                                                )
                                                            : const SizedBox.shrink(),

                                                        if (isFeedView)
                                                          GayaListTileButton(
                                                              title: GayaStrings.hide_this_community.tr,
                                                              subtitle: GayaStrings.i_dont_want_to_see_this_community.tr,
                                                              leading: SvgIcons.hide(height: 20.r, width: 20.r),
                                                              onTap: () {
                                                                Navigator.pop(context);
                                                                if (onHideCommunity != null) {
                                                                  onHideCommunity!();
                                                                }
                                                                AppConfigurationController.to.hideOrUnHideCommunity(
                                                                    communityId: postModel.community.communityId ?? "");
                                                                DefaultSnackBar.hideOrUnHideCommunity(context: context);
                                                              }),

                                                        if (AppConfigurationController.to.isSuperAdmin)
                                                          GayaListTileButton(
                                                              title: "Remove from feed",
                                                              subtitle: "Remove completely from feed for others.",
                                                              leading: SvgIcons.hide(height: 20.r, width: 20.r),
                                                              onTap: () async {
                                                                Navigator.pop(context);

                                                                if (postId?.isBlank == true) return;
                                                                showGayaAlertDialogButton(
                                                                  context: context,
                                                                  actionText: "remove completely from feed for others?",
                                                                  tapOnYes: () async {
                                                                    Navigator.pop(context);
                                                                    await AppConfigurationController.to
                                                                        .removePostFromFeedCompletely(postId!);
                                                                    if (!context.mounted) return;
                                                                    GayaSnackBar.show(
                                                                        context: context,
                                                                        type: GayaSnackBarType.success,
                                                                        text: GayaStrings.remove_from_feed_success.tr);
                                                                  },
                                                                  tapOnNo: () => Navigator.pop(context),
                                                                );
                                                              }),
                                                      ],
                                                    ),
                                                    SizedBox(height: 12.r),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    icon: SvgIcons.moreIcon),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20).r,
                child: Column(
                  children: [
                    SizedBox(height: MySpaces.gap3.h),
                    //captions/content of a post (paragraph)
                    Align(
                        alignment: Methods.isRTL(content) ? Alignment.centerRight : Alignment.centerLeft,
                        child: postModel.postTypeData?.typeOfPost.name == PostCreationFrom.postReply.name
                            ? GayaTextWidget(
                                content,
                                // "${postModel.score.toString() ?? "NULL"}}} ${postModel.postid ?? ""}",
                                style: isBigText
                                    ? CustomTypography.postCaptionStyle.copyWith(fontSize: 24.sp)
                                    : CustomTypography.postCaptionStyle.copyWith(fontSize: 16.sp),
                                colorClickableText: kprimaryColor,
                                shouldIgnoreHashTag: false,
                                shouldIgnoreSelectableText: (commentOntap == null) ? false : true,
                                community: postModel.community,
                                onHashTagPressed: (String? hashTag) async {
                                  final communityId = postModel.community.communityId ?? '';
                                  if (FirebaseAuth.instance.currentUser == null || hashTag.isBlank == true) {
                                    return;
                                  }
                                  String tagTopicText = hashTag!.split('#').last.split(':').last.trim();
                                  Get.lazyPut<CommunityFeedController>(
                                    () => CommunityFeedController(
                                      communityId: communityId,
                                      community: postModel.community,
                                      hashTagTopic: tagTopicText,
                                    ),
                                    tag: communityId,
                                  );
                                  // final communityModel = await Servic (communityId);
                                  String currentRoute = Get.currentRoute;
                                  debugPrint("currentRoute: $currentRoute");
                                  if (currentRoute == '/GroupView' || currentRoute == '') {
                                    Get.find<CommunityFeedController>(tag: communityId).setSelectedTopic(tagTopicText);
                                  } else {
                                    final community = await Services().getCommunityDetailsModel(postModel.community.communityId ?? "");
                                    debugPrint("routeToGroup: ${postModel.community.communityTopicList?.length}");
                                    Methods.routeToGroup(community: community ?? postModel.community);
                                  }
                                },
                              )
                            : postModel.postTypeData?.typeOfPost.name == PostCreationFrom.vibe.name
                                ? PostWithVibesWidget(
                                    postEmoji: postModel.postTypeData as PostWithVibes, postTitle: content, postModel: postModel)
                                : (postModel.postTypeData?.typeOfPost.name == PostCreationFrom.poll.name &&
                                        FirebaseAuth.instance.currentUser != null)
                                    ? HomeFeedPollWidget(
                                        key: UniqueKey(),
                                        postModel: postModel,
                                        poll: postModel.postTypeData as PostWithPoll,
                                        documentId: postModel.postid ?? "",
                                        color: themeColor,
                                      )
                                    : GayaTextWidget(
                          content,
                                        // "${postModel.score.toString() ?? "NULL"}}} ${postModel.postid ?? ""}",
                                        style: isBigText
                                            ? CustomTypography.postCaptionStyle.copyWith(fontSize: 24.sp)
                                            : CustomTypography.postCaptionStyle.copyWith(fontSize: 16.sp),
                                        colorClickableText: kprimaryColor,
                                        shouldIgnoreHashTag: false,
                                        shouldIgnoreSelectableText: (commentOntap == null) ? false : true,
                                        community: postModel.community,
                                        onHashTagPressed: (String? hashTag) async {
                                          final communityId = postModel.community.communityId ?? '';
                                          if (FirebaseAuth.instance.currentUser == null || hashTag.isBlank == true) return;
                                          String tagTopicText = hashTag!.split('#').last.split(':').last.trim();
                                          Get.lazyPut<CommunityFeedController>(
                                            () => CommunityFeedController(
                                              communityId: communityId,
                                              community: postModel.community,
                                              hashTagTopic: tagTopicText,
                                            ),
                                            tag: communityId,
                                          );
                                          // final communityModel = await Servic (communityId);
                                          String currentRoute = Get.currentRoute;
                                          debugPrint("currentRoute: $currentRoute");
                                          if (currentRoute == '/GroupView' || currentRoute == '') {
                                            Get.find<CommunityFeedController>(tag: communityId).setSelectedTopic(tagTopicText);
                                          } else {
                                            final community =
                                                await Services().getCommunityDetailsModel(postModel.community.communityId ?? "");
                                            debugPrint("routeToGroup: ${postModel.community.communityTopicList?.length}");
                                            Methods.routeToGroup(community: community ?? postModel.community);
                                          }
                                        },
                                      )),
                    const SizedBox(height: distance_5),

                    //video or image
                    isPostHasImage == true
                        ? MultipleNetworkImagesView(
                            images: postImage,
                          ) // ShowImages(images: postImage, crossAxisCount: crossAxis)
                        : pdfFiles != null && pdfFiles!.isNotEmpty
                            ? PdfviewWidget(
                                path: pdfFiles!.first['fileUrl'],
                                title: pdfFiles!.first['title'],
                                filename: pdfFiles!.first['fileName'],
                                thumbnailUrl: pdfFiles!.first['thumbnail'],
                              )
                            : Visibility(
                                visible: hasVideo == true && videoLink != null && videoLink != '',
                                child: SizedBox(
                                    height: MediaQuery.sizeOf(context).height * 0.5,
                                    child: HomePostVideoCustom(videoLink: videoLink ?? ""))),
                    SizedBox(height: 10.r),
                    // reply post
                    if (postModel.postTypeData != null && postModel.postTypeData?.typeOfPost.name == PostCreationFrom.postReply.name)
                      ReplyCommentPostWidget(
                          commentData: postModel.postTypeData as PostReplyDataType,
                          onTap: () {
                            if (FirebaseAuth.instance.currentUser?.uid == null) {
                              return;
                            }

                            Routes.postDetailsScreen(
                                post: Post(
                                    postid: (postModel.postTypeData as PostReplyDataType).postId,
                                    community: Community(),
                                    postedBy: UserModel()),
                                community: Community());
                          },
                          communityColor: themeColor),

                    if (postModel.recentComments != null && postModel.recentComments?.isNotEmpty == true) SizedBox(height: 8.r),
                    if (postModel.recentComments != null && postModel.recentComments?.isNotEmpty == true)
                      if (onTap != null)
                        GestureDetector(
                          onTap: commentOntap,
                          child: SizedBox(
                            height: 75.r,
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              // physics: const AlwaysScrollableScrollPhysics(),
                              // shrinkWrap: true, // 1st add
                              physics: const ClampingScrollPhysics(),
                              itemCount: postModel.recentComments?.length ?? 0,
                              itemBuilder: (_, index) {
                                return CommentCardItem(
                                    comment: postModel.recentComments![index]!,
                                    isAnonymous: (postModel.isPostedAnonymously == true &&
                                            postModel.postedBy.uId == postModel.recentComments?[index]!.user.uId)
                                        ? true
                                        : false,
                                    communityThemeColor: themeColor);
                              },
                            ),
                          ),
                        ),
                    SizedBox(height: 10.r),

                    if (approvalShow == true)
                      Row(
                        children: [
                          Expanded(
                            child: GayaButton(
                                height: 40.h,
                                primaryColor: kprimaryColor,
                                title: GayaStrings.approve_txt.tr,
                                textStyle: CustomTypography.darkWhite12.copyWith(fontSize: 14.sp),
                                onPressed: approveRequest,
                                borderColor: borderColor),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.04,
                          ),
                          Expanded(
                              child: GayaButton(
                                  height: 40.h,
                                  primaryColor: kBaseGrey,
                                  textStyle: CustomTypography.darkWhite12.copyWith(color: Colors.black, fontSize: 14.sp),
                                  title: GayaStrings.decline_txt.tr,
                                  onPressed: declineRequest,
                                  borderColor: kTransparentColor)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottom buttons
        if (doNotshowBottomrow == false)
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: kSecondaryLightColor, thickness: 1.0, height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // like reaction button
                    Builder(builder: (context) {
                      Widget prefixWidget =
                          Methods.getMyReactionIcon(postModel.reactionModel?.reaction, postReactionData: postModel.postReactionData);
                      Widget suffixWidget =
                          Methods.getMyReactionText(postModel.reactionModel?.reaction, postReactionData: postModel.postReactionData);
                      List<int>? reactionsCountList = Methods.getReactionsCountsList(postReactionData: postModel.postReactionData);
                      return FlutterFeedReaction(
                        reactions: Methods.reactions,
                        dragSpace: 30.0.r,
                        reactionsCountList: reactionsCountList,
                        onReactionSelected: (val) {
                          if (likeReactionOnTap == null) return;
                          if (postModel.reactionModel == null) {
                            likeReactionOnTap!(val.name, true);
                          } else if (postModel.reactionModel?.reaction == val.name) {
                            likeReactionOnTap!(val.name, false);
                          } else {
                            likeReactionOnTap!(val.name, true);
                          }
                        },
                        onPressed: () {
                          if (likeReactionOnTap == null) return;
                          if (postModel.reactionModel == null) {
                            likeReactionOnTap!('Like', true);
                          } else {
                            likeReactionOnTap!(postModel.reactionModel?.reaction, false);
                          }
                        },
                        prefix: prefixWidget,
                        suffix: suffixWidget,
                        containerWidth: 200.0.r,
                        spacing: 6.r,
                      );
                    }),

                    //Comment Button
                    (isCrowned == true)
                        ? ReactionButtonWidget(
                            onTap: crownOnTap,
                            icon: SvgIconWidget.crownFilledd(height: 19.r, width: 19.r, color: AppColors.warning),
                            // icon:SvgPicture.asset("Assets/images/filled_crown.svg", height: 14.r, width: 14.r)
                            title: '$totalCrownsCount ${GayaStrings.crowns_txt.tr}',
                          )
                        : ReactionButtonWidget(
                            onTap: crownOnTap,
                            icon: SvgIconWidget.crownOutline(height: 19.r, width: 19.r, color: AppColors.secondary),
                            // icon: SvgPicture.asset("Assets/images/crown.svg", height: 16.r, width: 16.r),
                            title: '$totalCrownsCount ${GayaStrings.crowns_txt.tr}',
                          ),

                    ReactionButtonWidget(
                      onTap: onTap,
                      icon: SvgIconWidget.messagesOutline(height: 19.r, width: 19.r, color: AppColors.secondary),
                      // icon: SvgPicture.asset("Assets/icons/comment_icon.svg"),
                      title: '$totalCommentsCount ${GayaStrings.comments_txt.tr}',
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ReactionButtonWidget extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback? onTap;

  const ReactionButtonWidget({Key? key, required this.title, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: GayaButtonStyles.actionRowTextButtonStyle2,
      onPressed: () {
        if (onTap != null) {
          onTap!();
          HapticFeedback.mediumImpact();
        }
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            WidgetSpan(alignment: PlaceholderAlignment.middle, child: icon),
            const WidgetSpan(child: SizedBox(width: 4)),
            TextSpan(
              text: title,
              style: GayaTypography.subtitleMedium.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
