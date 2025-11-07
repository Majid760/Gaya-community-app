import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:get/get.dart';

import '../utils/textstyles.dart';

class CommunityCreatedSuccessFullyView extends StatelessWidget {
  CommunityCreatedSuccessFullyView({super.key, this.community});

  Community? community;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                Assets.assets.images.communityLogo,
                fit: BoxFit.scaleDown,
                height: 100,
              ),
              const SizedBox(
                height: distance_20,
              ),
              Text(
                GayaStrings.new_community_created.tr,
                style: CustomTypography.headingStyle24,
              ),
              const SizedBox(
                height: distance_10,
              ),
              Text(
                GayaStrings.thanks_people_join.tr,
                style: CustomTypography.secondaryFontStyleWeightHeight,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              GayaButton(
                  height: 50,
                  textStyle: CustomTypography.body2Style,
                  borderColor: kTransparentColor,
                  title: GayaStrings.continue_txt.tr,
                  onPressed: () {
                    if (community == null) {
                      Routes.switchView();
                    } else {
                      print('previous route is: ${Get.previousRoute}');
                      SchedulerBinding.instance
                          .addPostFrameCallback((_) => Methods.routeToGroup(community: community!, clearPreviousRoutes: true));
                    }
                  },
                  primaryColor: kprimaryColor),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              )
            ],
          ),
        ),
      ),
    );
  }
}
