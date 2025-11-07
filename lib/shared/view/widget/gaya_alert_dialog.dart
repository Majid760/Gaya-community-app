import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

// class GalayAlertBoxWithButton extends StatelessWidget {
//   const GalayAlertBoxWithButton({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return showAlertDialog();
//   }
// }

showGayaAlertDialogButton(
    {required BuildContext context,
    String? actionText = "Delete",
    actionMsg = GayaStrings.are_you_sure,
    VoidCallback? tapOnYes,
    VoidCallback? tapOnNo,
    String? yseButtonTitle =  GayaStrings.yes_txt,
    String? noButtonTitle= GayaStrings.no_txt,}) {
  // set up the button
  Widget yesButton = GayaButton(
      title: yseButtonTitle!.tr,
      onPressed: tapOnYes,
      borderRadius: borderRadius_4,
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal:yseButtonTitle==GayaStrings.settings?35: 50).r,
      textStyle: CustomTypography.secondaryFontStyle.copyWith(color: kWhiteColor),
      primaryColor: kprimaryColor,
      borderColor: kprimaryColor);
  Widget noButton = GayaButton(
      title: noButtonTitle!.tr,
      textStyle: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor),
      onPressed: tapOnNo,
      height: 36.h,
      padding:  EdgeInsets.symmetric(horizontal:noButtonTitle==GayaStrings.no_thanks?32: 50).r,
      borderRadius: borderRadius_4,
      primaryColor: kSecondaryLightColor,
      borderColor: kSecondaryLightColor);

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    contentPadding: const EdgeInsets.only(bottom: 16, left: 20, right: 20).r,
    titlePadding: const EdgeInsets.only(top: 16, bottom: 8, left: 20, right: 20).r,
    title: Text("${actionMsg.toString().tr} ${actionText.toString().tr}", style: CustomTypography.bodyStyle),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        yesButton,
        SizedBox(width: 8.w),
        noButton,
      ],
    ),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext builderContext) {
      return alert;
    },
  );
}
