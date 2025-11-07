import 'dart:developer';

import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../shared/view/widget/gaya_back_button.dart';
import '../../../utils/theme/app_colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phoneCntrlr = TextEditingController();

  final validation = FormValidation();
  final int nameText = 1;
  final int emailText = 1;
  bool isValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final registerController = Provider.of<LoginController>(context, listen: true);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(appBar: getAppbar(), body: getBody(registerController, context)),
    );
  }

//Appbar
  PreferredSizeWidget getAppbar() {
    return AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: kBlackColor),
        shape: const Border(bottom: BorderSide(color: kBaseGrey)),
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Text(GayaStrings.create_account.tr, style: CustomTypography.bodyStyle),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
        elevation: 0);
  }

//body
  Widget getBody(LoginController registerController, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_20),
      child: Form(
        key: registerFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: distance_15),
              Text(GayaStrings.full_name.tr, style: CustomTypography.secondaryFontStyle),
              const SizedBox(height: distance_10),
              textField(
                  maxlines: 1,
                  borderColor: borderColor,
                  isPassword: false,
                  onChanged: _onTextChange,
                  inputType: TextInputType.name,
                  autovalidateModel: AutovalidateMode.onUserInteraction,
                  suffixIcon: nameText < 1 ? const Icon(Icons.error_sharp, color: kRedColor) : const SizedBox(),
                  validation: validation.firstNameValidator,
                  controller: name,
                  hintText: GayaStrings.full_name.tr),
              const SizedBox(height: distance_20),
              Text(GayaStrings.phone.tr, style: CustomTypography.secondaryFontStyle),
              const SizedBox(height: distance_10),
              textField(
                  prefixIcon: countryList(context),
                  autovalidateModel: AutovalidateMode.onUserInteraction,
                  onChanged: _onTextChange,
                  maxlines: 1,
                  borderColor: borderColor,
                  isPassword: false,
                  inputType: TextInputType.phone,
                  // suffixIcon: validation.phoneNumberValidator.isValid(registerController.phoneNumberController.text)
                  //     ? Icon(Icons.error_sharp, color: kRedColor)
                  //     : SizedBox(),
                  controller: phoneCntrlr,
                  hintText: GayaStrings.phone_no_txt.tr),
              const SizedBox(height: distance_20),
              Text(AuthString.password, style: CustomTypography.secondaryFontStyle),
              const SizedBox(height: distance_10),
              textField(
                  maxlines: 1,
                  autovalidateModel: AutovalidateMode.onUserInteraction,
                  borderColor: borderColor,
                  isPassword: !registerController.isPasswordVisible ? true : false,
                  inputType: TextInputType.text,
                  onChanged: _onTextChange,
                  // suffixWidget: validation.passwordValidator.isValid(registerController.password.text)
                  //     ? Icon(Icons.error_sharp, color: kRedColor)
                  //     : SizedBox(),
                  validation: validation.passwordValidator,
                  controller: password,
                  hintText: GayaStrings.type_password_hint.tr,
                  suffixIcon: IconButton(
                      onPressed: () => registerController.passwordVisibility(),
                      icon: registerController.isPasswordVisible ? SvgIconWidget.eyeFilled() : SvgIconWidget.eyeOffFilled()
                      // ? const Icon(Icons.visibility, color: kBlackColor)
                      // : const Icon(Icons.visibility_off, color: kBlackColor)

                      )),
              Consumer<LoginController>(builder: (context, logInCtrl, child) {
                return logInCtrl.signUpErrorMsg == null || logInCtrl.signUpErrorMsg!.isEmpty
                    ? const SizedBox.shrink()
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: distance_30.h),
                            Center(
                                child: Text(logInCtrl.signUpErrorMsg ?? '', style: CustomTypography.body3Style.copyWith(color: kRedColor))),
                          ],
                        ),
                      );
              }),
              // SizedBox(
              //   height: distance_5,
              // ),
              // Text(
              //   'Must be at least 8 charchters.',
              //   style: CustomTypography.body3Style,
              // ),

              const SizedBox(height: distance_15),
              GayaButton(
                  isLoading: registerController.isLoading,
                  height: 50.h,
                  borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
                  textStyle: isValid ? const TextStyle(color: Colors.white) : TextStyle(color: AppColors.secondary),
                  title: GayaStrings.create_gaya_account.tr,
                  onPressed: isValid
                      ? () async {
                          if (registerFormKey.currentState!.validate()) {
                            Map<String, dynamic> formData = Map.from(widget.data);
                            formData['password'] = password.text;
                            formData['fullName'] = name.text;
                            formData['phone'] = registerController.phoneCode + phoneCntrlr.text;
                            await registerController.register(context: context, data: formData);
                          }
                        }
                      : null,

                  primaryColor: isValid ? AppColors.primary : kBaseGrey),
              const SizedBox(height: 20),
              registerController.isLoading
                  ? const SizedBox.shrink()
                  : Center(
                      child: GayaButton(
                      title: GayaStrings.sign_in.tr,
                      height: 50,
                      borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
                      textStyle: CustomTypography.body2StyleWeightkPrimary,
                      onPressed: () {
                        Routes.loginView(clearPreviousRoutes: true);
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }

  _onTextChange(_) {
    if (validation.passwordValidator.isValid(password.text) && validation.firstNameValidator.isValid(name.text)) {
      setState(() {
        isValid = true;
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }

  Widget countryList(BuildContext context) {
    final registerController = Provider.of<LoginController>(context, listen: true);
    return StatefulBuilder(builder: (context, update) {
      return CountryListPick(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
          elevation: 0,
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.choose_country.tr, style: CustomTypography.bodyStyle),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(GayaStrings.done.tr, style: const TextStyle(color: kprimaryColor)))
          ],
        ),
        theme: CountryTheme(
            initialSelection: '+972',
            searchHintText: GayaStrings.search_txt.tr,
            isDownIcon: false,
            isShowTitle: false,
            labelColor: kBlackColor),
        initialSelection: '+972',
        onChanged: ((value) {
          registerController.phoneCode = value!.dialCode!;
          update(() {});
          log(registerController.phoneCode);
        }),
      );
    });
  }
}
