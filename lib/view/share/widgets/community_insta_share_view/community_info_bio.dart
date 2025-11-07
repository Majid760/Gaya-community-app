import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/theme/app_typography.dart';

class CommunityInfoBio extends StatelessWidget {
  const CommunityInfoBio({
    super.key,
    required this.communityInfo,
  });

  final String? communityInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
      child: Text(
        communityInfo ?? '',
        maxLines: 5,
        textDirection: TextDirection.ltr,
        style: GayaTypography.caption2Medium.copyWith(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
