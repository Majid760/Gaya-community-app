import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/refresh_builder_utils.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/components/moderators_skeleton_widget.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:get/get.dart';


class PaginatedCommunityMembers extends StatelessWidget {
  final String communityId;
  const PaginatedCommunityMembers({
    Key? key,
    required this.communityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skeletonList = Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
      child: ListView(physics: const NeverScrollableScrollPhysics(), children: const [
        ModeratorsSkeletonWidget(),
        ModeratorsSkeletonWidget(),
        ModeratorsSkeletonWidget(),
        ModeratorsSkeletonWidget(),
      ]),
    );
    return SizedBox(
      // width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: GetBuilder<EditCommunityController>(
          autoRemove: false,
          tag: communityId,
          init: EditCommunityController.to(tag: communityId),
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
                    separatorBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      );
                },
                itemCount: communityEditCtrl.getMembers().length,
                physics: physics,
                itemBuilder: (ctx, index) {
                  UserModel singleUser = communityEditCtrl.getMembers()[index];
                  return InkWell(
                    onTap: () async {
                      if (communityEditCtrl.isModeratorExists(singleUser)) {
                        communityEditCtrl.addRemoveCommumityModerator(context, singleUser, true);
                      } else {
                        showGayaAlertDialogButton(
                          context: context,
                          actionText: GayaStrings.remove_moderator.tr,
                          tapOnYes: () async {
                            Navigator.pop(context);
                            await communityEditCtrl.deleteCommunityModeratorsInDb(context, singleUser);
                          },
                          tapOnNo: () {
                            Navigator.pop(context);
                          },
                        );

                        // final result = await showConfirmationDialog(
                        //     context: context,
                        //     title: 'Are you sure to remove this moderator?',
                        //     cancelLabel: 'Cancel',
                        //     actions: [
                        //       const AlertDialogAction(
                        //         key: 1,
                        //         label: 'Remove Moderator',
                        //         textStyle: TextStyle(
                        //           fontSize: 18,
                        //         ),
                        //       ),
                        //     ]);
                        // if (result == 1) {
                        //   // ignore: use_build_context_synchronously
                        //   await communityEditCtrl.deleteCommunityModeratorsInDb(context, singleUser);
                        // } else {}
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 12,
                        leading: singleUser.profilePicture == '' || singleUser.profilePicture == null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundColor: kBaseGrey,
                                backgroundImage: AssetImage(Assets.assets.images.userDefault),
                              )
                            : CircleAvatar(
                                radius: 20,
                                backgroundColor: kBaseGrey,
                                child: CachedNetworkImage(
                                  memCacheHeight: 50,
                                  memCacheWidth: 50,
                                  imageUrl: singleUser.profilePicture ?? '',
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
                                  ),
                                  placeholder: (context, url) => Image.asset(
                                    Assets.assets.images.userDefault,
                                  ),
                                )),
                        trailing: Checkbox(
                          checkColor: kWhiteColor,
                          activeColor: kprimaryColor,
                          value: (communityEditCtrl.isModeratorExists(singleUser)) ? false : true,
                          onChanged: (isEnabled) async {
                            if (communityEditCtrl.isModeratorExists(singleUser)) {
                              communityEditCtrl.addRemoveCommumityModerator(context, singleUser, true);
                            } else {
                              showGayaAlertDialogButton(
                                context: context,
                                actionText: GayaStrings.remove_moderator.tr,
                                tapOnYes: () async {
                                  Navigator.pop(context);
                                  await communityEditCtrl.deleteCommunityModeratorsInDb(context, singleUser);
                                },
                                tapOnNo: () {
                                  Navigator.pop(context);
                                },
                              );
                              // final result = await showConfirmationDialog(
                              //     context: context,
                              //     title: 'Are you sure to remove this moderator?',
                              //     cancelLabel: 'Cancel',
                              //     actions: [
                              //       const AlertDialogAction(
                              //         key: 1,
                              //         label: 'Remove Moderator',
                              //         textStyle: TextStyle(
                              //           fontSize: 18,
                              //         ),
                              //       ),
                              //     ]);

                              // if (result == 1) {
                              //   // ignore: use_build_context_synchronously
                              //   await communityEditCtrl.deleteCommunityModeratorsInDb(context, singleUser);
                              // } else {}
                            }
                          },
                        ),
                        title: Container(
                          alignment: Alignment.topLeft,
                              child: Text(singleUser.name ?? "", style: CustomTypography.body2StyleWeightBlack),
                            ),
                      ),
                    ),
                  );
                });
          },
        );
      }),
    );
  }
}
