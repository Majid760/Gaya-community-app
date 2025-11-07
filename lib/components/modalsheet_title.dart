import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/gradient_text_widget.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:get/get.dart';

import '../utils/const.dart';

class ModalSheetTitle extends StatelessWidget {
  final String title;
  final Function onDone;
  final Function onCancel;
  final bool isDoneEnabled;
  final bool isCancelEnabled;
  final bool isDoneVisible;
  final TextStyle titleStyle;

  const ModalSheetTitle({
    Key? key,
    required this.title,
    required this.onDone,
    required this.onCancel,
    this.isDoneEnabled = true,
    this.isCancelEnabled = true,
    this.isDoneVisible = true,
    this.titleStyle = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isCancelEnabled)
            TextButton(
              onPressed: isCancelEnabled ? () => onCancel() : null,
              style: GayaButtonStyles.actionRowTextButtonStyle2.copyWith(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20).r),
              ),
              child: Text(GayaStrings.cancel_txt.tr, style: CustomTypography.body2EnableStyle1),
            ),
          Text(title, style: GayaTypography.titleMedium),
          if (isDoneVisible)
            TextButton(
                onPressed: isDoneEnabled ? () => onDone() : null,
                style: GayaButtonStyles.actionRowTextButtonStyle2.copyWith(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20).r),
                ),
                child: GradientTextWidget(
                  GayaStrings.done.tr,
                  style: CustomTypography.body2EnableStyle1.copyWith(color: kprimaryColor, fontWeight: FontWeight.bold),
                  gradient: AppColors.textGradient,
                )),
        ],
      ),
    );
  }
}
