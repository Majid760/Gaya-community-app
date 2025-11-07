import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/const.dart';
import '../../../../utils/gaya_text_widget.dart';
import '../../../../utils/methods.dart';
import '../../../../utils/theme/app_typography.dart';

class CommunityContentBio extends StatelessWidget {
  const CommunityContentBio({
    super.key,
    required this.communityBioContent,
    this.onReadMoreButtonTap,
  });

  final String communityBioContent;
  final VoidCallback? onReadMoreButtonTap;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                        main padding widget [Padding]                        */
    /* -------------------------------------------------------------------------- */
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0.w,
        right: 16.0.w,
        bottom: 16.0.w,
      ),
      child: Align(
        alignment: Methods.isRTL(communityBioContent) ? Alignment.centerRight : Alignment.centerLeft,
        /* -------------------------- community content/bio ------------------------- */
        child: GayaTextWidget(
          communityBioContent,
          style: GayaTypography.caption,
          colorClickableText: kprimaryColor,
          shouldIgnoreHashTag: false,
          trimLines: 2,
          trimLength: 60,
          onReadMoreButtonTap: onReadMoreButtonTap,
        ),
      ),
    );
  }
}
