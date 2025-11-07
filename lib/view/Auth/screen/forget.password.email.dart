import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/button.component.dart';
import '../../../components/textfield.component.dart';
import '../../../utils/const.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/vallidation.dart';
import '../controller/login.controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final validation = FormValidation();

  @override
  Widget build(BuildContext context) {
    final resetController = Provider.of<LoginController>(context, listen: true);
    final GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: getAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: distance_20),
        child: Form(
          key: resetFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: distance_20),
                Container(
                    padding: const EdgeInsets.only(right: distance_25),
                    width: double.infinity,
                    child: Text(GayaStrings.reset_password.tr, style: CustomTypography.body1Style)),
                const SizedBox(height: distance_10),
                Text(GayaStrings.email.tr, style: CustomTypography.body4Style),
                const SizedBox(height: distance_10),
                textField(
                    borderColor: borderColor,
                    isPassword: false,
                    onChanged: (value) {
                      // resetController.codeentered(value);
                    },
                    inputType: TextInputType.emailAddress,
                    validation: validation.emailValidator,
                    controller: resetController.email,
                    hintText: GayaStrings.enter_email_hint.tr),
                Consumer<LoginController>(builder: (context, logInCtrl, child) {
                  return logInCtrl.resetPasswordErrorMsg == null || logInCtrl.resetPasswordErrorMsg!.isEmpty
                      ? const SizedBox.shrink()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: distance_30.h),
                              Center(
                                  child: Text(logInCtrl.resetPasswordErrorMsg ?? '',
                                      style: CustomTypography.body3Style.copyWith(color: kRedColor))),
                            ],
                          ),
                        );
                }),
                const SizedBox(height: distance_20),
                resetController.isResetLoading
                    ? const Center(child: CircularProgressIndicator.adaptive(backgroundColor: kprimaryColor))
                    : GayaButton(
                        height: 50,
                        borderColor: kTransparentColor,
                        textStyle: CustomTypography.body2EnableStyle,
                        title: GayaStrings.send_email.tr,
                        primaryColor: AppColors.primary,
                        onPressed: () async {
                          if (resetFormKey.currentState!.validate()) {
                            final result = await resetController.resetPassword(context: context);
                            if (result != null && result) {
                              Routes.emailSentView(fromPage: FromPage.resetPassword);
                            }
                            // await resetController.getNumberAndPassword(context);
                          }
                          // await resetController.getNumberAndPassword(context);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//Appbar
  PreferredSizeWidget getAppbar() {
    return AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.25))),
        iconTheme: const IconThemeData(color: kBlackColor),
        title: Text(GayaStrings.reset_password_link.tr, style: CustomTypography.bodyStyle),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop() ? const GayaBackButton() : null,
        backgroundColor: const Color.fromARGB(0, 144, 91, 91),
        elevation: 0);
  }

  // Future sendOTP(BuildContext context) async {
  //   final controller = Provider.of<LoginController>(context, listen: false);
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: controller.number.toString(),
  //       codeSent: (verificationId, resendToken) {
  //         Navigator.of(context).pushNamed(route.resetPassword, arguments: {
  //           'phoneNumber': controller.number.toString(),
  //           'verificationId': verificationId,
  //         });
  //       },
  //       verificationCompleted: (credential) {},
  //       verificationFailed: (ex) {
  //         log(ex.code.toString());
  //       },
  //       codeAutoRetrievalTimeout: (verificationId) {},
  //       timeout: Duration(seconds: 30));
  // }
}
