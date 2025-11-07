import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';

class MessageTextField extends StatelessWidget {
  final TextInputType inputType;
  final Widget? suffixIcon;
  final String hintText;
  final TextEditingController controller;
  final Widget? suffixWidget;
  final Widget? prefixIcon;
  final Color? fillColor;
  final Color borderColor;
  final bool? isFilled;
  final int? maxlines;
  final int? minlines;
  final bool? isPassword;
  final String? Function(String?)? validation;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const MessageTextField(
      {Key? key,
      required this.inputType,
      required this.hintText,
      required this.controller,
      required this.borderColor,
      this.isPassword,
      this.suffixIcon,
      this.suffixWidget,
      this.prefixIcon,
      this.fillColor,
      this.isFilled,
      this.maxlines,
      this.minlines,
      this.validation,
      this.onChanged,
      this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, notify) {
      return TextFormField(
        textDirection: Methods.isRTL(controller.text) ? TextDirection.rtl : TextDirection.ltr,
        maxLines: maxlines,
        minLines: minlines,
        autocorrect: false,
        onChanged: onChanged,
        validator: validation,
        obscureText: isPassword ?? false,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        controller: controller,
        cursorColor: borderColor,
        focusNode: focusNode,
        decoration: InputDecoration(
            filled: isFilled,
            contentPadding: const EdgeInsets.only(left: distance_20, top: distance_10, bottom: distance_10),
            hintText: hintText,
            hintStyle: const TextStyle(
              color: kSecondaryColor,
              fontFamily: GayaFontTheme.primaryFont,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            fillColor: fillColor,
            suffix: suffixWidget,
            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30))),
      );
    });
  }
}
