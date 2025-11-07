import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

class InAppNotificationWatcher {
  static InAppNotificationWatcher? _instance;

  static InAppNotificationWatcher get instance {
    _instance ??= InAppNotificationWatcher._init();

    return _instance!;
  }

  InAppNotificationWatcher._init();

  final InAppNotificationUtils _utils = InAppNotificationUtils();

  /// Watches for in app notification (onListen method of FirebaseMessaging)
  /// * [message] is the notification payload
  /// It will perform the action based on the notification type (messageType in payload)
  /// If the notification type is not found, it will do nothing.
  ///
  /// Purpose of this method is to watch for in app notification and perform the action based on the notification type
  /// directly from the stream for better fluency.
  void watchInAppNotification(RemoteMessage? message) {
    debugPrint("watchInAppNotification: ${message?.notification?.title}");
    final payload = message?.data["payload"];
    final messageType = _utils.getNotificationType(payload?["messageType"]);
    if (messageType == null) return;

    switch (messageType) {
      case NotificationType.postCommented:
      case NotificationType.postLiked:
      case NotificationType.postCrowned:
      case NotificationType.communityPostRequest:
      case NotificationType.communityJoiningRejected:
      case NotificationType.friendRequest:
        break;
      // case NotificationType.communityJoiningrequest:
      case NotificationType.community:
        {
          debugPrint("Notification type:  community");

          /// check if notification is Approved joining request in community
          if (_utils.isCommunityRequestApprovedNotification(message?.notification?.title)) {
            final communityId = payload?["communityId"];

            _utils.onCommunityJoiningRequestAccept(communityId);
          } else {
            debugPrint("It wasn't a community request approved notification");
          }
        }
        break;

      default:
        break;
    }
  }
}

//// All Possible Notification Types
enum NotificationType {
  postCrowned,
  communityPostRequest,
  communityJoiningrequest,
  communityJoiningRejected,
  friendRequest,
  postCommented,
  postLiked,
  post,
  community,
  chatMessage,
  profile,
}

class InAppNotificationUtils {
  NotificationType? getNotificationType(String? notification) {
    switch (notification) {
      case "post":
        return NotificationType.post;
      case "community":
        return NotificationType.community;
      case "chatMessage":
        return NotificationType.chatMessage;
      case "profile":
        return NotificationType.profile;
      case "postCommented":
        return NotificationType.postCommented;
      case "postLiked":
        return NotificationType.postLiked;
      case "postCrowned":
        return NotificationType.postCrowned;
      case "communityPostRequest":
        return NotificationType.communityPostRequest;
      case "communityJoiningrequest":
        return NotificationType.communityJoiningrequest;
      case "communityJoiningRejected":
        return NotificationType.communityJoiningRejected;
      case "friendRequest":
        return NotificationType.friendRequest;

      default:
        return null;
    }
  }

  /// Directly add the user's to the community to [AppConfigurationController.to.userCommunities]
  /// this action is performed when the user accepts the community joining request - Local Action
  void onCommunityJoiningRequestAccept(String? communityId) {
    debugPrint("onCommunityJoiningRequestAccept called: $communityId");
    if (communityId.isBlank == true) return;
    AppConfigurationController.to.joinACommunity(Community.id(communityId: communityId!));
  }

  /// Checks if the notification is a community request notification
  /// * [notification] is the notification title from the payload
  /// * returns true if the notification is a community request notification
  bool isCommunityRequestApprovedNotification(String? notification) {
    return Locales.en_US[GayaStrings.requested_approved] == notification || Locales.he_IL[GayaStrings.requested_approved] == notification;
  }
}
