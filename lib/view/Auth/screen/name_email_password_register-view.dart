import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class NameEmailPasswordRegisterView extends StatefulWidget {
  const NameEmailPasswordRegisterView({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;
  @override
  State<NameEmailPasswordRegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<NameEmailPasswordRegisterView> {
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final validation = FormValidation();
  final int nameText = 1;
  final int emailText = 1;

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
        leading: BackButton(onPressed: () {
          showGayaAlertDialogButton(
              context: context,
              actionText: GayaStrings.log_out.tr,
              actionMsg: GayaStrings.want_to.tr,
              tapOnNo: () async {
                Navigator.pop(context);
              },
              tapOnYes: () {
                Provider.of<LoginController>(context, listen: false).logout(context);
                Routes.loginView();
              });
        }),
        title: Text(GayaStrings.sign_up.tr, style: CustomTypography.bodyStyle),
        centerTitle: true,
        backgroundColor: kTransparentColor,
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
              const SizedBox(height: distance_30),
              Text(GayaStrings.full_name.tr, style: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor)),
              const SizedBox(height: distance_10),
              textField(
                  maxlines: 1,
                  borderColor: borderColor,
                  isPassword: false,
                  inputType: TextInputType.name,
                  autovalidateModel: AutovalidateMode.onUserInteraction,
                  suffixIcon: nameText < 1 ? const Icon(Icons.error_sharp, color: kRedColor) : const SizedBox(),
                  validation: (value) {
                    if (value == null) {
                      return GayaStrings.please_enter_name.tr;
                    } else if (value.trim().isEmpty) {
                      return GayaStrings.please_enter_valid_name.tr;
                    } else if ((value.trim().toLowerCase().contains('anonymous'))) {
                      return GayaStrings.please_enter_real_name.tr;
                    } else {
                      return null;
                    }
                  },
                  controller: name,
                  hintText: AuthString.fullNameHint),
              const SizedBox(height: distance_20),
              Text(AuthString.email, style: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor)),
              const SizedBox(height: distance_10),
              textField(
                  controller: email,
                  maxlines: 1,
                  borderColor: borderColor,
                  isPassword: false,
                  autovalidateModel: AutovalidateMode.onUserInteraction,
                  inputType: TextInputType.emailAddress,
                  validation: validation.emailValidator,
                  hintText: GayaStrings.type_email_hint.tr),
              const SizedBox(height: distance_20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(GayaStrings.password.tr, style: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor)),
                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.pushReplacementNamed(context, route.resetPassword);
                  //     },
                  //     child: const Text("${AuthString.forgotPassword}?", style: CustomTypography.secondaryFontStyle)),
                ],
              ),
              const SizedBox(height: distance_10),
              textField(
                maxlines: 1,
                autovalidateModel: AutovalidateMode.onUserInteraction,
                borderColor: borderColor,
                isPassword: !registerController.isPasswordVisible ? true : false,
                inputType: TextInputType.text,
                // suffixWidget: validation.passwordValidator.isValid(registerController.password.text)
                //     ? Icon(Icons.error_sharp, color: kRedColor)
                //     : SizedBox(),
                validation: validation.passwordValidator,
                controller: password,
                hintText: GayaStrings.type_password_hint.tr,
                suffixIcon: IconButton(
                    onPressed: () => registerController.passwordVisibility(),
                    icon: !registerController.isPasswordVisible
                        ?  SvgIconWidget.eyeFilled()
                        : SvgIconWidget.eyeFilled()),
                        //  ? const Icon(Icons.visibility, color: kBlackColor)
                        // : const Icon(Icons.visibility_off, color: kBlackColor)),
              ),
              Consumer<LoginController>(builder: (context, logInCtrl, child) {
                return logInCtrl.signInErrorMsg == null || logInCtrl.signInErrorMsg!.isEmpty
                    ? const SizedBox.shrink()
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: distance_30.h),
                            Center(
                                child: Text(logInCtrl.signInErrorMsg ?? '', style: CustomTypography.body3Style.copyWith(color: kRedColor))),
                          ],
                        ),
                      );
              }),
              // SizedBox(height: distance_5),
              // Text('Must be at least 8 charchters.', style: CustomTypography.body3Style),
              const SizedBox(height: distance_30),
              registerController.isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : GayaButton(
                      height: 50,
                      borderColor: kTransparentColor,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: GayaFontTheme.primaryFont,
                      ),
                      title: GayaStrings.sign_up.tr,
                      onPressed: () async {
                        if (registerFormKey.currentState!.validate()) {
                          Map<String, dynamic> formData = Map.from(widget.data);
                          formData['password'] = password.text;
                          formData['name'] = name.text;
                          formData['email'] = email.text;
                          bool isLinkedSuccesfully = await registerController.linkPhoneWithEmail(context: context, data: formData);
                          if (isLinkedSuccesfully) Routes.registerDOBAndGenderView();
                          // Navigator.pushNamed(context, route.registerDOBAndGender);
                        }
                      },
                      primaryColor: kprimaryColor)
            ],
          ),
        ),
      ),
    );
  }
}
