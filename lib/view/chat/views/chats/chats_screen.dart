import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../../model/chatroom.model.dart';
import '../../../../model/user.model.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../shared/view/widget/gaya_alert_dialog.dart';
import '../../../../shared/view/widget/gaya_floating_action_button.dart';
import '../../../../utils/asset_images.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/textstyles.dart';
import '../../../../widgets/messaging.widgets/nomessage.widget.dart';
import '../../../group.view.dart';
import '../../../messaging/components/messages_skeleton_widget.dart';
import '../../../messaging/services/firestore/messages_firestore_services.dart';
import '../../components/paginated_connectycube_users.dart';
import '../../controllers/chat_controller.dart';
import '../group_detail/new_group_screen.dart';
import 'active_chat_user.dart';
import 'already_chatted_user_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // done by mak
  TextEditingController searchController = TextEditingController();
  final userModel = UserModel.to;
  @override
  void initState() {
    super.initState();
    if (UserModel.to.uId != null) {
      chatController.loginToCC(context, CubeUser(login: userModel.uId, password: userModel.uId));
    }
    chatController.getOnlineFriends(context);
    chatController.checkIfNotSubscribedToNewMsgsThenreSubscribe();
  }

  @override
  void dispose() {
    chatController.clearSearchValues();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      chatController.update();
    });
    searchController.dispose();
    super.dispose();
  }

  final chatController = ChatController.to();
  bool showProgressindicator = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          title: Text(GayaStrings.message_txt.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: ExtendedNestedScrollView(
          onlyOneScrollInBody: true,
          headerSliverBuilder: (context, _) {
            return [
              //search bar
              DynamicSliverAppBar(
                maxHeight: 80,
                child: Padding(
                  padding: const EdgeInsets.only(left: distance_15, right: distance_15, bottom: 5).r,
                  child: CupertinoSearchTextField(
                    onSuffixTap: () => [chatController.clearSearchValues(), chatController.update()],
                    controller: chatController.searchUsersTextField,
                    placeholder: GayaStrings.search_txt.tr,
                    onSubmitted: (value) => chatController.searchUsers(value.trim()),
                  ),
                ),
              ),
              //suggestions
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const Divider(
                      height: 1,
                    ),
                    GetBuilder<ChatController>(
                        init: chatController,
                        id: 'onlineFriendsList',
                        builder: (chatController) {
                          return Container(
                              margin: const EdgeInsets.only(top: distance_10).r,
                              padding: const EdgeInsets.only(
                                left: 7.0,
                                right: 7.0,
                                top: distance_5,
                              ).r,
                              constraints: (!chatController.isLoadingOnlineFriend && chatController.onlineFriendsList.isEmpty)
                                  ? BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.0)
                                  : BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.13),
                              child: (chatController.isLoadingOnlineFriend && chatController.onlineFriendsList.isEmpty)
                                  ? ListView(scrollDirection: Axis.horizontal, children: const [
                                      MessageSuggestionsSkeleton(),
                                      MessageSuggestionsSkeleton(),
                                      MessageSuggestionsSkeleton(),
                                      MessageSuggestionsSkeleton(),
                                    ])
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) => Column(children: [
                                        SizedBox(height: distance_20.h, width: distance_15.w),
                                        const Divider(color: kBaseGrey),
                                      ]),
                                      padding: const EdgeInsets.only(left: distance_10, right: distance_10).r,
                                      itemCount: chatController.onlineFriendsList.length,
                                      itemBuilder: (context, index) {
                                        UserModel otherUser = chatController.onlineFriendsList[index];
                                        final currentUser = FirebaseAuth.instance.currentUser;
                                        return (currentUser?.uid == otherUser.uId)
                                            ? const SizedBox.shrink()
                                            : StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                                return GestureDetector(
                                                    onTap: () async {
                                                      try {
                                                        if (otherUser.uId != null && currentUser?.uid != null) {
                                                          setState(() {
                                                            showProgressindicator = true;
                                                          });
                                                          await getUserByLogin(otherUser.uId ?? '').then((cubeUser) {
                                                            chatController.createNewConversation(context, {cubeUser?.id ?? 123}, false);
                                                            Future.delayed(const Duration(seconds: 3)).then((value) => setState(() {
                                                                  showProgressindicator = false;
                                                                }));
                                                          }).catchError((error) {
                                                            setState(() {
                                                              showProgressindicator = false;
                                                            });
                                                          });
                                                        }
                                                      } catch (_) {}
                                                    },
                                                    child: showProgressindicator
                                                        ? Column(
                                                            children: [
                                                              Container(
                                                                  width: 62.r,
                                                                  height: 62.r,
                                                                  padding: const EdgeInsets.all(8).r,
                                                                  decoration:
                                                                      BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                                                  child: const Center(child: CupertinoActivityIndicator())),
                                                              SizedBox(height: 8.h),
                                                              Text(
                                                                (otherUser.name?.length ?? 0) > 10
                                                                    ? '${otherUser.name!.substring(0, 7)}...'
                                                                    : otherUser.name ?? 'Anonymous user',
                                                                textAlign: TextAlign.center,
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    fontSize: 12.64.sp, height: 1.18, fontWeight: FontWeight.w400),
                                                              ),
                                                            ],
                                                          )
                                                        : ActiveChatUser(
                                                            url: otherUser.profilePicture ?? "",
                                                            userName: (otherUser.name?.length ?? 0) > 10
                                                                ? '${otherUser.name!.substring(0, 7)}...'
                                                                : otherUser.name ?? 'Anonymous user',
                                                            isActive: true,
                                                          ));
                                              });
                                      },
                                    ));
                        }),
                  ],
                ),
              ),
            ];
          },
          body: StatefulBuilder(builder: (context, update) {
            return EasyRefresh(
              // key: UniqueKey(),
              header: headerAbove,
              onRefresh: () => update(() {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  chatController.getAllUpdatedChatListIfNeeded();
                });
              }),
              child: GetBuilder<ChatController>(
                init: chatController,
                builder: (chatController) {
                  if (chatController.checkIsChatlistNotEmptyAndSerachIsOff()) {
                    return (chatController.chatsList.isEmpty)
                        ? SizedBox(height: MediaQuery.sizeOf(context).height * 0.65, child: const AbsorbPointer(child: NoMessageWidget()))
                        : ListView.builder(
                            itemCount: chatController.chatsList.length,
                            itemBuilder: (ctx, index) {
                              var dialog = chatController.chatsList[index].data;
                              return (dialog.lastMessage == null &&
                                      dialog.lastMessageDateSent == null &&
                                      dialog.type != CubeDialogType.PUBLIC)
                                  ? const SizedBox.shrink()
                                  : AlreadyChattedUserWidget(
                                      isMatchDialog: dialog.customData?.className == 'AIMatch' ? true : false,
                                      type: (chatController.chatsList[index].data.type == CubeDialogType.PRIVATE) ? 'Private' : 'Group',
                                      profileImage: chatController.chatsList[index].data.photo ?? '',
                                      ontap: () {
                                        Routes.openConversationAndRemovePreviousConversationRouteIfOpen(dialog);
                                        chatController.onOpenChat(index: index);
                                      },
                                      onLongTap: () {
                                        showGayaAlertDialogButton(
                                          context: context,
                                          actionText: GayaStrings.delete_chat.tr,
                                          tapOnYes: () async {
                                            Navigator.pop(context);

                                            chatController.deleteSingleConversation(
                                                chatController.chatsList[index].data.dialogId ?? '', true,
                                                ctx: context);
                                          },
                                          tapOnNo: () => Navigator.pop(context),
                                        );
                                      },
                                      name: chatController.chatsList[index].data.name ?? GayaStrings.not_available.tr,
                                      message: chatController.chatsList[index].data.lastMessage ?? '',
                                      time: chatController.chatsList[index].data.lastMessageDateSent != null
                                          ? Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                  chatController.chatsList[index].data.lastMessageDateSent! * 1000))
                                              .fromNow()
                                              .toString()
                                          : Jiffy(chatController.chatsList[index].data.createdAt ?? DateTime.now()).fromNow().toString(),
                                      isRead: chatController.chatsList[index].data.unreadMessageCount == null ||
                                              chatController.chatsList[index].data.unreadMessageCount == 0
                                          ? true
                                          : false,
                                      unreadMessagesCount: (chatController.chatsList[index].data.unreadMessageCount == null ||
                                              chatController.chatsList[index].data.unreadMessageCount == 0)
                                          ? 0
                                          : chatController.chatsList[index].data.unreadMessageCount!,
                                    );
                            });
                  }

                  if (chatController.checkIsChatlistIsEmptyAndChatIsLoading()) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15).r,
                      child: MessagesSkeletonWidget(
                        horizontolPadding: 16.0,
                      ),
                    );
                  }
                  if (chatController.searchUsersTextField.text.isNotEmpty) {
                    return (chatController.searchUsersTextField.text.isNotEmpty)
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20).r,
                            height: MediaQuery.sizeOf(context).height * 0.75,
                            child: const PaginatedSearchedConnectyCubeMembersToCreateNewChat(
                              isWithoutCheckboxTile: true,
                            ))
                        : const SizedBox.shrink();
                  } else {
                    return (chatController.chatsList.isEmpty)
                        ? SizedBox(height: MediaQuery.sizeOf(context).height * 0.65, child: const AbsorbPointer(child: NoMessageWidget()))
                        : ListView.builder(
                            itemCount: chatController.chatsList.length,
                            itemBuilder: (ctx, index) {
                              var dialog = chatController.chatsList[index].data;
                              try {
                                print(chatController.msgSubscription);
                              } catch (_) {}
                              return (dialog.lastMessage == null &&
                                      dialog.lastMessageDateSent == null &&
                                      dialog.type != CubeDialogType.PUBLIC)
                                  ? const SizedBox.shrink()
                                  : AlreadyChattedUserWidget(
                                      isMatchDialog: dialog.customData?.className == 'AIMatch' ? true : false,
                                      type: (chatController.chatsList[index].data.type == CubeDialogType.PRIVATE) ? 'Private' : 'Group',
                                      profileImage: chatController.chatsList[index].data.photo ?? '',
                                      ontap: () {
                                        // ChatController.to().updateCubeCurrentChat(dialog);
                                        Routes.openConversationAndRemovePreviousConversationRouteIfOpen(dialog);
                                        chatController.onOpenChat(index: index);
                                        // Get.toNamed(
                                        //   RouteHelper.conversation,
                                        // )?.then((value) => ChatController.to().refreshChatsList());
                                      },
                                      onLongTap: () {
                                        showGayaAlertDialogButton(
                                          context: context,
                                          actionText: GayaStrings.delete_chat.tr,
                                          tapOnYes: () async {
                                            Navigator.pop(context);
                                            chatController.deleteSingleConversation(
                                                chatController.chatsList[index].data.dialogId ?? '', true,
                                                ctx: context);
                                          },
                                          tapOnNo: () => Navigator.pop(context),
                                        );
                                      },
                                      name: chatController.chatsList[index].data.name ?? GayaStrings.not_available.tr,
                                      message: chatController.chatsList[index].data.lastMessage ?? '',
                                      time: chatController.chatsList[index].data.lastMessageDateSent != null
                                          ? Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                  chatController.chatsList[index].data.lastMessageDateSent! * 1000))
                                              .fromNow()
                                              .toString()
                                          : Jiffy(chatController.chatsList[index].data.createdAt ?? DateTime.now()).fromNow().toString(),
                                      isRead: chatController.chatsList[index].data.unreadMessageCount == null ||
                                              chatController.chatsList[index].data.unreadMessageCount == 0
                                          ? true
                                          : false,
                                      unreadMessagesCount: (chatController.chatsList[index].data.unreadMessageCount == null ||
                                              chatController.chatsList[index].data.unreadMessageCount == 0)
                                          ? 0
                                          : chatController.chatsList[index].data.unreadMessageCount!,
                                    );
                            });
                  }
                },
              ),
            );
          }),
        ),
        floatingActionButton: GayaFloatingActionButton(
          onPressed: () {
            showConnectyCubeNewChatSheets(ctx: context, onUserTap: null);
          },
          svgIconPath: ImageAssetsUtils.messageIcon,
        ));
  }

  final messageServices = MessagesFirestoreServices();

  //Function to check whether the chatroom between the current user and reciver is created or not
  Future<ChatRoomModel?> getchatRoomCUstom(String? recieverId) async {
    return await messageServices.getchatRoomCustom(recieverId);
  }
}

CupertinoHeader get headerAbove => const CupertinoHeader(
      position: IndicatorPosition.above,
      userWaterDrop: false,
      safeArea: true,
      triggerOffset: 40,
      hapticFeedback: true,
      emptyWidget: SizedBox(),
    );
