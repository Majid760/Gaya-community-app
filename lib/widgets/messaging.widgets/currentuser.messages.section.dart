import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/model/messaging.model/messages.model.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/view/messaging/components/load_message_as_communitypreview.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/const.dart';
import '../../utils/methods.dart';
import '../../utils/strings.dart';
import '../../utils/textstyles.dart';
import '../../view/messaging/components/load_message_as_postpreview.dart';

// uri parse throwing error for emojis and emoticons so guarded with try cathc
bool isAbsolute(data) {
  try {
    return Uri.parse(data.toString()).isAbsolute;
  } catch (_) {
    return false;
  }
}

class CurrentUserMessages extends StatelessWidget {
  final MessageModel currentMessage;
  final VoidCallback onLongTap;

  const CurrentUserMessages({super.key, required this.currentMessage, required this.onLongTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongTap,
      child: Padding(
        padding: const EdgeInsets.only(top: distance_10, bottom: distance_10, left: distance_30),
        child: Align(
          alignment: Alignment.bottomRight,
          child: IntrinsicWidth(
            child: Container(
                alignment: Alignment.center,
                padding: isAbsolute(currentMessage.message ?? "")
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_12.h),
                decoration: BoxDecoration(
                    color: (currentMessage.messageType == MessageType.post || currentMessage.messageType == MessageType.community)
                        ? const Color.fromRGBO(255, 255, 255, 0.0)
                        : isAbsolute(currentMessage.message ?? "")
                            ? const Color.fromRGBO(255, 255, 255, 0.0)
                            : kprimaryColorLight,
                    borderRadius: isAbsolute(currentMessage.message ?? "")
                        ? BorderRadius.circular(borderRadius_8)
                        : const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20))
                            .r
                            .r),
                child: currentMessage.messageType == MessageType.community
                    ? LoadCommunityMessage(communityId: currentMessage.message)
                    : currentMessage.messageType == MessageType.post
                        ? LoadPostMessage(postId: currentMessage.message)
                        : isAbsolute(currentMessage.message ?? "")
                            ? CachedNetworkImage(
                                memCacheHeight: 100,
                                memCacheWidth: 100,
                                imageUrl: currentMessage.message.toString(),
                                fit: BoxFit.contain,
                                imageBuilder: (BuildContext ctx, img) {
                                  return SizedBox(
                                    height: 150,
                                    width: 150,
                                    // constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(borderRadius_8),
                                      child: Image.network(
                                        currentMessage.message.toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (_, __, ___) {
                                  print("error builder otheruserdart");
                                  return InkWell(
                                      onTap: () {
                                        try {
                                          launchUrl(Uri.parse(currentMessage.message.toString()), mode: LaunchMode.externalApplication);
                                        } catch (_) {
                                          snackBar(context, somethingWrong, kprimaryColor);
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_10),
                                        decoration: const BoxDecoration(
                                            color: kprimaryColorLight,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                topRight: Radius.circular(16),
                                                bottomLeft: Radius.circular(16),
                                                bottomRight: Radius.circular(16))),
                                        child: Text(
                                          currentMessage.message.toString(),
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontFamily: GayaFontTheme.primaryFont,
                                          ),
                                        ),
                                      ));
                                },
                              )
                            // Text(currentMessage.message.toString())
                            : GetUtils.isURL(currentMessage.message.toString())
                                ? InkWell(
                                    onTap: () {
                                      String url = currentMessage.message.toString();
                                      if (url.contains("http")) {
                                        Methods.launchMyUrl(url, context: context);
                                      } else {
                                        url = "https://$url";
                                        Methods.launchMyUrl(url, context: context);
                                      }
                                    },
                                    child: SelectableText(
                                      currentMessage.message.toString(),
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontFamily: GayaFontTheme.primaryFont,
                                      ),
                                    ))
                                : SelectableText(
                                    currentMessage.message.toString(),
                                    textDirection: Methods.isRTL(currentMessage.message ?? "") ? TextDirection.rtl : TextDirection.ltr,
                                  )),
          ),
        ),
      ),
    );
  }
}
