//**
///
// Shifted to Local Notifications
//
//**

import 'dart:convert';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/other_user_profile/views/other.user.profile.dart';
import 'package:get/get.dart';

import '../../model/chatroom.model.dart';
import '../../view/messaging/personmessages.view.dart';

typedef NotificationPayload = Map<String, dynamic>?;

// class to navigate on notification click action
class NotificationNavigationService {
  static Future<void> navigateToChatroom(NotificationPayload payload) async {
    // showAlertDialog(Get.context!, 'isFromDeepLink', ChatController.to().currentUser ?? CubeUser(login: '321', password: '321'));

    if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
      Map<String, dynamic> params = {};
      params['dialogId'] = payload?['dialog_id'] ?? '123';
      final chats = await getDialogs(params);
      if (chats == null) return;
      final chatModel = chats.items.first;
      print(ChatController.to().currentUser);
      if (ChatController.to().currentUser == null) {
        Fluttertoast.showToast(msg: 'Error ${ChatController.to().currentUser}');
        return;
      }
      Get.toNamed(
        RouteHelper.conversation,
        arguments: {"dialog": chatModel},
      )?.then((value) => ChatController.to().refreshChatsList());
    } else {
      UserModel receiverUserModel = UserModel(
        uId: payload?["senderProfileUid"],
        profilePicture: payload?["senderProfilePicture"],
        name: payload?["senderProfileName"],
      );
      final chatRoomId = payload?["chatroomId"];

      if (receiverUserModel.uId != null && chatRoomId != null) {
        Get.to(() => PersonMessageView(
          name: receiverUserModel.name ?? "gaya User",
          uid: receiverUserModel.uId ?? "",
          profilePicture: receiverUserModel.profilePicture ?? "",
          chatRoomModel: ChatRoomModel(chatRoomId: chatRoomId),
        ));
      } else {
        MyLoggerServices.to.print("navigation failed on chatRoom navigation in NotificationNavigationService class.");
      }
    }

    // log('called navigateToChatroom function.');
  }

  static final _commonServices = Services();

  static Future<void> navigateToPost(NotificationPayload payload) async {
    debugPrint('on navigateToPost');
    try {
      UserModel userModel = UserModel(
        uId: payload?["senderProfileUid"],
        profilePicture: payload?["senderProfilePicture"],
        name: payload?["senderProfileName"],
      );
      final postId = payload?["postId"];
      final communityId = payload?["communityId"];
      if (postId != null && postId != '') {
        Community communityModel = Community(communityId: communityId);
        Post postModel = Post(postid: postId, community: communityModel, postedBy: userModel);
        final reactionModel = await _commonServices.getUserReactionOnPost(postModel.postid ?? '');
        postModel.reactionModel = reactionModel;

        try {
          List<MultiCommentModel> comments = await _commonServices.loadPostsComments(postModel.postid ?? "");
          final commentsList = comments.map<CommentCustomModel>((comment) => comment.comment).toList();
          postModel.recentComments = commentsList;
        } catch (_) {}

        Routes.postDetailsScreen(post: postModel, community: communityModel);
      } else {
        MyLoggerServices.to.print("navigation failed on post navigation in NotificationNavigationService class.");
      }
      log('called navigateToPost function.');
    } catch (_) {}
  }

  static Future<void> navigateToCommunity(NotificationPayload payload) async {
    try {
      final communityId = payload?["communityId"];

      if (communityId != null && communityId != '') {
        Community communityModel = Community(
          communityId: communityId,
          communityName: payload?["communityName"] ?? '',
          communityDescription: payload?["communityDescription"] ?? '',
          CommunityPic: payload?["CommunityPic"] ?? '',
          adminUid: payload?["adminUid"] ?? '',
          coverPicture: payload?["coverPicture"] ?? '',
        );

        ///Show join community modal if user is not a member of community.
        if (AppConfigurationController.to.isMemberOfCommunity(communityModel.communityId ?? "") == false &&
            Get.context != null &&
            (Get.context?.mounted ?? false)) {
          Methods.showModalSheetToJoinCommunity(communityId: communityModel.communityId ?? "", ctx: Get.context!);
          return;
        }
        Methods.routeToGroup(community: communityModel);

        // Routes.groupView(community: communityModel);
      } else {
        MyLoggerServices.to.print("navigation failed on community navigation in NotificationNavigationService class.");
      }
      log('called navigateToCommunity function.');
    } catch (_) {}
  }

  static Future<void> navigateToProfile(NotificationPayload payload) async {
    try {
      final uId = payload?["uId"];

      if (uId != null && uId != '') {
        UserModel userModel = UserModel(
          uId: uId,
          name: payload?["name"] ?? '',
          profilePicture: payload?["profilePicture"] ?? '',
        );

        Get.to(() => PeopleProfileView(
          usermodel: userModel,
        ));
      } else {
        MyLoggerServices.to.print("navigation failed on community navigation in NotificationNavigationService class.");
      }
      log('called navigateToProfile function.');
    } catch (_) {}
  }

  static Map<String, String>? getPayload({payload}) {
    try {
      MyLoggerServices.to.print("payload: $payload");
      payload = jsonDecode(payload);
      if (payload == null) return null;
      Map<String, String>? newPayload;
      if (payload["messageType"].toString() == "chatMessage") {
        log('returned chatmessage Payload from NotificationNavigationService class.');

        newPayload = {
          "senderProfilePicture": payload["senderProfilePicture"] ?? '',
          "senderProfileUid": payload["senderProfileUid"] ?? '',
          "senderProfileName": payload["senderProfileName"] ?? '',
          "chatroomId": payload["chatroomId"] ?? '',
          "messageType": payload["messageType"] ?? 'default'
        };
      } else if (payload["messageType"].toString() == "post") {
        log('returned post Payload from NotificationNavigationService class.');
        newPayload = {
          "senderProfilePicture": payload["senderProfilePicture"] ?? '',
          "senderProfileUid": payload["senderProfileUid"] ?? '',
          "senderProfileName": payload["senderProfileName"] ?? '',
          "postId": payload["postId"] ?? '',
          "communityId": payload["communityId"] ?? '',
          "messageType": payload["messageType"] ?? 'default'
        };
      } else if (payload["messageType"].toString() == "community") {
        log('returned community Payload from NotificationNavigationService class.');
        newPayload = {
          "communityName": payload["communityName"] ?? '',
          "communityDescription": payload["communityDescription"] ?? '',
          "coverPicture": payload["coverPicture"] ?? '',
          "CommunityPic": payload["CommunityPic"] ?? '',
          "adminUid": payload["adminUid"] ?? '',
          "communityId": payload["communityId"] ?? '',
          "messageType": payload["messageType"] ?? 'default'
        };
      } else if (payload["messageType"].toString() == "profile") {
        log('returned community Payload from NotificationNavigationService class.');
        newPayload = {
          "uId": payload["uId"] ?? '',
          "name": payload["name"] ?? '',
          "profilePicture": payload["profilePicture"] ?? '',
          "messageType": payload["messageType"] ?? 'default'
        };
      }
      log('returned else Payload from NotificationNavigationService class.');

      return newPayload;
    } catch (e) {
      log('catch block Payload from NotificationNavigationService class. $e');

      return null;
    }
  }
}
