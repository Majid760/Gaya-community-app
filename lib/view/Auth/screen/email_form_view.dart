import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:gaya/view/Auth/service/common_service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/gradient_text_widget.dart';
import '../../../shared/view/widget/gaya_back_button.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/button_styles.dart';

class EmailPhoneRegister extends StatefulWidget {
  const EmailPhoneRegister({super.key});
  @override
  State<EmailPhoneRegister> createState() => _EmailPhoneRegisterState();
}

class _EmailPhoneRegisterState extends State<EmailPhoneRegister> with SingleTickerProviderStateMixin {
  final int emailText = 1;

  // for registration
  final registerEmail = GlobalKey<FormState>();
  final registerPhone = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController phoneCntrlr;
  late TextEditingController phoneNumberController;
  final validation = FormValidation();
  late TabController _tabController;

  bool _isValidated = false;
  bool _isPhoneValid = false;

  // to show the suffix icon
  bool isPhoneSuffixIconVisible = false;

  @override
  void initState() {
    super.initState();
    phoneCntrlr = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    _tabController = TabController(vsync: this, length: AuthString.authTabs.length)..addListener(() {});
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    phoneCntrlr.dispose();
    _tabController.dispose();
    phoneNumberController.dispose();
  }

  void onChanged(String? value) {
    if ((value != null && value.isNotEmpty && AuthCommonService.isEmail(value))) {
      setState(() {
        _isValidated = true;
      });
    } else {
      setState(() {
        _isValidated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final validation = FormValidation();
    final loginController = Provider.of<LoginController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: kBlackColor),
        shape: const Border(bottom: BorderSide(color: kBaseGrey)),
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Text(GayaStrings.sign_up.tr, style: GayaTypography.titleMedium),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
        elevation: 0,
        bottom: TabBar(
            // padding: EdgeInsets.syme,
            controller: _tabController,
            indicatorWeight: 3,
            // indicator: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), color: kprimaryColor),
            // indicatorSize: TabBarIndicatorSize.label,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // phone tab view
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: distance_20),
            child: Form(
              key: registerPhone,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: distance_20),
                    Text(GayaStrings.enter_phone_to_sign_in.tr, style: CustomTypography.body1Style),
                    const SizedBox(height: distance_20),
                    Text(GayaStrings.phone.tr, style: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor)),
                    const SizedBox(height: distance_10),
                    Consumer<LoginController>(
                      builder: (context, logInCtrl, child) {
                        return textField(
                            prefixIcon: countryList(context),
                            autovalidateModel: AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              // if (validation.phoneNumberValidator.isValid(phoneCntrlr.text)) {
                              //   setState(() {
                              //     _isPhoneValid = true;
                              //   });
                              // } else {
                              //   setState(() {
                              //     _isPhoneValid = true;
                              //   });
                              // }
                            },
                            maxlines: 1,
                            borderColor: borderColor,
                            isPassword: false,
                            inputType: TextInputType.phone,
                            // suffixIcon: logInCtrl.isPhoneNumberValid ? const SizedBox() : const Icon(Icons.error_sharp, color: kRedColor),
                            validation: validation.phoneNumberValidator,
                            //     (value) {
                            //   final isvalid = validation.phoneNumberValidator(value);
                            //   if (isvalid == null) {
                            //     logInCtrl.changePhoneValidation(true);
                            //     return null;
                            //   } else {
                            //     logInCtrl.changePhoneValidation(false);
                            //     return isvalid;
                            //   }
                            // },
                            controller: phoneNumberController,
                            hintText: AuthString.phoneHint.tr);
                      },
                    ),
                    const SizedBox(height: distance_30),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(GayaStrings.have_account.tr, style: CustomTypography.secondaryFontStyle),
                      TextButton(
                          onPressed: () => Routes.loginView(clearPreviousRoutes: true),
                          child: Text(GayaStrings.logIn.tr, style: const TextStyle(color: kprimaryColor)))
                    ]),
                    GayaButton(
                      height: 50,
                      borderColor: kTransparentColor,
                      // textStyle: loginController.styleEmail,
                      primaryColor: AppColors.primary,
                      textStyle: CustomTypography.body2EnableStyle,
                      title: GayaStrings.send_code.tr,
                      onPressed: () async {
                        if ((registerPhone.currentState!.validate())) {
                          // await loginController.phoneAutenticaiton();
                          Routes.verifyPhoneOTPView(phoneNumber: loginController.phoneCode + phoneNumberController.text);
                          /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => VerifyPhoneNumberScreen(
                                      phoneNumber: loginController.phoneCode + loginController.phoneNumberController.text)));*/
                          // Navigator.push(context, route.registerDOBAndGender, arguments: {"email": emailController.text.trim()});
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),

          // email tab view
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: distance_20),
            child: Form(
              key: registerEmail,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: distance_20),
                    Text(GayaStrings.enter_email_to_sign_in.tr, style: CustomTypography.body1Style),
                    const SizedBox(height: distance_20),
                    Text(GayaStrings.email.tr, style: CustomTypography.secondaryFontStyle.copyWith(color: kBlackColor)),
                    const SizedBox(height: distance_10),
                    textField(
                        controller: emailController,
                        maxlines: 1,
                        borderColor: borderColor,
                        isPassword: false,
                        autovalidateModel: AutovalidateMode.onUserInteraction,
                        inputType: TextInputType.emailAddress,
                        validation: validation.emailValidator,
                        onChanged: (value) => onChanged(value),
                        hintText: GayaStrings.type_email_hint.tr),
                    const SizedBox(height: distance_30),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(GayaStrings.already_account.tr, style: CustomTypography.secondaryFontStyle),
                      TextButton(
                          style: GayaButtonStyles.actionRowTextButtonStyle2,
                          onPressed: () => Routes.loginView(clearPreviousRoutes: true),
                          child: Text(GayaStrings.logIn.tr, style: const TextStyle(color: kprimaryColor)))
                    ]),
                    GayaButton(
                      height: 50,
                      borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
                      // textStyle: loginController.styleEmail,
                      // textStyle: _isValidated ? CustomTypography.body2EnableStyle : CustomTypography.body2DisableStyle,
                      textStyle: CustomTypography.body2EnableStyle,
                      title: GayaStrings.continue_txt.tr,
                      onPressed: () {
                        if ((registerEmail.currentState!.validate())) {
                          Routes.registerDOBAndGenderView(email: emailController.text.trim());
                          // Navigator.pushNamed(context, route.registerDOBAndGender, arguments: {"email": emailController.text.trim()});
                        }
                      },
                      primaryColor: AppColors.primary,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
