import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/bindings/initializing_dependencies.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';


class FeatureCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final Widget widget1;

  const FeatureCardWidget({required this.title,required this.description,required this.widget1,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gap=SizedBox(
      height: MySpaces.gap2.h,
    );
    return  Stack(
      children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.only(left: 15,).r,
          child: Column(
            crossAxisAlignment: LocalizationController.to.isHebrew
                ?CrossAxisAlignment.end:CrossAxisAlignment.start,
            children: [
              Padding(
                padding:  EdgeInsets.only(right:LocalizationController.to.isHebrew
                    ? 65: 40).r,
                child: Text(
                  title.tr,
                  textAlign:LocalizationController.to.isHebrew
                      ? TextAlign.right: TextAlign.left,
                  style: GayaTypography.titleMedium.copyWith(height: 1.7),
                  textDirection: LocalizationController.to.isHebrew
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 65).r ,
                child: Text(
                  description.tr,
                  textAlign:LocalizationController.to.isHebrew
                      ? TextAlign.right: TextAlign.left,
                  style: GayaTypography.text.copyWith(fontSize: 14.sp, height: 1.7),
                  textDirection: LocalizationController.to.isHebrew
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
              ),
              gap,
            ],
          ),
        ),
        Positioned(top: 0, child: Image.asset("Assets/icons/feature_card_icons/feature_logo.png",height: 110.11.h,)),
        widget1,

      ],
    );
  }
}




