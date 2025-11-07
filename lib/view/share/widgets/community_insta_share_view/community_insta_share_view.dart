import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/theme/app_spaces.dart';
import '../../models/community_insta_share.dart';
import '../copy_link_button.dart';
import '../share_button.dart';
import 'screenshot_content_section.dart';

class CommunityInstaShareView extends StatelessWidget {
  const CommunityInstaShareView({
    Key? key,
    required this.communityInstaShare,
  }) : super(key: key);

  final CommunityInstaShare communityInstaShare;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(20.0.w),
            child: ScreenshotContentSection(communityInstaShare: communityInstaShare),
          ),
        ),
        /* -------------------------------------------------------------------------- */
        /*                       COPY LINK BUTTON | SHARE BUTTON                      */
        /* -------------------------------------------------------------------------- */
        Positioned(
          bottom: 16.0.w,
          left: 0.0,
          right: 0.0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0.w),
              child: Row(
                children: [
                  /* ---------------------------- copy link button ---------------------------- */
                  CopyLinkButton(community: communityInstaShare.community),
                  SizedBox(width: MySpaces.gap3.w),
                  /* ------------------------------ share button ------------------------------ */
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
