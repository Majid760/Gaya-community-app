import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/theme/app_spaces.dart';
import '../../models/post_insta_share.dart';
import '../copy_link_button.dart';
import 'post_screenshot_content.dart';
import '../share_button.dart';

class PostInstaShareView extends StatelessWidget {
  const PostInstaShareView({
    Key? key,
    required this.postInstaShare,
  }) : super(key: key);

  final PostInstaShare postInstaShare;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /* -------------------------------------------------------------------------- */
        /*                             SCREENSHOT SECTION                             */
        /* -------------------------------------------------------------------------- */
        Center(
          child: Padding(
            padding: EdgeInsets.all(20.0.w),
            child: PostScreenshotContent(postInstaShare: postInstaShare),
          ),
        ),
        Positioned(
          bottom: 16.0.w,
          left: 0.0,
          right: 0.0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0.w),
              child: Row(
                children: [
                  CopyLinkButton(post: postInstaShare.post),
                  SizedBox(width: MySpaces.gap3.w),
                  const ShareButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
