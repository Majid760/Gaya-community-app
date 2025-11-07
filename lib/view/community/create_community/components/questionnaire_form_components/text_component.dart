import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../utils/const.dart';
import '../../../../../utils/language/translation.dart';
import '../../../../../utils/theme/app_colors.dart';
import '../../../../../utils/theme/app_typography.dart';

class QuestionnaireTextWidgets extends StatelessWidget {
  const QuestionnaireTextWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(GayaStrings.community_entry_form.tr,style: GayaTypography.titleMedium.copyWith(height: 1.12),),
        SizedBox(height: distance_8.h,),
        Text(GayaStrings.community_entry_form_desc.tr,textAlign: TextAlign.start,style: GayaTypography.subtitleRegular.copyWith(height: 1.5,color: AppColors.secondary)),
      ],
    );
  }
}
