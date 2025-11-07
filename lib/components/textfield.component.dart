import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../utils/const.dart';
import '../utils/methods.dart';
import '../utils/textstyles.dart';

class GayaCupertinoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffixWidget;
  final bool? isPassword;
  final bool? isFilled;
  final bool? isEnabled;
  final bool? isReadOnly;
  final bool? isObscure;
  final bool? isAutoFocus;
  final bool? isDense;
  final bool? isEnableInteractiveSelection;
  final bool? isEnableSuggestions;
  final BoxDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool? maxLengthEnforced;
  final bool? minLenghtEnforced;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final Color? fillColor;
  final EdgeInsets padding;

  const GayaCupertinoTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixWidget,
    this.isPassword,
    this.isFilled,
    this.isEnabled,
    this.isReadOnly,
    this.isObscure,
    this.isAutoFocus,
    this.isDense,
    this.isEnableInteractiveSelection,
    this.isEnableSuggestions,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.maxLengthEnforced,
    this.minLenghtEnforced,
    this.focusNode,
    this.onTap,
    this.hintTextStyle,
    this.textStyle,
    this.fillColor,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: controller,
      decoration: BoxDecoration(
        color: fillColor ?? Colors.transparent,
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: padding,
      style: textStyle ?? const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
      placeholder: hintText ?? '',
      placeholderStyle: hintTextStyle ?? const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400),
      prefix: prefixIcon,
      obscureText: isObscure ?? false,
      autofocus: isAutoFocus ?? false,
      readOnly: isReadOnly ?? false,
      enabled: isEnabled ?? true,
      enableInteractiveSelection: isEnableInteractiveSelection ?? true,
      enableSuggestions: isEnableSuggestions ?? true,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction ?? TextInputAction.done,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      focusNode: focusNode,
      onTap: onTap,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorWidth: 1,
      onEditingComplete: () => FocusScope.of(context).unfocus(),
      onFieldSubmitted: (value) => FocusScope.of(context).unfocus(),
    );
  }
}

class textField extends StatelessWidget {
  final int? maxlength;
  final bool isPassword;
  final TextInputType inputType;
  final Widget? suffixIcon;
  final String hintText;
  final TextEditingController controller;
  final AutovalidateMode? autovalidateModel;
  final String? Function(String?)? validation;
  final Widget? suffixWidget;
  final Function(String)? onChanged;
  final Widget? prefixIcon;
  final Color? fillColor;
  final Color borderColor;
  final bool? isFilled;
  final bool? isEnabled;

  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;

  final int? maxlines;
  final int? minlines;

  final String? initialValue;
  final TextInputAction? textInputAction;
  final Widget? counter;
  final bool autoFocus;
  final String? Function(String?)? validator;
  final OutlineInputBorder? focusBorder;
  final InputBorder? enableBorder;
  final OutlineInputBorder? border;
  final InputDecoration? decoration;
  final TextCapitalization? textCapitalization;
  final BorderRadius? borderRadius;

  const textField({
    Key? key,
    required this.inputType,
    required this.hintText,
    required this.controller,
    required this.borderColor,
    this.maxlength,
    this.minlines,
    this.counter,
    this.isPassword = false,
    this.suffixIcon,
    this.autovalidateModel,
    this.validation,
    this.suffixWidget,
    this.onChanged,
    this.prefixIcon,
    this.fillColor,
    this.isFilled,
    this.isEnabled,
    this.focusNode,
    this.onTap,
    this.hintTextStyle,
    this.textStyle,
    this.maxlines,
    this.initialValue,
    this.textInputAction,
    this.autoFocus = false,
    this.validator,
    this.focusBorder,
    this.enableBorder,
    this.border,
    this.decoration,
    this.textCapitalization,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: isEnabled,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      initialValue: initialValue,
      autofocus: autoFocus,
      autocorrect: false,
      // if multi line, then obvsly it will be new line button.
      textInputAction: inputType == TextInputType.multiline ? TextInputAction.newline : textInputAction,
      keyboardType: inputType,
      focusNode: focusNode,
      minLines: minlines,
      textDirection: Methods.isRTL(controller.text) ? TextDirection.rtl : TextDirection.ltr,
      maxLength: maxlength,
      maxLines: maxlines,
      autovalidateMode: autovalidateModel,
      onTap: onTap,
      onChanged: onChanged,
      obscureText: isPassword,
      validator: validation,
      controller: controller,
      cursorColor: borderColor,
      style: textStyle,
      decoration: decoration ??
          InputDecoration(
            counter: counter,
            filled: isFilled,
            contentPadding: const EdgeInsets.only(left: distance_20, top: distance_15, bottom: distance_15),
            hintText: hintText,
            hintStyle: hintTextStyle ?? TextStyle(color: borderColor, fontFamily: GayaFontTheme.primaryFont),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            fillColor: fillColor,
            suffix: suffixWidget,
            focusedBorder: focusBorder ?? const OutlineInputBorder(borderSide: BorderSide(color: kprimaryColor)),
            enabledBorder: enableBorder ?? OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
            border: border ?? OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
          ),
    );
  }
}

class textField1 extends StatelessWidget {
  final bool read;
  final bool isPassword;
  final TextInputType inputType;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validation;
  final Widget? suffixWidget;
  final Function(String)? onChanged;
  final Widget? prefixIcon;
  final Color? fillColor;
  final Color borderColor;
  final bool? isFilled;
  final BorderRadius borderRadius;
  final TextStyle hintStyle;
  final VoidCallback ontap;
  final bool autoFocus;

  const textField1({
    Key? key,
    required this.read,
    this.controller,
    this.isPassword = false,
    this.autoFocus = false,
    required this.inputType,
    this.focusNode,
    this.suffixIcon,
    required this.hintText,
    required this.validation,
    this.suffixWidget,
    this.onChanged,
    this.prefixIcon,
    this.fillColor,
    required this.borderColor,
    this.isFilled,
    required this.borderRadius,
    required this.hintStyle,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        textDirection: Methods.isRTL(controller?.text ?? "") ? TextDirection.rtl : TextDirection.ltr,
        readOnly: read,
        autofocus: autoFocus,
        autocorrect: false,
        onTap: ontap,
        onFieldSubmitted: (_) => ontap(),
        onSaved: (_) => ontap(),
        focusNode: focusNode,
        onChanged: onChanged,
        obscureText: isPassword,
        keyboardType: inputType,
        validator: validation,
        controller: controller,
        cursorColor: borderColor,
        style: const TextStyle(color: Colors.black, fontFamily: GayaFontTheme.primaryFont),
        decoration: InputDecoration(
            filled: isFilled,
            contentPadding: const EdgeInsets.only(left: distance_20, top: distance_10),
            hintText: hintText,
            hintStyle: hintStyle,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            fillColor: fillColor,
            suffix: suffixWidget,
            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: borderRadius)),
      ),
    );
  }
}

class TextField2 extends StatelessWidget {
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

  const TextField2(
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
      this.validation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, notify) {
      return TextFormField(
        textDirection: Methods.isRTL(controller.text) ? TextDirection.rtl : TextDirection.ltr,
        maxLines: maxlines,
        minLines: minlines,
        textAlign: TextAlign.justify,
        autocorrect: false,
        onChanged: (value) {
          if (value.length == 1) {
            notify(() {});
          }
        },
        validator: validation,
        obscureText: isPassword ?? false,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        controller: controller,
        cursorColor: borderColor,
        decoration: InputDecoration(
            filled: isFilled,
            contentPadding: const EdgeInsets.only(left: distance_20, top: distance_15, bottom: distance_15),
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

class TextFormFieldComment extends StatelessWidget {
  final bool isPassword;
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, notify) {
      final bool isRTL = Methods.isRTL(controller.text);
      return TextFormField(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        autocorrect: false,
        minLines: 1,
        maxLines: 5,
        onChanged: (value) {
          if (value.length == 1) {
            notify(() {});
          }
        },
        onTap: onTap,
        obscureText: isPassword,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        controller: controller,
        cursorColor: borderColor,
        decoration: InputDecoration(
            filled: isFilled,
            contentPadding: const EdgeInsets.only(left: distance_20, right: distance_20, top: distance_15, bottom: distance_15).r,
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

  const TextFormFieldComment({
    Key? key,
    required this.isPassword,
    required this.inputType,
    this.suffixIcon,
    required this.hintText,
    required this.controller,
    this.suffixWidget,
    this.prefixIcon,
    this.fillColor,
    required this.borderColor,
    this.isFilled,
    this.maxlines,
    this.onTap,
  }) : super(key: key);
}

class GayaSearchTextField extends StatelessWidget {
  final bool isEnabled;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onEditingComplete;
  final Function()? onClear;
  final Function()? onSuffixTap;
  final String? hintText;
  final String? initialValue;
  final bool? autofocus;
  final Color? backgroundColor;
  final TextStyle? placeHolderStyle;
  final Color? prefixIconColor;
  final Color? cursorColor;
  final TextStyle? style;
  final BoxDecoration? decoration;
  final double? prefixIconSize;

  const GayaSearchTextField({
    Key? key,
    this.isEnabled = true,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onClear,
    this.onSuffixTap,
    this.hintText,
    this.initialValue,
    this.autofocus,
    this.backgroundColor,
    this.placeHolderStyle,
    this.prefixIconColor,
    this.cursorColor,
    this.style,
    this.decoration,
    this.prefixIconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: CupertinoSearchTextField(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
              placeholder: hintText ?? GayaStrings.search_hint.tr,
              prefixIcon: SvgIconWidget.searchLgOutline(
                color: prefixIconColor ?? AppColors.secondary,
                height: prefixIconSize ?? 20.h,
              ),
              backgroundColor: backgroundColor,
              style: style,
              placeholderStyle: placeHolderStyle),
        ),
      );
    }

    return CupertinoSearchTextField(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
      // padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: decoration,
      placeholder: hintText ?? GayaStrings.search_hint.tr,
      controller: controller,
      backgroundColor: backgroundColor,
      placeholderStyle: placeHolderStyle,
      onTap: onTap,
      prefixIcon: SvgIconWidget.searchLgOutline(
        color: prefixIconColor ?? AppColors.secondary,
        height: prefixIconSize ?? 20.h,
        width: prefixIconSize,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onSuffixTap: onSuffixTap,
      autocorrect: false,
      autofocus: autofocus ?? false,
      style: style ??
          const TextStyle(
            color: Colors.black,
            fontFamily: GayaFontTheme.primaryFont,
          ),
    );
  }
}

class GayaMultiLineTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const GayaMultiLineTextField({
    Key? key,
    required this.controller,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, notify) {
      return TextFormField(
        textDirection: Methods.isRTL(controller.text) ? TextDirection.rtl : TextDirection.ltr,
        keyboardType: keyboardType,
        controller: controller,
        validator: validator,
        textInputAction: textInputAction ?? TextInputAction.done,
        maxLines: maxLines,
        maxLength: maxLength,
        minLines: minLines,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6).r),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: kprimaryColor), borderRadius: BorderRadius.circular(6).r),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2.0), borderRadius: BorderRadius.circular(6).r),
            filled: true,
            hintStyle: TextStyle(color: Colors.grey[600]),
            fillColor: Colors.white70),
      );
    });
  }
}

class MultiLineMessagetextField extends StatelessWidget {
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
  final BorderRadius borderRadius;

  const MultiLineMessagetextField(
      {Key? key,
      required this.inputType,
      required this.hintText,
      required this.controller,
      required this.borderColor,
      required this.borderRadius,
      this.isPassword,
      this.suffixIcon,
      this.suffixWidget,
      this.prefixIcon,
      this.fillColor,
      this.isFilled,
      this.maxlines,
      this.minlines,
      this.validation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, notify) {
      return TextFormField(
        textDirection: Methods.isRTL(controller.text) ? TextDirection.rtl : TextDirection.ltr,
        maxLines: maxlines,
        minLines: minlines,
        textAlign: TextAlign.justify,
        autocorrect: false,
        onChanged: (value) {
          if (value.length == 1) {
            notify(() {});
          }
        },
        validator: validation,
        obscureText: isPassword ?? false,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        controller: controller,
        cursorColor: borderColor,
        decoration: InputDecoration(
            filled: isFilled,
            contentPadding: const EdgeInsets.only(left: distance_20, top: distance_15, bottom: distance_15),
            hintText: hintText,
            hintStyle: const TextStyle(
              color: kSecondaryColor,
              fontFamily: GayaFontTheme.primaryFont,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            fillColor: fillColor,
            suffix: suffixWidget,
            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: borderRadius)),
      );
    });
  }
}

class MultiLineMessageCupertinoTextField extends StatelessWidget {
  final TextInputType inputType;
  final Widget? suffixIcon;
  final String hintText;
  final TextEditingController controller;
  final Widget? suffixWidget;
  final Widget? prefixIcon;
  final Color? fillColor;
  final bool? isFilled;
  final int? maxlines;
  final int? minlines;
  final bool? isPassword;
  final String? Function(String?)? validation;
  final BoxDecoration? decoration;

  const MultiLineMessageCupertinoTextField({
    Key? key,
    required this.inputType,
    required this.hintText,
    required this.controller,
    this.isPassword,
    this.suffixIcon,
    this.suffixWidget,
    this.prefixIcon,
    this.fillColor,
    this.isFilled,
    this.maxlines,
    this.minlines,
    this.validation,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, notify) {
      return CupertinoTextFormFieldRow(
        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
        placeholder: hintText ?? '',
        placeholderStyle: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400),
        prefix: prefixIcon,
        padding: const EdgeInsets.all(0),
        textDirection: Methods.isRTL(controller.text) ? TextDirection.rtl : TextDirection.ltr,
        maxLines: maxlines,
        minLines: minlines,
        textAlign: TextAlign.justify,
        autocorrect: false,
        onChanged: (value) {
          if (value.length == 1) {
            notify(() {});
          }
        },
        validator: validation,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        controller: controller,
        decoration: decoration,
      );
    });
  }
}
