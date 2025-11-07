import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

class InvitationSentView extends StatelessWidget {
  final String communityDescription = 'InvitationSentView';
  final String communityId;
  const InvitationSentView({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 29.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            SvgPicture.asset(
              'Assets/icons/add.svg',
              height: 100,
              width: 100,
              color: kprimaryColor,
            ),
            const SizedBox(
              height: distance_20,
            ),
            Text(
              GayaStrings.sent_invitation.tr,
              style: CustomTypography.headingStyle24,
            ),
            const SizedBox(
              height: distance_10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              child: Text(
                GayaStrings.friend_invited_name_community.tr,
                style: CustomTypography.secondaryFontStyleWeightHeight,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            GayaButton(
                height: 44,
                textStyle: CustomTypography.body2Style,
                borderColor: kTransparentColor,
                title: GayaStrings.continue_txt.tr,
                onPressed: () {
                  Navigator.pop(context);
                  // if(Get.previousRoute == '/GroupView'){
                  //   print('yes');
                  //   return;
                  //   Get.back();
                  // }else{
                  //   print('no');
                  //   return;
                  //   Methods.routeToGroup(community: CreateCommunityModel(communityId: communityId), clearPreviousRoutes: true);
                  // }
                },
                primaryColor: kprimaryColor),
          ],
        ),
      ),
    );
  }
}
