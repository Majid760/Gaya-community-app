import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/common.dart';
import 'package:gaya/view/chat/components/paginated_connectycube_users.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/view/chat/utils/consts.dart';
import 'package:get/get.dart';

// class AddOccupantToGroupScreen extends StatefulWidget {
//   final String dialogId;
//   @override
//   State<StatefulWidget> createState() {
//     return _AddOccupantToGroupScreenState();
//   }

//   const AddOccupantToGroupScreen({required this.dialogId, super.key});
// }

// class _AddOccupantToGroupScreenState extends State<AddOccupantToGroupScreen> {
//   _AddOccupantToGroupScreenState();

//   final chatController = ChatController.to();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     chatController.clearSearchValues();
//     chatController.clearNewGroupSelectedUsersValues();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         title: Text(
//           'Search users by name',
//           style: TextStyle(color: AppColors.black),
//         ),
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
//         leading: const GayaBackButton(),
//         centerTitle: false,
//         iconTheme: const IconThemeData(color: kBlackColor),
//         backgroundColor: kTransparentColor,
//         elevation: 0,
//       ),
//       body: const AddOccupantToGroupScreenBody(),
//     );
//   }
// }

class AddOccupantToGroupScreen extends StatefulWidget {
  final String dialogId;

  const AddOccupantToGroupScreen({required this.dialogId, super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddOccupantToGroupScreenState();
  }
}

class _AddOccupantToGroupScreenState extends State<AddOccupantToGroupScreen> {
  _AddOccupantToGroupScreenState();
  late ConversationController conversationController;

  @override
  void initState() {
    conversationController = ConversationController.to(widget.dialogId);
    super.initState();
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
          GayaStrings.search_user_by_name.tr,
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
            tag: widget.dialogId,
            builder: (chatController) {
              return Column(
                children: [
                  Column(
                    children: <Widget>[
                      CupertinoSearchTextField(
                        placeholder: GayaStrings.search_txt.tr,
                        controller: chatController.searchUsersTextField,
                        onSuffixTap: () {
                          chatController.clearSearchValues();
                          chatController.update();
                        },
                        onSubmitted: (value) {
                          conversationController.toggleIsNewGroupChat(shouldNotify: false, customValue: true);
                          conversationController.searchUsers(value.trim());
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Expanded(
                      child: (chatController.searchUsersTextField.text.isNotEmpty)
                          ? PaginatedSearchedConnectyCubeMembers(
                              dialogId: widget.dialogId,
                            )
                          : SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.5,
                              child: Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle)),
                            )),
                ],
              );
            },
          )),
      floatingActionButton: GetBuilder<ConversationController>(
        init: conversationController,
        tag: widget.dialogId,
        builder: (chatController) {
          return Visibility(
            visible: chatController.selectedUsers.isNotEmpty,
            child: FloatingActionButton(
              heroTag: "Update dialog",
              backgroundColor: AppColors.primary,
              onPressed: () => _updateDialog(context, chatController.selectedUsers.toList()),
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
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
                        '${GayaStrings.name_txt.tr}: ${conversationController.searchedUsersList[index].fullName}',
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

  void _updateDialog(BuildContext context, List<int> users) async {
    Navigator.pop(context, users);
  }
}
