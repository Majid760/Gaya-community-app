import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/const.dart';

class VerticalDivider extends StatelessWidget {
  const VerticalDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 10.h,
      margin: const EdgeInsets.symmetric(horizontal: 10).r,
      decoration: const BoxDecoration(color: kBaseGrey),
    );
  }
}
