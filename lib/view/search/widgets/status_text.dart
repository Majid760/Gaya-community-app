import 'package:flutter/material.dart';

import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';

class StatusText extends StatelessWidget {
  const StatusText({
    super.key,
    required this.statusText,
  });

  final String statusText;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                         main center widget [Center]                        */
    /* -------------------------------------------------------------------------- */
    return Center(
      child: Text(
        statusText,
        style: GayaTypography.title.copyWith(color: AppColors.secondary),
      ),
    );
  }
}
