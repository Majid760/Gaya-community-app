import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/comments/components/comments_dialogbox.dart';
import 'package:gaya/view/community/controllers/community_feed_controller.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../../../controller/create.post.controller.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../controller/group.controller.dart';
import '../../../controller/homepage.controller.dart';
import '../../../controller/report_controller.dart';
import '../../../routing/getx_route_methods.dart';
import '../../../utils/const.dart';
import '../../../utils/logger.dart';
import '../../../utils/strings.dart';
import '../../../widgets/home_view_widgets/home.post.widget.dart';
import '../../feed/controller/base/base_feed_impl.dart';
import '../controllers/community_editing_controller.dart';

/// Specifically for [CommunityFeedView]
class CommunityFeedPostTile extends StatelessWidget {
  final Post postModel;
  final String? pinnedPostId;
  final CommunityFeedController controller;

  /// make sure to pass this object as updated one otherwise use other Tile
  final Community community;

  const CommunityFeedPostTile({Key? key, required this.postModel, this.pinnedPostId, required this.controller, required this.community})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Post createPostModel = postModel;
    Community createCommunityModel = createPostModel.community;
    UserModel userModel = createPostModel.postedBy;

    if (AppConfigurationController.to.isUserBlockedAlready(userId: userModel.uId ?? "")) {
      return const SizedBox.shrink();
    }
    final editingController = EditCommunityController.to(tag: createPostModel.communityId);
    return GetBuilder<CommunityFeedController>(
        init: CommunityFeedController.to(tag: createCommunityModel.communityId),
        builder: (controller) {
          return HomePostWidget(
            // communityThemeColor: community.communityThemeModelOrDefault().toColor,
            /// COMMENTED For INFLUENCE BAR
            // influence points widget based on Influence Points
            // influenceIcon: (userModel.isUserInfluencePointsValid) ? userModel.getUserInfluencePointsIndicator : null,

            /// only use where communityfeed
            forcefullyAdminOrModerator: community.isModeratorOrAdmin,
            pdfFiles: createPostModel.pdfFiles,
            onTap: () async {
              MyLoggerServices.to.print("postDetailsScreen going to open");
              final post = await Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);

              if (post != null) {
                MyLoggerServices.to.print("UPDATE POST LOCALLY");
                //update community feed post
                controller.updatePostLocally(post);
                //update  parent feed post
                FeedControllerUtils.updatePostLocally(post, metadata: runtimeType.toString());
              } else {
                debugPrint("post is null, cant updateIT");
              }
            },
            isPostPinned: community.pinnedPostList?.contains(createPostModel.postid) ?? false,
            showModeratorTag: editingController.isPosterModerator(createPostModel.postedBy),
            moderatorData: editingController.createCommunityModel?.moderatorTagData ?? createCommunityModel.moderatorTagData,
            createdAt: createPostModel.approvedAt,
            postModel: createPostModel,
            isDiscussionView: true,
            hasVideo: (createPostModel.video == null || createPostModel.video == '') ? false : true,
            videoLink: createPostModel.video,
            crossAxis: createPostModel.multipleImages == null
                ? 1
                : createPostModel.multipleImages!.length < 2
                    ? 1
                    : 2,
            postId: createPostModel.postid,
            report: () {
              Navigator.pop(context);
              ReportController.to.reportPost(
                createPostModel.postid ?? "",
                context,
                createPostModel.community.adminUid,
                communityId: createPostModel.community.communityId ?? "",
              );
            },
            onDeleteTap: () async {
              Navigator.pop(context);
              try {
                controller.deletePostLocally(createPostModel);
                await context.read<GroupController>().deleteYourPost(
                      createPostModel.postid!,
                      context,
                      createPostModel.community.communityId,
                    );
              } catch (e) {
                debugPrint(e.toString());
              }
            },
            doNotshowBottomrow: false,
            totalLikesCount: createPostModel.likedBy?.length.toString() ?? "0",
            totalCommentsCount: createPostModel.totalCommentsCount ?? "0",

            likeIconColor: createPostModel.likedBy?.contains(UserModel.to.uId) == true ? kRedColor : kSecondaryColor,

            imageTap: (createPostModel.multipleImages?.isEmpty ?? true)
                ? null
                : () {
                    Routes.openMultipleImages(urls: createPostModel.multipleImages);
                  },

            //void call back on flower on tap
            // likeOnTap: () async {
            //   final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
            //   postController.likePost(postModel.postid, receiverUser: userModel);
            // },
            // like reaction on tap
            likeReactionOnTap: (reaction, isChecked) async {
              final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
              // postController.likePost(postModel.postid, receiverUser: userModel);
              postController.likeReactionOnPost(postModel.postid, receiverUser: userModel, reaction: reaction, isChecked: isChecked);
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
              if (postModel.crownsBy == null && userModel.uId != UserModel.to.uId) {
                print('poster id 1: ${postModel.memberId} and my id: ${UserModel.to.uId}');

                final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
                postController.crownPost(createPostModel.postid, receiverUser: createPostModel.postedBy);
              } else if (postModel.crownsBy!.contains(UserModel.to.uId) || userModel.uId == UserModel.to.uId) {
              } else {
                final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
                postController.crownPost(createPostModel.postid, receiverUser: createPostModel.postedBy);
              }
            },

            commentOntap: () async {
              // MyLoggerServices.to.print("postDetailsScreen going to open");
              // final post = await Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);
              // if (post != null && post is Post) {
              //   MyLoggerServices.to.print("UPDATE POST LOCALLY");
              //   //update community feed post
              //   controller.updatePostLocally(post);
              //   //update  parent feed post
              //   FeedControllerUtils.updatePostLocally(post, metadata: runtimeType.toString());
              // }
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
                      content: CommentsDialogBox(postModel: createPostModel),
                    );
                  });
            },
            save: AppConfigurationController.to.savedPostsID.contains(createPostModel.postid) == true ? "Unsave" : "Save",
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
                  postId: postModel.postid ?? '',
                );

                await context.read<HomePageController>().deletePostFromUserCollection(createPostModel.postid!);
              } else {
                Navigator.pop(context);
                AppConfigurationController.to.savedPostsID.add(createPostModel.postid ?? "");
                await context.read<CreatePostController>().savePost(
                      createPostModel.postid!,
                    );

                // Logging save post analytics event
                AnalyticsController.to.instance.logSaveOrUnSavePost(
                  eventType: 'save',
                  userId: UserModel.to.uId ?? '',
                  communityId: createPostModel.communityId ?? '',
                  postId: postModel.postid ?? '',
                );

                await context.read<HomePageController>().setSavePostInUSerCollection(
                  {
                    'postId': createPostModel.postid,
                    'communityId': createCommunityModel.communityId,
                    'userUid': UserModel.to.uId,
                  },
                  context,
                );
              }
            },
            currentUserPost: createPostModel.memberId == UserModel.to.uId,
            onManageTopics: () {
              Navigator.pop(context);
              Methods.showTopicPostUpdateModalSheet(
                  community: createCommunityModel,
                  post: postModel,
                  context: context,
                  onDoneButtonPressed: (updatedPost) => Get.find<CommunityFeedController>().updatePostTopicsFirebase(updatedPost));
            },
            onPinPost: () {
              Navigator.pop(context);
              if (createCommunityModel.communityId != null && createPostModel.postid != null) {
                controller.togglePinPost(createCommunityModel, createPostModel);
              }
            },
            onUserTap: () {
              if (createPostModel.isPostedAnonymously == true) {
              } else {
                Routes.viewProfile(uid: userModel.uId, model: userModel);
              }
            },
            anonymousPost: createPostModel.isPostedAnonymously == true ? true : false,
            groupImage: userModel.profilePicture ?? "",

            title: postModel.isPostedAnonymously == true
                ? postModel.postedBy.gender == null
                    ? anonymousUser
                    : postModel.postedBy.gender == 'male'
                        ? anonymousBoy
                        : postModel.postedBy.gender == 'female'
                            ? anonymousGirl
                            : anonymousUser
                : userModel.name.toString(),
            gender: postModel.postedBy.gender,
            content: createPostModel.postDescription.toString(),
            postImage: createPostModel.multipleImages ?? [],
            subtitle: Jiffy(createPostModel.postCreatedOn).fromNow(),
            isPostHasImage: createPostModel.isPostHaveImage,
            approvalShow: false,
          );
        });
  }
}

/// Specifically for [CommunityFeedViewV2]
class HomeCommunityFeedPostTile extends StatelessWidget {
  final Post postModel;
  final String? pinnedPostId;
  final CommunityFeedController controller;
  final Community community;

  const HomeCommunityFeedPostTile({Key? key, required this.postModel, this.pinnedPostId, required this.controller, required this.community})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Post createPostModel = postModel;
    Community createCommunityModel = createPostModel.community;
    UserModel userModel = createPostModel.postedBy;
    if (AppConfigurationController.to.isUserBlockedAlready(userId: userModel.uId ?? "")) {
      return const SizedBox.shrink();
    }
    // final editingController = EditCommunityController.to(tag: createPostModel.communityId);
    return HomePostWidget(

      /// COMMENTED For INFLUENCE BAR
      // influence points widget based on Influence Points
      // influenceIcon: (userModel.isUserInfluencePointsValid) ? userModel.getUserInfluencePointsIndicator : null,
      forcefullyAdminOrModerator: community.isModeratorOrAdmin,
      pdfFiles: createPostModel.pdfFiles,

      onTap: () async {
        MyLoggerServices.to.print("postDetailsScreen going to open");
        final post = await Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);

        if (post != null) {
          MyLoggerServices.to.print("UPDATE POST LOCALLY");
          //update community feed post
          controller.updatePostLocally(post);
          //update  parent feed post

          FeedControllerUtils.updatePostLocally(post, metadata: runtimeType.toString());
        } else {
          debugPrint("post is null, cant updateIT");
        }
      },
      // isPostPinned: createCommunityModel.pinnedPostList?.contains(createPostModel.postid) ?? false,

      // showModeratorTag: editingController.isPosterModerator(createPostModel.postedBy),
      // moderatorData: editingController.createCommunityModel?.moderatorTagData ?? createCommunityModel.moderatorTagData,
      createdAt: createPostModel.approvedAt,
      postModel: createPostModel,
      isDiscussionView: true,
      hasVideo: (createPostModel.video == null || createPostModel.video == '') ? false : true,
      videoLink: createPostModel.video,
      crossAxis: createPostModel.multipleImages == null
          ? 1
          : createPostModel.multipleImages!.length < 2
              ? 1
              : 2,
      postId: createPostModel.postid,
      report: () {
        Navigator.pop(context);
        ReportController.to.reportPost(createPostModel.postid ?? "", context, createPostModel.community.adminUid,
            communityId: createPostModel.community.communityId ?? "");
      },
      onDeleteTap: () async {
        Navigator.pop(context);
        try {
          controller.deletePostLocally(createPostModel);
          await context.read<GroupController>().deleteYourPost(
                createPostModel.postid!,
                context,
                createPostModel.community.communityId,
              );
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      doNotshowBottomrow: false,
      totalLikesCount: createPostModel.likedBy?.length.toString() ?? "0",
      totalCommentsCount: createPostModel.totalCommentsCount ?? "0",

      likeIconColor: createPostModel.likedBy?.contains(UserModel.to.uId) == true ? kRedColor : kSecondaryColor,

      imageTap: (createPostModel.multipleImages?.isEmpty ?? true)
          ? null
          : () {
              Routes.openMultipleImages(urls: createPostModel.multipleImages);
            },

      //void call back on flower on tap
      // likeOnTap: () async {
      //   final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
      //   postController.likePost(postModel.postid, receiverUser: userModel);
      // },

      // like reaction on tap
      likeReactionOnTap: (reaction, isChecked) async {
        final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
        // postController.likePost(postModel.postid, receiverUser: userModel);
        postController.likeReactionOnPost(postModel.postid, receiverUser: userModel, reaction: reaction, isChecked: isChecked);
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
        if (postModel.crownsBy == null && userModel.uId != UserModel.to.uId) {
          print('poster id 1: ${postModel.memberId} and my id: ${UserModel.to.uId}');

          final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
          postController.crownPost(createPostModel.postid, receiverUser: createPostModel.postedBy);
        } else if (postModel.crownsBy!.contains(UserModel.to.uId) || userModel.uId == UserModel.to.uId) {
        } else {
          final CommunityFeedController postController = CommunityFeedController.to(tag: createCommunityModel.communityId);
          postController.crownPost(createPostModel.postid, receiverUser: createPostModel.postedBy);
        }
      },

      commentOntap: () async {
        // MyLoggerServices.to.print("postDetailsScreen going to open");
        // final post = await Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);
        // if (post != null && post is Post) {
        //   MyLoggerServices.to.print("UPDATE POST LOCALLY");
        //   //update community feed post
        //   controller.updatePostLocally(post);
        //   //update  parent feed post
        //   FeedControllerUtils.updatePostLocally(post, metadata: runtimeType.toString());
        // }
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
                    Text(GayaStrings.comments.tr, style: GayaTypography.title),
                    InkWell(
                      child: Icon(Icons.close, size: 24.r, color: AppColors.black),
                      onTap: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                content: CommentsDialogBox(postModel: createPostModel),
              );
            });
      },
      save: AppConfigurationController.to.savedPostsID.contains(createPostModel.postid) == true ? "Unsave" : "Save",
      onTapSaved: () async {
        if (AppConfigurationController.to.savedPostsID.contains(createPostModel.postid) == true) {
          Navigator.pop(context);
          AppConfigurationController.to.savedPostsID.remove(createPostModel.postid);

          await context.read<HomePageController>().deleteUserSaveDocFromPostCollection(createPostModel.postid!, context);

          // Logging un-save post analytics event
          AnalyticsController.to.instance.logSaveOrUnSavePost(
            eventType: 'un_save',
            userId: UserModel.to.uId ?? '',
            communityId: createCommunityModel.communityId ?? '',
            postId: postModel.postid ?? '',
          );

          await context.read<HomePageController>().deletePostFromUserCollection(createPostModel.postid!);
        } else {
          Navigator.pop(context);
          AppConfigurationController.to.savedPostsID.add(createPostModel.postid ?? "");
          await context.read<CreatePostController>().savePost(
                createPostModel.postid!,
              );

          // Logging save post analytics event
          AnalyticsController.to.instance.logSaveOrUnSavePost(
            eventType: 'save',
            userId: UserModel.to.uId ?? '',
            communityId: createPostModel.communityId ?? '',
            postId: postModel.postid ?? '',
          );

          await context.read<HomePageController>().setSavePostInUSerCollection(
            {
              'postId': createPostModel.postid,
              'communityId': createCommunityModel.communityId,
              'userUid': UserModel.to.uId,
            },
            context,
          );
        }
      },
      currentUserPost: createPostModel.memberId == UserModel.to.uId,
      onManageTopics: () {
        Navigator.pop(context);
        Methods.showTopicPostUpdateModalSheet(
            community: createCommunityModel,
            post: postModel,
            context: context,
            onDoneButtonPressed: (updatedPost) => Get.find<CommunityFeedController>().updatePostTopicsFirebase(updatedPost));
      },
      onPinPost: () {
        Navigator.pop(context);
        if (createCommunityModel.communityId != null && createPostModel.postid != null) {
          controller.togglePinPost(createCommunityModel, createPostModel);
        }
      },
      onUserTap: () {
        if (createPostModel.isPostedAnonymously == true) {
        } else {
          Routes.viewProfile(uid: userModel.uId, model: userModel);
        }
      },
      anonymousPost: createPostModel.isPostedAnonymously == true ? true : false,
      groupImage: userModel.profilePicture ?? "",

      title: postModel.isPostedAnonymously == true
          ? postModel.postedBy.gender == null
              ? anonymousUser
              : postModel.postedBy.gender == 'male'
                  ? anonymousBoy
                  : postModel.postedBy.gender == 'female'
                      ? anonymousGirl
                      : anonymousUser
          : userModel.name.toString(),
      gender: postModel.postedBy.gender,
      content: createPostModel.postDescription.toString(),
      postImage: createPostModel.multipleImages ?? [],
      subtitle: Jiffy(createPostModel.postCreatedOn).fromNow(),
      isPostHasImage: createPostModel.isPostHaveImage,
      approvalShow: false,
      showPinOption: false,
    );
  }
}
