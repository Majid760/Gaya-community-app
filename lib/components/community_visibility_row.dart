import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:get/get.dart';

import '../utils/theme/app_typography.dart';

class CommunityTypeWidget extends StatelessWidget {
  final Community community;

  /// default 10
  final double? spaceBetween;

  final double? iconSize;

  /// default [CustomTypography.community]
  final TextStyle? textStyle;

  final Widget? trailingIcon;

  final String? communityType;

  const CommunityTypeWidget(
      {Key? key, required this.community, this.spaceBetween = 10, this.textStyle, this.iconSize, this.trailingIcon, this.communityType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GayaSvgAsset(
          (communityType ?? community.communityType) == "Private"
              ? IconsAssetsPathUtils.lockOutline
              : (communityType ?? community.communityType) == "Secret"
                  ? IconsAssetsPathUtils.eyeOffOutline
                  : IconsAssetsPathUtils.lockUnlockedOutline,
          height: iconSize,
          width: iconSize,
        ),
        SizedBox(width: spaceBetween ?? 8),
        Text(
          (communityType ?? community.communityType)?.isBlank == true
              ? GayaStrings.public_txt.tr
              : ((communityType ?? community.communityType) ?? GayaStrings.public_txt).toLowerCase().tr,
          style: textStyle ?? CustomTypography.community.copyWith(height: 2),
        ),
        if (trailingIcon != null) ...[SizedBox(width: MySpaces.gap2.w), trailingIcon!]
      ],
    );
  }
}
