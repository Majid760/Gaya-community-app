import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static showCustomSnackBar({required String? title, required String message, Duration? duration}) {
    if (message.trim().isEmpty) return;
    Get.closeAllSnackbars();
    Get.snackbar(
      title ?? "",
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(left: 10, right: 10),
      colorText: AppColors.black,
      backgroundColor: AppColors.white,
    );
  }

  static showCustomErrorSnackBar({required String title, required String message, Color? color, Duration? duration}) {
    if (message.trim().isEmpty) return;
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: Colors.white,
      backgroundColor: color ?? Colors.redAccent,
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    );
  }

  static showCustomToast(
      {String? title,
      required String message,
      Color? color,
      Duration? duration,
      Color? textColor,
      Color? messageColor,
      TextStyle? messageStyle,
      Widget? icon,
      EdgeInsets? padding}) {
    if (message.trim().isEmpty) return;
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      title: title,
      messageText: Text(
        message,
        style: messageStyle ?? TextStyle(color: messageColor ?? Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w400),
      ),
      icon: icon,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? kprimaryColor,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 15).r,
      onTap: (snack) {
        Get.closeAllSnackbars();
      },
      message: message,
    );
  }

  static showCustomErrorToast({String? title, required String message, Color? color, Duration? duration}) {
    if (message.trim().isEmpty) return;
    //close all snackbars if opened.
    Get.closeAllSnackbars();

    Get.rawSnackbar(
      title: title,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20).r,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? Colors.redAccent,
      icon: const Icon(Icons.warning, color: Colors.white),
      onTap: (snack) {
        Get.closeAllSnackbars();
      },
      //overlayBlur: 0.8,
      message: message,
    );
  }

  static showCustomToastWhite({String? title, required String message, Color? color, Duration? duration}) {
    if (message.trim().isEmpty) return;
    //close all snackbars if opened.
    Get.closeAllSnackbars();

    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? Colors.redAccent,
      onTap: (snack) {
        Get.closeAllSnackbars();
      },
      //overlayBlur: 0.8,
      message: message,
    );
  }
}
