import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../../../utils/language/translation.dart';

showGayaAlertDialogBox({
  required BuildContext context,
  String? title,
  String? subTitle,
  String? okButtonText,
  String? cancleButtonText,
  VoidCallback? tapOnYes,
  VoidCallback? tapOnNo,
  Widget? child,
}) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: child ??
        AlertBoxView(
            title: title,
            subTitle: subTitle,
            okButtonText: okButtonText,
            cancleButtonText: cancleButtonText,
            tapOnYes: tapOnYes,
            tapOnNo: tapOnNo),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext builderContext) {
      return alert;
    },
  );
}

class AlertBoxView extends StatelessWidget {
  const AlertBoxView({Key? key, this.title, this.subTitle, this.okButtonText, this.cancleButtonText, this.tapOnYes, this.tapOnNo})
      : super(key: key);
  final String? title;
  final String? subTitle;
  final String? okButtonText;
  final String? cancleButtonText;
  final VoidCallback? tapOnYes;
  final VoidCallback? tapOnNo;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 295.w,
        height: 235.h,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4).r),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // icon
              // SvgPicture.asset(Assets.assets.icons.cameraIcon, height: 28.h, color: kprimaryColor),
              SvgIconWidget.cameraOutline(height: 28.h, color: AppColors.primary),
              SizedBox(height: distance_8.h),
              Center(child: Text(GayaStrings.we_need_access.tr, style: GayaTypography.h3.copyWith(height: 1.93, fontSize: 16.sp))),
              SizedBox(height: distance_5.h),
              Text(GayaStrings.access_desc.tr,
                  textAlign: TextAlign.center, style: GayaTypography.body2.copyWith(height: 1.55, fontSize: 14.22.sp)),
              SizedBox(height: distance_8.h),
              GayaButton(
                height: 36.h,
                title: GayaStrings.enable_permission.tr,
                borderColor: kprimaryColor,
                primaryColor: kprimaryColor,
                onPressed: tapOnYes,
                textStyle: GayaTypography.text.copyWith(fontWeight: FontWeight.w500, fontSize: 14.22.sp, color: AppColors.white),
              ),
              SizedBox(height: distance_8.h),
              GayaButton(
                height: 36.h,
                title: GayaStrings.cancel_txt.tr,
                borderColor: kBaseGrey,
                primaryColor: kBaseGrey,
                onPressed: tapOnNo,
                textStyle: GayaTypography.text.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.22.sp,
                ),
              )
            ],
          ),
        ));
  }
}

class AlertBoxViewDynamic extends StatelessWidget {
  const AlertBoxViewDynamic(
      {Key? key,
      this.title,
      this.subTitle,
      this.okButtonText,
      this.cancleButtonText,
      this.tapOnYes,
      this.tapOnNo,
      this.icon,
      this.okBtnColor})
      : super(key: key);
  final String? title;
  final String? subTitle;
  final String? okButtonText;
  final String? cancleButtonText;
  final VoidCallback? tapOnYes;
  final VoidCallback? tapOnNo;
  final Widget? icon;
  final Color? okBtnColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 295.w,
        height: 235.h,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4).r),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // icon
              if (icon != null) icon!,
              SizedBox(height: distance_8.h),
              Center(child: Text(title ?? "", style: GayaTypography.h3.copyWith(height: 1.93, fontSize: 16.sp))),
              SizedBox(height: distance_5.h),
              Text(subTitle ?? "", textAlign: TextAlign.center, style: GayaTypography.body2.copyWith(height: 1.55, fontSize: 14.22.sp)),
              SizedBox(height: distance_8.h),
              GayaButton(
                height: 36.h,
                title: okButtonText ?? "",
                borderColor: okBtnColor ?? kprimaryColor,
                primaryColor: okBtnColor ?? kprimaryColor,
                onPressed: tapOnYes,
                textStyle: GayaTypography.text.copyWith(fontWeight: FontWeight.w500, fontSize: 14.22.sp, color: AppColors.white),
              ),
              SizedBox(height: distance_8.h),
              GayaButton(
                height: 36.h,
                title: GayaStrings.cancel_txt.tr,
                borderColor: kBaseGrey,
                primaryColor: kBaseGrey,
                onPressed: tapOnNo,
                textStyle: GayaTypography.text.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.22.sp,
                ),
              )
            ],
          ),
        ));
  }
}