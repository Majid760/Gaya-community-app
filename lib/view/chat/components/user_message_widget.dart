import 'package:connectycube_sdk/connectycube_sdk.dart' as Connectycube;
// import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/image_swiper.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/audio_widget.dart';
import 'package:gaya/view/chat/components/network_pdf_view.dart';
import 'package:gaya/view/chat/components/play_video_widget.dart';
import 'package:gaya/view/chat/components/text_link_widget.dart';
import 'package:gaya/view/chat/helper/helper_functions.dart';
import 'package:gaya/view/messaging/components/load_message_as_communitypreview.dart';
import 'package:gaya/view/messaging/components/load_message_as_postpreview.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:get/utils.dart';

class UserMessageWidget extends StatelessWidget {
  // final Message currentMessage;
  final VoidCallback onLongTap;
  final int index;
  final MessageType messageType;
  final Connectycube.CubeMessage? message;
  final String dialogId;
  String sentTime = '';
  String deliveryStatus = '';

  UserMessageWidget(
      {super.key,
      // required this.currentMessage,
      required this.onLongTap,
      required this.index,
      this.message,
      required this.messageType,
      required this.dialogId,
      required this.sentTime,
      required this.deliveryStatus});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongTap,
      child: Padding(
        padding: const EdgeInsets.only(top: distance_10, bottom: distance_10),
        child: Align(
          alignment: Alignment.bottomRight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if ((messageType == MessageType.nullAttachment) && (message?.body == null || (message?.body?.isEmpty ?? true))) {
                return const SizedBox.shrink();
              } else {
                // returns type of widget whether it's text, image,video...
                if (messageType == MessageType.community) {
                  return message!.attachments != null && !isListEmptyOrNull(message!.attachments)
                      ? LoadCommunityMessageWidget(
                          message: message,
                          sentTime: sentTime,
                          deliveryStatus: deliveryStatus,
                        )
                      : const SizedBox.shrink();
                } else if (messageType == MessageType.post) {
                  return message!.attachments != null && !isListEmptyOrNull(message!.attachments)
                      ? LoadPostMessageWidget(
                          message: message,
                          sentTime: sentTime,
                          deliveryStatus: deliveryStatus,
                        )
                      // LoadPostMessage(postId: message!.attachments!.first.data.toString(), isCurrentUser: false)
                      : const SizedBox.shrink();
                } else if (messageType == MessageType.link) {
                  return message!.attachments != null && !isListEmptyOrNull(message!.attachments)
                      ? TextlinkWidget(
                          isLink: GetUtils.isURL(message!.attachments!.first.data.toString()),
                          text: message!.attachments!.first.data ?? '',
                          currentMessage: message!,
                          mySelf: true,
                          sentTime: sentTime,
                          deliveryStatus: deliveryStatus,
                        )
                      : const SizedBox.shrink();
                } else if (messageType == MessageType.image) {
                  return message!.attachments != null && !isListEmptyOrNull(message!.attachments)
                      ? ConstrainedBox(
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
                                        Row(
                                          children: [
                                            SizedBox(width: 4.r),
                                            getReadDeliveredWidget(deliveryStatus),
                                          ],
                                        )
                                      ],
                                    ))
                              ],
                            ),
                          ))
                      : const SizedBox.shrink();
                } else if (messageType == MessageType.video) {
                  return PlayVideoWidget(currentMessage: message!, sentTime: sentTime, deliveryStatus: deliveryStatus, mySelf: true);
                } else if (messageType == MessageType.audio) {
                  return message!.attachments != null && !isListEmptyOrNull(message!.attachments)
                      ? AudioWidget(
                    isCurrentUser: true,
                          audioPath: message!.attachments!.first.url!,
                          sentTime: sentTime,
                          deliveryStatus: deliveryStatus,
                          duration: message?.properties['duration'],
                        )
                      : const SizedBox.shrink();
                } else if (messageType == MessageType.document) {
                  return message!.attachments != null && !isListEmptyOrNull(message!.attachments)
                      ? NetworkPDFView(
                          path: message!.attachments!.first.url!,
                          filename: message!.attachments!.first.name ?? '',
                          chatDialogId: dialogId,
                          width: 230.w,
                          thumbnailUrl: message!.attachments!.first.data,
                          sentTime: sentTime,
                          deliveryStatus: deliveryStatus,
                          mySelf: true,
                        )
                      : const SizedBox.shrink();
                }
                return message!.body != null && (message!.body?.isNotEmpty ?? false)
                    ? TextlinkWidget(
                        isLink: GetUtils.isURL(message!.body.toString()),
                        text: message!.body ?? '',
                        currentMessage: message!,
                        mySelf: true,
                        sentTime: sentTime,
                        deliveryStatus: deliveryStatus,
                      )
                    : const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
