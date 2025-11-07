import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/gaya_chip.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/message_service/message_service.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../../components/button.component.dart';
import '../../components/profile_image_widget.dart';
import '../../components/remove.user.dialogue.dart';
import '../../controller/group.controller.dart';
import '../../model/communities.memebers.model.dart';
import '../../model/user.model.dart';
import '../../services/services.dart';
import '../../utils/const.dart';
import '../../utils/logger.dart';
import '../../utils/methods.dart';
import '../../utils/refresh_builder_utils.dart';
import '../../utils/textstyles.dart';
import '../../view/community/components/moderators_skeleton_widget.dart';
import '../../view/community/controllers/base_controller.dart';
import '../../view/community/services/community_members_services.dart';

class CommunityMembersController extends BaseController {
  static CommunityMembersController to({required String tag}) => Get.find(tag: tag);

  CommunityMembersController({required this.communityId});

  @override
  onInit() {
    _communityMembersServices = CommunityMembersServices(communityId: communityId);
    requestMoreData(fromInit: true);
    super.onInit();
  }

  final String communityId;

  // Community members for paginated form community members
  bool isFirstTime = false;
  List<UserModel> _paginatedCommunityMembers = [];
  CommunityMembersServices? _communityMembersServices;
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
  );
  bool isLoading = false;

  bool get isMembersEmpty => _paginatedCommunityMembers.isEmpty;

  List<UserModel> getMembers() => _paginatedCommunityMembers;

  void resetController({bool isDisposing = false}) async {
    _paginatedCommunityMembers = [];
    isFirstTime = false;
    isLoading = false;
    if (_communityMembersServices != null) {
      _communityMembersServices?.reset();
    }
    if (isDisposing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    } else {
      await requestMoreData(
        fromInit: true,
      );
    }
  }

  Future<void> requestMoreData({bool fromInit = false}) async {
    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      isLoading = true;
      // update();
    }
    isFirstTime = true;
    final newPosts = await _communityMembersServices!.requestMoreData();
    MyLoggerServices.to.print("newMembers.length ${newPosts.length}");
    _paginatedCommunityMembers.addAll(newPosts);
    isLoading = false;
    update();
    refreshController.finishLoad(newPosts.isEmpty ? IndicatorResult.noMore : IndicatorResult.success);
  }
}

class GetCommunityMembers extends StatelessWidget {
  final dynamic getAllMembers;
  final GroupController controller;
  final String communityId;
  final Community communityModel;

  const GetCommunityMembers(
      {super.key, required this.communityModel, required this.getAllMembers, required this.controller, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 4).r;

    final skeletonList = Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
      child: ListView(physics: const NeverScrollableScrollPhysics(), children: const [
        ModeratorsSkeletonWidget(),
        ModeratorsSkeletonWidget(),
        ModeratorsSkeletonWidget(),
        ModeratorsSkeletonWidget(),
      ]),
    );
    return GetBuilder<CommunityMembersController>(
        autoRemove: false,
        tag: communityId,
        init: CommunityMembersController(communityId: communityId),
        builder: (communityEditCtrl) {
          // Consumer<CommunityEditingController>(builder: (context, communityEditCtrl, child) {
          return EasyRefresh.builder(
            // refreshOnStart: true,
            simultaneously: true,
            // noMoreLoad: false,
            controller: communityEditCtrl.refreshController,
            header: RefreshBuilderUtils.headerAbove,
            footer: RefreshBuilderUtils.footerAbove,
            onRefresh: () async => communityEditCtrl.resetController(),
            onLoad: communityEditCtrl.isMembersEmpty ? null : () async => await communityEditCtrl.requestMoreData(),
            childBuilder: (context, physics) {
              if (communityEditCtrl.isLoading) {
                return skeletonList;
              }
              return ListView.separated(
                  separatorBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 5).r),
                  itemCount: communityEditCtrl.getMembers().length,
                  physics: physics,
                  itemBuilder: (ctx, index) {
                    UserModel userModel = communityEditCtrl.getMembers()[index];
                    return UserMemberTile(
                      userModel: userModel,
                      adminId: controller.groupAdminId ?? "",
                      communityId: communityId,
                      padding: padding,
                    );
                  });
            },
          );
        });
  }

  /// Get Member Tag (Admin, Moderator)
  Widget? getTagWidget(CommunityMembership member) {
    if (member.isAdmin == true) {
      return GayaChipWidget(text: GayaStrings.manager_txt.tr, color: AppColors.primary);
    }

    // add if(community.modertators.contain(member.uiserId))
    // else if (member.isModerator == true) {

    else if (communityModel.moderators?.contains(member.userUid) == true) {
      return GayaChipWidget(text: GayaStrings.moderator.tr, color: AppColors.primary);
    }
    return null;
  }
}

class UserMemberTile extends StatelessWidget {
  final UserModel userModel;
  final EdgeInsets? padding;
  final String adminId;
  final String communityId;

  UserMemberTile({Key? key, required this.userModel, this.padding, required this.adminId, required this.communityId}) : super(key: key);

  _viewProfile(UserModel userModel) {
    return Routes.viewProfile(uid: userModel.uId, model: userModel);
  }

  bool isSendMessageLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _viewProfile(userModel),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 4).r,
            child: Row(
              children: [
                userModel.profilePicture == ''
                    ? const CircleAvatar(backgroundColor: kBaseGrey, backgroundImage: AssetImage('Assets/images/user.png'))
                    : CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                        child: ProfileImageWidget(url: userModel.profilePicture, size: const Size(50, 50))),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onLongPress: () async {
                      if (adminId == FirebaseAuth.instance.currentUser?.uid) {
                        HapticFeedback.mediumImpact();
                        final membership = await Get.find<Services>().getUserMembership(communityId: communityId, userId: userModel.uId);
                        membership?.isAdmin == true ? null : kickUserFromGroupDialogue(context, userModel, communityId);
                      }
                    },
                    child: Text(
                      userModel.name.toString(),
                      maxLines: 2,
                      style: CustomTypography.body4StyleLowWeight,
                      textDirection: Methods.isRTL(userModel.name.toString()) ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ),
                SizedBox(width: MySpaces.gap2.w),
                // getTagWidget(communityModel) ?? const SizedBox.shrink(),
                const Spacer(flex: 1),
                StatefulBuilder(builder: (context, update) {
                  if (isSendMessageLoading) {
                    return SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.27,
                      height: 30.h,
                      child: const CupertinoActivityIndicator(),
                    );
                  }
                  return Row(
                    children: [
                      GayaButton(
                          textStyle: GayaTypography.caption2.copyWith(height: 1),
                          leadingIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.mail_outline,
                              size: 15.r,
                              color: AppColors.black,
                            ),
                          ),
                          primaryColor: kBaseGrey,
                          width: MediaQuery.sizeOf(context).width * 0.27,
                          height: 30.h,
                          title: GayaStrings.send_message.tr,
                          borderColor: kTransparentColor,
                          onPressed: isSendMessageLoading
                              ? null
                              : () async {
                                  isSendMessageLoading = true;
                                  update(() {});
                                  await MessageUtils.sendAMessage(userModel, context: context);
                                  isSendMessageLoading = false;
                                  update(() {});
                                  // Routes.viewProfile(uid: userModel.uId, model: userModel);
                                }),
                    ],
                  );
                })
              ],
            ),
          ),
        ),
        // const SizedBox(height: MySpaces.gap2),
      ],
    );
  }
}
