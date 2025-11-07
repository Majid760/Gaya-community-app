import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/view/splash/constant/boarding_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingSplashView extends StatefulWidget {
  const OnBoardingSplashView({Key? key}) : super(key: key);

  @override
  State<OnBoardingSplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<OnBoardingSplashView> {
  int? readdata;
  int? termsAndConditions;

  LocalStorage storage = LocalStorage();
  final Services _firebaseServices = Services();
  // animation (done by mak)
  final duration = const Duration(milliseconds: 2000);
  double iconSizeInitial = 250.0;
  double iconSizeFinal = 40.0;

  @override
  void initState() {
    readData();
    _navigateToPreferredScreen();
    // FirebaseMessaging.instance.getInitialMessage();»
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

    Routes.splashBrowse();

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
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1.0),
                      duration: duration,
                      curve: Curves.linear,
                      builder: (_, value, child) {
                        return Transform.translate(
                          offset: Offset(-(value * size.width / 2.8), -(value * size.height / 2.4)),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: iconSizeInitial, end: iconSizeFinal),
                            duration: duration,
                            curve: Curves.linear,
                            builder: (_, size, child) {
                              return Transform.rotate(
                                  angle: 0, child: Image.asset(Assets.assets.images.gayaLogo.path, height: size, width: size));
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 60,
                left: 44,
                child: SizedBox(
                  height: 150,
                  width: 260,
                  child: AnimatedTextKit(
                    repeatForever: false,
                    pause: duration,
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      ColorizeAnimatedText(OnBoardinString.discoverIC,
                          textStyle: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: kBlackColor),
                          colors: [gayaLogoColor, Colors.blue, Colors.yellow, Colors.red])
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
