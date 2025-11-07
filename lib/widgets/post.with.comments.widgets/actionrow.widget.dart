import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../utils/theme/app_colors.dart';
import '../../utils/theme/app_typography.dart';
import '../../utils/theme/button_styles.dart';

class ActionRow extends StatelessWidget {
  final VoidCallback? likeOnTap, flowerOnTap;
  final VoidCallback? replyOnTap;
  final VoidCallback? postReplyTap;
  final Widget likeWidget, flowerWidget;
  final Widget? postReplyWidget;
  final double? childPadding;
  final String? textContent;

  const ActionRow(
      {Key? key,
      required this.likeOnTap,
      required this.flowerOnTap,
      this.replyOnTap,
      this.postReplyTap,
      required this.likeWidget,
      required this.flowerWidget,
      this.childPadding,
      this.postReplyWidget,
      this.textContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final btnStyle = GayaButtonStyles.actionRowTextButtonStyle;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(width: childPadding ?? 8.w),
      likeOnTap != null
          ? TextButton(style: btnStyle, onPressed: likeOnTap, child: likeWidget)
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: likeWidget,
            ),
      SizedBox(width: childPadding ?? 6.w),
      SizedBox(width: childPadding ?? 6.w),
      TextButton(style: btnStyle, onPressed: flowerOnTap, child: flowerWidget),
      SizedBox(width: childPadding ?? 6.w),
      SizedBox(width: childPadding ?? 6.w),
      if (replyOnTap != null)
        TextButton(
            style: GayaButtonStyles.actionRowTextButtonStyleForCommentsDialog,
            onPressed: replyOnTap,
            child: Text(GayaStrings.reply_txt.tr, style: GayaTypography.caption.copyWith(color: AppColors.secondary))),
      SizedBox(width: childPadding ?? 6.w),
      SizedBox(width: childPadding ?? 6.w),
      if (textContent != null && textContent!.isNotEmpty)
        TextButton(
            style: GayaButtonStyles.actionRowTextButtonStyleForCommentsDialog,
            onPressed: postReplyTap,
            child: postReplyWidget ?? const SizedBox.shrink()),
    ]);
  }
}
