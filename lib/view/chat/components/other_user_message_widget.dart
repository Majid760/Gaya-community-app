import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/image_swiper.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/audio_widget.dart';
import 'package:gaya/view/chat/components/network_pdf_view.dart';
import 'package:gaya/view/chat/components/play_video_widget.dart';
import 'package:gaya/view/chat/components/text_link_widget.dart';
import 'package:gaya/view/chat/helper/helper_functions.dart' as Helper;
import 'package:gaya/view/messaging/components/load_message_as_communitypreview.dart';
import 'package:gaya/view/messaging/components/load_message_as_postpreview.dart';
import 'package:get/get.dart';

class OtherUserMessageWidget extends StatelessWidget {
  final Widget profilePicture;
  final String dialogId;

  // final Message currentMessage;
  final int index;
  final CubeMessage? message;
  final Helper.MessageType messageType;
  String sentTime = '';
  String deliveryStatus = '';

  OtherUserMessageWidget(
      {super.key,
      required this.profilePicture,
      required this.dialogId,
      // required this.currentMessage,
      required this.index,
      this.message,
      required this.messageType,
      required this.sentTime,
      required this.deliveryStatus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Align(
          alignment: Alignment.bottomLeft,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if ((messageType == Helper.MessageType.nullAttachment) && (message?.body == null && (message?.body?.isEmpty ?? true))) {
                return const SizedBox.shrink();
              } else {
                // returns type of widget whether it's text, image,video...
                if (messageType == Helper.MessageType.community) {
                  return message!.attachments != null && !Helper.isListEmptyOrNull(message!.attachments)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: profilePicture,
                            ),
                            const SizedBox(width: 10),
                            LoadCommunityMessageWidget(
                              message: message,
                              sentTime: sentTime,
                              deliveryStatus: deliveryStatus,
                              isCurrentUser: false,
                            ),
                            // LoadCommunityMessage(communityId: message!.attachments!.first.data.toString()),
                          ],
                        )
                      : const SizedBox.shrink();
                } else if (messageType == Helper.MessageType.post) {
                  return message!.attachments != null && !Helper.isListEmptyOrNull(message!.attachments)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: profilePicture,
                            ),
                            const SizedBox(width: 10),
                            LoadPostMessageWidget(
                              message: message,
                              isCurrentUser: false,
                              sentTime: sentTime,
                              deliveryStatus: deliveryStatus,
                            ),
                          ],
                        )
                      : const SizedBox.shrink();
                } else if (messageType == Helper.MessageType.link) {
                  return message!.attachments != null && !Helper.isListEmptyOrNull(message!.attachments)
                      ? TextlinkWidget(
                          isLink: GetUtils.isURL(message!.attachments!.first.data.toString()),
                          text: message!.attachments!.first.data ?? '',
                          currentMessage: message!,
                          mySelf: false,
                          userAvatar: profilePicture,
                          sentTime: sentTime,
                          deliveryStatus: deliveryStatus,
                        )
                      : const SizedBox.shrink();
                } else if (messageType == Helper.MessageType.image) {
                  return message!.attachments != null && !Helper.isListEmptyOrNull(message!.attachments)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: profilePicture,
                            ),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 150.w, minWidth: 150.w, maxHeight: 200.h),
                                child: GestureDetector(
                                  onTap: () {
                                    if (message!.attachments!.first.url != null) {
                                      List<String> images = [message!.attachments!.first.url!];
                                      Routes.openImages(urls: images, index: 0, ctx: context);
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12).r),
                                          child: ScrolledHero(
                                              tag: message!.attachments!.first,
                                              transitionOnUserGestures: true,
                                              child: PostImageWidget(url: message!.attachments!.first.url))),
                                      Positioned(
                                          bottom: 4.r,
                                          right: 4.r,
                                          child: Row(
                                            children: [
                                              Text(
                                                sentTime,
                                                style: TextStyle(color: AppColors.white, fontSize: 10.0.sp, fontStyle: FontStyle.italic),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                ))
                          ],
                        )
                      : const SizedBox.shrink();
                } else if (messageType == Helper.MessageType.video) {
                  return message!.attachments != null && !Helper.isListEmptyOrNull(message!.attachments)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: profilePicture,
                            ),
                            const SizedBox(width: 10),
                            PlayVideoWidget(
                              currentMessage: message!,
                              sentTime: sentTime,
                              deliveryStatus: deliveryStatus,
                              mySelf: false,
                            ),
                          ],
                        )
                      : const SizedBox.shrink();
                } else if (messageType == Helper.MessageType.audio) {
                  return message!.attachments != null && !Helper.isListEmptyOrNull(message!.attachments)
                      ? AudioWidget(
                          userImage: profilePicture,
                          isCurrentUser: false,
                          audioPath: message!.attachments!.first.url!,
                          sentTime: sentTime,
                          deliveryStatus: deliveryStatus,
                          duration: message?.properties["duration"],
                        )
                      : const SizedBox.shrink();
                } else if (messageType == Helper.MessageType.document) {
                  return message!.attachments != null && !Helper.isListEmptyOrNull(message!.attachments)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: profilePicture,
                            ),
                            const SizedBox(width: 10),
                            NetworkPDFView(
                              path: message!.attachments!.first.url!,
                              filename: message!.attachments!.first.name ?? '',
                              width: 230.w,
                              chatDialogId: dialogId,
                              sentTime: sentTime,
                              deliveryStatus: deliveryStatus,
                              mySelf: false,
                            ),
                          ],
                        )
                      : const SizedBox.shrink();
                }
                return message!.body != null && (message!.body?.isNotEmpty ?? false)
                    ? TextlinkWidget(
                        isLink: GetUtils.isURL(message!.body.toString()),
                        text: message!.body ?? '',
                        currentMessage: message!,
                        mySelf: false,
                        userAvatar: profilePicture,
                        sentTime: sentTime,
                        deliveryStatus: deliveryStatus,
                      )
                    : const SizedBox.shrink();
              }
            },
          )),
    );
  }
}
