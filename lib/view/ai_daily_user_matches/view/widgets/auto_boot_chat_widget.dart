import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/ai_assets_path.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/strings.dart';

class AutoBootChatWidget extends StatelessWidget {
  const AutoBootChatWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(8).r,
          padding: const EdgeInsets.all(7).r,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientColor1,
                AppColors.gradientColor5,
              ],
            ),
          ),
          child: Image.asset(
            AiAssetsPath.boot,
            width: 30.w,
            height: 34.3.h,
          ),
        ),
        // messageContainer(msgTxt: AIMatchesStrings.messageText1),
        // messageContainer(msgTxt: AIMatchesStrings.messageText2),
      ],
    );
  }
}

Widget messageContainer({required String msgTxt}) {
  return Container(
    margin: const EdgeInsets.all(8).r,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      color: const Color(0xffEFE6FD),
    ),
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4).r,
    child: Text(msgTxt, textAlign: TextAlign.start, style: GayaTypography.subtitleRegular),
  );
}
