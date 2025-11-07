import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/home.view.dart';
import 'package:get/get.dart';

import '../../../components/button.component.dart';
import '../../../controller/crowns_controller.dart';
import '../../../utils/const.dart';
import '../../../utils/textstyles.dart';

class GiveCrownToPostWidget extends StatelessWidget {
  const GiveCrownToPostWidget({super.key});

  UserModel get userModel => UserModel.to;

  String getCrownText() => (userModel.userDailyCrowns == null)
      ? '0/0 ${GayaStrings.left_txt.tr}'
      : (userModel.userDailyCrowns == 0)
          ? '0'
          : '${userModel.userDailyCrowns}/3 ${GayaStrings.left_txt.tr}';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: Get.find<CrownsController>().checkUpdatedCrownsInDb(),
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(GayaStrings.crowns_txt.tr, style: CustomTypography.headingStyle24),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIconWidget.crownFilledd(color: AppColors.warning, height: 16.h, width: 16.h),
                  // SvgPicture.asset("Assets/images/filled_crown.svg", height: 12.5, width: 15),
                  const SizedBox(width: 10),
                  Text(getCrownText(), style: CustomTypography.body2StyleWeightBlack),
                ],
              ),
              const SizedBox(height: 12),
              (userModel.userDailyCrowns == null)
                  ? const SizedBox.shrink()
                  : (userModel.userDailyCrowns == 0)
                      ? const CrownTweenTimer(showSeconds: true)
                      : Text(
                          GayaStrings.hand_out_helped_you.tr,
                          style: CustomTypography.body2EnableStyle1,
                        ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18).r,
                child: GayaButton(
                    title: GayaStrings.continue_txt.tr,
                    onPressed: () async {
                      // if (userModel.userDailyCrowns == null || userModel.userDailyCrowns == 0) return;
                      // if (crownRoute == CrownRouteEnum.home) {
                      //   final PostControllerStream postController = Get.find();
                      //   postController.crownPost(post.postid, receiverUser: post.postedBy);
                      // } else if (crownRoute == CrownRouteEnum.group) {
                      //   final CommunityFeedController postController = Get.find();
                      //   postController.crownPost(post.postid, receiverUser: post.postedBy);
                      // } else if (crownRoute == CrownRouteEnum.savePost) {
                      //   if (post.crownsBy == null || post.crownsBy?.contains(FirebaseAuth.instance.currentUser!.uid) == false) {
                      //     context.read<CreatePostController>().crownPost(post.postid, receiverUser: post.postedBy);
                      //   }
                      // } else if (crownRoute == CrownRouteEnum.postWithComments) {
                      //   final PostWithCommentController postController = Get.find();
                      //   postController.crownPost(post.postid, receiverUser: post.postedBy);
                      // }

                      Navigator.pop(context);

                      // if (reportFormKey.currentState!.validate() && selectedTagColor != '') {
                      //   await controller.updateModeratorsTagData(
                      //     context,
                      //     selectedTagColor,
                      //     moderatorTag: textEditController.text,
                      //   );
                      //   textEditController.clear();
                      //   Get.back();
                      // }
                    },
                    borderColor: kTransparentColor,
                    height: 48,
                    primaryColor: kprimaryColor,
                    textStyle: const TextStyle(
                      color: kWhiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: GayaFontTheme.primaryFont,
                    ),
                    width: MediaQuery.sizeOf(context).width),
              )
            ],
          );
        });
  }
}
