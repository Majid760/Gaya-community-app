import 'package:flutter/material.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

Future<void> GayaAlertDialog(
    {required BuildContext context,
    String? title,
    TextStyle? titileTextStyle,
    String? body,
    TextStyle? bodyTextStyle,
    String? okButtonText,
    double? okButtonHeight,
    double? cancleButtonHeight,
    double? okButtonWidht,
    double? cancleButtonWidth,
    VoidCallback? tapOnOk,
    TextStyle? okButtonTextStyle,
    String? cancleButtonText,
    VoidCallback? tapOnCancel,
    TextStyle? cancleButtonTextStyle}) async {
  // set up the buttons
  Widget cancelButton = GayaButton(
      height: cancleButtonHeight ?? 40,
      width: cancleButtonWidth ?? 80,
      borderColor: kTransparentColor,
      // textStyle: loginController.styleEmail,
      textStyle: CustomTypography.body2EnableStyle,
      title: cancleButtonText ?? GayaStrings.cancel_txt.tr,
      onPressed: tapOnCancel,
      primaryColor: kprimaryColor);
  Widget continueButton = GayaButton(
      height: okButtonHeight ?? 40,
      width: okButtonWidht ?? 80,
      borderColor: kTransparentColor,
      // textStyle: loginController.styleEmail,
      textStyle: CustomTypography.body2EnableStyle,
      title: okButtonText ?? GayaStrings.continue_txt.tr,
      onPressed: tapOnOk,
      primaryColor: kprimaryColor);
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
      title: Text(title ?? '', style: titileTextStyle ?? const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500)),
      content: SelectableText(body ?? '', style: bodyTextStyle ?? const TextStyle(fontSize: 14, color: Colors.black)),
      actionsAlignment: MainAxisAlignment.end,
      actions: [cancelButton, continueButton]);

  // show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
