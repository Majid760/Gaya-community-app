import 'dart:async';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/notification/cc_notif_manager.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:gaya/view/chat/utils/configs.dart' as config;
import 'package:gaya/view/chat/utils/pref_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../components/check_for_app_update.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  int? readdata;
  int? termsAndConditions;
  final Services _firebaseServices = Services();

  @override
  void initState() {
    readData();
    _navigateToPreferredScreen();
    super.initState();
  }

  final performance = PerformanceController.to.instance;

  ///Navigate to screen and load my app user
  _navigateToPreferredScreen() async {
    AnalyticsController.to.instance.setUserId(FirebaseAuth.instance.currentUser?.uid ?? "Guest");
    performance.startSplashLoadTime();
    dynamic futures = [
      AppConfigurationController.to.loadAppConfiguration(),
      Future.delayed(const Duration(seconds: 2)),
      _firebaseServices.getUserById(FirebaseAuth.instance.currentUser?.uid, forcefullyServer: true),
      //[don't add another function below this]
    ];
    if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
      futures.add(Provider.of<LoginController>(context, listen: false).connectyCubeLogin(
        context,
        CubeUser(
          login: FirebaseAuth.instance.currentUser?.uid,
          password: FirebaseAuth.instance.currentUser?.uid,
        ),
        saveUser: true,
      ));
    }
    List<dynamic> waitAndLoadMyAppUser = await Future.wait(futures);

    if (waitAndLoadMyAppUser[2] != null) {
      UserModel? myAppUser = waitAndLoadMyAppUser[2];
      UserModel.to.update(myAppUser);

      // CC
      if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
        try {
          await init(config.APP_ID, config.AUTH_KEY, config.AUTH_SECRET, onSessionRestore: () async {
            SharedPrefs sharedPrefs = await SharedPrefs.instance.init();
            CubeUser? user = sharedPrefs.getUser();
            return createSession(user);
          });
          // subscribe to connectyCube notification
          ConnectyCubeNotification.subscribe();
        } catch (_) {}
      }
    }

    performance.stopSplashLoadTime();
    Routes.switchView();
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
      body: Center(
        child: SizedBox(
          height: 205,
          width: double.infinity,
          child: Image.asset(Assets.assets.images.gayaLogo.path),
        ),
      ),
    );
  }
}
