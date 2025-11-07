import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../utils/theme/app_typography.dart';

class GayaMessagePopUpModalSheet extends StatelessWidget {
  final String title;
  final String btnTitle;
  final VoidCallback? onDismiss;

  const GayaMessagePopUpModalSheet({Key? key, required this.title, this.onDismiss, this.btnTitle = "Close"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
        child: Column(
          children: [
            Text(title, style: GayaTypography.text.copyWith(color: AppColors.secondary, fontSize: 14.sp), textAlign: TextAlign.center),
            SizedBox(height: MySpaces.gap3.h),
            GayaButton(
              title: btnTitle == "Close" ? GayaStrings.close.tr : btnTitle,
              onPressed: () {
                if (onDismiss != null) {
                  onDismiss!();
                }
                Navigator.pop(context);
              },
              height: 40.h,
              textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
              borderColor: AppColors.primary,
              primaryColor: AppColors.primary,
            ),
          ],
        ),
      ),
    ));
  }
}
