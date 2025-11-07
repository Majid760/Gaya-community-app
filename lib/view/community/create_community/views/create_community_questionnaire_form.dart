import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../../../../components/button.component.dart';
import '../../../../shared/view/widget/gaya_alert_dialog.dart';
import '../../../../shared/view/widget/gaya_back_button.dart';
import '../../../../utils/assets_icons.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/textstyles.dart';
import '../../../../utils/theme/app_spaces.dart';
import '../components/questionnaire_form_components/text_component.dart';
import '../controllers/community_questionnaire_controller.dart';
import '../controllers/create_community_controller.dart';

class CreateCommunityQuestionnaireForm extends StatefulWidget {
  const CreateCommunityQuestionnaireForm({Key? key}) : super(key: key);

  @override
  State<CreateCommunityQuestionnaireForm> createState() => _CreateCommunityQuestionnaireFormState();
}

class _CreateCommunityQuestionnaireFormState extends State<CreateCommunityQuestionnaireForm> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        checkCreateCommunityChanges(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          leading: GayaBackButton(onPop: () => checkCreateCommunityChanges(context)),
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.create_form.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12).r,
          child: SingleChildScrollView(
            child: GetBuilder<QuestionnaireController>(
                autoRemove: false,
                init: QuestionnaireController.to,
                builder: (questionnaireController) {
                  return Form(
                    key: questionnaireController.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const QuestionnaireTextWidgets(),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: questionnaireController.questionWidgets.length,
                          itemBuilder: (context, i) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: MySpaces.gap4.h),
                                Text("${GayaStrings.question.tr.capitalizeFirst} ${i + 1}",
                                    style: GayaTypography.titleMedium.copyWith(height: 1.12)),
                                SizedBox(height: MySpaces.gap2.h),
                                questionnaireController.questionWidgets[i]
                              ],
                            );
                          },
                        ),

                        SizedBox(
                          height: MySpaces.gap4.h,
                        ),

                        ///add new question
                        GayaButton(
                            height: 50.h,
                            borderColor: AppColors.divider,
                            textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.black),
                            leadingIcon: Padding(
                              padding: const EdgeInsets.only(right: 6).r,
                              child: SvgIconWidget.plusOutline(height: 20.r, width: 20.r),
                            ),
                            title: GayaStrings.add_new_quest_txt.tr,
                            onPressed: () async {
                              questionnaireController.addQuestionWidget();
                            },
                            primaryColor: AppColors.divider),

                        SizedBox(
                          height: MySpaces.gap4.h,
                        ),

                        ///continue Button
                        GayaButton(
                            height: 50,
                            borderColor: kTransparentColor,
                            textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
                            title: GayaStrings.continue_txt.tr,
                            onPressed: () async {
                              if (questionnaireController.formKey.currentState!.validate()) {
                                await questionnaireController.addQuestionsToList(context);
                                Get.back();
                              }
                            },
                            primaryColor: kprimaryColor),
                        MySpaces.bottom
                      ],
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  checkCreateCommunityChanges(context) async {
    final CreateCommunityController createCommunityController = Get.find();
    bool shouldPop = await createCommunityController.shouldPop(context);

    if (shouldPop) {
      Navigator.pop(context);
    } else {
      showGayaAlertDialogButton(
        context: context,
        actionText: GayaStrings.discard_changes.tr,
        tapOnYes: () async {
          Navigator.pop(context);
          QuestionnaireController.to.resetQuestionList();
          // await createCommunityController.resetState(context);
          Navigator.pop(context);
        },
        tapOnNo: () {
          Navigator.pop(context);
        },
      );
    }
  }
}
