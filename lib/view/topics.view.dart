import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/view/feed/controller/base/base_feed_impl.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/topics.controller.dart';
import '../model/topic.model.dart';
import '../utils/local.storage.dart';
import '../utils/textstyles.dart';
import '../utils/theme/button_styles.dart';
import '../widgets/topic_view_widgets/interest.widget.dart';

class TopicsView extends StatefulWidget {
  const TopicsView({Key? key}) : super(key: key);

  @override
  State<TopicsView> createState() => _TopicsViewState();
}

class _TopicsViewState extends State<TopicsView> {
  LocalStorage storage = LocalStorage();
  int? readdata;
  int? termsAndConditions;
  TextEditingController textController = TextEditingController();
  final GlobalKey<FormState> _reportFormKey = GlobalKey<FormState>();
  GetInterestStorageController getStorage = Get.find<GetInterestStorageController>();
  late TopicsController topicController;

  @override
  void initState() {
    topicController = Provider.of<TopicsController>(context, listen: false);
    readTermsAndConditionFromLocalSorage();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (getStorage.getInterestList()?.isEmpty ?? true) {
      List items = topicController.selectedItems.map((e) => e.toMap()).toList();
      getStorage.storeInterestList(recentInterests: items);
    }
    textController.dispose();
  }

  Future readTermsAndConditionFromLocalSorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    termsAndConditions = preferences.getInt('termsAndConditions');
    readdata = preferences.getInt('initScreen');
    // await preferences.setInt('initScreen', 1);

    if (termsAndConditions == null || termsAndConditions == 0) {
      if (!mounted) return;
      androidAlertDialog(context);
    } else {
      setTermsAndConditionIntoLocalSorage();
    }
  }

  Future setTermsAndConditionIntoLocalSorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt('termsAndConditions', 1);
    await preferences.setInt('initScreen', 1);
    termsAndConditions = preferences.getInt('termsAndConditions');
    readdata = preferences.getInt('initScreen');
    setState(() {
      termsAndConditions = 1;
      readdata = 1;
    });
    log(termsAndConditions.toString());
  }

  @override
  Widget build(BuildContext context) {
    final topicController = Provider.of<TopicsController>(context, listen: true);
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: distance_15).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(GayaStrings.interested_in.tr, style: CustomTypography.headingStyle),
          const SizedBox(height: distance_5),
          Padding(
            padding: const EdgeInsets.only(right: distance_50),
            child: Text(GayaStrings.select_interests.tr, style: CustomTypography.body1Style),
          ),
          const SizedBox(height: distance_15),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Wrap(
                direction: Axis.horizontal,
                runAlignment: WrapAlignment.start,
                runSpacing: distance_15,
                spacing: distance_15,
                children: List.generate(topicController.topics.length + 1, (index) {
                  late TopicsModel currentTopic;
                  if (index != topicController.topics.length) {
                    currentTopic = topicController.topics[index];
                  }
                  return (index != topicController.topics.length)
                      ? InterestWidget(
                          textstyle: topicController.selectedList.contains(currentTopic)
                              ? CustomTypography.body4KStylePrimary
                              : CustomTypography.secondaryFontStyle,
                          horizontalDistance: distance_15,
                          image: currentTopic.image,
                          title: currentTopic.title,
                          color: topicController.selectedList.contains(currentTopic) ? kprimaryColorLight : kBaseGrey,
                          onTap: () {
                            if (!topicController.selectedItems.contains(currentTopic)) {
                              // if (topicController.selectedList.length < 4) {
                              context.read<TopicsController>().addTopics(currentTopic);
                              context.read<TopicsController>().addTitles(currentTopic);
                              // }
                              log(topicController.selectedList.length.toString());
                            } else {
                              context.read<TopicsController>().removeTopics(currentTopic);
                              context.read<TopicsController>().removeTitles(currentTopic);
                            }
                          })
                      : InkWell(
                          onTap: () {
                            reportTextFieldBottomModal(context, topicController, textController, _reportFormKey);
                            textController.clear();
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kBaseGrey,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: kSecondaryColor,
                            ),
                          ),
                        );
                }),
              ),
            ),
          ),
          SizedBox(height: MySpaces.gap1.h),
          GayaButton(
              height: 50.h,
              borderColor: kTransparentColor,
              width: double.infinity,
              title: GayaStrings.continue_txt.tr,
              // topicController.selectedList.isEmpty
              //     ?
              //     //  '0 out of 4'
              //     '0'
              //     : '${topicController.selectedList.length.toString()} ',
              // out of 4,
              textStyle: CustomTypography.body2Style,
              primaryColor: topicController.selectedList.isEmpty ? kSecondaryColor : kprimaryColor,
              onPressed: topicController.selectedList.isEmpty
                  ? null
                  : () async {
                      if (termsAndConditions == 1) {
                        List<Map<String, dynamic>> interests = [];
                        for (var topic in topicController.selectedList) {
                          interests.add({'icon': topic.image, 'title': topic.title});
                        }
                        await topicController.updateIntrest(context: context, intrests: interests);

                        /// reresh home feed
                        FeedControllerUtils.resetController();
                        Get.back();
                        /*Navigator.of(context).pushReplacementNamed(route.switchView);*/
                      } else {
                        androidAlertDialog(context);
                      }

                      // topicController.selectedList.clear();
                    }),
          const SizedBox(height: distance_10),
          Container(
            alignment: Alignment.center,
            child: TextButton(
                style: GayaButtonStyles.actionRowTextButtonStyle2,
                onPressed: () async {
                  if (termsAndConditions == 1) {
                    await storage.writeBool(storage.interestUiKey, true);
                    context.read<TopicsController>().getTitlesSelected.clear();
                    // Routes.switchView();
                    Get.back();
                    /*Navigator.of(context).pushReplacementNamed(route.switchView);*/
                  } else {
                    androidAlertDialog(context);
                  }

                  // context.read<RegisterController>().fromSignUp == true
                  //     ? {
                  //         (FirebaseAuth.instance.currentUser == null)
                  //             ? {
                  //                 Navigator.of(context).pushReplacementNamed(route.switchView),
                  //                 context.read<RegisterController>().fromSignUp = true,
                  //               }
                  //             : {
                  //                 Navigator.of(context).pushReplacementNamed(route.emailSent, arguments: {
                  //                   'isFromLogn': false,
                  //                 }),
                  //                 FirebaseAuth.instance.signOut(),
                  //               },
                  //       }
                  // : {
                  //         Navigator.of(context).pushReplacementNamed(route.switchView),
                  //         context.read<RegisterController>().fromSignUp = true,
                  //       };
//waqar privacy policy work
                  //        topicController.getTitlesSelected.clear();

                  //        await storage.writeData(storage.interestUiKey, true);

                  //       if (termsAndConditions == 1) {
                  //      context.read<TopicsController>().getTitlesSelected.clear();
                  //      context.read<RegisterController>().fromSignUp == true
                  //         ? {
                  //             (FirebaseAuth.instance.currentUser == null)
                  //                 ? {
                  //                    Navigator.of(context).pushReplacementNamed(route.switchView),
                  //                    context.read<RegisterController>().fromSignUp = true,
                  //                }
                  //              : {
                  //                Navigator.of(context).pushReplacementNamed(route.emailSent, arguments: {
                  //                 'isFromLogn': false,
                  //               }),
                  //              FirebaseAuth.instance.signOut(),
                  //         },
                  //   }
                  //  : {
                  //      Navigator.of(context).pushReplacementNamed(route.switchView),
                  //       context.read<RegisterController>().fromSignUp = true,
                  //      };
                  //  topicController.getTitlesSelected.clear();
//await storage.writeData(storage.interestUiKey, true);
                  //} else {
                  //    (!Platform.isIOS) ? androidAlertDialog(context) : iosalertDialog(context);
//}
                },
                child: Text(
                  GayaStrings.skip_btn.tr,
                  style: CustomTypography.secondaryFontStyle,
                )),
          ),
          SizedBox(height: MySpaces.gap3.h),
        ],
      ),
    );
  }

/*  Future<dynamic> iosalertDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        content: RichText(
          textScaleFactor: 1.2,
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'By tapping "Agree and Continue", You agree to our ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            children: [
              TextSpan(
                text: 'Terms of Service ',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Methods.launchMyUrl("https://www.gaya.app/terms", context: context, showConfirmationToOpenLink: false);
                  },
                style: const TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              TextSpan(
                text: 'and acknowledge that you have read our ',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              TextSpan(
                text: 'Privacy Policy ',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Methods.launchMyUrl("https://www.gaya.app/privacy", context: context, showConfirmationToOpenLink: false);
                  },
                style: const TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              TextSpan(
                text: 'to learn our data policies.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text(
              'Agree and Continue',
              style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            onPressed: () {
              setTermsAndConditionIntoLocalSorage();
              Get.back();
              */ /*Navigator.pop(context);*/ /*
            },
          ),
        ],
      ),
    );
  }*/

  Future<dynamic> androidAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 18, right: 18, top: 17, bottom: 0).r,
        actionsPadding: const EdgeInsets.only(
          left: 18,
          right: 18,
        ).r,
        content: RichText(
          textScaleFactor: 1.2,
          textAlign: TextAlign.center,
          text: TextSpan(
            text: GayaStrings.by_tapping_agree_dash.tr,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp, height: 1.57),
            children: [
              TextSpan(
                text: GayaStrings.terms_of_service_dash.tr,
                recognizer: TapGestureRecognizer()..onTap = () => Methods.openTermsAndConditions(context),
                style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13.sp, height: 1.57),
              ),
              TextSpan(
                text: GayaStrings.and_ack_that_you_read_dash.tr,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp, height: 1.57),
              ),
              TextSpan(
                text: GayaStrings.privacy_policy_dash.tr,
                recognizer: TapGestureRecognizer()..onTap = () => Methods.openPrivacyPolicy(context),
                style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13.sp, height: 1.57),
              ),
              TextSpan(
                text: GayaStrings.to_learn_about_privacy_dot.tr,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp, height: 1.57),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          SizedBox(height: 15.h),
          GayaButton(
            title: GayaStrings.agree_continue.tr,
            height: 40.h,
            textStyle: const TextStyle(color: kWhiteColor),
            primaryColor: kprimaryColor,
            borderColor: kprimaryColor,
            onPressed: () {
              setTermsAndConditionIntoLocalSorage();
              Get.back();
              /*Navigator.pop(context);*/
            },
          ),
          SizedBox(height: 15.h)
        ],
      ),
    );
  }

  reportTextFieldBottomModal(
      BuildContext context, TopicsController controller, TextEditingController textEditController, dynamic reportFormKey) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          width: MediaQuery.sizeOf(context).width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
          ),
          child: Form(
            key: reportFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: const ShapeDecoration(color: kBaseGrey, shape: StadiumBorder()),
                  ),
                ),
                const SizedBox(height: distance_10),
                Text("Have an interest suggestion?", style: CustomTypography.secondaryFontStyleWeight.copyWith(color: kBlackColor)),
                const SizedBox(height: distance_20),
                textField(
                    controller: textEditController,
                    maxlines: 1,
                    borderColor: borderColor,
                    isPassword: false,
                    autovalidateModel: AutovalidateMode.onUserInteraction,
                    inputType: TextInputType.text,
                    validation: (value) {
                      if (value.toString().trim().isEmpty) {
                        return "Please enter your suggestion";
                      }
                      return null;
                    },
                    onChanged: (value) {},
                    hintTextStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF8E8E93)),
                    hintText: "Enter your suggestion here"),
                const SizedBox(height: 10),
                GayaButton(
                    title: GayaStrings.send_txt.tr,
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (reportFormKey.currentState!.validate()) {
                        await controller.sendNewInterestSuggestion(context, interest: textEditController.text);
                        textEditController.clear();
                        Get.back();
                        /* Navigator.pop(context);*/
                      }
                    },
                    borderColor: kTransparentColor,
                    height: 50,
                    primaryColor: kprimaryColor,
                    textStyle: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.w500, fontSize: 14),
                    width: MediaQuery.sizeOf(context).width)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// await showOkAlertDialog(
//   context: context,
//   barrierDismissible: false,
//   builder: (context, child) {
//     return AlertDialog(
//       contentPadding: EdgeInsets.only(left: 18, right: 18, top: 24),
//       content: RichText(
//         textScaleFactor: 1.2,
//         textAlign: TextAlign.center,
//         text: TextSpan(
//           text: 'By tapping "Agree and Continue", You agree to our ',
//           style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//           children: [
//             TextSpan(
//               text: 'Terms of Service ',
//               style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13),
//             ),
//             TextSpan(
//               text: 'and acknowledge that you have read our ',
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//             ),
//             TextSpan(
//               text: 'Privacy Policy ',
//               style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 13),
//             ),
//             TextSpan(
//               text: 'to learn our data policies.',
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           child: Text(
//             'Agree and Continue',
//             style: TextStyle(color: kBlackColor, fontWeight: FontWeight.w600, fontSize: 16),
//           ),
//           onPressed: () {
//             setTermsAndConditionIntoLocalSorage();
//             Navigator.pop(context);
//           },
//         )
//       ],
//     );
//   },
// );
