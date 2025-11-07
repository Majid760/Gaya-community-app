import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

class NotFoundView extends StatelessWidget {
  final bool shouldHaveScaffold;

  const NotFoundView({Key? key, this.shouldHaveScaffold = true}) : super(key: key);

  factory NotFoundView.noScaffold() => const NotFoundView(shouldHaveScaffold: false);

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcons.notFoundSolid(),
          SizedBox(height: MySpaces.gap3.h),
          Text(GayaStrings.page_not_found.tr, style: GayaTypography.h2.copyWith(height: 1.19)),
          SizedBox(height: MySpaces.gap2.h),
          Text(GayaStrings.page_not_exists.tr,
              textAlign: TextAlign.center, style: GayaTypography.body2.copyWith(color: AppColors.secondary)),
          SizedBox(height: MySpaces.gap4.h),
          GayaButton(
            width: 117.w,
            title: GayaStrings.take_me_back.tr,
            onPressed: () {
              /// cant pop if in stack only screen is this. so go to view.
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Routes.switchView();
              }
            },
            padding: const EdgeInsets.all(8).r,
            primaryColor: AppColors.divider,
            textStyle: GayaTypography.subtitleMedium,
          )
        ],
      ),
    );
    if (shouldHaveScaffold) {
      return Scaffold(body: body);
    }
    return body;
  }
}
