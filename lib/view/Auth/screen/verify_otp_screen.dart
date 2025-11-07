import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:gaya/view/Auth/widget/pin_input_field.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controller/app_config_controller.dart';
import '../../../scripts/delete_account_script.dart';
import '../../../services/notification/fcm_service.dart';
import '../../../shared/view/widget/gaya_back_button.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  static const id = 'VerifyPhoneNumberScreen';

  final String phoneNumber;
  final bool isDeleteProcess;

  const VerifyPhoneNumberScreen({Key? key, required this.phoneNumber, required this.isDeleteProcess}) : super(key: key);

  @override
  State<VerifyPhoneNumberScreen> createState() => _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> with WidgetsBindingObserver {
  bool isKeyboardVisible = false;
  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: const IconThemeData(color: kBlackColor),
          shape: const Border(bottom: BorderSide(color: kBaseGrey)),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          title: Text(widget.isDeleteProcess ? GayaStrings.delete_my_account.tr : GayaStrings.sign_up.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0),
      body: FirebasePhoneAuthHandler(
        phoneNumber: widget.phoneNumber,
        signOutOnSuccessfulVerification: false,
        sendOtpOnInitialize: true,
        linkWithExistingUser: false,
        autoRetrievalTimeOutDuration: const Duration(seconds: 60),
        otpExpirationDuration: const Duration(seconds: 60),
        onCodeSent: () {
          snackBar(context, '${GayaStrings.otp_code_sent.tr}${widget.phoneNumber}!', kprimaryColor, borderRadius: 8);
        },
        onLoginSuccess: (userCredential, autoVerified) async {
          try {
            if (widget.isDeleteProcess) {
              AccountDeletionServices.instance.deleteMyAccountPermenantly(credential: userCredential);

              Get.back();
              AppConfigurationController.to.resetOnLogInOrOut();
              Routes.loginView(clearPreviousRoutes: true);
              return;
            }
            snackBar(context, GayaStrings.number_verified_msg.tr, kprimaryColor, borderRadius: 8);
            final appUser = await Provider.of<LoginController>(context, listen: false).getUserById(userCredential.user?.uid);
            if (appUser != null) {
              UserModel.to.update(appUser);
              FirebaseMessagingService.instance.generateFcmToken();
              Routes.switchView();
            } else {
              Routes.askNameFieldView(fromPhoneProvider: true);
            }

            //
            // if (userCredential.user!.providerData.any((element) => element.providerId == 'password')) {
            //   snackBar(context, GayaStrings.already_linked.tr, kprimaryColor, borderRadius: 8);
            //   await Provider.of<LoginController>(context, listen: false).logout(context);
            //   Routes.loginView(clearPreviousRoutes: true);
            // } else {
            //   Routes.registerNameEmailPhone(phoneNumber: widget.phoneNumber);
            // }
          } catch (e) {
            debugPrint('error caught during opt login success!');
          }
        },
        onLoginFailed: (authException, stackTrace) => getCodeDesc(authException),
        onError: (error, stackTrace) => snackBar(context, GayaStrings.something_went_wrong.tr, kprimaryColor, borderRadius: 8),
        builder: (context, controller) {
          return ListView(
            padding: const EdgeInsets.all(20),
            controller: scrollController,
            children: [
              Text(GayaStrings.enter_code.tr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text("${GayaStrings.sent_code.tr} ${widget.phoneNumber}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93))),

              const SizedBox(height: 40),
              PinInputField(
                length: 6,
                // phoneNumber:
                onFocusChange: (hasFocus) async {
                  // if (hasFocus) await _scrollToBottomOnKeyboardOpen();
                },
                onSubmit: (enteredOtp) async {
                  final verified = await controller.verifyOtp(enteredOtp);
                  if (verified) {
                    // snackBar(context, 'Successfully login!', kprimaryColor);
                    // number verify success
                    // will call onLoginSuccess handler
                  } else {
                    // await controller.signOut();
                    // print('yes number fail done');
                    // snackBar(context, 'Invalid Otp! Please enter valid otp!', kprimaryColor);
                    // phone verification failed
                    // will call onLoginFailed or onError callbacks with the error
                  }
                },
              ),

              /// listening UI deprecated
              if (controller.isListeningForOtpAutoRetrieve) ...[
                /*     const SizedBox(height: 40),
                const Text(AuthString.listeningOTP,
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),*/
                const SizedBox(height: distance_50),
                controller.codeSent && !controller.isOtpExpired
                    ? Center(
                        child: RichText(
                            text: TextSpan(
                          children: [
                            TextSpan(text: GayaStrings.timeLeft.tr, style: const TextStyle(color: kBlackColor, fontSize: 16)),
                            TextSpan(
                                text: getRemainingTime(controller.otpExpirationTimeLeft),
                                style: const TextStyle(color: kprimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        )),
                      )
                    : const SizedBox.shrink(),
              ],
              // const SizedBox(height: 50),
              // controller.isSendingCode
              //     ? Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: const [
              //           CustomLoader(color: kprimaryColor),
              //           SizedBox(height: 50),
              //           Center(child: Text(AuthString.sendingOTP, style: TextStyle(fontSize: 25))),
              //         ],
              //       )
              //     : const SizedBox.shrink(),
              const SizedBox(height: 50),
              (controller.isOtpExpired && controller.codeSent)
                  ? Center(
                      child: RichText(
                          text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        children: [
                          TextSpan(text: GayaStrings.did_not_receive_an_otp.tr, style: const TextStyle(color: kBlackColor)),
                          TextSpan(
                            text: GayaStrings.resend_code.tr,
                            style: const TextStyle(color: kprimaryColor, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await controller.sendOTP();
                                // context.read<RegisterController>().fromSignUp = true;
                              },
                          ),
                        ],
                      )),
                    )
                  : const SizedBox.shrink(),
              // otp expiration time left
            ],
          );
        },
      ),
    );
  }

  String getRemainingTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds - (minutes * 60);
    return '  $minutes : $seconds  ';
  }

  void getCodeDesc(FirebaseAuthException authException) {
    switch (authException.code) {
      case 'invalid-phone-number':
        // invalid phone number
        snackBar(context, GayaStrings.invalid_phone_number.tr, kprimaryColor, borderRadius: 8);
        break;
      case "too-many-requests":
        snackBar(context, GayaStrings.too_many_request.tr, kprimaryColor, borderRadius: 8);
        break;
      case "session-expired":
        break;
      // return snackBar(context, 'Too many requests from same  device please try again later!', kprimaryColor);
      case 'invalid-verification-code':
        // invalid otp entered
        snackBar(context, GayaStrings.invalid_otp.tr, kprimaryColor, borderRadius: 8);
        break;
      // handle other error codes
      default:
        snackBar(context, GayaStrings.something_wrong.tr, kprimaryColor, borderRadius: 8);
      // snackBar(context, '${authException.code} \n ${authException.message}', kprimaryColor);
      // handle error further if needed
    }
  }
}

bool isNullOrBlank(String? data) => data?.trim().isEmpty ?? true;
