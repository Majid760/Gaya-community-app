import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/theme/app_typography.dart';

import '../../../../utils/const.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../../utils/theme/app_spaces.dart';

class InterestWidget extends StatelessWidget {
  const InterestWidget({Key? key, required this.imageUrl, this.title, this.onTap, this.isSelected = false}) : super(key: key);
  final String imageUrl;
  final String? title;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = 103.r;
    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(15).r,
      border: Border.all(color: AppColors.white, width: 4.r),
    );
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Tooltip(
          message: title,
          enableFeedback: true,
          child: Container(
              // margin:isGridView?null: const EdgeInsets.only(left: distance_20).r,
              height: size,
              width: size,
              decoration: isSelected ? decoration : null,
              child: CachedNetworkImage(
                  errorWidget: (_, __, ___) => AppData.defaultInterestImage,
                  imageUrl: imageUrl,
                  height: size,
                  width: size,
                  fit: BoxFit.fill)),
        ),
        Container(
          padding: const EdgeInsets.only(left: distance_10, right: distance_10).r,
          alignment: Alignment.bottomLeft,
          height: size,
          width: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(title ?? '',
                    style: GayaTypography.body2.copyWith(fontWeight: FontWeight.w700, fontSize: 17.sp, color: AppColors.white, height: 1.2),
                    textAlign: TextAlign.left,
                    maxLines: 2),
              ),
              SizedBox(height: MySpaces.gap3.h)
            ],
          ),
        ),
      ]),
    );
  }
}
