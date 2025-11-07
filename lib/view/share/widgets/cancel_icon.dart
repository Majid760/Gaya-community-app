import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/view/share/controllers/instagram_story_share_controller.dart';

import '../../../utils/theme/app_colors.dart';

class CancelIcon extends StatelessWidget {
  const CancelIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 48.0,
      right: 16.0.w,
      child: IconButton(
        onPressed: () {
          InstagramStoryShareController.instance.instaShare = null;
          Navigator.maybePop(context);
        },
        icon: Icon(
          Icons.cancel,
          size: 32.0.w,
          color: AppColors.divider,
        ),
      ),
    );
  }
}
