// import 'package:flutter/material.dart';
// import 'package:connectycube_sdk/connectycube_sdk.dart';
// import 'package:gaya/view/chat/components/common.dart';
// import 'package:gaya/view/chat/controllers/chat_controller.dart';
// import 'package:gaya/view/chat/utils/consts.dart';
// import 'package:get/get.dart';

// //////////////////////// Group Chat Detail Screen Below //////////////////////

// class GroupChatDetailScreen extends StatefulWidget {
//   const GroupChatDetailScreen({
//     super.key,
//   });

//   @override
//   State<GroupChatDetailScreen> createState() => _GroupChatDetailScreenState();
// }

// class _GroupChatDetailScreenState extends State<GroupChatDetailScreen> {
//   final chatController = ChatController.to();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(40),
//             child: GetBuilder<ChatController>(
//               init: chatController,
//               builder: (chatController) {
//                 return Column(
//                   children: [
//                     _buildPhotoFields(),
//                     _buildTextFields(),
//                     // _buildGroupFields(),
//                     (chatController.isChatDetailScreenLoading)
//                         ? const SizedBox.shrink()
//                         : Column(
//                             children: <Widget>[
//                               _addMemberBtn(),
//                               _removeMemberBtn(),
//                               (chatController.isChatDetailScreenLoading)
//                                   ? const SizedBox.shrink()
//                                   : ListView.separated(
//                                       padding: const EdgeInsets.only(top: 8),
//                                       scrollDirection: Axis.vertical,
//                                       shrinkWrap: true,
//                                       primary: false,
//                                       itemCount: chatController.chatDetailScreenOccupants.length,
//                                       itemBuilder: getGroupOpponentListItemTile,
//                                       separatorBuilder: (context, index) {
//                                         return const Divider(thickness: 2, indent: 20, endIndent: 20);
//                                       },
//                                     ),
//                               _exitGroupBtn(),
//                             ],
//                           ),
//                     Container(
//                       margin: const EdgeInsets.only(left: 8),
//                       child: Visibility(
//                         maintainSize: false,
//                         maintainAnimation: false,
//                         maintainState: false,
//                         visible: chatController.isChatDetailScreenLoading,
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 2,
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             )),
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "Update dialog",
//         backgroundColor: Colors.blue,
//         onPressed: () => chatController.updateGroupDetails(),
//         child: const Icon(
//           Icons.check,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _buildPhotoFields() {
//     if (chatController.isChatDetailScreenLoading) {
//       return const SizedBox.shrink();
//     }
//     Widget avatarCircle = CircleAvatar(
//       backgroundImage: chatController.currentChat?.photo != null && chatController.currentChat!.photo!.isNotEmpty
//           ? NetworkImage(chatController.currentChat!.photo!)
//           : null,
//       backgroundColor: greyColor2,
//       radius: 50,
//       child: getAvatarTextWidget(chatController.currentChat?.photo != null && chatController.currentChat!.photo!.isNotEmpty,
//           chatController.currentChat?.name!.substring(0, 2).toUpperCase()),
//     );

//     return Stack(
//       children: <Widget>[
//         InkWell(
//           splashColor: greyColor2,
//           borderRadius: BorderRadius.circular(45),
//           onTap: () => chatController.changeGroupProfile(),
//           child: avatarCircle,
//         ),
//         Positioned(
//           top: 55.0,
//           right: 35.0,
//           child: RawMaterialButton(
//             onPressed: () {
//               chatController.changeGroupProfile();
//             },
//             elevation: 2.0,
//             fillColor: Colors.white,
//             padding: const EdgeInsets.all(5.0),
//             shape: const CircleBorder(),
//             child: const Icon(
//               Icons.mode_edit,
//               size: 20.0,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextFields() {
//     if (chatController.isChatDetailScreenLoading) {
//       return const SizedBox.shrink();
//     }
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: <Widget>[
//           TextField(
//             style: TextStyle(color: primaryColor, fontSize: 20.0),
//             controller: chatController.groupNameTextField,
//             decoration: const InputDecoration(labelText: 'Change group name'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _addMemberBtn() {
//     return Container(
//       padding: const EdgeInsets.only(
//         bottom: 3, // space between underline and text
//       ),
//       decoration: BoxDecoration(
//           border: Border(
//               bottom: BorderSide(
//         color: greyColor, // Text colour here
//         width: 1.0, // Underline width
//       ))),
//       child: InkWell(
//         splashColor: greyColor2,
//         borderRadius: BorderRadius.circular(45),
//         onTap: () => chatController.navigateToaddOpponentsToGroupScreen(context),
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             Icon(
//               Icons.person_add,
//               size: 35.0,
//               color: blueColor,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 16),
//               child: Text(
//                 'Add member',
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontSize: 20, // Text colour here
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _removeMemberBtn() {
//     if (chatController.userstoRemoveFromGroup.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     return Container(
//       padding: const EdgeInsets.only(
//         bottom: 3, // space between underline and text
//       ),
//       decoration: BoxDecoration(
//           border: Border(
//               bottom: BorderSide(
//         color: greyColor, // Text colour here
//         width: 1.0, // Underline width
//       ))),
//       child: InkWell(
//         splashColor: greyColor2,
//         borderRadius: BorderRadius.circular(45),
//         onTap: () => chatController.removeOpponentFromGroup(),
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(left: 4),
//               child: Icon(
//                 Icons.person_outline,
//                 size: 35.0,
//                 color: blueColor,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 12),
//               child: Text(
//                 'Remove member',
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontSize: 20, // Text colour here
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getGroupOpponentListItemTile(BuildContext context, int index) {
//     final user = chatController.chatDetailScreenOccupants.values.elementAt(index);
//     Widget getUserAvatar() {
//       if (user.avatar != null && user.avatar!.isNotEmpty) {
//         return CircleAvatar(
//           backgroundImage: NetworkImage(user.avatar!),
//           backgroundColor: greyColor2,
//           radius: 25.0,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(55),
//           ),
//         );
//       } else {
//         return Material(
//           borderRadius: const BorderRadius.all(Radius.circular(25.0)),
//           clipBehavior: Clip.hardEdge,
//           child: Icon(
//             Icons.account_circle,
//             size: 50.0,
//             color: greyColor,
//           ),
//         );
//       }
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10.0),
//       child: TextButton(
//         child: Row(
//           children: <Widget>[
//             getUserAvatar(),
//             Flexible(
//               child: Container(
//                 margin: const EdgeInsets.only(left: 20.0),
//                 child: Column(
//                   children: <Widget>[
//                     Container(
//                       alignment: Alignment.centerLeft,
//                       margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
//                       child: Text(
//                         '${user.fullName}',
//                         style: TextStyle(color: primaryColor),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               child: Checkbox(
//                 value: chatController.userstoRemoveFromGroup.contains(chatController.chatDetailScreenOccupants.values.elementAt(index).id),
//                 onChanged: ((checked) {
//                   chatController.toggleGroupOpponents(index, checked ?? false);
//                 }),
//               ),
//             ),
//           ],
//         ),
//         onPressed: () {
//           log("user onPressed");
//         },
//       ),
//     );
//   }

//   Widget _exitGroupBtn() {
//     return Container(
//       padding: const EdgeInsets.only(
//         bottom: 3, // space between underline and text
//       ),
//       decoration: BoxDecoration(
//           border: Border(
//               bottom: BorderSide(
//         color: greyColor, // Text colour here
//         width: 1.0, // Underline width
//       ))),
//       child: InkWell(
//         splashColor: greyColor2,
//         borderRadius: BorderRadius.circular(45),
//         onTap: () => chatController.exitGroup(context),
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             Icon(
//               Icons.exit_to_app,
//               size: 35.0,
//               color: blueColor,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 16),
//               child: Text(
//                 'Exit group member',
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontSize: 20, // Text colour here
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
