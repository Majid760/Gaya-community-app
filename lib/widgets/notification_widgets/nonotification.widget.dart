import 'package:flutter/material.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../../gen/assets.gen.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';

class NoNotificationWidget extends StatelessWidget {
  const NoNotificationWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Image.asset(Assets.assets.images.notificationImage, height: 80, width: 96, color: AppColors.primary),
        ),
        const SizedBox(height: distance_15),
        Text(GayaStrings.no_notifications_yet.tr, style: CustomTypography.headingStyle),
        const SizedBox(height: distance_10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: distance_30),
          child: Text(
            GayaStrings.notification_show_up_here.tr,
            style: CustomTypography.body1Style,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
