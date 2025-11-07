import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:gaya/view/community/community_invites/controllers/community_invites_controller.dart';
import 'package:get/get.dart';

class AddPhoneNoView extends GetView<CommunityInvitesController> {
  final String communityDescriiption = 'AddPhoneNoView';
  final String communityId;
  const AddPhoneNoView({Key? key, required this.communityId}) : super(key: key);
  onTap() {
    CommunityInvitesController.to.phoneNumberC.clear();
    Get.back();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: kBlackColor),
        shape: const Border(bottom: BorderSide(color: kBaseGrey)),
        automaticallyImplyLeading: true,
        title: Text(GayaStrings.add_phone_no.tr, style: CustomTypography.bodyStyle),
        centerTitle: true,
        backgroundColor: kWhiteColor,
        elevation: 0.1,
        leading:  GayaBackButton(
          onPop: onTap,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: 16.0),
          child: Column(
            children: [
              Text(GayaStrings.enter_phone_no_invite_secret_community.tr,
                  style: CustomTypography.secondaryFontStyleWeight.copyWith(height: 1.5, fontSize: 16)),
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(AuthString.phone, style: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor)),
                    const SizedBox(height: distance_10),
                    textField(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontFamily: GayaFontTheme.primaryFont,
                      ),

                      prefixIcon: countryList(context),
                      autovalidateModel: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {},
                      maxlines: 1,
                      borderColor: borderColor,
                      isPassword: false,
                      inputType: TextInputType.phone,
                      validation: (_) {

                        final String? data = controller.validation.phoneNumberValidator(_);
                        if (data != null) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            controller.setIsValidated(false);
                          });
                          return data;
                        } else {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            controller.setIsValidated(true);
                          });
                          return null;
                        }
                      },
                      controller: controller.phoneNumberC,
                      hintText: AuthString.phoneHint,
                      // hintTextStyle: CustomTypography.body4StyleLowWeight.copyWith(color: AppColors.black5),
                    ),
                    const SizedBox(height: 16.0),
                    GetBuilder<CommunityInvitesController>(
                      builder: (controller) {
                        return GayaButton(
                          height: 48,
                          borderColor: kTransparentColor,
                          primaryColor: //kprimaryColor,
                              controller.isInvitationSent || controller.isValidated == false || controller.isLoading
                                  ? kBaseGrey
                                  : kprimaryColor,
                          textStyle: //CustomTypography.body2EnableStyle,
                              controller.isValidated == false || controller.isLoading || controller.isInvitationSent
                                  ? CustomTypography.body2DisableStyle
                                  : CustomTypography.body2EnableStyle,
                          title: //'Add',
                              controller.isLoading
                                  ? AuthString.sendingInvitation
                                  : controller.isInvitationSent
                                      ? AuthString.sentInvitation
                                      : AuthString.sendInvitation,
                          onPressed: () {
                            // Routes.openInvitationSent(
                            //   communityId: communityId,
                            // );
                            // Routes.openInvitationSent(
                            //   communityId: communityId,
                            // );
                            if (controller.formKey.currentState!.validate() && controller.isLoading == false ) {
                              controller.formKey.currentState!.save();
                              FocusScope.of(context).unfocus();
                              controller.sendInvitationToPhone(context: context);
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget countryList(BuildContext context) {
    return StatefulBuilder(builder: (ctx, update) {
      return CountryListPick(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: kTransparentColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(AuthString.chooseCountry, style: CustomTypography.bodyStyle),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child:  Text(GayaStrings.done.tr,
                    style: const TextStyle(
                      color: kprimaryColor,
                      fontFamily: GayaFontTheme.primaryFont,
                    )))
          ],
        ),
        theme: CountryTheme(
          initialSelection: '+972',
          searchHintText: GayaStrings.search_txt.tr,
          isDownIcon: false,
          isShowTitle: false,
          labelColor: kBlackColor,
        ),
        initialSelection: '+972',
        onChanged: ((value) {
          controller.phoneCountryCodeC.text = value!.dialCode!;
          update(() {});
        }),
      );
    });
  }
}
