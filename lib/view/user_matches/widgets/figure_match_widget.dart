import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';

class FiguresMatchWidget extends StatelessWidget {
  final String count;
  final Widget icon;
  final String title;
  const FiguresMatchWidget({Key? key,required this.count,required this.icon,required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   Column(
      children: [
        Row(

          children: [
            icon,
            Padding(
              padding: const EdgeInsets.only(bottom: 3, left: 3).r,
              child: Text(count,textAlign: TextAlign.center,style: GayaTypography.titleSemiBold.copyWith(color: AppColors.white),),
            )
          ],
        ),
        Text(title,textAlign: TextAlign.center,style: GayaTypography.text.copyWith(color: AppColors.white),),

      ],
    );
  }
}