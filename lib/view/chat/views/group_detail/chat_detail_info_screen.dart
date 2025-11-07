import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/services.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/chat/components/single_chat_detail_widget.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/view/chat/views/group_detail/edit_group_details_screen.dart';
import 'package:gaya/view/chat/utils/consts.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

//////////////////////// Main ChatDetailInfoScreen Screen Below //////////////////////
class ChatDetailInfoScreen extends StatefulWidget {
  final String dialogId;

  const ChatDetailInfoScreen({required this.dialogId, super.key});

  @override
  State<ChatDetailInfoScreen> createState() => _ChatDetailInfoScreenState();
}

class _ChatDetailInfoScreenState extends State<ChatDetailInfoScreen> {
  late ConversationController conversationController;
  @override
  void initState() {
    super.initState();
    conversationController = ConversationController.to(widget.dialogId);
    if (conversationController.chatDetailScreenOccupants.isEmpty) {
      conversationController.initOfChatDetailInfoScreen();
    }
  }

  @override
  void dispose() {
    conversationController.disposeOfChatDetailInfoScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const GayaBackButton(),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          title: Text(
            GayaStrings.group_info.tr,
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: klightGrey,
          elevation: 0,
        ),
        body: conversationController.currentChatDialog.type == CubeDialogType.PRIVATE
            ? ContactChatDetailScreen(
                dialogId: widget.dialogId,
              )
            : EditGroupDetailsScreen(
                dialogId: widget.dialogId,
              ));
  }
}
