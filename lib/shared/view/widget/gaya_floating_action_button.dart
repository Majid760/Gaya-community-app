import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../../utils/theme/app_colors.dart';

class GayaFloatingActionButton extends StatelessWidget {
  const GayaFloatingActionButton({Key? key, required this.onPressed, required this.svgIconPath}) : super(key: key);
  final VoidCallback? onPressed;
  final String svgIconPath;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
          HapticFeedback.mediumImpact();
        }
      },
      backgroundColor: kTransparentColor,
      elevation: 0,
      child: Container(
          padding: const EdgeInsets.all(12).r,
          height: 48.r,
          width: 48.r,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(borderRadius_4).r,
          ),
          child:  SvgPicture.asset(
          svgIconPath,
          color: kWhiteColor,
        )
      ),
    );
  }
}

class GayaNavBArFloatingActionButton extends StatelessWidget {
  const GayaNavBArFloatingActionButton({Key? key, required this.onPressed, required this.svgIconPath}) : super(key: key);
  final VoidCallback? onPressed;
  final String svgIconPath;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
       //   HapticFeedback.mediumImpact();
        }
      },
      backgroundColor: kTransparentColor,
      tooltip: GayaStrings.create_post.tr,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8).r,
        child: Container(
      alignment: Alignment.center,
            height: 36.r,
            width: 36.r,
            decoration: BoxDecoration(
              color: AppColors.gradientColor1,
              borderRadius: BorderRadius.circular(borderRadius_8).r,
            ),
            child:  SvgPicture.asset(width: 18.r,height: 18.r,
            svgIconPath,
            color: AppColors.white,
          )
        ),
      ),
    );
  }
}
