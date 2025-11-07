import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';

import '../../../utils/textstyles.dart';

class GayaListTileButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool haveIcon;
  final EdgeInsets? margin;

  final Widget? leading;
  final Widget? trailing;

  const GayaListTileButton(
      {Key? key, required this.title, this.subtitle, this.onTap, this.margin, this.haveIcon = false, this.leading, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.all(0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).r,
          child: Row(
            children: [
              (leading == null)
                  ? SizedBox(height: 18.r, width: 20.r, child: const Icon(Icons.delete))
                  : SizedBox(height: 24.r, width: 24.r, child: leading!),
              SizedBox(width: distance_10.r),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GayaTypography.titleMedium
                          .copyWith(color: AppColors.black, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.7),
                    ),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: GayaTypography.subtitleRegular
                              .copyWith(color: kSecondaryColor, fontSize: 14.sp, fontWeight: FontWeight.w400, height: 1.57))
                    else
                      SizedBox(height: 8.r)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GayaSwitchButtonListTile extends StatelessWidget {
  final Function(bool)? onChanged;

  final String title;
  final String? subtitle;
  final EdgeInsets? margin;
  bool value = false;
  final Widget? trailing;
  final Widget? leading;

  GayaSwitchButtonListTile(
      {Key? key, required this.title, this.subtitle, this.onChanged, this.margin, this.value = false, this.trailing, this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8).r,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                (leading == null) ? const SizedBox.shrink() : SizedBox(height: 24.r, width: 24.r, child: leading!),
                SizedBox(width: distance_10.r),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GayaTypography.titleMedium
                              .copyWith(color: AppColors.black, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.7)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: GayaTypography.subtitleRegular
                                .copyWith(color: kSecondaryColor, fontSize: 14.sp, fontWeight: FontWeight.w400, height: 1.57))
                      else
                        SizedBox(height: 8.r)
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: distance_30.r),
          StatefulBuilder(builder: (context, updateState) {
            return Switch.adaptive(
                activeColor: kprimaryColor,
                value: value,
                onChanged: (value) {
                  onChanged!(value);
                  updateState(() => value = value);
                });
          })
        ],
      ),
    );
  }
}


