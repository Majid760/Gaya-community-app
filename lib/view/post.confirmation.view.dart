import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../components/button.component.dart';
import '../utils/textstyles.dart';

class PostConfirmationView extends StatelessWidget {
  final VoidCallback onSuccessCallback;
  const PostConfirmationView({super.key, required this.onSuccessCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Icon(
            Icons.done,
            color: kprimaryColor,
            size: MediaQuery.sizeOf(context).height * 0.2,
          ),
            Center(
            child: Text(
              GayaStrings.thanks_posting.tr,
              style: CustomTypography.headingStyle24,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              GayaStrings.manager_review_post.tr,
              style: CustomTypography.secondaryFontStyleWeightHeightlow,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GayaButton(
                onPressed: () {
                  onSuccessCallback();
                  //  Get.offAllNamed(route.switchView);
                },
                height: 48,
                title: GayaStrings.continue_txt.tr,
                borderColor: kTransparentColor,
                primaryColor: kprimaryColor,
                textStyle: CustomTypography.body4StyleWhite),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
