import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_data.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.coverImage,
  });

  final String? coverImage;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: coverImage ?? '',
      errorWidget: (context, url, error) => AppData.defaultGreySimpleImage,
      placeholder: (context, url) => AppData.defaultGreyLoadingImage,
      height: 150.0.h,
      width: double.infinity,
      fit: BoxFit.cover,
      maxHeightDiskCache: 550,
      maxWidthDiskCache: 550,
    );
  }
}
