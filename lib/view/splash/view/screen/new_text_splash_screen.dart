import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'splash_animated_background_screen.dart';

class NewTextSplashScren extends StatefulWidget {
  const NewTextSplashScren({Key? key}) : super(key: key);

  @override
  State<NewTextSplashScren> createState() => _NewTextSplashScrenState();
}

class _NewTextSplashScrenState extends State<NewTextSplashScren> {
  int? readdata;
  int? termsAndConditions;

  LocalStorage storage = LocalStorage();
  final Services _firebaseServices = Services();
  List<String> stringList = [
    'Action TV Shows Anime Netflix',
    'Munch Food Cooking Baking Baking',
    'Games Music K-pop Taylor Rap',
    'Romance Relationships Dating Advice Games',
    'Tennis Sports Basketball Socker',
    'Xbox Gaming D&D Playstation',
    'Hiking Travel & Outdoor Road Trips Places',
    'Sketch Art & Design Illustrations Games',
    'Together Just Chatting Friends Games'
  ];

  @override
  void initState() {
    readData();
    _navigateToPreferredScreen();
    super.initState();
  }

  ///Navigate to screen and load my app user
  _navigateToPreferredScreen() async {
    List<dynamic> waitAndLoadMyAppUser = await Future.wait([
      AppConfigurationController.to.loadAppConfiguration(),
      Future.delayed(const Duration(seconds: 4)),
      _firebaseServices.getUserById(FirebaseAuth.instance.currentUser?.uid),
      //[dont add another function below this]
    ]);
    if (waitAndLoadMyAppUser.last != null) {
      UserModel? myAppUser = await _firebaseServices.getUserById(FirebaseAuth.instance.currentUser?.uid);
      UserModel.to.update(myAppUser);
    }

    Routes.openNewSplashWelcomeScreen();

//     if (readdata == null || readdata == 0 || termsAndConditions == null || termsAndConditions == 0) {
//       Routes.topicView();
//       //Navigator.of(context).pushReplacementNamed(route.topics);
//     } else {
//       /**/
//       Routes.splashBrowse();
//       // Routes.switchView();
// /*
//       Navigator.pushReplacementNamed(context, route.switchView);
// */
//     }
  }

  Future readData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    readdata = preferences.getInt('initScreen');
    termsAndConditions = preferences.getInt('termsAndConditions');
    // await preferences.setInt('initScreen', 1);
    // log(readdata.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(top: -25, left: 0, right: 0, bottom: 0, child: OnboardingV2()),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.separated(
                    itemCount: stringList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 120.h, bottom: 56.h),
                    itemBuilder: (BuildContext context, int index) {
                      List<String> splittedString = stringList[index].split(' ');
                      return RichText(
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        text: TextSpan(
                            text: (index == 4 ? " " : '') + '${splittedString.first.substring(splittedString.first.length - 2)} ',
                            style: GayaTypography.h1.copyWith(
                                fontSize: 32.sp, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.black.withOpacity(0.2)),
                            children: <TextSpan>[
                              TextSpan(
                                  text: (index == 6 || index == 7)
                                      ? '${splittedString[1]}  ${splittedString[2]}  ${splittedString[3]} '
                                      : index == 8
                                          ? ' ${splittedString[1]} ${splittedString[2]} '
                                          : "${splittedString[1]} ",
                                  style: GayaTypography.h1
                                      .copyWith(fontSize: 32.sp, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.white),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // navigate to desired screen
                                    }),
                              TextSpan(
                                text: (index == 6 || index == 7)
                                    ? splittedString.sublist(4).join(' ')
                                    : index == 8
                                        ? splittedString.sublist(3).join(' ')
                                        : splittedString.sublist(2).join(' '),
                                style: GayaTypography.h1.copyWith(
                                    fontSize: 32.sp, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.black.withOpacity(0.2)),
                              )
                            ]),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 8.h);
                    },
                  ),
                  SizedBox(
                      width: 310.w,
                      child: RichText(
                        text: TextSpan(
                          text: GayaStrings.community_for_you.tr,
                          style:
                              GayaTypography.h1.copyWith(fontSize: 40.sp, fontWeight: FontWeight.w700, height: 1, color: AppColors.white),
                          children: const <TextSpan>[TextSpan(text: ' 😊')],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
