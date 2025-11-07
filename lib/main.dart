import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/constant/string_constant.dart';
import 'package:gaya/shared/service/firebase_performance_services.dart';
import 'package:gaya/utils/flavors/flavors.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';

Future<void> main() async {
  F.appFlavor = Flavor.PROD;
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: Env.firebaseProject);
  } else {
    await Firebase.initializeApp();
  }

  // Invoking method to check whether user entered/opened the app for the first time
  getEntry();

  // Initializing crashlytics
  initCrashlytics();

  // Registering service locators
  serviceLocators();

  // Initializing firebase messaging (push notifications)
  await _initFirebaseMessaging();

  // Set preferred refresh rate to the max possible (the other OS may ignore this)
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  // Initializing firebase performance service
  PerformanceServices.init();

  // Initializing get storage (db)
  await GetStorage.init();

  runApp( const GayaApp());
}

/// Invoke to initialize firebase messaging (push notifications)
Future<void> _initFirebaseMessaging() async {
  if (!kIsWeb) {
    // await FcmHelper.initFcm();
    // FcmHelper.onNotificationClicked = (payload) {
    //   return FcmHelper.onNotificationSelected(payload);
    // };
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    await ScreenUtil.ensureScreenSize();
  }
}
