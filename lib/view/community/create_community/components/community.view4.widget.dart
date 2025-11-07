import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/create_community/controllers/create_community_controller.dart';
import 'package:get/get.dart';

import '../../../../components/button.component.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../utils/assets_icons.dart';
import '../../../../utils/theme/app_colors.dart';
import '../controllers/community_questionnaire_controller.dart';

class CommunityView4 extends StatelessWidget {
  const CommunityView4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateCommunityController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(GayaStrings.community_settings.tr, style: CustomTypography.bodyStyle),
          const SizedBox(height: distance_12),
          Text(GayaStrings.setup_community_settings.tr, style: CustomTypography.secondaryFontStyleWeight),
          SizedBox(height: distance_12.r),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(GayaStrings.post_approval.tr, style: CustomTypography.bodyStyle),
                  Switch.adaptive(
                      activeColor: kprimaryColor,
                      value: controller.isPostApprovalNeeded,
                      onChanged: (newValue) async {
                        controller.setPostApprovalStatus(newValue);
                      })
                ],
              ),
              // const SizedBox(height: 8.0),
              Text(
                GayaStrings.post_community_must_approve.tr,
                style: CustomTypography.secondaryFontStyleWeight,
                maxLines: 2,
              ),
            ],
          ),
          SizedBox(height: distance_12.r),

          ///entry form widget
          GetBuilder<QuestionnaireController>(
              autoRemove: false,
              init: QuestionnaireController.to,
              builder: (questionnaireController) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(GayaStrings.entry_forms.tr, style: CustomTypography.bodyStyle),
                        Switch.adaptive(
                            activeColor: kprimaryColor,
                            value: controller.isQuestionnaire,
                            onChanged: (newValue) async {
                              debugPrint("new value is $newValue");

                              controller.setQuestionnaireStatus(newValue);
                            })
                      ],
                    ),
                    // const SizedBox(height: 8.0),
                    Text(
                      GayaStrings.entry_forms_desc.tr,
                      style: CustomTypography.secondaryFontStyleWeight,
                      maxLines: 2,
                    ),
                    if (controller.isQuestionnaire) SizedBox(height: distance_12.h),

                    if (controller.isQuestionnaire && questionnaireController.questionnaire.isNotEmpty)
                      Container(
                        width: 100.w,
                        height: 44.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4).r, color: AppColors.black5),
                        child: Text(
                          GayaStrings.entry_forms.tr,
                          style: GayaTypography.subtitleMedium,
                        ),
                      ),
                    if (controller.isQuestionnaire && questionnaireController.questionnaire.isEmpty)
                      GayaButton(
                          height: 44.h,
                          borderColor: AppColors.divider,
                          textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.black),
                          leadingIcon: Padding(
                            padding: const EdgeInsets.only(right: 6).r,
                            child: SvgIconWidget.plusOutline(height: 20.r, width: 20.r),
                          ),
                          title: GayaStrings.create_custom_form.tr,
                          onPressed: () async {
                            Routes.gotoQuestionnaireForm();
                          },
                          primaryColor: AppColors.divider),
                  ],
                );
              }),
          if (controller.isCustomThemeSelected) ...[
            const SizedBox(height: distance_12),
            Text(GayaStrings.change_theme.tr, style: CustomTypography.bodyStyle),
            const SizedBox(height: distance_12),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Padding(padding: const EdgeInsets.only(right: 8).r);
                },
                itemCount: moderatortagColors.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  Color? retrieveColor = getColorFromHex(moderatortagColors[index]);
                  return GestureDetector(
                    onTap: () {
                      controller.setCommunityThemeModel(moderatortagColors[index]);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                            height: 60,
                            width: 60,
                            child: CircleAvatar(
                              backgroundColor: retrieveColor ?? kBaseGrey,
                            )),
                        if (controller.communityThemeModel != null && controller.communityThemeModel?.color == moderatortagColors[index])
                          const Positioned(left: 0, right: 0, top: 0, bottom: 0, child: Icon(Icons.check, color: kBlackColor))
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: distance_25),
          ],
        ],
      );
    });
  }
}
