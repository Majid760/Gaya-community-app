// /*
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
//
// import '../../../components/button.component.dart';
// import '../../../components/textfield.component.dart';
// import '../controller/login.controller.dart';
// import '../../../utils/const.dart';
// import '../../../utils/textstyles.dart';
// import '../../../utils/vallidation.dart';
//
// class ForgotPasswordPhoneView extends StatefulWidget {
//   final String phoneNumber;
//   final String verificationId;
//
//   const ForgotPasswordPhoneView({Key? key, required this.phoneNumber, required this.verificationId}) : super(key: key);
//
//   @override
//   State<ForgotPasswordPhoneView> createState() => _ForgotPasswordPhoneViewState();
// }
//
// class _ForgotPasswordPhoneViewState extends State<ForgotPasswordPhoneView> {
//   final validation = FormValidation();
//
//   @override
//   Widget build(BuildContext context) {
//     final resetController = Provider.of<LoginController>(context, listen: true);
//
//     return Scaffold(
//       appBar: getAppBar(),
//       body: getbody(validation, resetController, context),
//     );
//   }
//
// //Appbar
//   PreferredSizeWidget getAppBar() {
//     return AppBar(
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       shape: Border(
//           bottom: BorderSide(
//         color: kBaseGrey.withOpacity(0.25),
//       )),
//       iconTheme: const IconThemeData(color: kBlackColor),
//       title: const Text(
//         'Reset Password',
//         style: CustomTypography.bodyStyle,
//       ),
//       centerTitle: true,
//       backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
//       elevation: 0,
//     );
//   }
//
// //body
//   Widget getbody(FormValidation validation, LoginController resetController, BuildContext context) {
//     log("verification id is : ${widget.verificationId}");
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: distance_20),
//       child: Form(
//         key: resetController.resetPasswordFormKey,
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         child: SingleChildScrollView(
//           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(
//                 height: distance_20,
//               ),
//               Container(
//                 padding: const EdgeInsets.only(right: distance_25),
//                 width: double.infinity,
//                 child: Text('Enter the 6-digit code we just texted to your phone number, ${widget.phoneNumber}.', style: CustomTypography.body1Style),
//               ),
//               const SizedBox(
//                 height: distance_20,
//               ),
//               const Text('Code', style: CustomTypography.body4Style),
//               const SizedBox(
//                 height: distance_10,
//               ),
//               textField(
//                   onChanged: (value) {
//                     // resetController.verifyPasswordOnChange(value, context);
//                     resetController.codeentered(value);
//                   },
//                   counter: const Text(''),
//                   maxlength: 6,
//                   borderColor: borderColor,
//                   isPassword: false,
//                   inputType: TextInputType.number,
//                   validation: validation.verifyPhone,
//                   controller: resetController.otpController,
//                   hintText: '6-digit code from SMS'),
//               const SizedBox(
//                 height: distance_20,
//               ),
//               resetController.isLoading
//                   ? const Center(child: CircularProgressIndicator.adaptive())
//                   : button(
//                       height: 50,
//                       borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
//                       textStyle: resetController.isCodeEntered
//                           ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
//                           : const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
//                       title: 'Verify',
//                       onPressed: () async {
//                         // Navigator.pushNamed(context, route.createNewPassword);
//                         if (resetController.resetPasswordFormKey.currentState!.validate()) {
//                           await resetController.verifyOtp();
//
//                         } else {}
//                       },
//                       primaryColor: resetController.isCodeEntered ? kprimaryColor : Colors.grey.shade200,
//                     ),
//               const SizedBox(
//                 height: 10,
//               ),
//               button(
//                 height: 50,
//                 borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
//                 textStyle: CustomTypography.secondaryFontStyleBig,
//                 title: 'Resend code',
//                 primaryColor: kBaseGrey,
//                 onPressed: () async {
//                   await resetController.resendOtp();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// */
