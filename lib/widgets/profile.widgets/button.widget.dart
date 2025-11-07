import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/const.dart';

class ButtonWidget extends StatelessWidget {
  final String? title;
  final Color buttonColor;
  final Color color;
  final TextStyle style;
  final VoidCallback onTap;
  final Widget? icon;
  final double height;
  final bool isLoading;

  const ButtonWidget({
    Key? key,
    this.title,
    required this.color,
    required this.style,
    required this.buttonColor,
    required this.onTap,
    this.icon,
    this.height = distance_40,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          alignment: Alignment.center,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: distance_5),
          decoration: BoxDecoration(
              color: isLoading ? buttonColor.withOpacity(.5) : buttonColor, borderRadius: BorderRadius.circular(borderRadius_4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) const Spacer(),
              if (icon != null) icon!,
              const SizedBox(width: distance_10),
              Text(title ?? '', style: style),
              if (isLoading) const Spacer(),
              if (isLoading) CupertinoActivityIndicator(radius: 8.r, color: style.color),
              if (isLoading) const SizedBox(width: distance_5),
            ],
          ),
        ));
  }
}

class CupertinoIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const CupertinoIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: icon,
    );
  }
}
