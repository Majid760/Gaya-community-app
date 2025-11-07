import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/ai_daily_user_matches/view/widgets/auto_boot_chat_widget.dart';
import 'package:gaya/view/chat/components/text_link_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class AIMatchInitialMesgaeWidget extends StatelessWidget {
  final String dialogId;
  final CubeMessage? message;

  const AIMatchInitialMesgaeWidget({
    super.key,
    required this.dialogId,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: (message?.properties['flag'] == null)
            ? const SizedBox.shrink()
            : (message?.properties['imageUrl'] != '')
                ? const AutoBootChatWidget()
                : (message?.body != '' && message?.properties['imageUrl'] == '')
                    ? Container(
                        margin: const EdgeInsets.all(8).r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: const Color(0xffEFE6FD),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4).r,
                        child: Text((message?.body == 'Default message') ? GayaStrings.match_message_text2.tr : message?.body ?? "",
                            textAlign: TextAlign.center, style: GayaTypography.subtitleRegular),
                      )
                    : const SizedBox.shrink()
        // const AutoBootChatWidget()
        );
  }
}
