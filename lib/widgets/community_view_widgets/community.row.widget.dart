import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../../utils/const.dart';
import '../../utils/language/translation.dart';
import '../../utils/textstyles.dart';
import '../../utils/theme/button_styles.dart';

class CommunityRow extends StatelessWidget {
  const CommunityRow({
    Key? key,
    required this.style,
    required this.typeOfCommunity,
    required this.onTap,
    this.trailingBtnText =  GayaStrings.see_all,
  }) : super(
          key: key,
        );

  final TextStyle style;
  final String typeOfCommunity;
  final String trailingBtnText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: distance_20, right: distance_20, bottom: 12).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(typeOfCommunity.tr, style: style),
          TextButton(
            style: GayaButtonStyles.actionRowTextButtonStyle2.copyWith(
              visualDensity: const VisualDensity(
                vertical: -4,
              ),
            ),
            onPressed: onTap,
            child: Text(
              trailingBtnText.tr,
              style: TextStyle(color: AppColors.primary, fontFamily: GayaFontTheme.primaryFont),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityRowSkeleton extends StatelessWidget {
  const CommunityRowSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 20,
            width: 100,
            color: kTransparentColor,
          ),
          Container(
            height: 20,
            width: 100,
            color: kTransparentColor,
          ),
        ],
      ),
    );
  }
}
