//contains the implementation of the methods for the notificiation services interface
import 'package:flutter/foundation.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:get/get.dart';

import '../../../../model/user.model.dart';
import '../../../../services/notification/notification_api/notification_api.dart';
import '../../../../services/services.dart';
import '../../../../utils/logger.dart';

mixin PostNotificationImpl {
  final _commonServices = Services();
  final _notificationApiHitting = NotificationApiHitting();

  NotificationApiHitting get notificationApi => _notificationApiHitting;

  Future<void> sendLikeNotification(
      {required String postId, required UserModel user, required String communityId, required String type}) async {
    final myAppUser = UserModel.to;
    //don't send notification if the user is the same.
    if (myAppUser.uId == user.uId) {
      MyLoggerServices.to.print("user is same");
      return;
    }

    //send fcm notification
    // await _notificationApiHitting.callOnFcmApiSendPushNotifications(gaya_message: postIsLikedNotification, fcmToken: user.fm_token);

    UserModel? userData = await _commonServices.getUserById(user.uId, forcefullyServer: true);
    String reactionData = Methods.getEmojiByType(type);

    if (userData?.uId == null) return;
    final fcmPostModel = FcmCreatePostModel(
      postid: postId,
      communityId: communityId,
      // messageContent: "${myAppUser.name} ${GayaStrings.dash_reacted_your_post.tr}",
      messageContent: "${myAppUser.name} ${GayaStrings.vibed_with.tr} '$reactionData' ${GayaStrings.to_your_post.tr}",
      messageTitle: GayaStrings.post_is_vibed_notification.tr,
      receiverFcm: userData?.fm_token ?? '',
    );

    debugPrint("sendLikeNotification FCM");
    _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel);

    debugPrint("ADD Notification in-app");

    //add into user's table.
    await _commonServices.addNotification(
        isRead: false,
        posId: postId,
        // body: "${myAppUser.name} ${GayaStrings.dash_reacted_your_post.tr}",
        body: "${myAppUser.name} ${GayaStrings.vibed_with.tr} '$reactionData' ${GayaStrings.to_your_post.tr}",
        title: GayaStrings.post_is_vibed_notification.tr,
        receiverUserID: user.uId!,
        senderId: myAppUser.uId ?? "",
        time: DateTime.now().toString(),
        type: type,
        userImage: myAppUser.profilePicture ?? "");
    MyLoggerServices.to.print("notification sent to ${user.name} for post $postId type: postLiked");
  }
}
