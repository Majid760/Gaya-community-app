// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/widgets/notification_widgets/compliment_text_widget.dart';
import 'package:get/get.dart';

import '../../components/avatar.component.dart';
import '../../model/user.model.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';
import 'widgets/watches_eye_icon.dart';

class RequestNotificationWidget extends StatelessWidget {
  final String text;
  final String postedTime;
  final Widget pic;
  final Widget? widget1, widget2;
  final Color color;
  final String? profileImg;
  final user = FirebaseAuth.instance.currentUser;
  final String senderId;

  RequestNotificationWidget(
      {Key? key,
      this.profileImg,
      required this.text,
      required this.postedTime,
      required this.pic,
      required this.color,
      required this.senderId,
      this.widget1,
      this.widget2})
      : super(key: key);

  void openProfile({required UserModel userModel, required BuildContext context}) {
    Routes.viewProfile(uid: userModel.uId, model: userModel);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      // height: 135.h,
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              openProfile(
                userModel: UserModel(uId: senderId, name: text, profilePicture: profileImg),
                context: context,
              );
            },
            child: AvatarWidget(
              backgroundColor: color,
              imageWidget: pic,
              profileImg: profileImg!,
            ),
          ),
          const SizedBox(width: distance_12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    openProfile(userModel: UserModel(uId: user?.uid ?? '', name: text, profilePicture: profileImg), context: context);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(text,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp, color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          IconButton(
                              tooltip: GayaStrings.more_txt.tr,
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              splashRadius: 20.r,
                              onPressed: () {},
                              icon: SvgIcons.moreIcon),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(GayaStrings.wants_to_connect.tr,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(postedTime.toString(),
                    // "Time",
                    style: CustomTypography.body3Style),
                // const Spacer(),
                const SizedBox(
                  height: distance_8,
                ),
                Row(
                  children: [
                    Expanded(child: widget1 ?? const SizedBox()),
                    const SizedBox(width: 8),
                    Expanded(child: widget2 ?? const SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OtherNotificationWidget extends StatelessWidget {
  final String text;
  final String typeOfComment;
  final String? postedTime;
  final Widget pic;
  final Color color;
  final String? profileImg;
  final String? message;
  final String? receiverUserId;
  final bool shouldShowImageWidget;
  final String? notificationId;
  final Color unreadMessageColor;
  final VoidCallback onTapNotification, onTapMore;

  const OtherNotificationWidget({
    Key? key,
    this.profileImg,
    required this.text,
    required this.typeOfComment,
    this.postedTime,
    required this.pic,
    this.shouldShowImageWidget = true,
    required this.color,
    required this.message,
    required this.receiverUserId,
    required this.notificationId,
    required this.unreadMessageColor,
    required this.onTapNotification,
    required this.onTapMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTitleAvailable = text.isBlank == false;
    final _moreIconButton = IconButton(
        splashRadius: 20.r,
        enableFeedback: true,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        padding: EdgeInsets.zero,
        onPressed: onTapMore,
        icon: SvgIcons.moreIcon);
    return InkWell(
      onTap: onTapNotification,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 20, right: 20).r,
        width: double.infinity,
        decoration: BoxDecoration(color: unreadMessageColor, border: Border.all(color: kBaseGrey)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (typeOfComment == 'watches')
              const WatchesEyeIcon()
            else
              (profileImg == null)
                  ? Container(
                alignment: Alignment.center,
                child: ColorAvatarWidget(
                  backgroundColor: color,
                  imageWidget: pic,
                  shouldShowImageWidget: shouldShowImageWidget,
                ),
              )
                  : Container(
                alignment: Alignment.center,
                child: AvatarWidget(
                  backgroundColor: color,
                  imageWidget: pic,
                  profileImg: profileImg ?? "",
                  shouldShowImageWidget: shouldShowImageWidget,
                ),
              ),
            const SizedBox(width: distance_12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTitleAvailable)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            text,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _moreIconButton,
                      ],
                    ),
                  if (message.isBlank == false)
                    Row(
                      children: [
                        typeOfComment == 'compliment'
                            ? ComplimentTextWidget(text: message.toString())
                            : Expanded(
                                child: Text(
                                  message ?? '',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                        if (!isTitleAvailable) _moreIconButton,
                      ],
                    ),
                  SizedBox(height: 5.h),
                  if (postedTime.isBlank == false)
                    Text(
                      // postedTime.toString(),
                      postedTime ?? '',
                      style: CustomTypography.body3Style,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
