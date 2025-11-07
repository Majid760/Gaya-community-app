import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/const.dart';

class TimelineTabBarTitle extends StatelessWidget {
  const TimelineTabBarTitle({
    super.key,
    required this.selected,
    required this.text,
  });

  /* -------------------------------------------------------------------------- */
  /*                               STATE VARIABLES                              */
  /* -------------------------------------------------------------------------- */
  final bool selected;
  final String text;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                           main text widget [Text]                          */
    /* -------------------------------------------------------------------------- */
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.0.sp,
        color: selected ? kWhiteColor : kSecondaryColor,
      ),
    );
  }
}
