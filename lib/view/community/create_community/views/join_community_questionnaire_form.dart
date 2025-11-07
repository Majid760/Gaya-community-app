// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/community/create_community/controllers/community_questionnaire_controller.dart';
import 'package:get/get.dart';

import '../../../../shared/view/widget/gaya_back_button.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/textstyles.dart';
import '../../components/community_joined_view.dart';

class JoinCommunityQuestionnaireForm extends StatelessWidget {
  final String communityName;
  final String communityId;
  final Function onSubmit;
  final bool shouldNavigate;
  final VoidCallback? onSuccess;

  JoinCommunityQuestionnaireForm(
      {Key? key,
      required this.communityName,
      required this.communityId,
      required this.onSubmit,
      this.shouldNavigate = true,
      this.onSuccess})
      : super(key: key);
  bool isAsyncInProcess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        iconTheme: const IconThemeData(color: kBlackColor),
        title: Text(communityName.length > 20 ? "${communityName.substring(0, 20)}..." : communityName, style: CustomTypography.bodyStyle),
        centerTitle: true,
        backgroundColor: kTransparentColor,
        elevation: 0,
      ),
      body: GetBuilder<QuestionnaireController>(
          init: QuestionnaireController(communityId: communityId),
          tag: communityId,
          builder: (controller) {
            if (controller.isLoading) {
              return Center(child: CircularProgressIndicator(backgroundColor: AppColors.primary));
            }
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20).r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: controller.questionnaire.length,
                        itemBuilder: (context, index) {
                          Questionnaire questionnaire = controller.questionnaire[index];
                          if (controller.questionnaire.isEmpty) {
                            return Center(
                                child: Text(GayaStrings.no_quetion_found_in_questionnaire.tr,
                                    style: GayaTypography.titleMedium.copyWith(height: 1.2.h)));
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(questionnaire.question, style: GayaTypography.titleMedium.copyWith(height: 1.2.h)),
                              SizedBox(height: MySpaces.gap2.h),
                              textField(
                                  inputType: TextInputType.text,
                                  hintText: GayaStrings.answer.tr,
                                  validation: FormValidation().fieldNotEmptyValidator,
                                  controller: controller.answerControllers[index],
                                  borderColor: borderColor),
                              SizedBox(height: MySpaces.gap2.h),
                            ],
                          );
                        }),
                  ),
                  MySpaces.gap2y,
                  StatefulBuilder(builder: (context, update) {
                    return GayaButton(
                        isLoading: controller.isButtonLoading,

                        /// avoid multiple clicks if in process
                        onPressed: isAsyncInProcess
                            ? null
                            : () async {
                                for (int ans = 0; ans < controller.answerControllers.length; ans++) {
                                  if (controller.answerControllers[ans].text.isEmpty) {
                                    snackBar(context, GayaStrings.answer_alert.tr, kRedColor);
                                    return;
                                  }
                                }
                                isAsyncInProcess = true;
                                update(() {});
                                await onSubmit();
                                bool isSubmittedSuccessfully = await controller.sendQuestionnaire(context, communityId);
                                if (isSubmittedSuccessfully) {
                                  if (Navigator.canPop(context) && shouldNavigate) {
                                    Navigator.pop(context);
                                  } else {
                                    onSuccess?.call();
                                  }

                                  /// it will be [false] in case of public communities because we want to navigate directly into public
                                  /// community instead of showing approval screen.
                                  if (shouldNavigate) {
                                    Get.to(
                                      () => JoiningApprovalScreen(
                                          community: Community(communityId: communityId, communityName: communityName)),
                                      transition: Transition.topLevel,
                                    );
                                  }
                                }
                              },
                        height: 50.h,
                        title: GayaStrings.submit.tr,
                        textStyle: GayaTypography.titleMedium.copyWith(color: AppColors.white),
                        primaryColor: AppColors.primary,
                        borderColor: AppColors.primary);
                  }),
                  MySpaces.gap8y,
                ],
              ),
            );
          }),
    );
  }
}
