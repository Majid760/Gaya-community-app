import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/common.dart';
import 'package:gaya/view/chat/components/connectycube_user_listTile.dart';
import 'package:gaya/view/chat/components/paginated_connectycube_users.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/view/chat/utils/consts.dart';
import 'package:get/get.dart';

class SearchGroupMembersScreen extends StatefulWidget {
  final String dialogId;

  const SearchGroupMembersScreen({super.key, required this.dialogId});

  @override
  State<StatefulWidget> createState() {
    return _SearchGroupMembersScreenState();
  }
}

class _SearchGroupMembersScreenState extends State<SearchGroupMembersScreen> {
  _SearchGroupMembersScreenState();

  late ConversationController conversationController;

  @override
  void initState() {
    super.initState();
    conversationController = ConversationController.to(widget.dialogId);
  }

  @override
  void dispose() {
    conversationController.clearSearchValues();
    conversationController.clearNewGroupSelectedUsersValues();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          // 'Group users',
          GayaStrings.group_users.tr,
          style: TextStyle(color: AppColors.black),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        leading: const GayaBackButton(),
        centerTitle: false,
        iconTheme: const IconThemeData(color: kBlackColor),
        backgroundColor: kTransparentColor,
        elevation: 0,
      ),
      body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 24).r,
          child: GetBuilder<ConversationController>(
            init: conversationController,
            builder: (conversationController) {
              return Column(
                children: [
                  Expanded(
                      child: (conversationController.searchUsersTextField.text.isNotEmpty)
                          ? PaginatedSearchedConnectyCubeMembers(
                              dialogId: widget.dialogId,
                            )
                          : (conversationController.chatDetailScreenOccupants.keys.isNotEmpty)
                              ? ListView.builder(
                                  key: UniqueKey(),
                                  itemCount: conversationController.chatDetailScreenOccupants.keys.length,
                                  itemBuilder: (ctx, index) {
                                    try {
                                      final user = conversationController.chatDetailScreenOccupants.values.elementAt(index);

                                      bool isAdmin = conversationController.isGroupAdmin(user.id!);

                                      return ConnectyCubeUserListTileWithoutCheckBox(
                                        user: user,
                                        onUserTap: () {
                                          bool amIAdmin = conversationController.amIGroupAdmin;
                                          if (amIAdmin) {
                                            showMoreItemModalSheet(user, isAdmin);
                                          } else {
                                            Routes.viewProfile(uid: user.login);
                                          }
                                        },
                                        onUserLongTap: () {},
                                        trailingText: isAdmin ? GayaStrings.admin_txt.tr : '',
                                      );
                                    } catch (_) {
                                      return const SizedBox.shrink();
                                    }
                                  })
                              : SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.5,
                                  child: Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle)),
                                )),
                ],
              );
            },
          )),
    );
  }

  Widget _getListItemTile(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      child: TextButton(
        child: Row(
          children: <Widget>[
            Material(
              borderRadius: const BorderRadius.all(
                Radius.circular(40.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  backgroundImage: conversationController.searchedUsersList[index].avatar != null &&
                          conversationController.searchedUsersList[index].avatar!.isNotEmpty
                      ? NetworkImage(conversationController.searchedUsersList[index].avatar!)
                      : null,
                  radius: 25,
                  child: getAvatarTextWidget(
                      conversationController.searchedUsersList[index].avatar != null &&
                          conversationController.searchedUsersList[index].avatar!.isNotEmpty,
                      conversationController.searchedUsersList[index].fullName!.substring(0, 2).toUpperCase()),
                ),
              ),
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      child: Text(
                        'Name: ${conversationController.searchedUsersList[index].fullName}',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Checkbox(
              value: conversationController.selectedUsers.contains(conversationController.searchedUsersList[index].id),
              onChanged: ((checked) {
                conversationController.addRemoveUsersInNewGroupChat(index);
              }),
            ),
          ],
        ),
        onPressed: () {
          conversationController.addRemoveUsersInNewGroupChat(index);
        },
      ),
    );
  }

  void showMoreItemModalSheet(CubeUser? user, bool isAdmin) {
    Methods.showCircularModalSheet(
        context,
        Column(
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.profile_circled),
              title: Text(GayaStrings.view_profile.tr),
              onTap: () {
                Navigator.pop(context);
                Routes.viewProfile(uid: user?.login);
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_rounded),
              title: Text(isAdmin ? 'Remove admin'.tr : 'Make admin'.tr),
              onTap: () {
                Navigator.pop(context);
                if (!isAdmin) {
                  addRemoveAdmins(conversationController.currentChatDialog.dialogId ?? '123',
                      toAddIds: {user?.id ?? 123}, toRemoveIds: {88708, 88709}).then((cubeDialog) {
                    conversationController.updateCubeCurrentChat(cubeDialog);
                  }).catchError((error) {});
                } else {
                  addRemoveAdmins(conversationController.currentChatDialog.dialogId ?? '123', toRemoveIds: {user?.id ?? 123})
                      .then((cubeDialog) {
                    conversationController.updateCubeCurrentChat(cubeDialog);
                  }).catchError((error) {});
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove, color: Colors.red),
              title: Text('Remove user'.tr, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                conversationController.userstoRemoveFromGroup.add(user?.id ?? 123);
                conversationController.updateGroupDetails();
              },
            ),
            SizedBox(height: 20.h)
          ],
        ));
  }
}
