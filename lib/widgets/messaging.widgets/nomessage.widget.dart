import 'package:flutter/material.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../../gen/assets.gen.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';

class NoMessageWidget extends StatelessWidget {
  const NoMessageWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            Assets.assets.images.messageImage,
            height: 120,
            width: 120,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(
          height: distance_15,
        ),
        Text(GayaStrings.no_message.tr, style: CustomTypography.headingStyle),
        const SizedBox(
          height: distance_10,
        ),
        Text(
          GayaStrings.no_active_chat.tr,
          style: CustomTypography.body1Style,
        ),
      ],
    );
  }
}
