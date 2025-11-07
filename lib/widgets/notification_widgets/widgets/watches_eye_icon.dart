import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../components/profile_image_widget.dart';
import '../../../utils/asset_images.dart';

class WatchesEyeIcon extends StatelessWidget {
  const WatchesEyeIcon({
    Key? key,
    this.profileImg,
  }) : super(key: key);

  final String? profileImg;

  @override
  Widget build(BuildContext context) {
    return profileImg != null
        ? SizedBox(
            width: 55.0,
            height: 24.0.h,
            child: Center(
              child: PostImageWidget(
                url: profileImg,
                height: 24.0.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        : SizedBox(
            width: 55.0,
            child: Center(child: SvgIcons.watches),
          );
  }
}
