import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/assets_icons.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';

/// Leading trailing subtitle button
class LeadingTrailingSubtitleButton extends StatelessWidget {
  /// Constructor for leading trailing subtitle button
  const LeadingTrailingSubtitleButton({
    Key? key,
    required this.leadingIcon,
    required this.subTitle,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  /* -------------------------------------------------------------------------- */
  /*                               STATE VARIABLES                              */
  /* -------------------------------------------------------------------------- */
  /// Leading icon of the button
  final String leadingIcon;

  /// Subtitle of the button
  final String subTitle;

  /// Title of the button
  final String title;

  /// On tap function of the button
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                               Main Container                               */
    /* -------------------------------------------------------------------------- */
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0.r),
        color: AppColors.foundationPurple,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: AppColors.foundationPurple.withOpacity(0.2),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /* ---------------------------- Leading icon svg ---------------------------- */
                GayaSvgAsset(
                  leadingIcon,
                  height: 20.0,
                  width: 20.0,
                  color: AppColors.white,
                ),
                SizedBox(width: 8.0.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* ------------------------------- Title text ------------------------------- */
                      Text(
                        title,
                        style: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
                      ),
                      SizedBox(height: 8.0.h),
                      /* ----------------------------- Sub-title text ----------------------------- */
                      Text(
                        subTitle,
                        style: GayaTypography.caption.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0.w),
                /* -------------------------- Right arrow svg icon -------------------------- */
                GayaSvgAsset(
                  IconsAssetsPathUtils.rightArrow,
                  height: 20.0,
                  width: 20.0,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
