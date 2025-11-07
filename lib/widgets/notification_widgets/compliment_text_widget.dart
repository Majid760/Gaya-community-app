import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ComplimentTextWidget extends StatelessWidget {
  final String text;

  const ComplimentTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = [];

    RegExp regex = RegExp(r'\*{2}(.*?)\*{2}');
    Iterable<Match> matches = regex.allMatches(text);

    int currentIndex = 0;
    for (Match match in matches) {
      String normalText = text.substring(currentIndex, match.start);
      String boldText = match.group(1) ?? '';

      textSpans.add(
        TextSpan(
          text: "$normalText ",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

      textSpans.add(
        TextSpan(
          text: boldText.tr,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 14.sp, // Adjust font size as needed
          ),
        ),
      );

      currentIndex = match.end;
    }

    // Add any remaining normal text after the last match
    if (currentIndex < text.length) {
      String remainingText = text.substring(currentIndex);

      textSpans.add(
        TextSpan(
          text: remainingText,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}
