import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../components/skeleton.post.component.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../model/community.model.dart';
import '../../../../model/create.post.model.dart';
import '../../../../model/user.model.dart';
import '../../../../utils/animation.dart';
import '../../../../utils/const.dart';
import '../../../../utils/strings.dart';
import '../../../../utils/theme/app_spaces.dart';
import '../../../../widgets/home_view_widgets/home.post.widget.dart';
import '../../../Auth/controller/require.sigin.register.dart';
import '../../controller/for_you_controller.dart';

class GuestUserFeed extends GetView<ForYouFeedController> {
  const GuestUserFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final skeletonList = Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_16).r,
      child: ListView(physics: const NeverScrollableScrollPhysics(), children: const [
        SizedBox(height: 40),
        PostsSkeleton(isTextOnly: true),
        PostsSkeleton(),
        PostsSkeleton(),
      ]),
    );
    return GetBuilder<ForYouFeedController>(
        init: controller,
        builder: (controller) {
          return EasyRefresh.builder(
            simultaneously: true,
            // noMoreLoad: false,
            controller: controller.refreshController,
            header: const CupertinoHeader(
              position: IndicatorPosition.above,
              userWaterDrop: false,
              safeArea: true,
              triggerOffset: 60,
              hapticFeedback: true,
              triggerWhenRelease: true,
              emptyWidget: SizedBox(),
            ),
            footer: const CupertinoFooter(
              position: IndicatorPosition.above,
              userWaterDrop: false,
              emptyWidget: SizedBox(),
            ),
            onLoad: () async {
              await controller.requestMoreData();
              return IndicatorMode.processing;
            },
            childBuilder: (context, physics) {
              if (controller.isLoading) {
                return skeletonList;
              }
              if (controller.isFeedEmpty) {
                return ListView(physics: physics, children: const [
                  AnimationLottie(),
                ]);
              }
              return ListView.separated(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  separatorBuilder: (ctx, index) => MyDividers.postFeed,
                  controller: controller.homeScrollController,
                  itemCount: controller.posts.length,
                  physics: physics,
                  itemBuilder: (ctx, index) {
                    Post createPostModel = controller.posts[index];

                    Community? createCommunityModel = createPostModel.community;

                    UserModel userModel = createPostModel.postedBy;

                    return HomePostWidget(
                      /// COMMENTED For INFLUENCE BAR
                      // influence points widget based on Influence Points
                      // influenceIcon: (userModel.isUserInfluencePointsValid) ? userModel.getUserInfluencePointsIndicator : null,
                      key: ValueKey("_${createPostModel.postid}"),
                      pdfFiles: createPostModel.pdfFiles,
                      createdAt: createPostModel.approvedAt,
                      anonymousPost: createPostModel.isPostedAnonymously,
                      // anonymousPost: createPostModel.isPostedAnonymously ,
                      hasVideo: (createPostModel.video == null || createPostModel.video == '') ? false : true,
                      gender: userModel.gender,
                      videoLink: createPostModel.video,
                      likeIconColor: kSecondaryColor,
                      postModel: createPostModel,
                      crossAxis: createPostModel.multipleImages == null
                          ? 1
                          : createPostModel.multipleImages!.length < 2
                              ? 1
                              : 2,
                      doNotshowBottomrow: false,
                      totalLikesCount: createPostModel.likedBy?.isEmpty ?? true ? "0" : createPostModel.likedBy!.length.toString(),
                      totalCommentsCount:
                          createPostModel.totalCommentsCount?.isEmpty ?? true ? "0" : createPostModel.totalCommentsCount!.toString(),
                      overlapImage: CircleAvatar(
                        backgroundColor: kWhiteColor,
                        radius: 17,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                          },
                          child: (createPostModel.isPostedAnonymously == true)
                              ? CircleAvatar(
                                  radius: distance_15,
                                  backgroundImage: AssetImage(
                                    createPostModel.postedBy.gender == null
                                        ? "Assets/images/anonymous_user.png"
                                        : createPostModel.postedBy.gender == 'male'
                                            ? "Assets/images/anonymous_boy.png"
                                            : createPostModel.postedBy.gender == 'female'
                                                ? "Assets/images/anonymous_girl.png"
                                                : "Assets/images/anonymous_user.png",
                                  ),
                                )
                              : userModel.profilePicture?.trim() == ''
                                  ? const CircleAvatar(radius: distance_15, backgroundImage: AssetImage('Assets/images/user.png'))
                                  : CircleAvatar(
                                      // backgroundImage: CachedNetworkImageProvider(_userModel.profilePicture.toString()),
                                      radius: distance_15,
                                      backgroundColor: kBaseGrey,
                                      // backgroundImage: CachedNetworkImageProvider(_userModel.profilePicture.toString()),
                                      child: CachedNetworkImage(
                                        memCacheHeight: 50,
                                        memCacheWidth: 50,
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
                      ),
                      // likeOnTap: () async {
                      //   Get.to(() => const RequireSignRegisterView(isButtonLiked: false, isflower: true),
                      //       transition: Transition.cupertinoDialog);
                      // },

                      // like reaction on tap
                      likeReactionOnTap: (reaction, isChecked) async {
                        Get.to(() => const RequireSignRegisterView(isButtonLiked: false, isflower: true),
                            transition: Transition.cupertinoDialog);
                      },
                      // flowerOnTap: () {
                      //   Get.to(() => const RequireSignRegisterView(isButtonLiked: true, isflower: false),
                      //       transition: Transition.cupertinoDialog);
                      // },
                      totalCrownsCount: createPostModel.crownsBy?.length.toString() ?? "0",
                      posterCrownsCount: userModel.userTotalCrowns?.toString() ?? "0",

                      // isCrowned: createPostModel.crownsBy?.contains(UserModel.to.uId) == true ? true : false,
                      //void call back on crown on tap
                      crownOnTap: () {
                        Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                      },
                      commentOntap: () {
                        Get.to(() => const RequireSignRegisterView(isButtonLiked: true, isflower: true),
                            transition: Transition.cupertinoDialog);
                      },
                      onTapSaved: () {
                        Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                      },

                      onUserTap: () {
                        Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                      },
                      onTap: () {
                        Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                      },
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
                      isPostHasImage: createPostModel.multipleImages == null
                          ? false
                          : createPostModel.multipleImages!.isEmpty == true
                              ? false
                              : true,
                      approvalShow: false,
                    );
                  });
            },
          );
        });
  }
}
