import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/service/firebase_performance_services.dart';
import 'package:gaya/utils/flavors/flavors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
//Pushing to tag release
Future<void> main() async {
  F.appFlavor = Flavor.DEV;

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  getEntry();
  //crashlytics
  initCrashlytics();
  //register service locators
  serviceLocators();
  // init connectycube and create session with or without login user
  //
  // await FcmHelper.initFcm();
  // // await PushNotificationsManager.instance.init();
  // FcmHelper.onNotificationClicked = (payload) {
  //   return FcmHelper.onNotificationSelected(payload);
  // };
  // SubscribeToCommunity().subscribeToTopics();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await GetStorage.init();
  await ScreenUtil.ensureScreenSize();
  PerformanceServices.init();
  // ApplyToCommunity().applyToCommunity('1163d610-8f4e-11ed-af30-83d11c1c3a22');

  debugPrint("LoggedIn UserId: ${FirebaseAuth.instance.currentUser?.uid}");
  initializeDateFormatting().then((_) => runApp(const GayaApp()));
}
