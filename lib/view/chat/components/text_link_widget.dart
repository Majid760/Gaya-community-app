import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/chat/components/select_link_widget.dart';
import 'package:gaya/view/chat/helper/helper_functions.dart' as Helper;
import 'package:gaya/view/chat/utils/consts.dart' as UtilColors;

class TextlinkWidget extends StatelessWidget {
  const TextlinkWidget(
      {super.key,
      required this.isLink,
      this.userAvatar,
      required this.text,
      required this.currentMessage,
      required this.mySelf,
      this.sentTime = '',
      this.deliveryStatus = ''});

  final bool isLink;
  final String text;
  final CubeMessage currentMessage;
  final bool mySelf;
  final Widget? userAvatar;
  final String sentTime;

  final String deliveryStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.65,
      child: Row(
        mainAxisAlignment: mySelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!mySelf) userAvatar ?? const SizedBox.shrink(),
          if (!mySelf) const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: distance_12, vertical: distance_8),
              decoration: BoxDecoration(
                color: Helper.checkMessageType(currentMessage) == Helper.MessageType.post ||
                        (Helper.checkMessageType(currentMessage) == Helper.MessageType.community)
                    ? kTransparentColor
                    : mySelf
                        ? kprimaryColorLight
                        : kBaseGrey,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: !mySelf ? Radius.circular(4.r) : Radius.circular(16.r),
                  bottomRight: !mySelf ? Radius.circular(16.r) : Radius.circular(4.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: Methods.isRTL(text) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isLink
                          ? SelectLinkWidget(
                              data: text,
                              onTap: () {
                                String? url = text;
                                if (url.contains("http")) {
                                  Methods.launchMyUrl(url, context: context);
                                } else {
                                  url = "https://";
                                  Methods.launchMyUrl(url, context: context);
                                }
                              },
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16.sp,
                                fontFamily: GayaFontTheme.primaryFont,
                              ),
                            )
                          : SelectableText(
                              text,
                              textDirection: Methods.isRTL(text) ? TextDirection.rtl : TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 16.sp,
                              ),
                            ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            sentTime,
                            style: TextStyle(color: UtilColors.greyColor, fontSize: 10.0.sp, fontStyle: FontStyle.italic),
                          ),
                          (mySelf)
                              ? Row(
                                  children: [
                                    SizedBox(width: 4.r),
                                    getReadDeliveredWidget(deliveryStatus),
                                  ],
                                )
                              : const SizedBox.shrink()
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget getReadDeliveredWidget(String deliveryStatus) {
  if (deliveryStatus == 'read') {
    return Stack(children: <Widget>[
      Icon(
        Icons.check,
        size: 14.0.r,
        color: blueColor,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Icon(
          Icons.check,
          size: 14.0.r,
          color: blueColor,
        ),
      )
    ]);
  } else if (deliveryStatus == 'delivered') {
    return Stack(children: <Widget>[
      Icon(
        Icons.check,
        size: 14.0.r,
        color: UtilColors.greyColor,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Icon(
          Icons.check,
          size: 14.0.r,
          color: UtilColors.greyColor,
        ),
      )
    ]);
  } else {
    return Icon(
      Icons.check,
      size: 14.0.r,
      color: UtilColors.greyColor,
    );
  }
}

class EmojiText extends StatelessWidget {
  const EmojiText({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildText(text),
      textDirection: Methods.isRTL(text) ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  TextSpan _buildText(String text) {
    final children = <TextSpan>[];
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...
      final isEmoji = current > 255;
      final shouldBreak = isEmoji ? (x) => x <= 255 : (x) => x > 255;

      final chunk = <int>[];
      while (!shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }

      children.add(
        TextSpan(
          text: "String.fromCharCodes(chunk)",
          style: TextStyle(
            fontFamily: isEmoji ? 'EmojiOne' : null,
            fontSize: isEmoji ? 20.0.r : 14.22.sp,
          ),
        ),
      );
    }

    return TextSpan(children: children);
  }
}