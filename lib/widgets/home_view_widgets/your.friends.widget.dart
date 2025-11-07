import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/message_service/message_service.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:get/get.dart';

import '../../components/check_for_app_update.dart';
import '../../controller/firebase_analytics_controller.dart';
import '../../controller/homepage.controller.dart';
import '../../gen/assets.gen.dart';
import '../../model/user.model.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';

/// Used only for Send message as Post or Community
class FriendsListModalWidget extends StatelessWidget {
  final HomePageController homeController;
  final List<UserModel> friend;
  final String postId;
  final String lastMessage;
  final MessageType messageType;
  final Post? post;
  final Community? community;

  const FriendsListModalWidget(
      {super.key,
      required this.homeController,
      required this.friend,
      required this.postId,
      required this.lastMessage,
      required this.messageType,
      this.post,
      this.community});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: friend.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          UserModel userModel = friend[index];

          homeController.addUserInAllFriends(userModel);

          return ListTile(
            onTap: () {
              Navigator.pop(context);
              Routes.viewProfile(uid: userModel.uId, model: userModel);
            },
            leading: userModel.profilePicture == ''
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(Assets.assets.images.userDefault),
                  )
                : CircleAvatar(
                    radius: 16,
                    // backgroundImage: CachedNetworkImageProvider(userModel.profilePicture ?? ''),
                    child: CachedNetworkImage(
                      memCacheHeight: 100,
                      memCacheWidth: 100,
                      imageUrl: userModel.profilePicture ?? '',
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                        child: const Center(
                            child: Icon(
                          Icons.error,
                          color: Colors.red,
                        )),
                      ),
                      placeholder: (context, url) => Image.asset(
                        Assets.assets.images.userDefault,
                      ),
                    ),
                  ),
            title: Text(
              userModel.name ?? '',
              style: CustomTypography.body4Style,
            ),
            trailing: StatefulBuilder(builder: (context, update) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: homeController.sentMessageUserIds.contains(userModel.uId) == false
                        ? CustomTypography.titleStyleWhite
                        : CustomTypography.dark12,
                    backgroundColor: homeController.sentMessageUserIds.contains(userModel.uId) == false ? kprimaryColor : kBaseGrey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: () async {
                  if (homeController.sentMessageUserIds.contains(userModel.uId) == true) {
                    log("Already sent");
                  } else {
                    if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
                      //// Check if user can send message
                      final errorMessage = await MessageUtils.canSendAMessage(user: userModel);
                      if (errorMessage != null) {
                        if (context.mounted) {
                          GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: errorMessage);
                        }

                        /// If user can't send message then return
                        return;
                      }
                      String type = messageType == MessageType.community ? 'community' : 'post';
                      ChatController.to().helperFunc.createNewChatAndSendMessage(context, userModel.uId ?? '', postId, type,
                          attachmentData: postId, post: post, community: community);
                    } else {
                      await MessageUtils.sendAPostMessage(userModel, context: context, onPostShare: () {
                        homeController.helperFunc
                            .sendMessageAsPostOrCommunity(userModel.uId ?? "", postId, context, lastMessage, messageType: messageType);
                      });
                    }

                    homeController.sentMessageUserIds.add(userModel.uId!);
                  }

                  update(() => homeController.sentMessageUserIds);
                },
                // },
                child: Text(
                  homeController.sentMessageUserIds.contains(userModel.uId) == false ? GayaStrings.send_txt.tr : GayaStrings.sent_txt.tr,
                  style: homeController.sentMessageUserIds.contains(userModel.uId) == false
                      ? CustomTypography.titleStyleWhite
                      : CustomTypography.dark12,
                ),
              );
            }),
          );
        });
  }
}

/// Used only for Send message as Post or Community
class FriendsListSearchModalWidget extends StatelessWidget {
  final HomePageController homeController;
  final List<UserModel> friend;
  final String postId;
  final String lastMessage;
  final MessageType messageType;
  final Post? post;
  final Community? community;

  const FriendsListSearchModalWidget(
      {super.key,
      required this.homeController,
      required this.friend,
      required this.postId,
      required this.lastMessage,
      required this.messageType,
      this.post,
      this.community});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: friend.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          UserModel userModel = friend[index];
          homeController.addUserInAllFriends(userModel);
          return ListTile(
            onTap: () {
              Navigator.pop(context);
              Routes.viewProfile(uid: friend[index].uId, model: friend[index]);
            },
            leading: userModel.profilePicture == ''
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(Assets.assets.images.userDefault),
                  )
                : CircleAvatar(
                    radius: 16,
                    // backgroundImage: CachedNetworkImageProvider(userModel.profilePicture ?? ''),
                    child: CachedNetworkImage(
                      memCacheHeight: 100,
                      memCacheWidth: 100,
                      imageUrl: userModel.profilePicture ?? '',
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                        child: const Center(
                            child: Icon(
                          Icons.error,
                          color: Colors.red,
                        )),
                      ),
                      placeholder: (context, url) => Image.asset(
                        Assets.assets.images.userDefault,
                      ),
                    ),
                  ),
            title: Text(
              userModel.name ?? '',
              style: CustomTypography.body4Style,
            ),
            trailing: StatefulBuilder(builder: (context, update) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: homeController.sentMessageUserIds.contains(userModel.uId) == false
                        ? CustomTypography.titleStyleWhite
                        : CustomTypography.dark12,
                    backgroundColor: homeController.sentMessageUserIds.contains(userModel.uId) == false ? kprimaryColor : kBaseGrey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: () async {
                  if (homeController.sentMessageUserIds.contains(userModel.uId) == true) {
                    log("Already sent");
                  } else {
                    if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
                      //// Check if user can send message
                      final errorMessage = await MessageUtils.canSendAMessage(user: userModel);
                      if (errorMessage != null) {
                        if (context.mounted) {
                          GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: errorMessage);
                        }

                        /// If user can't send message then return
                        return;
                      }
                      String type = messageType == MessageType.community ? 'community' : 'post';
                      ChatController.to().helperFunc.createNewChatAndSendMessage(
                            context,
                            userModel.uId ?? '',
                            postId,
                            type,
                            attachmentData: postId,
                            post: post,
                            community: community,
                          );
                    } else {
                      await homeController.helperFunc.sendMessageAsPostOrCommunity(
                        userModel.uId!,
                        postId,
                        context,
                        lastMessage,
                        messageType: messageType,
                      );
                    }

                    homeController.sentMessageUserIds.add(userModel.uId!);

                    // logging group invite event
                    AnalyticsController.to.instance.logCommunityInvite(
                      communityId: community?.communityId ?? '',
                      userId: UserModel.to.uId ?? '',
                      invitationSentUserId: userModel.uId ?? '',
                    );
                  }

                  update(() => homeController.sentMessageUserIds);
                },
                // },
                child: Text(
                  homeController.sentMessageUserIds.contains(userModel.uId) == false ? GayaStrings.send_txt.tr : GayaStrings.sent_txt.tr,
                  style: homeController.sentMessageUserIds.contains(userModel.uId) == false
                      ? CustomTypography.titleStyleWhite
                      : CustomTypography.dark12,
                ),
              );
            }),
          );
        });
  }
}

class MyFriendsList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Object?>> rawFriends;
  final Function(UserModel?)? onUserTap;
  final String buttonName;

  const MyFriendsList({Key? key, required this.rawFriends, required this.onUserTap, this.buttonName = GayaStrings.chat_txt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: rawFriends.length,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, index) {
          try {
            final rawFriend = rawFriends[index];
            final friend = UserModel.fromSnapshot(rawFriend);
            return MyFriendsListTile(
              user: friend,
              onUserTap: () => onUserTap!(friend),
              buttonName: buttonName.tr,
            );
          } catch (_) {
            return const SizedBox.shrink();
          }
        });
  }
}

class MyFriendsListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onUserTap;
  final String buttonName;

  const MyFriendsListTile({Key? key, required this.user, required this.onUserTap, required this.buttonName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20, right: 20).r,
      onTap: () => onUserTap(),
      leading: user.profilePicture == ''
          ? CircleAvatar(radius: 16, backgroundImage: AssetImage(Assets.assets.images.userDefault))
          : CircleAvatar(
              radius: 16,
              child: CachedNetworkImage(
                memCacheHeight: 100,
                memCacheWidth: 100,
                imageUrl: user.profilePicture ?? '',
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                  );
                },
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                  child: const Center(child: Icon(Icons.error, color: Colors.red)),
                ),
                placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
              ),
            ),
      title: Text(user.name ?? '', style: CustomTypography.body4Style),
      trailing: SvgPicture.asset("Assets/icons/right_arrow.svg", height: 20),
    );
  }
}
