import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/skeleton.post.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/controller/homepage.controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/comments/components/comments_dialogbox.dart';
import 'package:gaya/widgets/home_view_widgets/home.post.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controller/firebase_analytics_controller.dart';
import '../controller/group.controller.dart';
import '../controller/report_controller.dart';
import '../routing/getx_route_methods.dart';
import '../shared/view/widget/gaya_back_button.dart';
import '../utils/strings.dart';

class SavedPostsView extends StatefulWidget {
  const SavedPostsView({Key? key}) : super(key: key);

  @override
  State<SavedPostsView> createState() => _SavedPostsViewState();
}

class _SavedPostsViewState extends State<SavedPostsView> {
  final Services _firestoreServices = Services();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        backgroundColor: kTransparentColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kBlackColor),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Text(GayaStrings.saved_posts.tr, style: CustomTypography.bodyStyle),
      ),
      body: AppConfigurationController.to.savedPostsID.isEmpty
          ? Center(child: Text(GayaStrings.no_saved_posts.tr))
          : ListView.separated(
              separatorBuilder: (ctx, index) => MyDividers.postFeed,
              itemCount: AppConfigurationController.to.savedPostsID.length,
              itemBuilder: (ctx, index) {
                return PostViewBuilderByIdWidget(
                  onUnsavecallback: () => setState(() {}),
                  postId: AppConfigurationController.to.savedPostsID[index],
                  firestoreService: _firestoreServices,
                );
              },
            ),
    );
  }
}

class PostViewBuilderByIdWidget extends StatefulWidget {
  final String postId;
  final Services firestoreService;
  final Function? onUnsavecallback;

  const PostViewBuilderByIdWidget({Key? key, required this.postId, required this.firestoreService, this.onUnsavecallback})
      : super(key: key);

  @override
  State<PostViewBuilderByIdWidget> createState() => _PostViewBuilderByIdWidgetState();
}

class _PostViewBuilderByIdWidgetState extends State<PostViewBuilderByIdWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Post?>(
        future: widget.firestoreService.getPostDetailsSnapshot(widget.postId),
        builder: (ctx, postSnap) {
          if (postSnap.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20).r,
              child: const PostsSkeleton(),
            );
          }
          if (postSnap.data != null) {
            final createPostModel = postSnap.data!;
            final userModel = postSnap.data!.postedBy;
            final createCommunityModel = postSnap.data!.community;
            if (AppConfigurationController.to.isUserBlockedAlready(userId: userModel.uId ?? "")) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                if (createPostModel.isPostedAnonymously == true) {
                } else {
                  Routes.viewProfile(uid: userModel.uId, model: userModel);
                }
              },
              child: HomePostWidget(
                   /// COMMENTED For INFLUENCE BAR
                  // influence points widget based on Influence Points
                  // influenceIcon: (userModel.isUserInfluencePointsValid) ? userModel.getUserInfluencePointsIndicator : null,
                  pdfFiles: createPostModel.pdfFiles,
                  createdAt: createPostModel.approvedAt,
                  postId: createPostModel.postid,
                  anonymousPost: createPostModel.isPostedAnonymously,
                  postModel: createPostModel,
                  hasVideo: (createPostModel.video == null || createPostModel.video == '') ? false : true,
                  report: () {
                    Navigator.pop(context);
                    ReportController.to.reportPost(createPostModel.postid ?? "", context, createPostModel.community.adminUid,
                        communityId: createPostModel.community.communityId ?? "");
                  },
                  videoLink: createPostModel.video,
                  onTap: () {
                    Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);
                  },
                  onUserTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Methods.showModalSheetToJoinCommunity(
                          communityModel: createCommunityModel, communityId: createCommunityModel.communityId, ctx: context);
                      // Methods.routeToGroup(
                      //   community: createCommunityModel,
                      // );
                      // Routes.groupView(community: createCommunityModel);
                    });
                  },
                  imageTap: (createPostModel.multipleImages?.isEmpty ?? true)
                      ? null
                      : () {
                          Routes.openMultipleImages(urls: createPostModel.multipleImages ?? []);
                        },
                  crossAxis: createPostModel.multipleImages == null
                      ? 1
                      : createPostModel.multipleImages!.length < 2
                          ? 1
                          : 2,
                  approvalShow: false,
                  doNotshowBottomrow: true,
                  overlapImage: GestureDetector(
                    onTap: () {
                      if (createPostModel.isPostedAnonymously == true) {
                      } else {
                        Routes.viewProfile(uid: userModel.uId, model: userModel);
                      }
                    },
                    child: createPostModel.isPostedAnonymously == true
                        ? CircleAvatar(
                            radius: 17,
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
                                radius: 17,
                                backgroundImage: AssetImage(Assets.assets.images.userDefault),
                              )
                            : CircleAvatar(
                                backgroundColor: kBaseGrey,
                                radius: 17,
                                //backgroundImage: CachedNetworkImageProvider(userModel.profilePicture!),
                                child: CachedNetworkImage(
                                  memCacheHeight: 40,
                                  memCacheWidth: 40,
                                  imageUrl: userModel.profilePicture ?? '',
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                    child: const Center(
                                        child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    )),
                                  ),
                                  placeholder: (context, url) => Image.asset(
                                    Assets.assets.images.userDefault,
                                  ),
                                ),
                              ),
                  ),
                  totalLikesCount: createPostModel.likedBy?.length.toString() ?? "0",
                  likeIconColor: createPostModel.likedBy?.contains(UserModel.to.uId) == true ? kRedColor : kSecondaryColor,
                  savePostColor: kSecondaryColor,
                  isPostHasImage: createPostModel.multipleImages == null
                      ? false
                      : createPostModel.multipleImages!.isEmpty == true
                          ? false
                          : true,
                  currentUserPost: createPostModel.memberId == FirebaseAuth.instance.currentUser!.uid ? true : false,
                  groupImage: createCommunityModel.CommunityPic.toString(),
                  title: createCommunityModel.communityName.toString(),
                  subtitle: createPostModel.isPostedAnonymously == true
                      ? createPostModel.postedBy.gender == null
                          ? anonymousUser
                          : createPostModel.postedBy.gender == 'male'
                              ? anonymousBoy
                              : createPostModel.postedBy.gender == 'female'
                                  ? anonymousGirl
                                  : anonymousUser
                      : userModel.name.toString(),
                  postImage: createPostModel.multipleImages ?? [],
                  content: createPostModel.postDescription.toString(),
                  totalCommentsCount: createPostModel.totalCommentsCount ?? "0",
                  likeOnTap: () {
                    if (createPostModel.likedBy?.contains(FirebaseAuth.instance.currentUser!.uid) == false) {
                      context.read<CreatePostController>().likePost(createPostModel.postid!, createPostModel.communityId ?? "");
                    } else {
                      FirebaseFirestore.instance
                          .collection('communityposts')
                          .doc(createPostModel.postid)
                          .collection('likes')
                          .where('userUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .get()
                          .then((value) => value.docs.first.reference.delete());
                    }
                  },
                  // flowerOnTap: () {
                  //   if (createPostModel.flowersBy?.contains(UserModel.to.uId) == false) {
                  //     context.read<CreatePostController>().flowerPost(
                  //           createPostModel.postid!,
                  //         );
                  //     log('Post flower ${index}');
                  //   } else {
                  //     FirebaseFirestore.instance
                  //         .collection('communityposts')
                  //         .doc(createPostModel.postid)
                  //         .collection('flowers')
                  //         .where('userUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  //         .get()
                  //         .then((value) => value.docs.first.reference.delete());
                  //     log('unliking the flower ${index}');
                  //   }
                  // },
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
                      if (createPostModel.crownsBy == null ||
                          createPostModel.crownsBy?.contains(FirebaseAuth.instance.currentUser!.uid) == false) {
                        context.read<CreatePostController>().crownPost(createPostModel.postid,
                            receiverUser: createPostModel.postedBy, communityId: createPostModel.communityId ?? "");
                      }
                    } else if (createPostModel.crownsBy!.contains(UserModel.to.uId) || userModel.uId == UserModel.to.uId) {
                    } else {
                      if (createPostModel.crownsBy == null ||
                          createPostModel.crownsBy?.contains(FirebaseAuth.instance.currentUser!.uid) == false) {
                        context.read<CreatePostController>().crownPost(createPostModel.postid,
                            receiverUser: createPostModel.postedBy, communityId: createPostModel.communityId ?? "");
                      }
                    }
                  },
                  onDeleteTap: () async {
                    Navigator.pop(context);
                    await context.read<GroupController>().deleteYourPost(
                          createPostModel.postid!,
                          context,
                          createPostModel.community.communityId,
                        );
                  },

                  // currentUserPost: createPostModel.memberId == FirebaseAuth.instance.currentUser!.uid ? true : false,
                  save: AppConfigurationController.to.savedPostsID.contains(createPostModel.postid) == true ? "Unsave" : "Save",
                  onTapSaved: () async {
                    if (AppConfigurationController.to.savedPostsID.contains(createPostModel.postid) == true) {
                      Navigator.pop(context);
                      AppConfigurationController.to.savedPostsID.remove(createPostModel.postid);
                      widget.onUnsavecallback!();
                      await context.read<HomePageController>().deleteUserSaveDocFromPostCollection(createPostModel.postid!, context);

                      // Logging un-save post analytics event
                      AnalyticsController.to.instance.logSaveOrUnSavePost(
                        eventType: 'un_save',
                        userId: UserModel.to.uId ?? '',
                        communityId: createPostModel.community.communityId ?? '',
                        postId: createPostModel.postid ?? '',
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
                  commentOntap: () {
                    // Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);

                    // Get.to(() => CommentWithPostScreen(postModel: createPostModel, userModel: userModel));
                    // Navigator.of(context).pushNamed(route.postWithComments, arguments: {
                    //   'userModel': userModel,
                    //   'postModel': createPostModel,
                    //   'communityModel': createCommunityModel,
                    // });
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
                  }),
            );
          }
          return Container();
        });
  }

  @override
  bool get wantKeepAlive => true;
}
