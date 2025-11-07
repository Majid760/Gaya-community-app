import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_typography.dart';

import '../../utils/textstyles.dart';

class ApprovalRow extends StatelessWidget {
  final String icon;
  final String title;

  const ApprovalRow({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).r,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(icon, fit: BoxFit.scaleDown, height: 20.r , width: 20.r ),
          SizedBox(width: 5.w),
          Text(title, style: GayaTypography.caption3.copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5)),
          const Spacer(),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: kBlackColor), shape: BoxShape.circle),
            child: Icon(Icons.keyboard_arrow_right_outlined, size: 16.r),
          ),
        ],
      ),
    );
  }
}
