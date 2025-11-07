import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/profile_image_widget.dart';
import '../../../../utils/app_data.dart';
import '../../../../utils/const.dart';

class CommunityImage extends StatelessWidget {
  const CommunityImage({
    super.key,
    required this.communityImage,
  });

  final String? communityImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.r,
      width: 56.w,
      margin: const EdgeInsets.only(right: distance_8).r,
      child: CircleAvatar(
        radius: 56.r,
        backgroundColor: kBaseGrey,
        child: ProfileImageWidget(
          url: communityImage,
          onError: AppData.defaultUserProfileWidget(),
        ),
      ),
    );
  }
}
