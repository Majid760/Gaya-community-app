import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/chat/components/connectyCubeUser_listTile_skeleton.dart';
import 'package:gaya/view/chat/components/connectycube_user_listTile.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:get/get.dart';

class PaginatedAllConnectyCubeMembers extends StatelessWidget {
  final String dialogId;
  const PaginatedAllConnectyCubeMembers({Key? key, required this.dialogId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skeletonList = ListView(physics: const NeverScrollableScrollPhysics(), children: const [
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
    ]);
    return GetBuilder<ConversationController>(
        autoRemove: false,
        init: ConversationController.to(dialogId),
        tag: dialogId,
        builder: (conversationController) {
          return EasyRefresh.builder(
            // refreshOnStart: true,
            simultaneously: true,
            // noMoreLoad: false,
            controller: conversationController.refreshController,
            header: const MaterialHeader(
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
            footer: ClassicFooter(
                processedText: "",
                succeededIcon: const Icon(Icons.check, color: kTransparentColor),
                showMessage: false,
                triggerWhenReach: true,
                noMoreText: GayaStrings.no_more_user.tr),
            onRefresh: () async => conversationController.resetAllUsersController(),
            onLoad: conversationController.allCubeUsers.isEmpty ? null : () async => await conversationController.requestMoreAllUsers(),
            childBuilder: (context, physics) {
              if (conversationController.isConnectyCubeUsersLoading) {
                return skeletonList;
              }
              if (conversationController.allCubeUsers.isEmpty) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle)),
                );
              }
              return ListView.builder(
                  itemCount: conversationController.allCubeUsers.length,
                  physics: physics,
                  itemBuilder: (ctx, index) {
                    try {
                      final user = conversationController.allCubeUsers[index];
                      return ConnectyCubeUserListTile(
                        user: user,
                        onUserTap: () {
                          conversationController.addRemoveUsersInNewGroupChatForAllUsersList(index);
                        },
                        conversationController: conversationController,
                      );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  });
            },
          );
        });
  }
}

class PaginatedSearchedConnectyCubeMembers extends StatelessWidget {
  final String dialogId;

  const PaginatedSearchedConnectyCubeMembers({Key? key, this.isWithoutCheckboxTile, required this.dialogId}) : super(key: key);

  final bool? isWithoutCheckboxTile;

  @override
  Widget build(BuildContext context) {
    final skeletonList = ListView(physics: const NeverScrollableScrollPhysics(), children: const [
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
    ]);
    return GetBuilder<ConversationController>(
        autoRemove: false,
        init: ConversationController.to(dialogId),
        tag: dialogId,
        builder: (conversationController) {
          return EasyRefresh.builder(
            // refreshOnStart: true,
            simultaneously: true,
            // noMoreLoad: false,
            controller: conversationController.searchRefreshController,
            header: const MaterialHeader(
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
            footer: ClassicFooter(
                processedText: "",
                succeededIcon: const Icon(Icons.check, color: kTransparentColor),
                showMessage: false,
                triggerWhenReach: true,
                noMoreText: GayaStrings.no_more_user.tr),
            onRefresh: () async => conversationController.resetSearchedUsersController(),
            onLoad: conversationController.searchedUsersList.isEmpty
                ? null
                : () async => await conversationController.requestMoreSearchedUsers(),
            childBuilder: (context, physics) {
              if (conversationController.isConnectyCubeUsersLoading) {
                return skeletonList;
              }
              if (conversationController.searchedUsersList.isEmpty) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle)),
                );
              }

              return ListView.builder(
                  itemCount: conversationController.searchedUsersList.length,
                  physics: physics,
                  itemBuilder: (ctx, index) {
                    try {
                      final user = conversationController.searchedUsersList[index];
                      return (user.login == UserModel.to.uId)
                          ? const SizedBox.shrink()
                          : (isWithoutCheckboxTile == null || isWithoutCheckboxTile == false)
                              ? ConnectyCubeUserListTile(
                                  user: user,
                                  onUserTap: () {
                                    conversationController.addRemoveUsersInNewGroupChatForSearchedUsers(index);
                                  },
                                  conversationController: conversationController,
                                )
                              : ConnectyCubeUserListTileWithoutCheckBox(
                                  user: user,
                                  onUserLongTap: () {},
                                  onUserTap: () {
                                    // chatController.addRemoveUsersInNewGroupChatForSearchedUsers(index);
                                    if (conversationController.searchedUsersList.isNotEmpty) {
                                      conversationController.createNewConversation(context, {user.id ?? 123}, false);
                                    }
                                  },
                                );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  });
            },
          );
        });
  }
}

class PaginatedAllConnectyCubeMembersToCreateNewChat extends StatelessWidget {
  const PaginatedAllConnectyCubeMembersToCreateNewChat({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skeletonList = ListView(physics: const NeverScrollableScrollPhysics(), children: const [
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
    ]);
    return GetBuilder<ChatController>(
        autoRemove: false,
        init: ChatController.to(),
        builder: (chatController) {
          return EasyRefresh.builder(
            // refreshOnStart: true,
            simultaneously: true,
            // noMoreLoad: false,
            controller: chatController.refreshController,
            header: const MaterialHeader(
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
            footer: ClassicFooter(
                processedText: "",
                processingText: "${GayaStrings.loading_txt.tr} ...",
                succeededIcon: const Icon(Icons.check, color: kTransparentColor),
                showMessage: false,
                triggerWhenReach: true,
                noMoreText: GayaStrings.no_more_user.tr),
            onRefresh: () async => chatController.resetAllUsersController(),
            onLoad: chatController.allCubeUsers.isEmpty ? null : () async => await chatController.requestMoreAllUsers(),
            childBuilder: (context, physics) {
              if (chatController.isConnectyCubeUsersLoading) {
                return skeletonList;
              }
              if (chatController.allCubeUsers.isEmpty) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle)),
                );
              }
              return ListView.builder(
                  itemCount: chatController.allCubeUsers.length,
                  physics: physics,
                  itemBuilder: (ctx, index) {
                    try {
                      final user = chatController.allCubeUsers[index];
                      return ConnectyCubeUserListTile(
                        user: user,
                        onUserTap: () {
                          print("user.id ${user.id}");
                          chatController.addRemoveUsersInNewGroupChatForAllUsersList(index);
                        },
                        chatController: chatController,
                      );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  });
            },
          );
        });
  }
}

class PaginatedSearchedConnectyCubeMembersToCreateNewChat extends StatelessWidget {
  const PaginatedSearchedConnectyCubeMembersToCreateNewChat({Key? key, this.isWithoutCheckboxTile}) : super(key: key);

  final bool? isWithoutCheckboxTile;

  @override
  Widget build(BuildContext context) {
    final skeletonList = ListView(physics: const NeverScrollableScrollPhysics(), children: const [
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
      ConnectyCubeUserListTileSkeleton(),
    ]);
    return GetBuilder<ChatController>(
        autoRemove: false,
        init: ChatController.to(),
        builder: (chatController) {
          return EasyRefresh.builder(
            // refreshOnStart: true,
            simultaneously: true,
            // noMoreLoad: false,
            controller: chatController.searchRefreshController,
            header: const MaterialHeader(
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
            footer: ClassicFooter(
                processedText: "",
                succeededIcon: const Icon(Icons.check, color: kTransparentColor),
                showMessage: false,
                triggerWhenReach: true,
                noMoreText: GayaStrings.no_more_user.tr),
            onRefresh: () async => chatController.resetSearchedUsersController(),
            onLoad: chatController.searchedUsersList.isEmpty ? null : () async => await chatController.requestMoreSearchedUsers(),
            childBuilder: (context, physics) {
              if (chatController.isConnectyCubeUsersLoading) {
                return skeletonList;
              }
              if (chatController.searchedUsersList.isEmpty) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle)),
                );
              }

              return ListView.builder(
                  itemCount: chatController.searchedUsersList.length,
                  physics: physics,
                  itemBuilder: (ctx, index) {
                    try {
                      final user = chatController.searchedUsersList[index];
                      return (user.login == UserModel.to.uId)
                          ? const SizedBox.shrink()
                          : (isWithoutCheckboxTile == null || isWithoutCheckboxTile == false)
                              ? ConnectyCubeUserListTile(
                                  user: user,
                                  onUserTap: () {
                                    chatController.addRemoveUsersInNewGroupChatForSearchedUsers(index);
                                  },
                                  chatController: chatController,
                                )
                              : ConnectyCubeUserListTileWithoutCheckBox(
                                  user: user,
                                  onUserLongTap: () {},
                                  onUserTap: () {
                                    // chatController.addRemoveUsersInNewGroupChatForSearchedUsers(index);
                                    if (chatController.searchedUsersList.isNotEmpty) {
                                      chatController.createNewConversation(context, {user.id ?? 123}, false);
                                    }
                                  },
                                );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  });
            },
          );
        });
  }
}
