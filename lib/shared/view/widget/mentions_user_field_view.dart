import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/shared/controller/mentioned_user_controller.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class GayaMentionedField extends StatelessWidget {
  GayaMentionedField(
      {Key? key,
      this.isFilled = false,
      this.isPassword = false,
      this.autoFocus = false,
      this.inputType = TextInputType.text,
      this.suffixIcon,
      this.hintText = '',
      this.suffixWidget,
      this.prefixIcon,
      this.fillColor,
      this.borderColor = Colors.transparent,
      this.maxLines,
      this.onTap,
      required this.textFormFieldKey})
      : super(key: key);
  final bool isPassword;
  final TextInputType inputType;
  final Widget? suffixIcon;
  final String hintText;
  final Widget? suffixWidget;
  final Widget? prefixIcon;
  final Color? fillColor;
  final Color borderColor;
  final bool? isFilled;
  final int? maxLines;
  final VoidCallback? onTap;
  final dynamic textFormFieldKey;
  final bool autoFocus;

  // done by mak for mentioned user

  final Debouncer _debouncer = Debouncer(delay: 800.milliseconds);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MentionedUserController>(
        init: MentionedUserController(),
        builder: (mentionedCntrl) {
          return FlutterMentions(
            scrollController: ScrollController(),
            key: textFormFieldKey,
            onMarkupChanged: (v) {
              mentionedCntrl.addItem(v.toString());
            },
            onMentionAdd: (item) {},
            suggestionListDecoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3) // changes position of shadow
                    ),
              ],
              borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
            ),
            suggestionPosition: SuggestionPosition.Top,
            maxLines: 5,
            scrollPhysics: const ClampingScrollPhysics(),
            autocorrect: true,
            minLines: 1,
            autofocus: autoFocus,
            style: GayaTypography.caption.copyWith(
                color: Colors.black,
                fontSize: 16.sp,
                height: 1,
                fontFamily: GayaFontTheme.primaryFont,
                fontFamilyFallback: Platform.isIOS ? null : [GayaFontTheme.notoColorEmoji],
                fontWeight: FontWeight.w400),
            onChanged: (str) {
              // List<String> lists= str.split("@");
              // print("ops: #$lists");
              // print("lastData: #${lists.last}");
              // mentionedCntrl.getMentionedData(lists.last);

              _debouncer.call(() {
                mentionedCntrl.getMentionedData(str);
              });
            },
            decoration: InputDecoration(
                filled: isFilled,
                contentPadding: const EdgeInsets.only(left: distance_20, right: distance_20, bottom: 0, top: 0).r,
                hintText: hintText,
                hintStyle: TextStyle(color: kSecondaryColor, fontFamily: GayaFontTheme.primaryFont, fontSize: 16.sp),
                suffixIcon: suffixIcon,
                prefixIcon: prefixIcon,
                fillColor: fillColor,
                suffix: suffixWidget,
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30))),
            mentions: [
              Mention(
                  trigger: '@',
                  style: const TextStyle(color: Colors.blue),
                  data: mentionedCntrl.userCommunitiesAndFriends,
                  // disableMarkup: true,
                  suggestionBuilder: (data) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 24).r,
                      child: GestureDetector(
                        child: ListTile(
                            minVerticalPadding: 0,
                            leading: Container(
                                height: 40.h,
                                width: 40.h,
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(48),
                                    child: (data['senderProfile'] != null && data['senderProfile'].toString().isNotEmpty)
                                        ? PostImageWidget(url: data['senderProfile'], fit: BoxFit.cover, height: 30, width: 30)
                                        : AppData.defaultUserProfileWidget())),
                            title: Text(data['display'] ?? '',
                                style: GayaTypography.caption.copyWith(
                                    color: Colors.black,
                                    fontSize: 16.sp,
                                    height: 1,
                                    fontFamily: GayaFontTheme.primaryFont,
                                    fontWeight: FontWeight.w400)),
                            subtitle: Text(
                              '@${data['display'] ?? ''}',
                              style: GayaTypography.caption.copyWith(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  height: 1,
                                  fontFamily: GayaFontTheme.primaryFont,
                                  fontWeight: FontWeight.w400),
                            )),
                      ),
                    );
                  }),
            ],
          );
        });
  }
}
