import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/theme/app_colors.dart';

class AnalyticsTile extends StatelessWidget {
  const AnalyticsTile({
    super.key,
    required this.child,
  });

  /* -------------------------------- VARIABLES ------------------------------- */
  final Widget child;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                      main container widget [Container]                     */
    /* -------------------------------------------------------------------------- */
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.0.w),
      decoration: BoxDecoration(
        color: MyColorHex().blackShade5,
        borderRadius: BorderRadius.circular(4.0.r),
      ),
      child: child,
    );
  }
}
