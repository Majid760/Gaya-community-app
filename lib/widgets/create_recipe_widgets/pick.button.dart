//button
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class PickImageButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const PickImageButtonWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(borderRadius_4)),
        alignment: Alignment.center,
        child: Row(
          children: [
            SvgIconWidget.imageOutline(color: AppColors.white, height: 20.h),
            // SvgPicture.asset(
            //   Assets.assets.icons.galleryIcon,
            //   color: kWhiteColor,
            // ),
            const SizedBox(width: distance_5),
            Text(GayaStrings.media_txt.tr, style: CustomTypography.body4StyleWhite)
          ],
        ),
      ),
    );
  }
}
