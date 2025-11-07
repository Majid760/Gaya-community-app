import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/profile_image_widget.dart';

class CommunityDp extends StatelessWidget {
  const CommunityDp({
    super.key,
    required this.communityDp,
  });

  final String communityDp;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 56.0.r + 15,
      left: 16.0.w,
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: Colors.transparent,
        child: ProfileImageWidget(
          url: communityDp,
        ),
      ),
    );
  }
}
