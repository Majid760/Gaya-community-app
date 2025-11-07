import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/snackbar_utils.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../../../utils/language/translation.dart';

// auto import the utils folder
export 'package:gaya/utils/snackbar_utils.dart';

class GayaSnackBar extends StatelessWidget {
  final GayaSnackBarType type;
  final String text;

  const GayaSnackBar({Key? key, required this.type, required this.text}) : super(key: key);

  /// Shows the snack-bar
  static void show({required BuildContext context, required GayaSnackBarType type, required String text}) {
    final snack = SnackBar(

      backgroundColor: AppColors.transparrent,
      elevation: 0,
      content: GayaSnackBar(type: type, text: text),
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      behavior: SnackBarBehavior.fixed,
    );
    //close all  snack-bar if opened.

    //check if snackbar opened, if yes then close it
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  @override
  Widget build(BuildContext context) {
    final icon = SnackBarUtils.getIconByType(type: type);
    final padding = EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);
    return Container(
      padding: padding,
      margin: padding,
      decoration: BoxDecoration(
        // show snackbar with different color based on type
        color: SnackBarUtils.backgroundColor(type: type),
        borderRadius: BorderRadius.circular(4.r),
        // backdrop shadow for the snackbar
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 6), blurRadius: 16.r, spreadRadius: -2),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            // icon
            icon,
            // spacing
            SizedBox(width: 6.w),
          ],

          // main text of the snackbar
          Flexible(
            child: Text(
              text,
              style: GayaTypography.caption2Medium.copyWith(color: SnackBarUtils.textColor(type: type), height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

class DefaultSnackBar {
  /// upon hide or unhide community
  static void hideOrUnHideCommunity({required BuildContext context, bool isHidden = false}) {
    GayaSnackBar.show(
        context: context,
        type: GayaSnackBarType.communities,
        text: isHidden ? GayaStrings.community_has_been_unhide.tr : GayaStrings.community_has_been_hidden.tr);
  }

  /// pin or unpin post
  static void pinOrUnPinPost({required BuildContext context, bool isPinned = false}) {
    GayaSnackBar.show(
        context: context,
        type: GayaSnackBarType.pin,
        text: isPinned ? GayaStrings.pin_post_removed_successfully.tr : GayaStrings.pin_post_successfully.tr);
  }
}
