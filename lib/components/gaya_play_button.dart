import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GayaPlayButtonWidget extends StatelessWidget {
  const GayaPlayButtonWidget(
      {Key? key, this.onClick, this.height, this.width, this.iconPath, this.iconHeight, this.iconWidth, this.iconColor})
      : super(key: key);
  final VoidCallback? onClick;
  final double? height;
  final double? width;
  final String? iconPath;
  final double? iconHeight;
  final double? iconWidth;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: SvgPicture.asset("Assets/icons/play_button.svg"), onPressed: onClick, iconSize: height ?? 50.h);
  }
}
