import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/utils/theme/app_typography.dart';

import '../../../../utils/const.dart';

class ListTileRow extends StatelessWidget {
  final Color externalColor, internalColor, borderColorcircle;
  final String title, subtitle;
  final String icon;
  final VoidCallback onTap;
  final double? iconSize;

  const ListTileRow({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.externalColor,
    required this.internalColor,
    required this.borderColorcircle,
    required this.onTap,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(externalColor);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).r,
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(icon, height: iconSize, width: iconSize),
                SizedBox(width: distance_5.h),
                Text(title, style: GayaTypography.titleMedium),
              ],
            ),
            SizedBox(height: distance_5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(subtitle, style: GayaTypography.text.copyWith(color: kSecondaryColor, fontSize: 14.sp, height: 1.57))),
                SizedBox(width: 73.w),
                GestureDetector(
                  onTap: onTap,
                  child: CircleAvatar(
                    radius: 13.r,
                    backgroundColor: borderColorcircle,
                    child: CircleAvatar(
                      radius: 12.r,
                      backgroundColor: externalColor,
                      child: CircleAvatar(radius: 5.r, backgroundColor: internalColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
