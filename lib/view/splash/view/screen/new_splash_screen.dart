import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/constant/string_constant.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/splash/controller/interest_search_controller.dart';
import 'package:gaya/view/splash/view/widget/gradient_text.dart';
import 'package:gaya/view/splash/view/widget/interest_widget.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewWelComeSplashScreen extends StatefulWidget {
  const NewWelComeSplashScreen({Key? key}) : super(key: key);

  @override
  State<NewWelComeSplashScreen> createState() => _NewWelComeSplashScreenState();
}

class _NewWelComeSplashScreenState extends State<NewWelComeSplashScreen> {
  LocalStorage storage = LocalStorage();
  int? readdata;
  int? termsAndConditions;

  @override
  void initState() {
    readTermsAndConditionFromLocalSorage();
    super.initState();
  }

  Future readTermsAndConditionFromLocalSorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    termsAndConditions = preferences.getInt('termsAndConditions');
    readdata = preferences.getInt('initScreen');
    // await preferences.setInt('initScreen', 1);

    if (true ?? termsAndConditions == null || termsAndConditions == 0) {
      if (!mounted) return;
      androidAlertDialog(context);
    } else {
      setTermsAndConditionIntoLocalSorage();
    }
  }

  Future setTermsAndConditionIntoLocalSorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt('termsAndConditions', 1);
    await preferences.setInt('initScreen', 1);
    termsAndConditions = preferences.getInt('termsAndConditions');
    readdata = preferences.getInt('initScreen');
    setState(() {
      termsAndConditions = 1;
      readdata = 1;
    });
    log(termsAndConditions.toString());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Theme(
            /// To change cursor for this specific screen, this is the workaround
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.white, selectionColor: AppColors.white),
            ),
            child: Stack(
              alignment: Alignment.center,
              // fit: StackFit.expand,
              children: [
                Positioned.fill(child: Image.asset(IconsAssetsPathUtils.splashWelcomePng, fit: BoxFit.cover)),
                Positioned(
                  child: Padding(
                    padding: EdgeInsets.only(top: 76.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.r),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text("${GayaStrings.let_find_your_people.tr} 🧐",
                                  style: GayaTypography.h1
                                      .copyWith(fontSize: 24.sp, fontWeight: FontWeight.w800, height: 1.6, color: AppColors.white)),
                              // SvgIconWidget.findEmojiIcon(width: 46.w, height: 36.h)
                            ],
                          ),
                          Text(GayaStrings.choose_find_your_interest.tr,
                              style: GayaTypography.h1
                                  .copyWith(fontSize: 32.sp, fontWeight: FontWeight.w800, height: 1.6, color: AppColors.white)),
                          SizedBox(height: 8.h),
                          GetBuilder<InterestController>(
                              autoRemove: false,
                              init: Get.find<InterestController>(),
                              builder: (interestController) {
                                return GayaSearchTextField(
                                  controller: interestController.textController,
                                  backgroundColor: AppColors.white.withOpacity(0.6),
                                  prefixIconColor: AppColors.white,
                                  style: TextStyle(color: AppColors.white),
                                  hintText: GayaStrings.write_here_something_you_love.tr,
                                  onChanged: (query) {
                                    interestController.searchInterest(query);
                                  },
                                  placeHolderStyle: GayaTypography.body2.copyWith(fontSize: 14.22.sp, color: AppColors.white, height: 1.4),
                                );
                              }),
                          SizedBox(height: 18.h),
                          GetBuilder<InterestController>(
                              autoRemove: false,
                              init: Get.find<InterestController>(),
                              builder: (interestController) {
                                return Expanded(
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomCenter,
                                    children: [
                                      interestController.textController.text.isNotEmpty
                                          ? interestController.filteredList.isNotEmpty
                                              ? GridView.builder(
                                                  itemCount: interestController.filteredList.length,
                                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 140,
                                                      childAspectRatio: 1,
                                                      crossAxisSpacing: 13,
                                                      mainAxisSpacing: 13),
                                                  itemBuilder: (context, index) {
                                                    final interest = interestController.filteredList[index];
                                                    return InterestWidget(
                                                      onTap: () => interestController.addInterest(interest),
                                                      isSelected: interestController.selectedInterests.contains(interest),
                                                      imageUrl: interest.url ?? "",
                                                      title: interest.title,
                                                    );
                                                  })
                                              : Positioned(
                                                  top: 100,
                                                  child: Text(GayaStrings.no_interest_found.tr, style: CustomTypography.body2DisableStyle))
                                          : GridView.builder(
                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 60.r),
                                              itemCount: interestController.interests.length,
                                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                  maxCrossAxisExtent: 140, childAspectRatio: 1, crossAxisSpacing: 13, mainAxisSpacing: 13),
                                              itemBuilder: (context, index) {
                                                final interest = interestController.interests[index];
                                                return InterestWidget(
                                                  onTap: () => interestController.addInterest(interest),
                                                  isSelected: interestController.selectedInterests.contains(interest),
                                                  imageUrl: interest.url ?? "",
                                                  title: interest.title,
                                                );
                                              },
                                            ),
                                      // button part
                                      GetBuilder<InterestController>(
                                        init: Get.find<InterestController>(),
                                        autoRemove: false,
                                        builder: (interestController) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: interestController.selectedInterests.length >= 5
                                                    ? () async {
                                                        if (termsAndConditions == 1) {
                                                          List<Map<String, dynamic>> interests = [];
                                                          for (var topic in interestController.selectedInterests) {
                                                            interests.add({'icon': topic.image, 'title': topic.title});
                                                          }
                                                          await interestController.updateInterest(context: context, intrests: interests);
                                                          interestController.saveToLocalStorage();

                                                          /// reresh home feed
                                                          // FeedControllerUtils.resetController();
                                                          // Get.back();
                                                          Routes.newFindingCommunitiesSplashScreen();
                                                          /*Navigator.of(context).pushReplacementNamed(route.switchView);*/
                                                        } else {
                                                          androidAlertDialog(context);
                                                        }
                                                      }
                                                    : null,
                                                child: Container(
                                                  height: 58.h,
                                                  decoration: BoxDecoration(
                                                      color: AppColors.white.withOpacity(0.78), borderRadius: BorderRadius.circular(4).r),
                                                  child: Center(
                                                      child: GradientText(
                                                          interestController.selectedInterests.length >= 5
                                                              ? GayaStrings.let_go.tr
                                                              : '${GayaStrings.choose.tr} ${interestController.minimumInterest - interestController.selectedInterests.length} ${GayaStrings.more.tr}',
                                                          style: GayaTypography.h2
                                                              .copyWith(fontSize: 24.sp, fontWeight: FontWeight.w700, height: 1))),
                                                ),
                                              ),
                                              SizedBox(height: 20.h)
                                            ],
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future<dynamic> androidAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 18, right: 18, top: 17, bottom: 0).r,
        actionsPadding: const EdgeInsets.only(
          left: 18,
          right: 18,
        ).r,
        content: RichText(
          textScaleFactor: 1.2,
          textAlign: TextAlign.center,
          text: TextSpan(
            text: GayaStrings.by_tapping_agree_dash.tr,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp, height: 1.57),
            children: [
              TextSpan(
                text: GayaStrings.terms_of_service_dash.tr,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Methods.launchMyUrl(Env.kTermsAndConditionsUrl, context: context, showConfirmationToOpenLink: false);
                  },
                style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13.sp, height: 1.57),
              ),
              TextSpan(
                text: GayaStrings.and_ack_that_you_read_dash.tr,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp, height: 1.57),
              ),
              TextSpan(
                text: GayaStrings.privacy_policy_dash.tr,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Methods.launchMyUrl(Env.kPrivacyPolicyUrl, context: context, showConfirmationToOpenLink: false);
                  },
                style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13.sp, height: 1.57),
              ),
              TextSpan(
                text: GayaStrings.to_learn_about_privacy_dot.tr,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp, height: 1.57),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          SizedBox(height: 15.h),
          GayaButton(
            title: GayaStrings.agree_continue.tr,
            height: 40.h,
            textStyle: const TextStyle(color: kWhiteColor),
            primaryColor: kprimaryColor,
            borderColor: kprimaryColor,
            onPressed: () {
              setTermsAndConditionIntoLocalSorage();
              Get.back();
              /*Navigator.pop(context);*/
            },
          ),
          SizedBox(height: 15.h)
        ],
      ),
    );
  }
}
