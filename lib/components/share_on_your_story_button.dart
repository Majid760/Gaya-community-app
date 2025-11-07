import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/asset_images.dart';
import '../utils/language/translation.dart';
import '../utils/textstyles.dart';
import '../utils/theme/app_colors.dart';
import '../view/share/controllers/instagram_story_share_controller.dart';
import '../view/share/views/share_to_insta_screen.dart';

class ShareOnYourStoryButton extends StatelessWidget {
  const ShareOnYourStoryButton({
    super.key,
    required this.isCommunity,
  });

  final bool isCommunity;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                        main inkwell widget [InkWell]                       */
    /* -------------------------------------------------------------------------- */
    return InkWell(
      onTap: () {
        final instagramStoryShareController = InstagramStoryShareController.instance;
        Navigator.pop(context);
        Get.to(
          () => ShareToInstaView(
            isCommunityShare: isCommunity,
            instaShare: instagramStoryShareController.instaShare!,
          ),
          // transition: Transition.cupertino,
          // fullscreenDialog: true
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0.r),
          gradient: AppColors.primaryGradient,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* -------------------- white instagram log [Image.asset] ------------------- */
            Image.asset(
              ImageAssetsUtils.whiteInstagramLogo,
              width: 16.0.w,
              height: 16.0.w,
            ),
            SizedBox(width: 6.0.w),
            /* --------------------- share on your story text [Text] -------------------- */
            Text(
              GayaStrings.share_on_your_story.tr,
              style: CustomTypography.body2Style,
            ),
          ],
        ),
      ),
    );
  }
}
