import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

void snackBar(BuildContext context, String? mainText, Color backgroundColor,
    {double borderRadius = 0.0, GayaSnackBarType snackType = GayaSnackBarType.other}) {
  try {
    GayaSnackBarType type = snackType;
    // if background is red then send type as error.
    if (backgroundColor == kRedColor) {
      type = GayaSnackBarType.error;
    }

    /// show only if context is mounted.
    if (context.mounted) {
      GayaSnackBar.show(context: context, type: type, text: mainText ?? GayaStrings.something_went_wrong.tr);
    } else {
      /// get context from Get.context if context is not mounted.
      context = Get.context!;
      GayaSnackBar.show(context: context, type: type, text: mainText ?? GayaStrings.something_went_wrong.tr);
    }

    // Get.showSnackbar(GetSnackBar(
    //   message: mainText ?? 'Something went wrong',
    //   borderRadius: borderRadius,
    //   backgroundColor: backgroundColor,
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 4),
    // ));
  } catch (_) {
    log(_.toString());
  }

  // try {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     content: Text(mainText),
  //     backgroundColor: backgroundColor,
  //   ));
  // } on Exception catch (e) {
  //   log(e.toString());
  // }
}
