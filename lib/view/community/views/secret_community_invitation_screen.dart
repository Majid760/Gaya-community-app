import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:gaya/view/community/controllers/secret_community_controller.dart';
import 'package:get/get.dart';

import '../../../shared/view/widget/gaya_back_button.dart';

class SecretCommunityInvitationScreen extends GetView<SecretCommunityController> {
  const SecretCommunityInvitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: kBlackColor),
        shape: const Border(bottom: BorderSide(color: kBaseGrey)),
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title:   Text(AuthString.secretCommunityInvitation, style: CustomTypography.bodyStyle),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: 16),
          child: Column(
            children: [
              Text(AuthString.secretCommInviteDescription,
                  style: CustomTypography.secondaryFontStyleWeight.copyWith(height: 1.5, fontSize: 16)),
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: distance_20),
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
                      hintTextStyle: CustomTypography.body4StyleLowWeight,
                    ),
                    const SizedBox(height: distance_50),
                    GetBuilder<SecretCommunityController>(
                      init: controller,
                      builder: (controller) {
                        return GayaButton(
                          height: 50,
                          borderColor: kTransparentColor,
                          primaryColor: controller.isInvitationSent || controller.isValidated == false || controller.isLoading
                              ? kBaseGrey
                              : kprimaryColor,
                          textStyle: controller.isValidated == false || controller.isLoading || controller.isInvitationSent
                              ? CustomTypography.body2DisableStyle
                              : CustomTypography.body2EnableStyle,
                          title: controller.isLoading
                              ? AuthString.sendingInvitation
                              : controller.isInvitationSent
                                  ? AuthString.sentInvitation
                                  : AuthString.sendInvitation,
                          onPressed: () {
                            if (controller.formKey.currentState!.validate() && controller.isLoading == false) {
                              controller.formKey.currentState!.save();
                              FocusScope.of(context).unfocus();
                              controller.sendInvitationToPhone(context: context);
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
    _getSendButtonString(controller) {
      if (controller.isLoading) {
        return AuthString.sendingInvitation;
      } else if (controller.isInvitationSent) {
        return AuthString.sentInvitation;
      } else {
        return AuthString.sendInvitation;
      }
    }
  }

  Widget countryList(BuildContext context) {
    return StatefulBuilder(builder: (context, update) {
      return CountryListPick(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: kTransparentColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: kBlackColor),
          title:   Text(AuthString.chooseCountry, style: CustomTypography.bodyStyle),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(AuthString.done, style: TextStyle(color: kprimaryColor,fontFamily: GayaFontTheme.primaryFont,)))
          ],
        ),
        theme: CountryTheme(
          initialSelection: '+972',
          searchHintText: AuthString.searchHint,
          isDownIcon: false,
          isShowTitle: false,
          labelColor: kBlackColor,
        ),
        // pickerBuilder: (context, countryCode) {
        //   return Row(
        //     children: [
        //       Flexible(
        //         child: Padding(
        //           padding: const EdgeInsets.symmetric(horizontal: 5.0),
        //           child: Image.asset(
        //             countryCode!.flagUri!,
        //             package: 'country_list_pick',
        //             width: 32.0,
        //           ),
        //         ),
        //       ),
        //       Text(
        //         countryCode.toString(),
        //         style: const TextStyle(color: Colors.red),
        //       ),
        //     ],
        //   );
        // },
        initialSelection: '+972',
        onChanged: ((value) {
          controller.phoneCountryCodeC.text = value!.dialCode!;
          update(() {});
        }),
      );
    });
  }
}
