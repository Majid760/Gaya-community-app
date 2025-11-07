import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/community_invites/components/friends_list_loading_widget.dart';
import 'package:gaya/view/community/community_invites/controllers/community_invites_controller.dart';
import 'package:get/get.dart';

class InvitatePermissionView extends StatelessWidget {
  final String communityId;
  InvitatePermissionView({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('previous route is: ${Get.previousRoute}');

    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
          iconTheme: const IconThemeData(color: kBlackColor),
          leading: const BackButton(),
          backgroundColor: kTransparentColor,
          elevation: 0),
      body: GetBuilder<CommunityInvitesController>(
          init: Get.find<CommunityInvitesController>(),
          builder: (inviteController) {
            return (inviteController.isContactsLoading)
                ? const FriendListLoadingWidget()
                : LetsInviteFriendsButtonWidget(communityInvitesController: inviteController, communityId: communityId);
          }),
    );
  }
}

class LetsInviteFriendsButtonWidget extends StatelessWidget {
  const LetsInviteFriendsButtonWidget({
    super.key,
    required this.communityInvitesController,
    required this.communityId,
  });

  final CommunityInvitesController communityInvitesController;
  final String communityId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.all(48.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kBaseGrey,
                width: 1,
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'Assets/icons/add.svg',
                height: 33,
                width: 33,
                color: kprimaryColor,
              ),
              const SizedBox(
                height: distance_8,
              ),
              Text(
                GayaStrings.lets_find_your_friends.tr,
                style: CustomTypography.bodyStyle,
              ),
              const SizedBox(
                height: distance_8,
              ),
              Text(
                GayaStrings.you_and_your_friend_connect.tr,
                style: CustomTypography.secondaryFontStyleWeightHeight,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: distance_8,
              ),
              GayaButton(
                  height: 36,
                  textStyle: CustomTypography.body4StyleWhite,
                  borderColor: kTransparentColor,
                  title: GayaStrings.lets_do.tr,
                  onPressed: () async {
                    bool isContactsFetched = await communityInvitesController.loadContacts(context);
                    Routes.openInviteFriends(
                      communityId: communityId,
                    );
                    // print('Is Conta: $isContactsFetched');
                    //
                    // if (isContactsFetched) {
                    //   Routes.openInviteFriends(
                    //     communityId: communityId,
                    //   );
                    // } else {
                    //   snackBar(context, 'Something went wrong please try again in a while.', kprimaryColor);
                    // }
                  },
                  primaryColor: kprimaryColor),
            ],
          ),
        ),
      ],
    );
  }
}
