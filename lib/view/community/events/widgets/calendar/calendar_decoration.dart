import 'package:flutter/material.dart';
import 'package:gaya/utils/theme/app_colors.dart';

import '../../../../../utils/theme/app_typography.dart';

class CalendarDecoration {
  static final selectedDecoration = BoxDecoration(color: AppColors.primary, shape: BoxShape.circle);

  static final holidayDecoration = BoxDecoration(
    color: AppColors.primary5,
    shape: BoxShape.circle,
  );
  static final todayDecoration = BoxDecoration(
    color: AppColors.primary5,
    shape: BoxShape.circle,
  );
  static const defaultDecoration = BoxDecoration(
    color: AppColors.transparrent,
    shape: BoxShape.circle,
  );

  static final holidayTextStyle = GayaTypography.h4.copyWith(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700);
  static final todayTextStyle = GayaTypography.h4.copyWith(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700);
  static final selectedTextStyle = GayaTypography.h4.copyWith(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700);
  static final defaultTextStyle = GayaTypography.h4.copyWith(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700);
}
