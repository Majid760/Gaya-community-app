import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

import 'navigation_utils.dart';

class NotificationApiController {
  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(NotificationResponse receivedAction) async {
    print("payload recieved=> ${receivedAction.payload}");
    if (receivedAction.payload == null) return;
    Map<String, dynamic> decodedPayload = jsonDecode(receivedAction.payload.toString());
    // Your code goes here
    print("init catched for onActionReceivedMethod. ");

    if (decodedPayload["payload"] != null) {
      decodedPayload = jsonDecode(decodedPayload["payload"].toString());
    }

    navigate(decodedPayload["messageType"], decodedPayload);
  }

  static final Debouncer _onNavigateDebounce = Debouncer(delay: const Duration(milliseconds: 500));

  static void navigate(String? messageType, NotificationPayload payload) {
    print("👇🏻 PAYLOAD");
    MyLoggerServices.to.print(payload);
    _onNavigateDebounce(() {
      if (messageType == 'chatMessage' || payload?["dialog_id"] != null) {
        NotificationNavigationService.navigateToChatroom(payload);
      } else if (messageType == 'post') {
        NotificationNavigationService.navigateToPost(payload);
      } else if (messageType == 'community') {
        NotificationNavigationService.navigateToCommunity(payload);
      } else if (messageType == 'profile') {
        NotificationNavigationService.navigateToProfile(payload);
      }
    });
  }
}
