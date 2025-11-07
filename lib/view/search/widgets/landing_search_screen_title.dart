import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_typography.dart';

class LandingSearchScreenTitle extends StatelessWidget {
  const LandingSearchScreenTitle({
    super.key,
    required this.title,
    this.hasSeeAllButton = false,
    this.hasSeeAllButtonOnTap,
  });

  final String title;
  final bool hasSeeAllButton;
  final VoidCallback? hasSeeAllButtonOnTap;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                        main padding widget [Padding]                       */
    /* -------------------------------------------------------------------------- */
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* ------------------------------- title text ------------------------------- */
          Text(
            title,
            style: GayaTypography.h4,
          ),
          if (hasSeeAllButton)
            /* ----------------------------- see all button ----------------------------- */
            TextButton(
              onPressed: hasSeeAllButtonOnTap,
              child: Text(
                GayaStrings.see_all.tr,
                style: CustomTypography.body2StyleWeightkPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
