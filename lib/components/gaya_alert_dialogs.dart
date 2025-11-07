import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../utils/strings.dart';
import '../utils/theme/app_colors.dart';
import '../utils/theme/app_typography.dart';

class GayaAlertDialogs {
  /// Show alert pop up for not eligible DOB
  static Future showAlertPopNotEligibleDOB({required BuildContext ctx}) {
    return showDialog(
      context: ctx,
      builder: (BuildContext context) {
        if (DeviceCheck.isIOS) {
          return CupertinoAlertDialog(
            insetAnimationCurve: Curves.decelerate,
            content: const Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Text(Gaya_Strings.invalidAge),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  GayaStrings.ok_txt2.tr,
                  style: GayaTypography.caption2.copyWith(color: AppColors.primary, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
        return AlertDialog(
          content: const Text(Gaya_Strings.invalidAge),
          actions: [
            TextButton(
              child: Text(GayaStrings.ok_txt.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
