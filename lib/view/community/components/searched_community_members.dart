import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/components/moderators_skeleton_widget.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:get/get.dart';

class SearchedCommunityMembers extends StatelessWidget {
  final String communityId;

  const SearchedCommunityMembers({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: GetBuilder<EditCommunityController>(
          autoRemove: false,
          tag: communityId,
          init: EditCommunityController.to(tag: communityId),
          builder: (communityEditCtrl) {
            // Consumer<CommunityEditingController>(builder: (context, communityEditCtrl, child) {
            return (communityEditCtrl.isLoading)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: ListView(physics: const NeverScrollableScrollPhysics(), children: const [
                        ModeratorsSkeletonWidget(),
                        ModeratorsSkeletonWidget(),
                        ModeratorsSkeletonWidget(),
                        ModeratorsSkeletonWidget(),
                      ]),
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      );
                    },
                    itemCount: communityEditCtrl.searchedUsers.length,
                    itemBuilder: (context, index) {
                      UserModel singleUser = communityEditCtrl.searchedUsers[index];
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
                              onChanged: (newvalue) async {
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
                              child: Text(communityEditCtrl.searchedUsers[index].name ?? GayaStrings.name_not_found.tr,
                                  style: CustomTypography.body2StyleWeightBlack),
                            ),
                          ),
                        ),
                      );
                    },
                  );
          }),
    );
  }
}
