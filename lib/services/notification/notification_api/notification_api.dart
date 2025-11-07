import 'dart:convert';
import 'dart:developer';

import 'package:gaya/model/user.model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/flavors/flavors.dart';

abstract class NotificationApiCredentials {
  Future<bool> sendNotificationHttpsMethod(Map body) async {
    final Map<String, String> header = {
      'Authorization': 'key=${F.getFcmApiKey("NotificationApiCredentials")}',
      'Content-Type': 'application/json',
    };
    try {

      /// if there is no token, then return false
      if (body['to'].toString().isBlank == true) {
        log('FCM Token is null');
        return false;
      }
      final response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        body: jsonEncode(body),
        headers: header,
      );
      if (response.statusCode == 200) {
        // On success
        log('<=============Test Ok Push CFM=============>');
        log(response.body.toString());
        return true;
      } else {
        // On failure
        log('<=============CFM error=============>');
        log(response.body.toString());
        return false;
      }
    } catch (ex) {
      log("Inside Catch Statement");
      log("Exception caught $ex");
      return false;
    }
  }
}

class NotificationApiHitting extends NotificationApiCredentials {
  Future<bool> callOnFcmApiSendPushNotifications({required String gaya_message, required fcmToken, Map<String, String>? metadata}) async {
    Map customBody = {
      "to": fcmToken,
      "collapse_key": "type_a",
      "notification": {
        "body": gaya_message,
        "title": "Gaya",
        "sound": "default",
      },
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "android": {
        "notification": {"channel_id": "high_importance_channel"}
      },
      "apns": {
        "payload": {
          "aps": {
            "sound": "default",
          }
        }
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "body": gaya_message,
        "title": "Gaya",
        "content_available": true,
        "priority": "high",
        ...?metadata,
      },
    };

    // print(userDatas);

    return await sendNotificationHttpsMethod(customBody);
  }

  Future<bool> callOnFcmApiChat(FcmMessageModel fcmMessageModel) async {
    Map customBody = {
      "to": fcmMessageModel.receiverFcm,
      "collapse_key": "type_a",
      "notification": {
        "body": fcmMessageModel.messageContent,
        "title": fcmMessageModel.messageTitle,
        "sound": "default",
      },
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "android": {
        "notification": {"channel_id": "high_importance_channel"}
      },
      "apns": {
        "payload": {
          "aps": {
            "sound": "default",
          }
        }
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "body": fcmMessageModel.messageContent,
        "title": fcmMessageModel.messageTitle,
        "content_available": true,
        "priority": "high",
        "payload": {
          "senderProfilePicture": fcmMessageModel.myAppUser.profilePicture,
          "senderProfileUid": fcmMessageModel.myAppUser.uId,
          "senderProfileName": fcmMessageModel.myAppUser.name,
          "chatroomId": fcmMessageModel.chatroomId,
          "messageType": fcmMessageModel.messageType,
        }
      },
    };
    return await sendNotificationHttpsMethod(customBody);
  }

  Future<bool> callOnFcmApiForPostRelatedNotifications(FcmCreatePostModel fcmCreatePostModel) async {
    Map customBody = {
      "to": fcmCreatePostModel.receiverFcm,
      "collapse_key": "type_a",
      "notification": {
        "body": fcmCreatePostModel.messageContent,
        "title": fcmCreatePostModel.messageTitle,
      },
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "android": {
        "notification": {"channel_id": "high_importance_channel"}
      },
      "apns": {
        "payload": {
          "aps": {
            "sound": "default",
          }
        }
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "body": fcmCreatePostModel.messageContent,
        "title": fcmCreatePostModel.messageTitle,
        "content_available": true,
        "priority": "high",
        "payload": {
          "senderProfilePicture": fcmCreatePostModel.myAppUser.profilePicture,
          "senderProfileUid": fcmCreatePostModel.myAppUser.uId,
          "senderProfileName": fcmCreatePostModel.myAppUser.name,
          "postId": fcmCreatePostModel.postid,
          'communtiyId': fcmCreatePostModel.communityId,
          "messageType": fcmCreatePostModel.messageType,
        }
      },
    };

    return await sendNotificationHttpsMethod(customBody);
  }

  Future<bool> callOnFcmApiForCommunityNotifications(FcmCreateCommunityModel fcmcommunityModel) async {
    Map customBody = {
      "to": fcmcommunityModel.receiverFcm,
      "collapse_key": "type_a",
      "notification": {
        "body": fcmcommunityModel.messageContent,
        "title": fcmcommunityModel.messageTitle,
      },
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "android": {
        "notification": {"channel_id": "high_importance_channel"}
      },
      "apns": {
        "payload": {
          "aps": {
            "sound": "default",
          }
        }
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "body": fcmcommunityModel.messageContent,
        "title": fcmcommunityModel.messageTitle,
        "content_available": true,
        "priority": "high",
        "payload": {
          "communityId": fcmcommunityModel.communityId,
          "communityName": fcmcommunityModel.communityName,
          "communityDescription": fcmcommunityModel.communityDescription,
          "coverPicture": fcmcommunityModel.coverPicture,
          "CommunityPic": fcmcommunityModel.CommunityPic,
          "adminUid": fcmcommunityModel.adminUid,
          "messageType": fcmcommunityModel.messageType,
        }
      },
    };
    return await sendNotificationHttpsMethod(customBody);
  }

  Future<bool> callOnFcmApiForProfileNotifications(FcmUserModel fcmUserModel) async {
    Map customBody = {
      "to": fcmUserModel.receiverFcm,
      "collapse_key": "type_a",
      "notification": {
        "body": fcmUserModel.messageContent,
        "title": fcmUserModel.messageTitle,
      },
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "android": {
        "notification": {"channel_id": "high_importance_channel"}
      },
      "apns": {
        "payload": {
          "aps": {
            "sound": "default",
          }
        }
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "body": fcmUserModel.messageContent,
        "title": fcmUserModel.messageTitle,
        "content_available": true,
        "priority": "high",
        "payload": {
          "uId": fcmUserModel.uId,
          "name": fcmUserModel.name,
          "profilePicture": fcmUserModel.profilePicture,
          "messageType": fcmUserModel.messageType,
        }
      },
    };
    return await sendNotificationHttpsMethod(customBody);
  }
}

class FcmMessageModel {
  final String receiverFcm;
  final String messageTitle;
  final String messageContent;
  final String messageType;
  final String chatroomId;
  final UserModel myAppUser;

  FcmMessageModel({required this.chatroomId, required this.messageContent, required this.messageTitle, required this.receiverFcm})
      : messageType = "chatMessage",
        myAppUser = UserModel.to;
}

class FcmCreatePostModel {
  String? postid;
  String? communityId;
  final String receiverFcm;
  final String messageTitle;
  final String messageContent;
  final String messageType;
  final UserModel myAppUser;

  FcmCreatePostModel(
      {required this.postid,
      required this.messageContent,
      required this.messageTitle,
      required this.receiverFcm,
      required this.communityId})
      : messageType = "post",
        myAppUser = UserModel.to;
}

class FcmCreateCommunityModel {
  String? communityId;
  String? CommunityPic;
  String? communityDescription;
  String? communityName;

  // String? communityType;
  // int? communityMembers;
  // DateTime? createdon;
  String? coverPicture;
  String? adminUid;
  final String receiverFcm;
  final String messageTitle;
  final String messageContent;
  final String messageType;

  FcmCreateCommunityModel(
      {this.communityId,
      this.CommunityPic,
      this.communityDescription,
      this.communityName,
      // this.createdon,
      this.adminUid,
      this.coverPicture,
      required this.messageContent,
      required this.messageTitle,
      required this.receiverFcm})
      : messageType = "community";
}

class FcmUserModel {
  String? name;
  String? profilePicture;
  String? uId;
  final String receiverFcm;
  final String messageTitle;
  final String messageContent;
  final String messageType;

  FcmUserModel(
      {this.name, this.profilePicture, this.uId, required this.messageContent, required this.messageTitle, required this.receiverFcm})
      : messageType = "profile";
}
