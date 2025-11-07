import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:get/get.dart';

import '../../../profile/contact_us/controller/contact_us_controller.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(GayaStrings.contact_us.tr, style: CustomTypography.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0),
      body: GetBuilder<ContactUsController>(
        init: ContactUsController(),
        builder: (controller) {
          return ListView(padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20).r, children: [
            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      GayaStrings.lets_Talk.tr,
                      style: GayaTypography.titleSemiBold.copyWith(fontWeight: FontWeight.w700, fontSize: 22.sp),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    GayaStrings.use_form_comments_suggestions_report.tr,
                    style: CustomTypography.bodyStyle.copyWith(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    GayaStrings.your_name_txt.tr,
                    style: GayaTypography.title.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10.h),
                  textField(
                      autovalidateModel: AutovalidateMode.onUserInteraction,
                      maxlines: 1,
                      borderColor: borderColor,
                      isPassword: false,
                      inputType: TextInputType.name,
                      fillColor: kBaseGrey,
                      isFilled: true,
                      enableBorder:
                          OutlineInputBorder(borderSide: const BorderSide(color: borderColor), borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(borderSide: const BorderSide(color: borderColor), borderRadius: BorderRadius.circular(10)),
                      focusBorder:
                          OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(10)),
                      validation: (_) => FormValidation.validateName(_),
                      validator: (_) => FormValidation.validateName(_),
                      controller: controller.nameController,
                      hintTextStyle: TextStyle(color: AppColors.black.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w400),
                      hintText: GayaStrings.full_name_txt.tr),
                  SizedBox(height: 10.h),
                  Text(
                    GayaStrings.your_email_txt.tr,
                    style: GayaTypography.title.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10.h),
                  textField(
                      autovalidateModel: AutovalidateMode.onUserInteraction,
                      maxlines: 1,
                      borderColor: borderColor,
                      isPassword: false,
                      inputType: TextInputType.emailAddress,
                      fillColor: kBaseGrey,
                      isFilled: true,
                      enableBorder:
                          OutlineInputBorder(borderSide: const BorderSide(color: borderColor), borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(borderSide: const BorderSide(color: borderColor), borderRadius: BorderRadius.circular(10)),
                      focusBorder:
                          OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(10)),
                      validation: (_) => FormValidation.validateEmail(_),
                      validator: (emailString) => FormValidation.validateEmail(emailString),
                      controller: controller.emailController,
                      hintTextStyle: TextStyle(color: AppColors.black.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w400),
                      hintText: GayaStrings.best_email_txt.tr),
                  SizedBox(height: 10.h),
                  Text(
                    GayaStrings.message.tr,
                    style: GayaTypography.title.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10.h),
                  textField(
                      minlines: 6,
                      borderColor: borderColor,
                      isPassword: false,
                      inputType: TextInputType.emailAddress,
                      fillColor: kBaseGrey,
                      isFilled: true,
                      enableBorder:
                          OutlineInputBorder(borderSide: const BorderSide(color: borderColor), borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(borderSide: const BorderSide(color: borderColor), borderRadius: BorderRadius.circular(10)),
                      focusBorder:
                          OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(10)),
                      validation: (_) => FormValidation.validateMessage(_),
                      controller: controller.messageController,
                      autovalidateModel: AutovalidateMode.onUserInteraction,
                      hintTextStyle: TextStyle(color: AppColors.black.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w400),
                      hintText: GayaStrings.how_can_we_help_you.tr),
                  // MultiLineMessageCupertinoTextField(
                  //     isFilled: true,
                  //     minlines: 6,
                  //     fillColor: kBaseGrey,
                  //     controller: controller.messageController,
                  //     hintText: GayaStrings.how_can_we_help_you.tr,
                  //     inputType: TextInputType.text,
                  //     isPassword: false,
                  //     decoration: BoxDecoration(color: kBaseGrey, borderRadius: BorderRadius.circular(10)),
                  //     validation: (_) => FormValidation.validateMessage(_)),
                  SizedBox(height: 20.h),
                  GayaButton(
                    isLoading: controller.isLoading,
                    height: 45.h,
                    textStyle: GayaTypography.title.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                    title: GayaStrings.lets_Talk.tr,
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (controller.formKey.currentState!.validate()) {
                        bool isSubmitted = await controller.onSubmit(context: context);
                        Navigator.pop(context, isSubmitted);
                      }
                    },
                    primaryColor: AppColors.primary,
                  ),
                ],
              ),
            )
          ]);
        },
      ),
    );
  }
}
