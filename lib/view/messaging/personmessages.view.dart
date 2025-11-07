// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/app.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/message.controller.dart';
import 'package:gaya/controller/profile.controller.dart';
import 'package:gaya/controller/report_controller.dart';
import 'package:gaya/model/chatroom.model.dart';
import 'package:gaya/model/messaging.model/messages.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_report_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/widgets/messaging.widgets/load.image.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:provider/provider.dart';

import '../../components/textfield.component.dart';
import '../../controller/block_controller.dart';
import '../../services/notification/notification_api/notification_api.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';
import '../../utils/theme/app_typography.dart';
import '../../widgets/messaging.widgets/currentuser.messages.section.dart';
import '../../widgets/messaging.widgets/otheruser.message.section.dart';
import 'components/online_dot.dart';

final bucket = PageStorageBucket();

class PersonMessageView extends StatefulWidget {
  const PersonMessageView({Key? key, required this.name, required this.profilePicture, required this.uid, required this.chatRoomModel})
      : super(key: key);

  final String name;
  final String profilePicture;
  final String uid;
  final ChatRoomModel chatRoomModel;

  @override
  State<PersonMessageView> createState() => _PersonMessageViewState();
}

class _PersonMessageViewState extends State<PersonMessageView> {
  /// for message typing indicator
  final Debouncer _debouncer = Debouncer(delay: 3000.milliseconds);
  String otherChatParticipantFcmToken = '';
  final NotificationApiHitting _notificationApiHitting = NotificationApiHitting();
  late ScrollController messagesScrollController;

  @override
  void initState() {
    messagesScrollController = ScrollController();
    final controller = context.read<MessageController>();
    controller.getMesssages = controller.getMessages(widget.chatRoomModel.chatRoomId!);
    getOtherParticipantFcmToken(widget.chatRoomModel);
    super.initState();
  }

  @override
  void dispose() {
    messagesScrollController.dispose();
    super.dispose();
  }

  void openProfile({required UserModel userModel}) {
    final userModel = UserModel(uId: widget.uid, name: widget.name, profilePicture: widget.profilePicture);
    Routes.viewProfile(uid: userModel.uId, model: userModel);
  }

  void showMoreItemModalSheet() {
    Methods.showCircularModalSheet(
        context,
        Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(GayaStrings.view_profile.tr),
              onTap: () {
                Navigator.pop(context);
                //goto user's profile.
                openProfile(userModel: UserModel(uId: widget.uid, name: widget.name, profilePicture: widget.profilePicture));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: Text(GayaStrings.report_user.tr),
              onTap: () {
                Navigator.pop(context);
                reportTextFieldBottomModal(
                  context,
                  onSubmit: (String reportMsg) async {
                    final controller = Provider.of<ProfileController>(context, listen: false);
                    UserModel userModel = UserModel.to;
                    bool isExist = await controller.checkCurrentUserReportedThatUserAlready(widget.uid);
                    if (!isExist) {
                      await ReportController.to.reportAUser(userModel.uId ?? '', context, reportMsg: reportMsg);
                      Navigator.pop(context);
                    } else {
                      snackBar(context, GayaStrings.already_reported.tr, kRedColor);
                    }
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(GayaStrings.block_user.tr),
              onTap: () async {
                Navigator.pop(context);
                BlockController.to.block(userId: widget.uid, context: context);
              },
            ),
            SizedBox(
              height: 20.h,
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final messageController = Provider.of<MessageController>(context, listen: true);
    final chatroom = context.read<MessageController>().listeningForMessages(widget.chatRoomModel);
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          centerTitle: false,
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Row(
            children: [
              InkWell(
                highlightColor: kTransparentColor,
                onTap: () => openProfile(userModel: UserModel(uId: widget.uid, name: widget.name, profilePicture: widget.profilePicture)),
                child: widget.profilePicture == ''
                    ? const CircleAvatar(backgroundColor: kBaseGrey, backgroundImage: AssetImage('Assets/images/user.png'))
                    : CircleAvatar(radius: 20.r, child: ProfileImageWidget(url: widget.profilePicture)),
              ),
              const SizedBox(width: distance_10),
              InkWell(
                highlightColor: kTransparentColor,
                onTap: () => openProfile(userModel: UserModel(uId: widget.uid, name: widget.name, profilePicture: widget.profilePicture)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: CustomTypography.bodyStyle),
                    PresenceIndicatorWidget(uid: widget.uid),
                  ],
                ),
              ),
            ],
          ),
          actions: [CupertinoIconButton(icon: Icon(Icons.more_horiz, color: AppColors.black), onPressed: showMoreItemModalSheet)],
          backgroundColor: kTransparentColor,
          elevation: 0,
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: messageController.getMesssages,
            builder: (context, typingSnap) {
              if (typingSnap.connectionState == ConnectionState.waiting || typingSnap.connectionState == ConnectionState.waiting) {
              } else if (typingSnap.connectionState == ConnectionState.active || typingSnap.connectionState == ConnectionState.active) {
                if (typingSnap.hasData || typingSnap.hasData || typingSnap.data != null) {
                  try {
                    DocumentSnapshot typinngQuery = typingSnap.data as DocumentSnapshot;
                    ChatRoomModel chatmodel = ChatRoomModel.fromMap(typinngQuery.data() as Map<String, dynamic>);
                    List? typingList = chatmodel.typing;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Expanded(
                            child: StreamProvider<QuerySnapshot?>(
                                initialData: null,
                                create: (context) => chatroom,
                                child: Consumer<QuerySnapshot?>(builder: (context, listenForChat, _) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: distance_10, horizontal: distance_20),
                                    child: Column(
                                      children: [

                                        listenForChat == null
                                            ? const SizedBox()
                                            : Expanded(
                                                child: ListView.builder(
                                                    reverse: true,
                                                    controller: messagesScrollController,
                                                    padding: EdgeInsets.zero,
                                                    itemCount: listenForChat.docs.length,
                                                    itemBuilder: (context, index) {
                                                      MessageModel currentMessage =
                                                          MessageModel.fromMap(listenForChat.docs[index].data() as Map<String, dynamic>);

                                                      return currentMessage.sender != widget.uid
                                                          ? CurrentUserMessages(
                                                              currentMessage: currentMessage,
                                                              onLongTap: () async {
                                                                if (widget.chatRoomModel.chatRoomId != null &&
                                                                    currentMessage.messageId != null) {
                                                                  showGayaAlertDialogButton(
                                                                    context: context,
                                                                    actionText: GayaStrings.delete_message.tr,
                                                                    tapOnYes: () async {
                                                                      Navigator.pop(context);
                                                                      // ignore: use_build_context_synchronously
                                                                      await context.read<MessageController>().deleteChatroomSinglemessage(
                                                                          widget.chatRoomModel.chatRoomId ?? '',
                                                                          currentMessage.messageId ?? '');
                                                                      if (widget.chatRoomModel.lastMessage == '') return;
                                                                      if (index + listenForChat.docs.length - 1 ==
                                                                              listenForChat.docs.length - 1 &&
                                                                          widget.chatRoomModel.lastMessage == currentMessage.message) {
                                                                        await context.read<MessageController>().deleteChatroomLastMessage(
                                                                              widget.chatRoomModel.chatRoomId ?? '',
                                                                            );
                                                                      }
                                                                    },
                                                                    tapOnNo: () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                  );
                                                                  // final result = await showConfirmationDialog(
                                                                  //     context: context,
                                                                  //     title: 'Are you sure to delete this message?',
                                                                  //     cancelLabel: 'Cancel',
                                                                  //     actions: [
                                                                  //       const AlertDialogAction(
                                                                  //         key: 1,
                                                                  //         label: 'Delete Message',
                                                                  //         textStyle: TextStyle(
                                                                  //           fontSize: 18,
                                                                  //         ),
                                                                  //       ),
                                                                  //     ]);

                                                                  // if (result == 1) {
                                                                  //   // ignore: use_build_context_synchronously
                                                                  //   await context.read<MessageController>().deleteChatroomSinglemessage(
                                                                  //       widget.chatRoomModel.chatRoomId ?? '',
                                                                  //       currentMessage.messageId ?? '');
                                                                  //   if (widget.chatRoomModel.lastMessage == '') return;
                                                                  //   if (index + listenForChat.docs.length - 1 ==
                                                                  //           listenForChat.docs.length - 1 &&
                                                                  //       widget.chatRoomModel.lastMessage == currentMessage.message) {
                                                                  //     await context.read<MessageController>().deleteChatroomLastMessage(
                                                                  //           widget.chatRoomModel.chatRoomId ?? '',
                                                                  //         );
                                                                  //   }
                                                                  // } else {}
                                                                }
                                                              },
                                                            )
                                                          : OtherUserMessageSection(
                                                              profilePicture: widget.profilePicture,
                                                              uid: widget.uid,
                                                              currentMessage: currentMessage,
                                                              index: index,
                                                              messageController: messageController,
                                                              listenForChat: listenForChat.docs,
                                                            );
                                                    }),
                                              ),
                                        const LoadImage(),
                                        typingList?.length == 2
                                            ? Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 40),
                                                  child: SvgPicture.asset("Assets/icons/Bubbles.svg"),
                                                ),
                                              )
                                            : typingList?.length == 1 &&
                                                    typingList?.contains(FirebaseAuth.instance.currentUser!.uid) == false
                                                ? Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 40),
                                                      child: SvgPicture.asset("Assets/icons/Bubbles.svg"),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                      ],
                                    ),
                                  );
                                }))),
                        SafeArea(
                          child: Consumer<MessageController>(builder: (context, controller, child) {
                            return SizedBox(
                              height: (controller.messageImage != null) ? 160 : null,
                              // decoration: const BoxDecoration(color: kWhiteColor),
                              child: Padding(
                                padding: const EdgeInsets.only(left: distance_20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: GestureDetector(
                                          onTap: () => context.read<MessageController>().messagingImage(widget.chatRoomModel),
                                          child: SvgIconWidget.imageOutline(color: AppColors.primary)),
                                    ),
                                    const SizedBox(
                                      width: distance_10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        // padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.only(right: 20),
                                        height: (controller.messageImage != null) ? 160 : null,
                                        alignment: Alignment.bottomRight,
                                        decoration:
                                            BoxDecoration(color: borderColor.withOpacity(0.30), borderRadius: BorderRadius.circular(30)),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                                child: (controller.messageImage != null)
                                                    ? Stack(
                                                        alignment: Alignment.bottomRight,
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            margin: const EdgeInsets.all(10),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(4),
                                                                image: controller.messageImage != null
                                                                    ? DecorationImage(
                                                                        image: FileImage(controller.messageImage ?? File('')),
                                                                        fit: BoxFit.cover)
                                                                    : null),
                                                          ),
                                                          Positioned(
                                                              top: 14,
                                                              right: 14,
                                                              child: InkWell(
                                                                child: Container(
                                                                  padding: const EdgeInsets.all(4),
                                                                  decoration: const BoxDecoration(
                                                                    color: Colors.white,
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                  child: const Icon(Icons.close, color: Colors.black, size: 14),
                                                                ),
                                                                onTap: () {
                                                                  controller.removeNewImage();
                                                                },
                                                              )),
                                                        ],
                                                      )
                                                    : TextField2(
                                                        fillColor: kTransparentColor,
                                                        isFilled: false,
                                                        isPassword: false,
                                                        maxlines: 5,
                                                        minlines: 1,
                                                        inputType: TextInputType.text,
                                                        hintText: GayaStrings.type_message.tr,
                                                        controller: messageController.messagetextfieldController,
                                                        borderColor: borderColor)),
                                            TextButton(
                                                onPressed: () async {
                                                  if (controller.isSendingNewMessage) return;
                                                  if (controller.messageImage == null &&
                                                      controller.messagetextfieldController.text.isEmpty) {
                                                    return;
                                                  }
                                                  if (controller.messageImage != null) {
                                                    await context.read<MessageController>().sendMessages(context, widget.chatRoomModel,
                                                        isTextMessageOnly: false, token: otherChatParticipantFcmToken);
                                                    // await sendMessage(context, isTextMessageOnly: false);
                                                    messagesScrollController.animateTo(0.0,
                                                        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                                  } else {
                                                    await context.read<MessageController>().sendMessages(context, widget.chatRoomModel,
                                                        isTextMessageOnly: true, token: otherChatParticipantFcmToken);
                                                    // await sendMessage(context, isTextMessageOnly: true);
                                                    messagesScrollController.animateTo(0.0,
                                                        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                                  }
                                                },
                                                child: Text(
                                                  GayaStrings.send_txt.tr,
                                                  style: TextStyle(
                                                      color: (controller.isSendingNewMessage == true) ? Colors.grey : kprimaryColor,
                                                      fontWeight: FontWeight.w600),
                                                )),
                                            SizedBox(height: DeviceCheck.isIOS ? 3 : 0)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                        )
                      ],
                    );
                  } catch (_) {}
                }
              }
              return const SizedBox.shrink();
            }));
  }

  Future<void> getOtherParticipantFcmToken(ChatRoomModel chatRoomModel) async {
    try {
      final usermodel = UserModel.to;
      int? receiverIndex = chatRoomModel.participants?.indexWhere((element) => element != usermodel.uId);
      if (receiverIndex == null || receiverIndex == -1) return;
      final OtherUserFCM =
          (await FirebaseFirestore.instance.collection('users').doc(chatRoomModel.participants![receiverIndex]).get()).data()?['fm_token'];

      if (OtherUserFCM.isBlank == false) {
        otherChatParticipantFcmToken = OtherUserFCM;
      }
    } catch (_) {
      debugPrint('getOtherParticipantFcmToken error: $_');
    }
  }

  sendMessage(BuildContext context, {required bool isTextMessageOnly}) async {
    String message = '';
    if (isTextMessageOnly == false) {
      context.read<MessageController>().uploadImageMessage(widget.chatRoomModel);
    } else {
      message = context.read<MessageController>().messagetextfieldController.text.trim();
      context.read<MessageController>().messagetextfieldController.clear();
    }

    if (message.isBlank == true && isTextMessageOnly == true) return;
    if (isTextMessageOnly == false && message.length > 10000) {
      GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: GayaStrings.long_message.tr);
      return;
    }

    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user = firebaseAuth.currentUser;

    MessageModel messagesModel = MessageModel(
      sender: user!.uid,
      message: message,
      createTime: DateTime.now(),
      messageId: uuid.v1(),
    );

    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatRoomModel.chatRoomId)
        .collection('messages')
        .doc(messagesModel.messageId)
        .set(messagesModel.toMap());
    widget.chatRoomModel.lastMessage = message;
    widget.chatRoomModel.lastMessageTime = DateTime.now();
    widget.chatRoomModel.isReadSender = true;
    widget.chatRoomModel.isReadReceiver = false;
    widget.chatRoomModel.lastMesgUserId = user.uid.toString();
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatRoomModel.chatRoomId)
        .set(widget.chatRoomModel.toUpdateRoomOnSentMap(), SetOptions(merge: true));
    FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatRoomModel.chatRoomId).update({
      "typing": FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
    });

    int? receiverIndex = widget.chatRoomModel.participants?.indexWhere((element) => element != messagesModel.sender);
    final usermodel = UserModel.to;
    if (receiverIndex != null && receiverIndex != -1 && otherChatParticipantFcmToken != '') {
      //do notification on fcm
      final fcmMessageModel = FcmMessageModel(
          chatroomId: widget.chatRoomModel.chatRoomId ?? '',
          messageContent: messagesModel.message ?? '',
          messageTitle: usermodel.name ?? '',
          receiverFcm: otherChatParticipantFcmToken);
      _notificationApiHitting.callOnFcmApiChat(fcmMessageModel
          // gaya_message: "${usermodel.name} sent you a new message.", fcmToken: otherChatParticipantFcmToken
          );
      log('new message sent successfully: $otherChatParticipantFcmToken');
    }
  }
}
