import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../../controller/homepage.controller.dart';
import '../../gen/assets.gen.dart';
import '../../model/user.model.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';

class SearchFriendsForModalSheet extends StatelessWidget {
  final HomePageController homeController;
  final String postId;
  final String lastMessage;
  final MessageType messageType;

  const SearchFriendsForModalSheet(
      {super.key, required this.homeController, required this.postId, required this.lastMessage, required this.messageType});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: homeController.searchFriends.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final searchFriends = homeController.searchFriends[index];
          log(searchFriends.name.toString());
          return ListTile(
            leading: searchFriends.profilePicture == ''
                ? CircleAvatar(radius: 16, backgroundImage: AssetImage(Assets.assets.images.userDefault))
                : CircleAvatar(
                    radius: 16,
                    // backgroundImage: CachedNetworkImageProvider(searchFriends.profilePicture ?? ''),
                    child: CachedNetworkImage(
                      memCacheHeight: 50,
                      memCacheWidth: 50,
                      imageUrl: searchFriends.profilePicture ?? '',
                      imageBuilder: (context, imageProvider) {
                        return Container(
                            decoration:
                                BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)));
                      },
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                        child: const Center(child: Icon(Icons.error, color: Colors.red)),
                      ),
                      placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
                    ),
                  ),
            title: Text(
              searchFriends.name ?? '',
              style: CustomTypography.body4Style,
            ),
            trailing: StatefulBuilder(builder: (context, update) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: homeController.sentMessageUserIds.contains(searchFriends.uId) == false
                        ? CustomTypography.titleStyleWhite
                        : CustomTypography.dark12,
                    backgroundColor: homeController.sentMessageUserIds.contains(searchFriends.uId) == false ? kprimaryColor : kBaseGrey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: () async {
                  if (homeController.sentMessageUserIds.contains(searchFriends.uId) == true) {
                    log("Already sent");
                    log(homeController.sentMessageUserIds.toString());
                  } else {
                    log(homeController.sentMessageUserIds.toString());
                    log("sending for the first time");
                    await homeController.helperFunc
                        .sendMessageAsPostOrCommunity(searchFriends.uId!, postId, context, lastMessage, messageType: messageType);
                    homeController.sentMessageUserIds.add(searchFriends.uId!);
                    update(() => update(() => homeController.sentMessageUserIds));
                  }
                },
                child: Text(
                  homeController.sentMessageUserIds.contains(searchFriends.uId) == false
                      ? GayaStrings.send_txt.tr
                      : GayaStrings.sent_txt.tr,
                  style: homeController.sentMessageUserIds.contains(searchFriends.uId) == false
                      ? CustomTypography.titleStyleWhite
                      : CustomTypography.dark12,
                ),
              );
            }),
          );
        });
  }
}

class SearchFriendListView extends StatelessWidget {
  final Function(UserModel?)? onUserTap;
  final String buttonName;
  final bool showTrailingIcon;
  final List<UserModel> users;

  const SearchFriendListView({
    Key? key,
    required this.onUserTap,
    this.buttonName = GayaStrings.send_txt,
    this.showTrailingIcon = false,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    return ListView.builder(
      itemCount: users.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final user = users[index];
        // this check is used for to avoid logged-in user to show in search list
        return user.uId == authUser?.uid
            ? const SizedBox.shrink()
            : UserTileView(
                user: user,
                onUserTap: (user) async => await onUserTap!(user),
                buttonName: buttonName,
                showTrailingIcon: showTrailingIcon,
              );
      },
    );
  }
}

class UserTileView extends StatelessWidget {
  UserTileView({Key? key, required this.user, this.showTrailingIcon = false, this.onUserTap, required this.buttonName}) : super(key: key);
  final UserModel user;
  final bool showTrailingIcon;
  final Function(UserModel?)? onUserTap;
  final String buttonName;

  bool isSendMessageLoading = false;
  bool sentMessage = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20, right: 20).r,
      leading: user.profilePicture == ''
          ? CircleAvatar(radius: 16, backgroundImage: AssetImage(Assets.assets.images.userDefault))
          : CircleAvatar(
              radius: 16,
              // backgroundImage: CachedNetworkImageProvider(searchFriends.profilePicture ?? ''),
              child: CachedNetworkImage(
                memCacheHeight: 50,
                memCacheWidth: 50,
                imageUrl: user.profilePicture ?? '',
                imageBuilder: (context, imageProvider) {
                  return Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)));
                },
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                ),
                placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
              ),
            ),
      title: Text(user.name ?? '', style: CustomTypography.body4Style),
      trailing: showTrailingIcon == true
          ? GestureDetector(onTap: () => onUserTap!(user), child: SvgPicture.asset("Assets/icons/right_arrow.svg", height: 20))
          : StatefulBuilder(builder: (context, update) {
              if (isSendMessageLoading) {
                return SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
                  height: 30.h,
                  child: const CupertinoActivityIndicator(),
                );
              }

              return GayaButton(
                title: sentMessage ? GayaStrings.sent_txt.tr : buttonName.tr,
                primaryColor: sentMessage ? AppColors.divider : AppColors.primary,
                textStyle: sentMessage ? CustomTypography.titleStyleBlack : CustomTypography.titleStyleWhite,
                height: 30.h,
                width: MediaQuery.sizeOf(context).width * 0.2,
                onPressed: sentMessage
                    ? null
                    : () async {
                        isSendMessageLoading = true;

                        update(() {});
                        await onUserTap!(user);
                        sentMessage = true;
                        isSendMessageLoading = false;
                        update(() {});
                      },
              );
            }),
    );
  }
}
