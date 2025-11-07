import 'dart:convert';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/utils/flavors/flavors.dart';
import 'package:gaya/view/chat/utils/pref_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:universal_io/io.dart';

class ConnectyCubeNotification {
  static void subscribe({String? token}) async {
    debugPrint('[subscribe] token: $token');

    token ??= await FirebaseMessaging.instance.getToken();
    SharedPrefs sharedPrefs = await SharedPrefs.instance.init();

    CreateSubscriptionParameters parameters = CreateSubscriptionParameters();
    parameters.pushToken = token;

    bool isProduction = kIsWeb ? true : !F.isDev; // bool.fromEnvironment('dart.vm.product');
    parameters.environment = isProduction ? CubeEnvironment.PRODUCTION : CubeEnvironment.DEVELOPMENT;

    if (Platform.isAndroid || kIsWeb) {
      parameters.channel = NotificationsChannels.GCM;
      parameters.platform = CubePlatform.ANDROID;
    } else if (Platform.isIOS || Platform.isMacOS) {
      parameters.channel = NotificationsChannels.GCM;
      parameters.platform = CubePlatform.ANDROID;
      parameters.pushToken = token;
      parameters.environment = CubeEnvironment.PRODUCTION;
      parameters.bundleIdentifier = 'com.gaya.ios';
    }

    var deviceId = await PlatformDeviceId.getDeviceId;

    if (kIsWeb) {
      parameters.udid = base64Encode(utf8.encode(deviceId ?? ''));
    } else {
      parameters.udid = deviceId;
    }

    var packageInfo = await PackageInfo.fromPlatform();
    parameters.bundleIdentifier = packageInfo.packageName;

    debugPrint('parameters ${parameters.channel}');

    try {
      final cubeSubscription = await createSubscription(parameters.getRequestParameters());
      debugPrint('cubeSubscription $cubeSubscription');
      sharedPrefs.saveSubscriptionToken(token!);
      for (var subscription in cubeSubscription) {
        if (subscription.clientIdentificationSequence == token) {
          debugPrint('subscription.id ${subscription.id}');
          sharedPrefs.saveSubscriptionId(subscription.id!);
        }
      }
    } catch (e) {
      debugPrint('error at createSubscription $e');
    }
  }

  static void unsubscribe() {
    SharedPrefs.instance.init().then((sharedPrefs) {
      int subscriptionId = sharedPrefs.getSubscriptionId();
      if (subscriptionId != 0) {
        deleteSubscription(subscriptionId).then((voidResult) {
          FirebaseMessaging.instance.deleteToken();
          sharedPrefs.saveSubscriptionId(0);
        });
      }
    }).catchError((onError) {
      log('[unsubscribe] ERROR: $onError');
    });
  }
}
