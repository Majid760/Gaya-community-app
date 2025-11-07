import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/button.component.dart';
import '../../../utils/textstyles.dart';
import '../controller/login.controller.dart';

class EmailVerifiedSentView extends StatelessWidget {
  final Map<String, dynamic> args;
  const EmailVerifiedSentView({super.key, required this.args});
  @override
  Widget build(BuildContext context) {
    final logInController = Provider.of<LoginController>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Spacer(),
            const GradientIcon(
              Icons.email_outlined,
              100,
              LinearGradient(colors: <Color>[Color(0xFFFFB5F3), kprimaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            Center(
                child: Text(args['page'] == FromPage.login ? GayaStrings.email_sent_title.tr : GayaStrings.reset_password.tr,
                    style: CustomTypography.headingStyle24, textAlign: TextAlign.center)),
            const SizedBox(height: 20),
            Text(args['page'] == FromPage.login ? GayaStrings.email_sent_desc.tr : GayaStrings.reset_password_desc.tr,
                style: CustomTypography.secondaryFontStyleWeightHeightlow, textAlign: TextAlign.center),
            const Spacer(),
            GayaButton(
                onPressed: () async {
                  if (args['page'] == FromPage.login) {
                    try {
                      logInController.resetIsEmailField();
                      User? user = logInController.authUser;
                      if (user != null) {
                        await user.reload();
                        user = logInController.authUser;
                        if (user?.emailVerified ?? false) {
                          Routes.splash();
                        } else {
                          await logInController.logout(context);
                          Routes.loginView(clearPreviousRoutes: true);
                        }
                      } else {
                        await logInController.logout(context);
                        Routes.loginView(clearPreviousRoutes: true);
                      }
                      // This code listens for changes to the user's FirebaseUser object and prints whether the email is verified or not. You can use this code to update your UI or perform any other actions based on the emailVerified status.
                    } catch (e) {
                      await logInController.logout(context);
                      Routes.loginView(clearPreviousRoutes: true);
                    }
                  } else if (args['page'] == FromPage.resetPassword) {
                    logInController.resetIsEmailField();
                    SchedulerBinding.instance.addPostFrameCallback((_) async {
                      await FirebaseAuth.instance.signOut();
                      Routes.loginView(clearPreviousRoutes: true);
                    });
                  } else {}
                },
                height: 48,
                title: AuthString.continueBtn,
                borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
                primaryColor: AppColors.primary,
                textStyle: CustomTypography.body4StyleWhite),
            const SizedBox(height: 20),
            ResendEmailRow(isResetPassword: args['page'] == FromPage.resetPassword, logInController: logInController),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ResendEmailRow extends StatelessWidget {
  // final UserCredential userCredentials;
  final bool isResetPassword;
  const ResendEmailRow({
    required this.isResetPassword,
    Key? key,
    required this.logInController,
  }) : super(key: key);
  final dynamic logInController;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(text: '${GayaStrings.did_not_get_it.tr} ', style: CustomTypography.secondaryFontStyle, children: [
        TextSpan(
          text: GayaStrings.resend_email.tr,
          style: CustomTypography.body4KStylePrimary,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (isResetPassword) {
                await logInController.resetPassword(context: context, isResend: true);
              } else {
                await logInController.sendVerificationEmail(context: context);
              }
            },
        ),
      ]),
    );
  }
}

class GradientIcon extends StatelessWidget {
  const GradientIcon(this.icon, this.size, this.gradient, {super.key});

  final IconData icon;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.2,
        child: Icon(icon, size: size, color: kWhiteColor),
      ),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 20, 150, size);
        return gradient.createShader(rect);
      },
    );
  }
}
