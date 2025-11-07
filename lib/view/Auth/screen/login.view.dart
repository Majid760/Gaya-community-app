import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/app_logo_title_widget.dart';
import '../../../components/button.component.dart';
import '../../../components/gradient_text_widget.dart';
import '../../../components/textfield.component.dart';
import '../../../shared/view/widget/gaya_back_button.dart';
import '../../../utils/const.dart';
import '../../../utils/vallidation.dart';
import '../constants/auth_constants.dart';
import '../controller/login.controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final validation = FormValidation();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late TextEditingController phoneNumberController;

  late LoginController _loginController;

  @override
  void initState() {
    _loginController = Provider.of<LoginController>(context, listen: false);
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _loginController.customDispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Provider.of<LoginController>(context, listen: true);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: kTransparentColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// app logo
                SizedBox(height: 30.r, width: 30.r, child: const GayaLogo(padding: EdgeInsets.zero)),
                const SizedBox(width: distance_10),
                Text("Gaya", style: CustomTypography.headingStyle),
              ],
            ),
            centerTitle: false,
            bottom: TabBar(
                indicatorWeight: 3,
                unselectedLabelColor: kSecondaryColor,
                overlayColor: MaterialStateProperty.all<Color>(kTransparentColor),
                unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                indicatorColor: kprimaryColor,
                labelPadding: const EdgeInsets.only(bottom: 12),
                labelColor: kBlackColor,
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kBlackColor),
                // onTap: (index) => onTabTap!(index),

                onTap: (_) {},
                tabs: const [Text(AuthString.phonee), Text(AuthString.email)]),
          ),
          body: Column(
            children: [
              Expanded(
                child: Form(
                  key: loginFormKey,
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: distance_20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              header(),
                              Text(GayaStrings.phone.tr, style: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor)),
                              const SizedBox(height: distance_10),
                              Consumer<LoginController>(
                                builder: (context, logInCtrl, child) {
                                  return textField(
                                      prefixIcon: countryList(context),
                                      autovalidateModel: AutovalidateMode.onUserInteraction,
                                      maxlines: 1,
                                      borderColor: borderColor,
                                      isPassword: false,
                                      inputType: TextInputType.phone,
                                      validation: validation.phoneNumberValidator,
                                      controller: phoneNumberController,
                                      hintText: AuthString.phoneHint.tr);
                                },
                              ),
                              const SizedBox(height: distance_30),
                              GayaButton(
                                height: 50,
                                borderColor: kTransparentColor,
                                // textStyle: loginController.styleEmail,
                                primaryColor: AppColors.primary,
                                textStyle: CustomTypography.body2EnableStyle,
                                title: GayaStrings.send_code.tr,
                                onPressed: () async {
                                  if ((loginFormKey.currentState!.validate())) {
                                    Routes.verifyPhoneOTPView(phoneNumber: loginController.phoneCode + phoneNumberController.text);
                                  }
                                },
                              ),
                              footer(context, loginController),
                            ],
                          ),
                        ),
                      ),

                      // email tab view
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: distance_20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              header(),
                              Text(GayaStrings.email.tr, style: CustomTypography.secondaryFontStyle),
                              const SizedBox(height: distance_10),
                              textField(
                                  maxlines: 1,
                                  borderColor: borderColor,
                                  isPassword: false,
                                  inputType: TextInputType.emailAddress,
                                  validation: validation.loginEmailValidation,
                                  controller: loginController.email,
                                  hintText: GayaStrings.enter_email_hint.tr),
                              const SizedBox(height: distance_10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(GayaStrings.password.tr, style: CustomTypography.secondaryFontStyle),
                                  TextButton(
                                    style: GayaButtonStyles.actionRowTextButtonStyle2,
                                    child: Text(GayaStrings.forgot_password.tr, style: CustomTypography.secondaryFontStyle),
                                    onPressed: () => Routes.resetPasswordView(),
                                  ),
                                ],
                              ),
                              textField(
                                  maxlines: 1,
                                  borderColor: borderColor,
                                  isPassword: !loginController.isPasswordVisible,
                                  inputType: TextInputType.text,
                                  validation: validation.loginPasswordValidation,
                                  controller: loginController.password,
                                  hintText: GayaStrings.type_password_hint.tr,
                                  suffixIcon: loginController.isPasswordVisible == true
                                      ? Consumer<LoginController>(builder: (context, passwordVisible, child) {
                                          return IconButton(
                                              onPressed: () {
                                                passwordVisible.passwordVisibility();
                                              },
                                              icon: SvgIconWidget.eyeFilled()
                                              );
                                        })
                                      : Consumer<LoginController>(builder: (context, passwordVisibleOff, child) {
                                          return IconButton(
                                              onPressed: () {
                                                passwordVisibleOff.passwordVisibility();
                                              },
                                              icon: SvgIconWidget.eyeOffFilled()
                                              );
                                        })),
                              Consumer<LoginController>(builder: (context, logInCtrl, child) {
                                return logInCtrl.signInErrorMsg == null || logInCtrl.signInErrorMsg!.isEmpty
                                    ? const SizedBox.shrink()
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(height: distance_30.h),
                                            Center(
                                                child: Text(logInCtrl.signInErrorMsg ?? '',
                                                    style: CustomTypography.body3Style.copyWith(color: kRedColor))),
                                          ],
                                        ),
                                      );
                              }),
                              const SizedBox(height: distance_15),
                              GayaButton(
                                height: 50,
                                isLoading: loginController.isLoginButtonLoading,
                                borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
                                textStyle: CustomTypography.body2EnableStyle,
                                title: GayaStrings.logIn.tr,
                                onPressed: () {
                                  if (loginFormKey.currentState?.validate() ?? false) {
                                    loginController.loginWithEmailAndPassword(context: context);
                                  }
                                },
                                primaryColor: AppColors.primary,
                              ),
                              SizedBox(height: distance_30.h),
                              footer(context, loginController),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget header() {
    return Column(
      children: [
        const SizedBox(height: distance_10),
        Padding(
            padding: const EdgeInsets.only(right: distance_40),
            child: Text(GayaStrings.createCommunityDesc.tr, style: CustomTypography.body1Style)),
        const SizedBox(height: distance_20),
      ],
    );
  }

  Widget footer(BuildContext context, LoginController loginController) {
    return Column(
      children: [
        loginController.isLoading
            ? const SizedBox.shrink()
            : Center(
                child: TextButton(
                    style: GayaButtonStyles.actionRowTextButtonStyle2,
                    onPressed: () => Routes.registerEmailView(),
                    child: Text(GayaStrings.sign_up.tr, style: CustomTypography.bodyStyle))),
        SizedBox(height: 20.h),
        Row(
          children: [
            const Expanded(child: Divider(thickness: 2, color: kBaseGrey)),
            const SizedBox(width: 10),
            Text(GayaStrings.or.tr,
                style:
                    GayaTypography.h2.copyWith(fontSize: 16.sp, color: AppColors.secondary, letterSpacing: 0, fontWeight: FontWeight.w400)),
            const SizedBox(width: 10),
            const Expanded(child: Divider(thickness: 2, color: kBaseGrey)),
          ],
        ),
        SizedBox(height: 20.h),
        Consumer<LoginController>(builder: ((context, loginController, child) {
          return loginController.isLoading
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  Center(child: CircularProgressIndicator.adaptive(backgroundColor: AppColors.primary)),
                  const SizedBox(height: distance_10)
                ])
              : Column(
                  children: [
                    loginController.socialSignInError == null || loginController.socialSignInError!.isEmpty
                        ? const SizedBox.shrink()
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: distance_20.h),
                                Center(
                                    child: Text(loginController.socialSignInError ?? '',
                                        style: CustomTypography.body3Style.copyWith(color: kRedColor))),
                                SizedBox(height: distance_20.h),
                              ],
                            ),
                          ),
                    SocialMediaButtons(
                        borderColor: AppColors.secondary,
                        textStyle: GayaTypography.h2.copyWith(fontSize: 16.sp, color: kprimaryColor, letterSpacing: 0),
                        backgroundColor: kWhiteColor,
                        onPressFunction: () => loginController.logInWithGoogle(context: context),
                        text: GayaStrings.continue_with_google.tr,
                        imageAsset: 'Assets/icons/google.png'),
                    const SizedBox(height: distance_10),
                    Visibility(
                      visible: DeviceCheck.isIOS,
                      child: SocialMediaButtons(
                          textStyle: GayaTypography.h2.copyWith(fontSize: 16.sp, color: kWhiteColor, letterSpacing: 0),
                          backgroundColor: kBlackColor,
                          onPressFunction: () async {
                            final userModel = await loginController.signInWithAppleFirebase(context);
                            if (userModel != null) {
                              if (userModel.dob == null ||
                                  userModel.phoneNumber == null ||
                                  userModel.phoneNumber == '' ||
                                  userModel.name == null ||
                                  userModel.name?.trim() == '') {
                                // go to splash screen only if we have name, phonenumber and dob
                                Routes.askNameFieldView();
                              } else {
                                Routes.splash();
                              }
                            }
                          },
                          text: GayaStrings.continue_with_apple.tr,
                          imageAsset: 'Assets/images/apple_logo.png'),
                    ),
                  ],
                );
        })),
        SizedBox(height: 20.h),
        Center(
          child: RichText(
              text: TextSpan(
            style: Theme.of(context).textTheme.bodyText1,
            children: [
              // TextSpan(text: GayaStrings.dont_have_account.tr, style: const TextStyle(color: Colors.grey)),
              TextSpan(
                text: GayaStrings.continue_as_guest.tr,
                style: const TextStyle(color: kprimaryColor, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    FirebaseAuth.instance.signOut();
                    Routes.switchView();
                  },
              ),
            ],
          )),
        ),
      ],
    );
  }

  String counntryCode = '+972';

  Widget countryList(BuildContext context) {
    final registerController = Provider.of<LoginController>(context, listen: true);
    return StatefulBuilder(builder: (context, update) {
      return CountryListPick(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: kTransparentColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.choose_country.tr, style: CustomTypography.bodyStyle),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          actions: [
            TextButton(
                style: GayaButtonStyles.actionRowTextButtonStyle2,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: GradientTextWidget(
                  GayaStrings.done.tr,
                  style: CustomTypography.body2EnableStyle1.copyWith(color: kprimaryColor, fontWeight: FontWeight.bold),
                  gradient: AppColors.textGradient,
                )),
          ],
        ),
        theme: CountryTheme(
            initialSelection: counntryCode,
            searchHintText: GayaStrings.search_txt.tr,
            isDownIcon: false,
            isShowTitle: false,
            labelColor: kBlackColor),
        initialSelection: counntryCode,
        onChanged: ((value) {
          registerController.phoneCode = value!.dialCode!;
          counntryCode = value.dialCode!;
          update(() {});
        }),
      );
    });
  }
}
