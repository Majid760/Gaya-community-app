// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/comments/components/comments_dialogbox.dart';
import 'package:gaya/widgets/home_view_widgets/home.post.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../components/show.full.picture.dart';
import '../../../controller/app_config_controller.dart';
import '../../../controller/create.post.controller.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../controller/group.controller.dart';
import '../../../controller/homepage.controller.dart';
import '../../../controller/report_controller.dart';
import '../../../model/community.model.dart';
import '../../../model/create.post.model.dart';
import '../../../model/user.model.dart';
import '../../../routing/getx_route_methods.dart';
import '../../../utils/const.dart';
import '../../../utils/logger.dart';
import '../../../utils/methods.dart';
import '../../../utils/strings.dart';
import '../../search/controllers/search_controller.dart';
import '../controller/base/base_feed_impl.dart';

class PostTile extends StatelessWidget {
  final Post postModel;

  /// whether post tile is mounted in the search screen (For Analytics)
  final bool inSearchScreen;

  /// index of post tile in search screen listing (For analytics)
  final int? index;

  const PostTile({
    Key? key,
    required this.postModel,
    this.inSearchScreen = false,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Post postModel = this.postModel;
    final Community communityModel = postModel.community;
    final UserModel userModel = postModel.postedBy;
    if (AppConfigurationController.to.isUserBlockedAlready(userId: userModel.uId ?? "")) {
      return const SizedBox.shrink();
    }

    return HomePostWidget(
      /// COMMENTED For INFLUENCE BAR
      // influence points widget based on Influence Points
      // influenceIcon: (userModel.isUserInfluencePointsValid) ? userModel.getUserInfluencePointsIndicator : null,
      pdfFiles: postModel.pdfFiles,
      postModel: postModel,
      createdAt: postModel.approvedAt,
      anonymousPost: postModel.isPostedAnonymously,
      //not in use
      hasVideo: (postModel.video == null || postModel.video == '') ? false : true,
      videoLink: postModel.video,
      postImage: postModel.multipleImages ?? [],
      postId: postModel.postid,
      doNotshowBottomrow: false,
      totalLikesCount: postModel.likedBy?.length.toString() ?? "0",
      totalCommentsCount: postModel.totalCommentsCount ?? "0",
      savePostColor: kSecondaryColor,
      profileImage: userModel.profilePicture,
      totalCrownsCount: postModel.crownsBy?.length.toString() ?? "0",
      posterCrownsCount: userModel.userTotalCrowns?.toString() ?? "0",
      isCrowned: postModel.crownsBy?.contains(UserModel.to.uId) == true ? true : false,
      groupImage: communityModel.CommunityPic.toString(),
      title: communityModel.communityName.toString(),
      content: postModel.postDescription.toString(),
      save: AppConfigurationController.to.savedPostsID.contains(postModel.postid) == true
          ? GayaStrings.unsave_txt.tr
          : GayaStrings.save_txt.tr,
      subtitle: postModel.isPostedAnonymously == true
          ? postModel.postedBy.gender == null
              ? anonymousUser
              : postModel.postedBy.gender == 'male'
                  ? anonymousBoy
                  : postModel.postedBy.gender == 'female'
                      ? anonymousGirl
                      : anonymousUser
          : userModel.name.toString(),
      approvalShow: false,
      currentUserPost: postModel.memberId == UserModel.to.uId,
      onTap: () async {
        // checking post tile is attached in search screen
        if (inSearchScreen) {
          // Logging user clicked search result analytics event
          AnalyticsController.to.instance.logUserClickedSearchResult(
            userId: UserModel.to.uId ?? '',
            clickedResultIndex: index.toString(),
            searchedText: GayaSearchController.to.searchTextEditingController.text,
            clickedResultText: postModel.postDescription ?? '',
            itemType: 'post',
          );
        }

        final post = await Routes.postDetailsScreen(
          post: postModel,
          community: communityModel,
        );
        MyLoggerServices.to.print("Post ==> $post");

        if (post != null && post is Post) {
          FeedControllerUtils.updatePostLocally(
            post,
            metadata: runtimeType.toString(),
          );
        }
      },
      onHideCommunity: () async {
        FeedControllerUtils.onHideCommunity(
          communityId: communityModel.communityId ?? "",
        );
      },
      crossAxis: postModel.multipleImages == null
          ? 1
          : postModel.multipleImages!.length < 2
              ? 1
              : 2,
      onDeleteTap: () async {
        Navigator.pop(context);
        await context.read<GroupController>().deleteYourPost(
              postModel.postid!,
              context,
              communityModel.communityId,
            );
        FeedControllerUtils.updatePostLocally(postModel, shouldDelete: true, metadata: runtimeType.toString());
      },
      report: () {
        Navigator.pop(context);
        ReportController.to.reportPost(
          postModel.postid ?? "",
          context,
          postModel.community.adminUid,
          communityId: postModel.community.communityId ?? "",
        );
      },
      imageTap: () {
        (postModel.multipleImages?.isEmpty ?? true)
            ? null
            : Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostImages(allImages: postModel.multipleImages ?? []),
                ),
              );
      },
      isPostHasImage: postModel.multipleImages == null
          ? false
          : postModel.multipleImages!.isEmpty == true
              ? false
              : true,
      //images
      overlapImage: GestureDetector(
        onTap: () {
          if (postModel.isPostedAnonymously == true) {
          } else {
            Routes.viewProfile(uid: userModel.uId, model: userModel);
          }
        },
        child: CircleAvatar(
          backgroundColor: kWhiteColor,
          radius: 17.r,
          child: (postModel.isPostedAnonymously == true)
              ? CircleAvatar(
                  radius: 17.r,
                  backgroundImage: AssetImage(
                    postModel.postedBy.gender == null
                        ? "Assets/images/anonymous_user.png"
                        : postModel.postedBy.gender == 'male'
                            ? "Assets/images/anonymous_boy.png"
                            : postModel.postedBy.gender == 'female'
                                ? "Assets/images/anonymous_girl.png"
                                : "Assets/images/anonymous_user.png",
                  ),
                )
              : userModel.profilePicture == ''
                  ? CircleAvatar(
                      radius: 17.r,
                      backgroundImage: const AssetImage('Assets/images/user.png'),
                    )
                  : CircleAvatar(
                      radius: 17.r,
                      backgroundColor: kBaseGrey,
                      child: ProfileImageWidget(
                        url: userModel.profilePicture,
                        size: const Size(100, 100),
                      ),
                    ),
        ),
      ),
      //void call back on flower on tap
      // likeOnTap: () => FeedControllerUtils.likePost(postModel.postid, receiverUser: userModel, metadata: runtimeType.toString()),

      // like reaction on tap
      likeReactionOnTap: (reaction, isChecked) async {
        FeedControllerUtils.likeReactionOnPost(postModel.postid,
            receiverUser: userModel, metadata: runtimeType.toString(), reaction: reaction, isChecked: isChecked);
      },

      likeIconColor: (postModel.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid) ?? false) ? kRedColor : kSecondaryColor,
      //void call back on crown on tap
      crownOnTap: () async {
        if (UserModel.to.userDailyCrowns == null &&
                postModel.crownsBy?.contains(UserModel.to.uId) == false &&
                userModel.uId != UserModel.to.uId ||
            UserModel.to.userDailyCrowns == 0 &&
                postModel.crownsBy?.contains(UserModel.to.uId) == false &&
                userModel.uId != UserModel.to.uId) {
          Methods.showCrownsTotalModalSheet(ctx: Get.context);
          return;
        }
        if (postModel.crownsBy!.contains(UserModel.to.uId) || userModel.uId == UserModel.to.uId) {
          debugPrint('calling');
        } else {
          FeedControllerUtils.crownPost(postModel.postid, receiverUser: postModel.postedBy);
        }
      },

      commentOntap: () {
        // MyLoggerServices.to.print("postDetailsScreen going to open comment");
        // final post = await Routes.postDetailsScreen(post: postModel, community: communityModel);
        // MyLoggerServices.to.print("Post=> $post");
        // if (post != null && post is Post) {
        //   print('total comments count ${post.totalCommentsCount}');
        //   FeedControllerUtils.updatePostLocally(post, metadata: runtimeType.toString());
        // }
        // new view for displaying comments in dialogbox

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 20).r,
                titlePadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15).r,
                contentPadding: const EdgeInsets.symmetric(horizontal: 19).r,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.r))),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Text(GayaStrings.comments_txt.tr, style: GayaTypography.title),
                    InkWell(
                      child: Icon(Icons.close, size: 24.r, color: AppColors.black),
                      onTap: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                content: CommentsDialogBox(postModel: postModel),
              );
            });
      },
      onTapSaved: () async {
        if (AppConfigurationController.to.savedPostsID.contains(postModel.postid) == true) {
          Navigator.pop(context);
          AppConfigurationController.to.savedPostsID.remove(postModel.postid);

          await context.read<HomePageController>().deleteUserSaveDocFromPostCollection(postModel.postid!, context);

          // Logging un-save post analytics event
          AnalyticsController.to.instance.logSaveOrUnSavePost(
            eventType: 'un_save',
            userId: UserModel.to.uId ?? '',
            communityId: communityModel.communityId ?? '',
            postId: postModel.postid ?? '',
          );

          await context.read<HomePageController>().deletePostFromUserCollection(postModel.postid!);
        } else {
          Navigator.pop(context);
          AppConfigurationController.to.savedPostsID.add(postModel.postid ?? "");
          await context.read<CreatePostController>().savePost(postModel.postid!);

          // Logging save post analytics event
          AnalyticsController.to.instance.logSaveOrUnSavePost(
            eventType: 'save',
            userId: UserModel.to.uId ?? '',
            communityId: communityModel.communityId ?? '',
            postId: postModel.postid ?? '',
          );

          await context.read<HomePageController>().setSavePostInUSerCollection(
            {
              'postId': postModel.postid,
              'communityId': communityModel.communityId,
              'userUid': UserModel.to.uId,
            },
            context,
          );
        }
      },
      onUserTap: () async {
        Methods.showModalSheetToJoinCommunity(
          communityModel: communityModel,
          communityId: communityModel.communityId,
          ctx: context,
        );
      },
      onManageTopics: () async {
        Methods.showTopicPostUpdateModalSheet(
          community: postModel.community,
          post: postModel,
          context: context,
          onDoneButtonPressed: (updatedPost) => FeedControllerUtils.updatePostTopics(post: updatedPost),
        );
      },
    );
  }
}
