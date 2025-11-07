import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/profile_image_widget.dart';

class PostPostedUserImage extends StatelessWidget {
  const PostPostedUserImage({
    super.key,
    required this.postPostedUserImage,
  });

  final String? postPostedUserImage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: CircleAvatar(
        radius: 20.r,
        backgroundColor: Colors.transparent,
        child: postPostedUserImage!.startsWith('Asset')
            ? Image.asset(
                postPostedUserImage!,
              )
            : ProfileImageWidget(
                url: postPostedUserImage,
              ),
      ),
    );
  }
}
