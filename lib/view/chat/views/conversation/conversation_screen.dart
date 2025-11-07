import 'dart:async';
import 'dart:io';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart' as methods;
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/ai_assets_path.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/strings.dart';
import 'package:gaya/view/ai_daily_user_matches/view/widgets/auto_boot_chat_widget.dart';
import 'package:gaya/view/chat/components/ai_match_initial_message_widget.dart';
import 'package:gaya/view/chat/components/message_placeholder.dart';
import 'package:gaya/view/chat/components/message_text_field.dart';
import 'package:gaya/view/chat/components/other_user_message_widget.dart';
import 'package:gaya/view/chat/components/selected_pdf_preview.dart';
import 'package:gaya/view/chat/components/social_media_recorder.dart';
import 'package:gaya/view/chat/components/user_image.dart';
import 'package:gaya/view/chat/components/user_message_widget.dart';
import 'package:gaya/view/chat/components/video_view_widget.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/view/chat/helper/helper_functions.dart' as Helper;
import 'package:gaya/view/chat/models/audio_encoder_type.dart';
import 'package:gaya/view/chat/utils/consts.dart' as UtilColors;
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late ConversationController chatController;
  File? audioFileToSend;

  late String? dialogId;

  @override
  void initState() {
    super.initState();

    dialogId = (Get.arguments["dialog"] as CubeDialog).dialogId;
    chatController = ConversationController.to(dialogId ?? "-1");

    /// when chat is opened, we need to stop notifications
    ChatController.to().stopNotifications();

    // Logging view chat analytics event
    ConversationController.to(dialogId ?? "").logViewChat();

    // add to screen stack
    ChatController.to().addDialogIdToOpenedScreens(dialogId ?? "");
  }

  @override
  void dispose() {
    /// close keyboard
    chatController.update();
    ChatController.to().removeDialogIdFromOpenedScreens(dialogId ?? "-1");
    chatController.conversationScreenDispose();
    chatController.messageTextFieldFocusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        centerTitle: false,
        iconTheme: const IconThemeData(color: kBlackColor),
        title: GetBuilder<ConversationController>(
            autoRemove: false,
            init: chatController,
            tag: dialogId,
            builder: (chatController) {
              return InkWell(
                onTap: () {
                  _chatDetails(context);
                },
                highlightColor: kTransparentColor,
                child: Row(
                  children: [
                    (chatController.currentChatDialog.photo == '' || chatController.currentChatDialog.photo == null)
                        ? (chatController.currentChatDialog.type == CubeDialogType.PRIVATE)
                            ? const CircleAvatar(backgroundColor: kBaseGrey, backgroundImage: AssetImage('Assets/images/user.png'))
                            : SvgPicture.asset(
                                Assets.assets.icons.groupImage,
                                fit: BoxFit.cover,
                              )
                        : UserAvatar(
                            url: chatController.currentChatDialog.photo,
                            isActive: false,
                            height: 50.r,
                            width: 50.r,
                          ),
                    const SizedBox(width: distance_10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            chatController.currentChatDialog.name ?? '',
                            style: CustomTypography.bodyStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          chatController.isTyping
                              ? Visibility(
                                  visible: chatController.isTyping,
                                  child: Text(
                                    GayaStrings.typing.tr,
                                    style: CustomTypography.bodyStyle.copyWith(fontSize: 14.sp),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        actions: [
          CupertinoIconButton(
              icon: Icon(Icons.more_horiz, color: AppColors.black),
              onPressed: () => showMoreItemModalSheet(chatController.currentChatDialog.type))
        ],
        backgroundColor: kTransparentColor,
        elevation: 0,
      ),
      body: GetBuilder<ConversationController>(
          autoRemove: false,
          init: chatController,
          tag: dialogId,
          builder: (chatController) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                  Expanded(
                      child: chatController.isAttachmentLoading && chatController.chatMessagesList.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: distance_10, horizontal: distance_20),
                                      child: MessagePlaceholder(messagetype: _getMessageTypeForLoading()),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : chatController.isMessagesGetting
                              ? const Center(child: CupertinoActivityIndicator())
                              : ListView.builder(
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20).r,
                                  itemBuilder: (context, index) {
                                    bool? isLoading = chatController.chatGlobalVariables.globalIsAttachmentLoading;
                                    Helper.MessageType messageType = Helper.checkMessageType(chatController.chatMessagesList[index]);
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          if (chatController.isLoadingMore && index == chatController.chatMessagesList.length - 1)
                                            const Center(child: CupertinoActivityIndicator()),
                                          buildItem(index, chatController.chatMessagesList[index], messageType),
                                          if (isLoading && index - 1 == -1) ...chatController.uploadingMessagesMap.values
                                        ],
                                      ),
                                    );
                                  },
                                  itemCount: chatController.chatMessagesList.length,
                                  controller: chatController.listScrollController,
                                )),
                  // Positioned(
                  //   bottom: 0,
                  //   left: 0,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Visibility(
                  //         visible: chatController.isTyping,
                  //         child: const IsTypingWidget(),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  GetBuilder<ConversationController>(
                      init: chatController,
                      autoRemove: false,
                      id: 'textfield',
                      tag: dialogId,
                      builder: (chatController) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              height: (chatController.messageImage != null) && !chatController.isAttachmentLoading ? 160.h : null,
                              // height: (chatController.messageImage != null) ? 160.h : null,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 10.0.w,
                                  top: 10.h,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: GestureDetector(
                                        onTap: () => Helper.showAttachmentBottomSheet(context, chatController),
                                        child: SizedBox(
                                          child: GayaSvgAsset(
                                            width: 25.r,
                                            height: 25.r,
                                            Assets.assets.icons.addIcon,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10.w),
                                        padding: EdgeInsets.only(right: 12.w),
                                        // height: (chatController.messageImage != null) ? 160.h : null,
                                        alignment: Alignment.bottomRight,
                                        decoration:
                                            BoxDecoration(color: borderColor.withOpacity(0.30), borderRadius: BorderRadius.circular(30)),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                                child:
                                                    // (chatController.messageImage != null || chatController.pdfFiles.isNotEmpty)
                                                    (chatController.messageImage != null || chatController.pdfFiles.isNotEmpty) &&
                                                            !chatController.isAttachmentLoading
                                                        ? Stack(
                                                            clipBehavior: Clip.none,
                                                            alignment: Alignment.bottomRight,
                                                            children: [
                                                              if (chatController.messageImage != null && chatController.isVideo)
                                                                VideoViewWidget(
                                                                  mediaFile: chatController.messageImage!,
                                                                  isVideo: true,
                                                                  height: 150.h,
                                                                ),
                                                              if (chatController.isPdf && chatController.pdfFiles.isNotEmpty)
                                                                ClipRRect(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8).r,
                                                                      child: SelectedPDFPreview(
                                                                        path: chatController.pdfFiles.first.path,
                                                                        chatDialogId: chatController.currentChatDialog.dialogId ?? '',
                                                                        tapOnImageRemove: () {
                                                                          chatController.removeSelectedPdf();
                                                                        },
                                                                      ),
                                                                    )),
                                                              if (chatController.messageImage != null)
                                                                Container(
                                                                  width: 100.w,
                                                                  margin: const EdgeInsets.only(top: 8, bottom: 10, right: 10, left: 10),
                                                                  decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(4),
                                                                      image: chatController.messageImage != null
                                                                          ? DecorationImage(
                                                                              image: FileImage(chatController.messageImage ?? File('')),
                                                                              fit: BoxFit.cover)
                                                                          : null),
                                                                ),
                                                              if (!chatController.isPdf && chatController.pdfFiles.isEmpty)
                                                                Positioned(
                                                                  top: 5,
                                                                  right: 5,
                                                                  child: InkWell(
                                                                    child: Container(
                                                                      padding: const EdgeInsets.all(4),
                                                                      decoration: const BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                      child: const Icon(
                                                                        Icons.close,
                                                                        color: Colors.black,
                                                                        size: 14,
                                                                      ),
                                                                    ),
                                                                    onTap: () {
                                                                      chatController.removeNewImage();
                                                                    },
                                                                  ),
                                                                ),
                                                            ],
                                                          )
                                                        : MessageTextField(
                                                            fillColor: kTransparentColor,
                                                            isFilled: false,
                                                            isPassword: false,
                                                            maxlines: 5,
                                                            minlines: 1,
                                                            inputType: TextInputType.text,
                                                            hintText: GayaStrings.type_message.tr,
                                                            controller: chatController.messageTextField,
                                                            focusNode: chatController.messageTextFieldFocusNode,
                                                            borderColor: borderColor,
                                                            onChanged: (p0) {
                                                              chatController.sendIsTypingStatus();
                                                              chatController.updatetextField();
                                                            },
                                                          )),
                                            SizedBox(height: Platform.isIOS ? 3 : 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    (chatController.messageTextField.text.isEmpty &&
                                            (chatController.messageImage == null) &&
                                            !chatController.isPdf &&
                                            chatController.pdfFiles.isEmpty)
                                        ? Flexible(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                CupertinoIconButton(
                                                    icon: GayaSvgAsset(
                                                      Assets.assets.icons.cameraIcon,
                                                      width: 18.r,
                                                      height: 18.r,
                                                      color: AppColors.primary,
                                                    ),
                                                    onPressed: () async {
                                                      chatController.cameraImage(context: context);
                                                    })
                                              ],
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: CupertinoIconButton(
                                                icon: GayaSvgAsset(
                                                  Assets.assets.icons.sendIcon,
                                                  width: 21.r,
                                                  height: 21.r,
                                                  color: AppColors.primary,
                                                ),
                                                onPressed: () {
                                                  chatController.sendMessage(
                                                    context,
                                                    _getMessageTypeForLoading(),
                                                  );
                                                }),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            (chatController.messageTextField.text.isEmpty &&
                                    (chatController.messageImage == null) &&
                                    !chatController.isPdf &&
                                    chatController.pdfFiles.isEmpty)
                                ? Positioned(
                                    right: 10.w,
                                    bottom: 0,
                                    child: SocialMediaRecorder(
                                      sendRequestFunction: (soundFile, duration) {
                                        audioFileToSend = soundFile;
                                        chatController.sendMessage(context, _getMessageTypeForLoading(),
                                            audioFile: audioFileToSend ?? soundFile, duration: duration);
                                      },
                                      encode: AudioEncoderType.AAC,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        );
                      }),

                  /// keyboard and textField gap
                  SizedBox(height: 10.h),
                ],
              ),
            );
          }),
    );
  }

  _chatDetails(BuildContext context) async {
    try {
      print("Current dialog: ${chatController.currentChatDialog.toJson()}");
      if (chatController.currentUser != null && chatController.currentChatDialog.type == CubeDialogType.PRIVATE) {
        // Map<int, CubeUser> chatDetailScreenOccupants = {};
        // CubeUser? otherContactParticipiant;
        //
        //
        // var result = await getUsersByIds(chatController.currentChatDialog.occupantsIds!.toSet());
        // chatDetailScreenOccupants.clear();
        // chatDetailScreenOccupants.addAll(result);
        // chatDetailScreenOccupants.remove(chatController.currentUser?.id);
        // otherContactParticipiant =
        //     chatDetailScreenOccupants.values.isNotEmpty ? chatDetailScreenOccupants.values.first : CubeUser(fullName: "Absent");
        //
        // UserModel userModel = UserModel(
        //   uId: otherContactParticipiant.login,
        //   name: otherContactParticipiant.fullName,
        //   profilePicture: otherContactParticipiant.avatar,
        // );
        final otherUser = await chatController.getOtherUserProfile();
        if (otherUser == null) return;
        Routes.viewProfile(uid: otherUser.uId, model: otherUser, shouldReplace: false);
      } else if (chatController.currentUser != null) {
        Routes.openChatDetailInfo(dialogId: chatController.currentChatDialog.dialogId ?? '');
      }
    } catch (_) {
      MyLoggerServices.to.print('_chatDetails error: $_');
    }
  }

  Helper.MessageType _getMessageTypeForLoading() {
    return chatController.messageTextField.text.isNotEmpty && chatController.messageImage == null
        ? Helper.MessageType.text
        : chatController.messageImage != null && !chatController.isVideo
            ? Helper.MessageType.image
            : chatController.messageImage != null && chatController.isVideo
                ? Helper.MessageType.video
                : chatController.isPdf && chatController.pdfFiles.isNotEmpty
                    ? Helper.MessageType.document
                    : audioFileToSend != null
                        ? Helper.MessageType.audio
                        : Helper.MessageType.nullAttachment;
  }

  Future<List<CubeMessage>> getMessagesList() async {
    if (chatController.chatMessagesList.isNotEmpty) return Future.value(chatController.chatMessagesList);

    Completer<List<CubeMessage>> completer = Completer();
    List<CubeMessage>? messages;
    try {
      await Future.wait<void>([
        chatController.getMessagesByDate(0, false).then((loadedMessages) {
          chatController.isLoading = false;
          messages = loadedMessages;
        }),
        getOccupantsOfTheChatDialog()
      ]);
      debugPrint("getMessagesList");
      completer.complete(messages);
    } catch (error) {
      print("getMessagesList error: $error");
      completer.completeError(error);
    }
    return completer.future;
  }

  getOccupantsOfTheChatDialog() async {
    if (chatController.currentChatDialog.type == CubeDialogType.PUBLIC) {
      await getDialogOccupants(chatController.currentChatDialog.dialogId ?? '').then((pagedResult) {
        if (pagedResult != null && pagedResult.items.isNotEmpty) {
          chatController.occupants.clear();
          Map<int, CubeUser> map = {for (var item in pagedResult.items) item.id ?? 1: item};
          chatController.occupants.addAll(map);
          chatController.occupants.remove(chatController.currentUser?.id);
        }
      }).catchError((error) {});
    } else {
      getAllUsersByIds(chatController.currentChatDialog.occupantsIds!.toSet()).then((result) {
        chatController.occupants.addAll({for (var item in result!.items) item.id: item});
        print(chatController.occupants.length);
      });
    }
  }

  Widget buildItem(int index, CubeMessage message, Helper.MessageType messageType) {
    markAsReadIfNeed() {
      var isOpponentMsgRead = message.readIds != null && message.readIds!.contains(chatController.currentUser?.id);
      // print("markAsReadIfNeed message= $message, isOpponentMsgRead= $isOpponentMsgRead");
      if (message.senderId != chatController.currentUser?.id && !isOpponentMsgRead) {
        if (message.readIds == null) {
          message.readIds = [chatController.currentUser?.id ?? 0];
        } else {
          message.readIds!.add(chatController.currentUser?.id ?? 0);
        }

        if (CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Ready) {
          chatController.currentChatDialog.readMessage(message);
        } else {
          chatController.unreadMessages.add(message);
        }
      }
    }

    Widget getReadDeliveredWidget() {
      log("[getReadDeliveredWidget]");
      bool messageIsRead() {
        log("[getReadDeliveredWidget] messageIsRead");
        if (chatController.currentChatDialog.type == CubeDialogType.PRIVATE) {
          return message.readIds != null && (message.recipientId == null || message.readIds!.contains(message.recipientId));
        }
        return message.readIds != null &&
            message.readIds!.any((int id) => id != chatController.currentUser?.id && chatController.occupants.keys.contains(id));
      }

      bool messageIsDelivered() {
        log("[getReadDeliveredWidget] messageIsDelivered");
        if (chatController.currentChatDialog.type == CubeDialogType.PRIVATE) {
          return message.deliveredIds != null && (message.recipientId == null || message.deliveredIds!.contains(message.recipientId));
        }
        return message.deliveredIds != null &&
            message.deliveredIds!.any((int id) => id != chatController.currentUser?.id && chatController.occupants.keys.contains(id));
      }

      if (messageIsRead()) {
        return const Stack(children: <Widget>[
          Icon(
            Icons.check,
            size: 15.0,
            color: blueColor,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.check,
              size: 15.0,
              color: blueColor,
            ),
          )
        ]);
      } else if (messageIsDelivered()) {
        return Stack(children: <Widget>[
          Icon(
            Icons.check,
            size: 15.0,
            color: UtilColors.greyColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.check,
              size: 15.0,
              color: UtilColors.greyColor,
            ),
          )
        ]);
      } else {
        return Icon(
          Icons.check,
          size: 15.0,
          color: UtilColors.greyColor,
        );
      }
    }

    Widget getDateWidget() {
      return Text(
        DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000)),
        style: TextStyle(color: UtilColors.greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
      );
    }

    Widget getHeaderDateWidget() {
      return Container(
        alignment: Alignment.center,
        width: Get.width * 0.25,
        height: 25.h,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: AppColors.divider, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8).r),
        child: Text(
          DateFormat('dd MMMM').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000)),
          style: TextStyle(color: AppColors.black, fontSize: 14.0.sp, fontStyle: FontStyle.italic),
        ),
      );
    }

    bool isHeaderView() {
      int headerId = int.parse(DateFormat('ddMMyyyy').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000)));
      if (index >= chatController.chatMessagesList.length - 1) {
        return false;
      }
      var msgPrev = chatController.chatMessagesList[index + 1];
      int nextItemHeaderId = int.parse(DateFormat('ddMMyyyy').format(DateTime.fromMillisecondsSinceEpoch(msgPrev.dateSent! * 1000)));
      var result = headerId != nextItemHeaderId;
      return result;
    }

    bool? isReadyByAllMembers;
    // AI Match Default Initial Messages rendered in the center
    // /(message?.body == null || (message?.body?.isEmpty ?? true))
    if (chatController.checkIfAIMatchInitialMessage(message)) {
      return AIMatchInitialMesgaeWidget(
        message: message,
        dialogId: chatController.currentChatDialog.dialogId ?? '',
      );
    } else if (message.senderId == chatController.currentUser?.id) {
      if (chatController.currentChatDialog.type == CubeDialogType.PUBLIC) {
        isReadyByAllMembers = chatController.occupants.length == message.readIds?.length;
      }
      return Column(
        key: Helper.MessageType.audio == messageType ? UniqueKey() : null,
        children: [
          isHeaderView() ? getHeaderDateWidget() : const SizedBox.shrink(),
          // isHeaderView() ? const AutoBootChatWidget() : const SizedBox.shrink(),
          UserMessageWidget(
            onLongTap: () async {
              if (chatController.currentUser == null) return;
              showGayaAlertDialogButton(
                context: context,
                actionText: GayaStrings.delete_message.tr,
                tapOnYes: () async {
                  Navigator.pop(context);
                  chatController.deleteMessage(message, true);
                },
                tapOnNo: () {
                  Navigator.pop(context);
                },
              );
            },
            index: index,
            message: message,
            messageType: messageType,
            dialogId: chatController.currentChatDialog.dialogId ?? '',
            sentTime: getTimeWidget(message),
            deliveryStatus: getReadDeliverStatus(message, isReadByAll: isReadyByAllMembers),
          ),
        ],
      );
      // message.
    }
    // Other participant messages
    else {
      markAsReadIfNeed();
      return OtherUserMessageWidget(
        key: Helper.MessageType.audio == messageType ? UniqueKey() : null,
        profilePicture: GestureDetector(
          onTap: () => Routes.viewProfile(uid: chatController.occupants[message.senderId]!.login),
          child: (chatController.occupants[message.senderId]?.avatar == null ||
                  chatController.occupants[message.senderId]?.avatar?.isEmpty == true)
              ? CircleAvatar(radius: 20.r, backgroundColor: kBaseGrey, backgroundImage: const AssetImage('Assets/images/user.png'))
              : UserAvatar(url: chatController.occupants[message.senderId]!.avatar!.toString(), isActive: false, height: 40.r, width: 40.r),
        ),
        // currentMessage: messagesList[index],
        index: index,
        message: message,
        messageType: messageType,
        dialogId: chatController.currentChatDialog.dialogId ?? '',
        sentTime: getTimeWidget(message),
        deliveryStatus: getReadDeliverStatus(message),
      );
    }
  }

  String getReadDeliverStatus(CubeMessage message, {bool? isReadByAll}) {
    if (messageIsRead(message) && isReadByAll != false) {
      return 'read';
    } else if (messageIsDelivered(message)) {
      return 'delivered';
    } else {
      return 'notDelivered';
    }
  }

  bool messageIsRead(CubeMessage message) {
    if (chatController.currentChatDialog.type == CubeDialogType.PRIVATE) {
      return message.readIds != null && (message.recipientId == null || message.readIds!.contains(message.recipientId));
    }
    return message.readIds != null &&
        message.readIds!.any((int id) => id != chatController.currentUser?.id && chatController.occupants.keys.contains(id));
  }

  bool messageIsDelivered(CubeMessage message) {
    if (chatController.currentChatDialog.type == CubeDialogType.PRIVATE) {
      return message.deliveredIds != null && (message.recipientId == null || message.deliveredIds!.contains(message.recipientId));
    }
    return message.deliveredIds != null &&
        message.deliveredIds!.any((int id) => id != chatController.currentUser?.id && chatController.occupants.keys.contains(id));
  }

  String getTimeWidget(CubeMessage message) {
    if (message != null) {
      return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000));
    } else {
      return 'Not available';
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && chatController.chatMessagesList[index - 1].id == chatController.currentUser?.id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && chatController.chatMessagesList[index - 1].id != chatController.currentUser?.id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void showMoreItemModalSheet(int? dialogType) {
    methods.Methods.showCircularModalSheet(
        context,
        Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(dialogType != CubeDialogType.PRIVATE ? GayaStrings.group_info.tr : GayaStrings.view_profile.tr),
              onTap: () {
                Navigator.pop(context);
                _chatDetails(context);
              },
            ),
            SizedBox(
              height: 20.h,
            )
          ],
        ));
  }
}

class IsTypingWidget extends StatelessWidget {
  const IsTypingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        height: 30.h,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 70).r,
        width: 58.w,
        padding: const EdgeInsets.symmetric(horizontal: distance_16, vertical: distance_12),
        decoration: BoxDecoration(
            color: kBaseGrey,
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16).r,
                topRight: const Radius.circular(16).r,
                bottomLeft: const Radius.circular(4).r,
                bottomRight: const Radius.circular(16).r)),
        child: Row(
          children: [
            Container(
              height: 6.r,
              width: 6.r,
              decoration: BoxDecoration(color: AppColors.secondary2, shape: BoxShape.circle),
            ),
            SizedBox(
              width: 2.r,
            ),
            Container(
              height: 6.r,
              width: 6.r,
              decoration: BoxDecoration(color: AppColors.secondary2, shape: BoxShape.circle),
            ),
            SizedBox(
              width: 2.r,
            ),
            Container(
              height: 6.r,
              width: 6.r,
              decoration: BoxDecoration(color: AppColors.secondary2, shape: BoxShape.circle),
            ),
          ],
        ));
  }
}
