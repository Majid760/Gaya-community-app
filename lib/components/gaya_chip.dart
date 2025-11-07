import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_typography.dart';
/// A widget that displays a chip with a text and a color
/// mainly used for tags in post header.  ie: Manager, Moderator etc
class GayaChipWidget extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final TextStyle? textStyle;

  const GayaChipWidget({Key? key, required this.text, required this.color, this.textStyle, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8).r + const EdgeInsets.symmetric(vertical: 4).r,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: color.withOpacity(.1)),
      child: Text(
        text,
        style: textStyle ??
            GayaTypography.caption2.copyWith(
              color: textColor ?? color,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
