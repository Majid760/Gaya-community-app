import 'package:flutter/material.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/view/chat/utils/consts.dart';
import 'package:get/get.dart';

//////////////////////// single Contact Detail Screen Below //////////////////////
class ContactChatDetailScreen extends StatefulWidget {
  final String dialogId;

  const ContactChatDetailScreen({
    required this.dialogId,
    super.key,
  });

  @override
  State<ContactChatDetailScreen> createState() => _ContactChatDetailScreenState();
}

class _ContactChatDetailScreenState extends State<ContactChatDetailScreen> {
  late ConversationController conversationController;
  @override
  void initState() {
    super.initState();
    conversationController = ConversationController.to(widget.dialogId);
    conversationController.initializeOtherContactOfContactChat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(60),
        child: GetBuilder<ConversationController>(
          init: conversationController,
          tag: widget.dialogId,
          builder: (chatController) {
            return Column(
              children: [
                Center(
                  child: Text(
                    chatController.userLastActivityTime,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildAvatarFields(),
                _buildTextFields(),
                _buildButtons(),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Visibility(
                    maintainSize: false,
                    maintainAnimation: false,
                    maintainState: false,
                    visible: chatController.isChatDetailScreenLoading,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }
  // Future<String> getLastActivityTime() async {
  //   String lastActivityTime = '';
  //   int seconds;
  //   try {
  //     seconds = await CubeChatConnection.instance.getLasUserActivity(chatController.otherContactParticipiant?.id ?? 0);
  //     lastActivityTime = Jiffy(seconds).fromNow().toString();
  //   } catch (_) {
  //     lastActivityTime = 'Last activity time error';
  //   }
  //   return lastActivityTime;
  // }

  Widget _buildAvatarFields() {
    if (conversationController.isChatDetailScreenLoading) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: conversationController.otherContactParticipiant?.avatar != null &&
                  conversationController.otherContactParticipiant!.avatar!.isNotEmpty
              ? NetworkImage(conversationController.otherContactParticipiant!.avatar!)
              : null,
          backgroundColor: greyColor2,
          radius: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(55),
            child: Text(
              conversationController.otherContactParticipiant!.fullName!.substring(0, 2).toUpperCase(),
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    if (conversationController.isChatDetailScreenLoading) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.all(50),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              right: 10, left: 10,
              bottom: 3, // space between underline and text
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: primaryColor, // Text colour here
              width: 1.0, // Underline width
            ))),
            child: Text(
              conversationController.otherContactParticipiant!.fullName!,
              style: TextStyle(
                color: primaryColor,
                fontSize: 20, // Text colour here
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (conversationController.isChatDetailScreenLoading) {
      return const SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        ElevatedButton(
          child: Text(
            GayaStrings.start_chat.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20, // Text colour here
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
