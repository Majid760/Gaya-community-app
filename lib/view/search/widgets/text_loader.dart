import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme/app_colors.dart';

class TextLoader extends StatelessWidget {
  const TextLoader({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                         main center widget [Center]                        */
    /* -------------------------------------------------------------------------- */
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 12.0.h),
          Text(
            text,
          ),
        ],
      ),
    );
  }
}
