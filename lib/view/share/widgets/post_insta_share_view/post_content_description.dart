import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/methods.dart';
import '../../../../utils/theme/app_typography.dart';
import '../../models/post_insta_share.dart';

class PostContent extends StatelessWidget {
  const PostContent({
    super.key,
    required this.postInstaShare,
  });

  final PostInstaShare postInstaShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 16.0.w,
        left: 16.0.w,
        right: 16.0.w,
      ),
      child: Align(
        alignment: Methods.isRTL(postInstaShare.postDescription!) ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          postInstaShare.postDescription!,
          style: postInstaShare.postImage == null ? GayaTypography.h4 : GayaTypography.titleMedium,
          maxLines: postInstaShare.postImage == null ? 10 : 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
