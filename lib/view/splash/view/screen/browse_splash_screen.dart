import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

class BrowseSplashScreen extends StatelessWidget {
  const BrowseSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kWhiteColor,
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.viewInsetsOf(context).bottom).r,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 60.h),
                  Text(GayaStrings.discover_ic.tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.sp)),
                  SizedBox(height: 4.h),
                  Text(GayaStrings.browser_desc.tr, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: kSecondaryColor)),
                  SizedBox(height: 40.h),
                  // Center(child: SvgPicture.asset(Assets.assets.images.onBoardingBrowse)),
                  Center(child: Image.asset("Assets/images/splash_browse.png", height: MediaQuery.sizeOf(context).height * 0.54)),
                ]),
                SafeArea(
                  minimum: const EdgeInsets.only(bottom: 10).r,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GayaButton(
                          height: 50,
                          borderColor: Colors.transparent,
                          textStyle: CustomTypography.body2EnableStyle,
                          title: GayaStrings.start_browsing.tr,
                          onPressed: () => Routes.switchView(),
                          primaryColor: kprimaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
