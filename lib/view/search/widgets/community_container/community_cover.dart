import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_data.dart';

class CommunityCover extends StatelessWidget {
  const CommunityCover({
    super.key,
    required this.communityCover,
  });

  final String communityCover;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: communityCover,
      errorWidget: (context, url, error) => AppData.defaultGreySimpleImage,
      placeholder: (context, url) => AppData.defaultGreyLoadingImage,
      height: 100.0.h,
      width: double.infinity,
      fit: BoxFit.cover,
      maxHeightDiskCache: 300,
      maxWidthDiskCache: 550,
    );
  }
}
