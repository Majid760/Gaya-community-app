import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';

class StartMatchingWidget extends StatelessWidget {
  final String message;
  const StartMatchingWidget({Key? key,required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding:const EdgeInsets.symmetric(horizontal: 66,vertical: 28).r,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Text(message,textAlign: TextAlign.center,style: GayaTypography.titleSemiBold,),
    );
  }
}
