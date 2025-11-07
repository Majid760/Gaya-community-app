import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/bindings/initializing_dependencies.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/ai_daily_user_matches/controller/ai_matches_controller.dart';
import 'package:gaya/view/ai_daily_user_matches/model/goal_Interest_model.dart';
import 'package:gaya/view/splash/view/widget/gradient_text.dart';
import 'package:get/get.dart';

/// This is the bottom sheet of match settings
matchSettingBottomSheet(BuildContext context) {
  final LocalizationController localizationController = Get.find();
  Size size = MediaQuery.sizeOf(context);
  const space = SizedBox(
    height: MySpaces.gap3,
  );
  const space2 = SizedBox(
    height: MySpaces.gap5,
  );
  final divider = Divider(
    height: 1.h,
    thickness: 1.h,
    color: AppColors.black5,
  );
  return Methods.showCircularModalSheet(
      context,
      GetBuilder<AIMatchesController>(
          autoRemove: false,
          init: AIMatchesController.to,
          builder: (controller) {
            return SizedBox(
              height: controller.isAIMatch ? 492.h : 168.h,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12).r,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///this text is only use for equal space with weight color
                          Text(
                            GayaStrings.cancel_txt.tr,
                            style: CustomTypography.body2StyleWeight.copyWith(color: AppColors.white),
                          ),
                          Text(GayaStrings.match_settings.tr,
                              textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                              textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                              style: CustomTypography.body2StyleWeight.copyWith(color: AppColors.black)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              GayaStrings.cancel_txt.tr,
                              textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                              textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                              style: CustomTypography.body2StyleWeight.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      space2,
                      divider,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(GayaStrings.gaya_ai_matches.tr,
                              textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                              textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                              style: CustomTypography.bodyStyle),
                          Switch.adaptive(activeColor: kprimaryColor, value: controller.isAIMatch, onChanged: controller.setAIMatchStatus)
                        ],
                      ),
                      divider,
                      if (controller.isAIMatch)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            space2,
                            Row(
                              // Set the mainAxisAlignment based on the language
                              mainAxisAlignment: localizationController.isHebrew ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: localizationController.isHebrew
                                  ? [
                                      // For Hebrew language, swap the positions of the text widgets
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          "(${GayaStrings.match_options.tr})",
                                          style: CustomTypography.bodyStyle.copyWith(color: AppColors.secondary),
                                        ),
                                      ),
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text("${GayaStrings.match_goals.tr} ", style: CustomTypography.bodyStyle),
                                      ),
                                    ]
                                  : [
                                      // For English or other languages, keep the original order of text widgets
                                      Text("${GayaStrings.match_goals.tr} ", style: CustomTypography.bodyStyle),
                                      Text(
                                        "(${GayaStrings.match_options.tr})",
                                        style: CustomTypography.bodyStyle.copyWith(color: AppColors.secondary),
                                      ),
                                    ],
                            ),
                            space,
                            MatchCardsRow(
                              items: controller.goals,
                              listType: "goals",
                            ),
                            space2,
                            Row(
                              // Set the mainAxisAlignment based on the language
                              mainAxisAlignment: localizationController.isHebrew ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: localizationController.isHebrew
                                  ? [
                                      // For Hebrew language, swap the positions of the text widgets
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          "(${GayaStrings.choose_one.tr})",
                                          style:
                                              CustomTypography.bodyStyle.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text("${GayaStrings.match_interest.tr} ", style: CustomTypography.bodyStyle),
                                      ),
                                    ]
                                  : [
                                      // For English or other languages, keep the original order of text widgets
                                      Text("${GayaStrings.match_interest.tr} ", style: CustomTypography.bodyStyle),
                                      Text(
                                        "(${GayaStrings.choose_one.tr})",
                                        style: CustomTypography.bodyStyle.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                            ),
                            space,
                            MatchCardsRow(
                              items: controller.genders,
                              listType: "genders",
                            ),
                            space2,
                             const LetsGoButton(),
                          ],
                        ),
                      //space2,
                      // //bottom black line
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: Container(
                      //     width: 134.w,
                      //     height: 5.h,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(6),
                      //       color: AppColors.black,
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            );
          }));
}

/// This is the row of goals & interested cards
class MatchCardsRow extends StatelessWidget {
  final List<GoalInterestModel> items;
  final String listType;

  const MatchCardsRow({Key? key, required this.items, required this.listType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final aiMatchesController = Get.find<AIMatchesController>();
    return SizedBox(
      width: size.width,
      height: 106.h,
      child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: items.map((item) {
            final index = items.indexOf(item);
            bool isLastItem = index == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLastItem ? 0.0 : 8.0).r,
              child: InkWell(
                onTap: () {
                  if (listType == "goals") {
                    aiMatchesController.addGoals(item.title, items.indexOf(item));
                  } else {
                    aiMatchesController.addGenders(item.title, items.indexOf(item));
                  }
                },
                child: MatchCard(item: item),
              ),
            );
          }).toList()),
    );
  }
}

/// This is the match card widget
class MatchCard extends StatelessWidget {
  final GoalInterestModel item;

  const MatchCard({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106.r,
      height: 106.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: item.isSelected ? AppColors.aiMatchCardGradient : AppColors.aiMatchCardGradient2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0).r,
        child: Container(
            width: 106.r,
            height: 106.r,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (item.image2 != null)SvgPicture.asset(
                        item.image2 ?? "",
                        fit: BoxFit.scaleDown,
                        height: 45.r,
                        width: 45.r,
                      ),
                    SvgPicture.asset(
                      item.image,
                      fit: BoxFit.scaleDown,
                      height: 45.r,
                      width: 45.r,
                    ),

                  ],
                ),
                SizedBox(
                  height: MySpaces.gap2.h,
                ),
                Text(
                  item.title.tr,
                  style: CustomTypography.body2StyleWeight.copyWith(color: AppColors.black),
                )
              ],
            )),
      ),
    );
  }
}

/// This is the let's go button
class LetsGoButton extends StatelessWidget {

 const  LetsGoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AIMatchesController aiMatchesController = Get.find();
    Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () async {
        if (aiMatchesController.selectedGenders.isNotEmpty && aiMatchesController.selectedGoals.isNotEmpty) {
          await aiMatchesController.sendMatchRequest();
          aiMatchesController.collapseExpandTile(expand: false);
          Navigator.pop(context);
        } else {
          GayaSnackBar.show( context: context, type: GayaSnackBarType.error, text:GayaStrings.choose_one.tr);
          Navigator.pop(context);
        }
      },
      child: Container(
          width: size.width,
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.aiMatchTextGradient,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0).r,
            child: Container(
                width: size.width,
                height: 40.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: GradientText(
                  GayaStrings.lets_go.tr,
                  gradient: AppColors.aiMatchTextGradient,
                  style: GayaTypography.titleSemiBold.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                )),
          )),
    );
  }
}
