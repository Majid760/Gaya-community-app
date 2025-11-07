import 'package:flutter/foundation.dart';

import '../../shared/constant/string_constant.dart';

enum Flavor {
  DEV,
  PROD,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  /// Firebase Cloud Messaging API Key
  static String  getFcmApiKey(String calledFrom) {
    debugPrint('flavor name=getFcmApiKey $calledFrom >>: ${appFlavor?.name ?? ''}');
    // return Env.fcmDebugServerKey;
    switch (appFlavor) {
      case Flavor.DEV:
        return Env.fcmDebugServerKey;
      default:
        return Env.fcmServerKey;
    }
  }

  static bool get isDev => appFlavor == Flavor.DEV;

  static String get getDynamicLinkBaseUrl {
    switch (appFlavor) {
      case Flavor.DEV:
        return Env.kDynamicLinkDebugBaseUrl;
      default:
        return Env.kDynamicLinkBaseUrl;
    }
  }
}
