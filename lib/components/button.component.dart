import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';

class GayaButton extends StatelessWidget {
  final Color? primaryColor;
  final String title;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final TextStyle? textStyle;
  final bool islogout;
  final Color? borderColor;
  final bool isLoading;
  final double borderRadius;
  final EdgeInsets? padding;
  final Color? loadingColor;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const GayaButton(
      {Key? key,
      this.primaryColor,
      required this.title,
      this.onPressed,
      this.height,
      this.width,
      this.textStyle,
      this.islogout = false,
      this.borderColor,
      this.borderRadius = borderRadius_4,
      this.isLoading = false,
      this.padding,
      this.loadingColor = Colors.white,
      this.leadingIcon,
      this.trailingIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: isLoading
            ? null
            : () {
                if (onPressed != null) {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              },
        child: Container(
          alignment: Alignment.center,
          height: height,
          padding: padding,
          width: width,
          decoration: BoxDecoration(
            border: (borderColor != null) ? Border.all(color: borderColor!) : null,
            color: isLoading ? primaryColor?.withOpacity(.5) : primaryColor,
            borderRadius: BorderRadius.circular(borderRadius).r,
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingIcon != null) leadingIcon!,
                  if (islogout)
                    Padding(padding: const EdgeInsets.only(right: 10), child: SvgIconWidget.logoutOutline(color: AppColors.error)),
                  Text(title, style: textStyle),
                  if (trailingIcon != null) trailingIcon!,
                ],
              ),
              if (isLoading)
                Positioned(
                  right: 20,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: CupertinoActivityIndicator(color: loadingColor),
                  ),
                )
            ],
          ),
        ));
  }
}

class buttonIcon extends StatelessWidget {
  final Color? primaryColor;
  final String title;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final String iconString;
  final IconData? icon;
  final TextStyle? textStyle;
  final Color? borderColor;
  final bool isLoading;
  final Color? iconColor;

  const buttonIcon({
    Key? key,
    this.primaryColor,
    required this.title,
    this.onPressed,
    this.height,
    this.width,
    required this.iconString,
    this.icon,
    this.textStyle,
    this.borderColor,
    this.isLoading = false,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          if (onPressed != null) {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: height,
          width: width,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? Colors.transparent),
            color: isLoading ? primaryColor?.withOpacity(.5) : primaryColor,
            borderRadius: BorderRadius.circular(borderRadius_4).r,
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  iconString == ""
                      ? Icon(icon, color: Colors.black)
                      : SvgPicture.asset(
                          iconString,
                          color: iconColor,
                          height: 20.h,
                          width: 20.h,
                        ),
                  const SizedBox(width: 4),
                  Text(title, style: textStyle),
                ],
              ),
              if (isLoading)
                const Positioned(
                  right: 20,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: CupertinoActivityIndicator(color: Colors.white),
                  ),
                )
            ],
          ),
        ));
  }
}

class SocialMediaButtons extends StatelessWidget {
  final Function()? onPressFunction;
  final String text;
  final String imageAsset;
  final Color backgroundColor;
  final TextStyle textStyle;
  final Color? borderColor;

  const SocialMediaButtons(
      {Key? key,
      required this.onPressFunction,
      required this.text,
      required this.imageAsset,
      required this.backgroundColor,
      this.borderColor,
      required this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          if (onPressFunction != null) {
            HapticFeedback.lightImpact();
            onPressFunction!();
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius_4).r,
              border: Border.all(color: borderColor ?? AppColors.transparrent)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(imageAsset, height: 20, width: 20),
              const SizedBox(width: 10),
              Text(text, style: textStyle),
            ],
          ),
        ));
  }
}