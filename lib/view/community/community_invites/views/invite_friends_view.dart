import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/community_invites/components/invite_friend_avatar_widget.dart';
import 'package:gaya/view/community/community_invites/controllers/community_invites_controller.dart';
import 'package:get/get.dart';

class InviteFriendsView extends StatelessWidget {
  final String communityDescription = 'InviteFriendsView';
  final String communityId;

  const InviteFriendsView({Key? key, required this.communityId}) : super(key: key);

  onTap() {
    CommunityInvitesController.to.resetController();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.viewInsetsOf(context).top),
      child: Scaffold(
          backgroundColor: kWhiteColor,
          body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                    pinned: true,
                    floating: true,
                    snap: true,
                    iconTheme: const IconThemeData(color: kBlackColor),
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    leading: GayaBackButton(onPop: onTap),
                    backgroundColor: kWhiteColor,
                    centerTitle: true,
                    title: Text(GayaStrings.invite_friends.tr, style: CustomTypography.bodyStyle),
                  ),
                ];
              },
              body: SizedBox(
                height: MediaQuery.sizeOf(context).height - (24 + kToolbarHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20).r,
                      child: GetBuilder<CommunityInvitesController>(
                          id: 'checkboxid',
                          init: Get.find<CommunityInvitesController>(),
                          builder: (inviteController) {
                            return GayaSearchTextField(
                                controller: inviteController.searchC, onChanged: (text) => inviteController.searchFriend(text));
                          }),
                    ),
                    const Divider(
                      color: kBaseGrey,
                      thickness: 0.5,
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GetBuilder<CommunityInvitesController>(
                          id: 'checkboxid',
                          init: Get.find<CommunityInvitesController>(),
                          builder: (inviteController) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  GayaStrings.invite_friends.tr,
                                  style: CustomTypography.bodyStyle,
                                ),
                                Text(
                                  (inviteController.selectedInvitationList.isEmpty)
                                      ? "0/10"
                                      : "${inviteController.selectedInvitationList.length}/10",
                                  style: CustomTypography.bodyStyle,
                                ),
                              ],
                            );
                          }),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          InviteFriendsGridview(communityId: communityId),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 21, right: 21, bottom: 16).r,
                              child: GetBuilder<CommunityInvitesController>(
                                  id: 'checkboxid',
                                  init: Get.find<CommunityInvitesController>(),
                                  builder: (inviteController) {
                                    return GayaButton(
                                      height: 48.r,
                                      borderColor: kTransparentColor,
                                      primaryColor: //kprimaryColor,
                                          inviteController.selectedInvitationList.isEmpty || inviteController.isLoading
                                              ? kBaseGrey
                                              : kprimaryColor,
                                      textStyle: //CustomTypography.body4StyleWhite,
                                          inviteController.selectedInvitationList.isEmpty || inviteController.isLoading
                                              ? CustomTypography.body2DisableStyle
                                              : CustomTypography.body2EnableStyle,
                                      title: GayaStrings.invite_txt.tr,
                                      onPressed: () {
                                        // Routes.openAddPhoneNo(
                                        //   communityId: communityId,
                                        // );
                                        if (inviteController.selectedInvitationList.isNotEmpty && inviteController.isLoading == false) {
                                          FocusScope.of(context).unfocus();

                                          inviteController.sendBulkInvitationToPhone(context: context);

                                          // inviteController.sendInvitationToPhone(context: context);
                                        }
                                      },
                                    );
                                  }),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
}

class InviteFriendsGridview extends StatelessWidget {
  const InviteFriendsGridview({super.key, required this.communityId});

  final String communityId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: CommunityInvitesController.to.contacts.isEmpty ? 16 : 0, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GetBuilder<CommunityInvitesController>(
              init: Get.find<CommunityInvitesController>(),
              builder: (inviteController) {
                return inviteController.contacts.isEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              CommunityInvitesController.to.resetIsInvitationSent();
                              Routes.openAddPhoneNo(communityId: communityId);
                            },
                            highlightColor: kTransparentColor,
                            splashColor: kTransparentColor,
                            child: Column(
                              children: [
                                Container(
                                  height: 88,
                                  width: 88,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: kBaseGrey, width: 1), shape: BoxShape.circle, color: kprimaryColorLight),
                                  child: Icon(Icons.add, size: 40.r, color: kprimaryColor),
                                ),
                                const SizedBox(height: 8.0),
                                Text(GayaStrings.phone_no_txt.tr, textAlign: TextAlign.center, style: CustomTypography.dark12),
                              ],
                            ),
                          )
                        ],
                      )
                    : GridView.builder(
                        itemCount: (inviteController.searchC.text.isNotEmpty)
                            ? inviteController.searchedContacts.length
                            : inviteController.contacts.length + 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: 138, crossAxisCount: 3, crossAxisSpacing: 46),
                        itemBuilder: (context, index) {
                          return (inviteController.searchC.text.isNotEmpty)
                              ? InkWell(
                                  onTap: () => inviteController.addContactToList(context, inviteController.searchedContacts[index]),
                                  highlightColor: kTransparentColor,
                                  splashColor: kTransparentColor,
                                  child: Column(
                                    children: [
                                      InviteFriendAvatarWidget(
                                        contactInfo: inviteController.searchedContacts[index],
                                        isActive:
                                            inviteController.isContactInList(inviteController.searchedContacts[index].phones.first.number),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        inviteController.searchedContacts[index].displayName,
                                        textAlign: TextAlign.center,
                                        style: CustomTypography.dark12,
                                      ),
                                    ],
                                  ),
                                )
                              : (index == 0)
                                  ? InkWell(
                                      onTap: () => Routes.openAddPhoneNo(communityId: communityId),
                                      highlightColor: kTransparentColor,
                                      splashColor: kTransparentColor,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 88,
                                            width: 88,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: kBaseGrey, width: 1),
                                                shape: BoxShape.circle,
                                                color: kprimaryColorLight),
                                            child: Icon(Icons.add, size: 40.r, color: kprimaryColor),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(GayaStrings.phone_number.tr, textAlign: TextAlign.center, style: CustomTypography.dark12),
                                        ],
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        inviteController.addContactToList(context, inviteController.contacts[index - 1]);
                                      },
                                      highlightColor: kTransparentColor,
                                      splashColor: kTransparentColor,
                                      child: Column(
                                        children: [
                                          InviteFriendAvatarWidget(
                                            contactInfo: inviteController.contacts[index - 1], //'Afaq Khan',
                                            isActive:
                                                inviteController.isContactInList(inviteController.contacts[index - 1].phones.first.number),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(inviteController.contacts[index - 1].displayName ?? "",
                                              textAlign: TextAlign.center, style: CustomTypography.dark12),
                                        ],
                                      ),
                                    );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
