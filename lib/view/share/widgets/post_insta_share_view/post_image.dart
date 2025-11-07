import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_data.dart';

class PostImage extends StatelessWidget {
  const PostImage({
    super.key,
    required this.postImage,
  });

  final String? postImage;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: postImage!,
      height: 180.0.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => AppData.defaultGreySimpleImage,
      placeholder: (context, url) => AppData.defaultGreyLoadingImage,
      maxHeightDiskCache: 550,
      maxWidthDiskCache: 550,
    );
  }
}
