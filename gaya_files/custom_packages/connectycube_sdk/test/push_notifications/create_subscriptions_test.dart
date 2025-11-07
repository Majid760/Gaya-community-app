import 'package:connectycube_sdk/connectycube_pushnotifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'push_notifications_test_utils.dart';

Future<void> main() async {
  setUpAll(initCubeFramework);

  group("Tests CREATE subscriptions", () {
    test("testCreateSubscriptionAndroid", () async {
      await createTestSession();

      bool isProduction = bool.fromEnvironment('dart.vm.product');

      CreateSubscriptionParameters parameters = CreateSubscriptionParameters();
      parameters.environment = isProduction
          ? CubeEnvironment.PRODUCTION
          : CubeEnvironment.DEVELOPMENT;

      parameters.channel = NotificationsChannels.GCM;
      parameters.platform = CubePlatform.ANDROID;
      parameters.bundleIdentifier = "com.connectycube.flutter_sdk.test";

      String? deviceId = 'FD1F59BF7937EE786A128675E4571B958FA0';
      parameters.udid = deviceId;
      parameters.pushToken =
          'chh73lZtSamGJ41B4KdDoL:APA91bFkCN0rqvtFEBnwPv3Gs1dCRQzk8X0YmU1vvQ8yjaEa-E41Wl9HdZgGAqg32hVowcvRu_VziXlxnX1Dq2rY10lbKWi9VehlJ37aKz7HDLSdpesejJ1iy6v-qfY8t4sRjLt55ZJF';

      await createSubscription(parameters.getRequestParameters())
          .then((cubeSubscriptions) {
        log("Subscription created successfully. Subscriptions: $cubeSubscriptions",
            "CCM:createSubscription:success");
      }).catchError((error) {
        log("Error creation Subscription. Error: $error",
            "CCM:createSubscription:error");
      }).whenComplete(deleteSession);
    });
  });
}
