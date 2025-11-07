import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/components/show.friends.sheet.dart';
import 'package:gaya/controller/message.controller.dart';
import 'package:gaya/model/chatroom.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/message_service/message_service.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/messaging/components/messages_skeleton_widget.dart';
import 'package:gaya/view/messaging/personmessages.view.dart';
import 'package:gaya/view/messaging/services/firestore/messages_firestore_services.dart';
import 'package:gaya/widgets/messaging.widgets/getmessages.list.widget.dart';
import 'package:gaya/widgets/messaging.widgets/nomessage.widget.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../../utils/refresh_builder_utils.dart';
import '../../utils/strings.dart';
import '../../utils/textstyles.dart';
import '../group.view.dart';

class MessageView extends StatefulWidget {
  const MessageView({Key? key}) : super(key: key);

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // done by mak
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// suggestions
    final friendsQuery = getUserFriends(context: context);
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
        body: ExtendedNestedScrollView(
          onlyOneScrollInBody: true,
          headerSliverBuilder: (context, _) {
            return [
              DynamicSliverAppBar(
                maxHeight: 80,
                child: Padding(
                  padding: const EdgeInsets.only(left: distance_15, right: distance_15, bottom: 5).r,
                  child: GestureDetector(
                    onTap: () {
                      showMyFriendsSheets(
                          context: context,
                          onUserTap: (recieverUser) async {
                            if (recieverUser != null) {
                              await MessageUtils.sendAMessage(recieverUser, context: context);
                            }
                          });
                    },
                    child: AbsorbPointer(
                        child: CupertinoSearchTextField(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
                            placeholder: GayaStrings.search_txt.tr,
                            prefixIcon: SvgIconWidget.searchLgOutline(color: AppColors.secondary, height: 20.h))),
                  ),
                ),
              ),
              //suggestions
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Divider(
                      height: 1.h,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: distance_10).r,
                      padding: const EdgeInsets.only(left: 7.0, right: 7.0, top: distance_5).r,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.13,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // const MeetSomeOneWidget(),
                          Expanded(
                            child: FutureBuilder<QuerySnapshot?>(
                                initialData: null,
                                future: friendsQuery,
                                builder: (context, querySnapshot) {
                                  if (querySnapshot.connectionState == ConnectionState.waiting) {
                                    return ListView(scrollDirection: Axis.horizontal, children: const [
                                      MessageSuggestionsSkeleton(),
                                      MessageSuggestionsSkeleton(),
                                      MessageSuggestionsSkeleton(),
                                      MessageSuggestionsSkeleton(),
                                    ]);
                                  }
                                  if (querySnapshot.data == null) return const SizedBox();
                                  QuerySnapshot dataQuery = querySnapshot.data!;
                                  return ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    separatorBuilder: (context, index) => Column(children: [
                                      SizedBox(height: distance_20.h, width: distance_15.w),
                                      const Divider(color: kBaseGrey),
                                    ]),
                                    padding: const EdgeInsets.only(left: distance_10, right: distance_10).r,
                                    itemCount: dataQuery.docs.length > 10 ? 10 : dataQuery.docs.length,
                                    itemBuilder: (context, index) {
                                      UserModel otherUser = UserModel();
                                      dataQuery.docs[index].data() == null
                                          ? otherUser = UserModel()
                                          : otherUser = UserModel.fromSnapshot(dataQuery.docs[index]);
                                      final currentUser = FirebaseAuth.instance.currentUser;
                                      return GestureDetector(
                                        onTap: () async {
                                          // show user profile or initiate conversation with selected user
                                          if ((otherUser.uId != null && currentUser?.uid != null)) {
                                            ChatRoomModel? chatRoomModel = await getchatRoomCUstom(otherUser.uId);
                                            if (chatRoomModel != null) {
                                              Routes.personMessages(person: otherUser, chatroom: chatRoomModel);
                                            }
                                          }
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Stack(children: [
                                              Stack(
                                                children: [
                                                  SizedBox(
                                                      width: 62.r,
                                                      height: 62.r,
                                                      child: ProfileImageWidget(
                                                          url: otherUser.profilePicture ?? "",
                                                          useHeightWidthForcefully: true,
                                                          onError: AppData.defaultUserProfileWidget(radius: 80),
                                                          height: 80,
                                                          width: 80)

                                                      /*  CachedNetworkImage(
                                                    imageUrl: otherUser.profilePicture ?? "",
                                                    memCacheHeight: 80,
                                                    memCacheWidth: 80,
                                                    imageBuilder: (context, imageProvider) {
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                        ),
                                                      );
                                                    },
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) => Container(
                                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                                    ),
                                                    placeholder: (context, url) => Container(
                                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                                    ),
                                                  ),*/
                                                      ),
                                                  // Container(
                                                  //     width: 62.r,
                                                  //     height: 62.r,
                                                  //     decoration: BoxDecoration(
                                                  //         shape: BoxShape.circle,
                                                  //         image: (otherUser.uId == null ||
                                                  //                 otherUser.profilePicture == null ||
                                                  //                 otherUser.profilePicture!.isEmpty)
                                                  //             ? const DecorationImage(image: AssetImage('Assets/images/user.png'), fit: BoxFit.cover)
                                                  //             : DecorationImage(image: NetworkImage(otherUser.profilePicture!), fit: BoxFit.cover),
                                                  //         border: Border.all(
                                                  //             color: (otherUser.isActive ?? false) ? Colors.green : kTransparentColor, width: 1))),
                                                  /// todo: uncomment this to show online status
                                                  if (false)
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Container(
                                                          width: 16.r,
                                                          height: 16.r,
                                                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                                                    ),
                                                ],
                                              )
                                            ]),
                                            SizedBox(height: 8.h),
                                            Text(
                                              //name cannot pass 10 chars
                                              (otherUser.name?.length ?? 0) > 10
                                                  ? '${otherUser.name!.substring(0, 7)}...'
                                                  : otherUser.name ??
                                                      (otherUser.gender == null
                                                          ? anonymousUser
                                                          : otherUser.gender == 'male'
                                                              ? anonymousBoy
                                                              : otherUser.gender == 'female'
                                                                  ? anonymousGirl
                                                                  : anonymousUser),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              style: TextStyle(fontSize: 12.64.sp, height: 1.18, fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: StatefulBuilder(builder: (context, update) {
            return EasyRefresh(
              key: UniqueKey(),
              header: RefreshBuilderUtils.headerAbove,
              onRefresh: () => update(() {}),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatrooms')
                    .where("userIds", arrayContains: _firebaseAuth.currentUser?.uid)
                    .where('lastMessageTime', isNull: false)
                    .orderBy("lastMessageTime", descending: true)
                    .snapshots(),
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15).r,
                      child: MessagesSkeletonWidget(
                        horizontolPadding: 16.0,
                      ),
                    );
                  } else if (dataSnapshot.hasData) {
                    QuerySnapshot dataQuery = dataSnapshot.data as QuerySnapshot;
                    return _firebaseAuth.currentUser == null
                        ? Center(
                            child: CupertinoButton(
                                onPressed: () => Routes.loginView(), child: Text('Sign In', style: CustomTypography.headingStyle)),
                          )
                        : dataQuery.docs.isEmpty
                            ? SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.65, child: const AbsorbPointer(child: NoMessageWidget()))
                            : ListView.builder(
                                itemCount: dataQuery.docs.length,
                                itemBuilder: (ctx, index) {
                                  final chatRoomMap = dataQuery.docs[index].data() as Map<String, dynamic>;
                                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomMap);
                                  List<String>? tempUids = chatRoomModel.participants;
                                  tempUids?.remove(FirebaseAuth.instance.currentUser!.uid);
                                  final String? otherUserID = tempUids?.first;
                                  final UserModel otherUser = UserModel.fromMap(chatRoomMap[otherUserID]);
                                  return (chatRoomModel.lastMessage == '')
                                      ? const SizedBox.shrink()
                                      : GetMessageList(
                                          ontap: () {
                                            context.read<MessageController>().seeMsg(dataQuery.docs[index].id, otherUserID);
                                            Get.to(() => PersonMessageView(
                                                  chatRoomModel: chatRoomModel,
                                                  name: otherUser.name ??
                                                      (otherUser.gender == null
                                                          ? anonymousUser
                                                          : otherUser.gender == 'male'
                                                              ? anonymousBoy
                                                              : otherUser.gender == 'female'
                                                                  ? anonymousGirl
                                                                  : anonymousUser),
                                                  profilePicture: otherUser.profilePicture ?? "",
                                                  uid: otherUser.uId ?? "",
                                                ));
                                          },
                                          onLongTap: () async {
                                            if (chatRoomModel.chatRoomId != null) {
                                              showGayaAlertDialogButton(
                                                context: context,
                                                actionText: GayaStrings.delete_chat.tr,
                                                tapOnYes: () async {
                                                  Navigator.pop(context);
                                                  await context.read<MessageController>().deleteChatroom(chatRoomModel.chatRoomId ?? '');
                                                },
                                                tapOnNo: () => Navigator.pop(context),
                                              );
                                            }
                                            // if (chatRoomModel.chatRoomId != null) {
                                            //   final result = await showConfirmationDialog(
                                            //       context: context,
                                            //       title: 'Are you sure to delete this chat?',
                                            //       cancelLabel: 'Cancel',
                                            //       actions: const [
                                            //         AlertDialogAction(key: 1, label: 'Delete Chat', textStyle: TextStyle(fontSize: 18)),
                                            //       ]);

                                            //   if (result == 1) {
                                            //     // ignore: use_build_context_synchronously
                                            //     await context.read<MessageController>().deleteChatroom(chatRoomModel.chatRoomId ?? '');
                                            //   } else {}
                                            // }
                                          },
                                          isRead: chatRoomModel.lastMesgUserId == FirebaseAuth.instance.currentUser?.uid
                                              ? chatRoomModel.isReadSender ?? false
                                              : chatRoomModel.isReadReceiver ?? false,
                                          message: chatRoomModel.lastMessage == '' ? '' : chatRoomModel.lastMessage.toString(),
                                          name: otherUser.name ??
                                              (otherUser.gender == null
                                                  ? anonymousUser
                                                  : otherUser.gender == 'male'
                                                      ? anonymousBoy
                                                      : otherUser.gender == 'female'
                                                          ? anonymousGirl
                                                          : anonymousUser),
                                          profileImage: otherUser.profilePicture ?? "",
                                          time: chatRoomModel.lastMessageTime == null ? "" : Jiffy(chatRoomModel.lastMessageTime).Hm,
                                        );
                                });
                  } else {
                    return Text(GayaStrings.something_went_wrong_2.tr);
                  }
                },
              ),
            );
          }),
        ));
  }

  final messageServices = MessagesFirestoreServices();

  //Function to check whether the chatroom between the current user and reciver is created or not
  Future<ChatRoomModel?> getchatRoomCUstom(String? recieverId) async {
    return await messageServices.getchatRoomCustom(recieverId);
  }
}
