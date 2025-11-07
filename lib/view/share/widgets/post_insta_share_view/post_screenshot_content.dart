import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../utils/asset_images.dart';
import '../../controllers/instagram_story_share_controller.dart';
import '../../models/post_insta_share.dart';
import 'post_content_container.dart';

class PostScreenshotContent extends StatelessWidget {
  const PostScreenshotContent({
    super.key,
    required this.postInstaShare,
  });

  final PostInstaShare postInstaShare;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstagramStoryShareController>(
      builder: (instagramStoryShareController) {
        return Screenshot(
          controller: instagramStoryShareController.screenshotController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* -------------------------------------------------------------------------- */
              /*                           POST CONTENT CONTAINER                           */
              /* -------------------------------------------------------------------------- */
              PostContentContainer(postInstaShare: postInstaShare),
              SizedBox(height: 30.0.w),
              /* -------------------------- paste your link image ------------------------- */
              Image.asset(
                'Assets/images/paste_your_link.png',
                width: 1.0.sw * 0.4,
              ),
              SizedBox(height: 16.0.w),
              /* ---------------------------------- arrow --------------------------------- */
              SvgIcons.arrows,
              SizedBox(height: 16.0.w),
              /* -------------------------------- gaya logo ------------------------------- */
              Image.asset(
                'Assets/images/gaya_logo_with_text.png',
                height: 26.0.w,
              ),
            ],
          ),
        );
      },
    );
  }
}
