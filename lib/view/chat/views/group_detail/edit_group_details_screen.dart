import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/common.dart';
import 'package:gaya/view/chat/components/edit_name_dialog.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/view/chat/utils/consts.dart';
import 'package:gaya/view/chat/views/group_detail/group_information_tile.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../../utils/asset_images.dart';

//////////////////////// Group Chat Detail Screen Below //////////////////////

class EditGroupDetailsScreen extends StatefulWidget {
  final String dialogId;

  const EditGroupDetailsScreen({
    required this.dialogId,
    super.key,
  });

  @override
  State<EditGroupDetailsScreen> createState() => _EditGroupDetailsScreenState();
}

class _EditGroupDetailsScreenState extends State<EditGroupDetailsScreen> {
  late ConversationController conversationController;

  @override
  void initState() {
    super.initState();
    conversationController = ConversationController.to(widget.dialogId);
  }

  bool _isCreatingShareLink = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: klightGrey,
      body: SingleChildScrollView(
        child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20).r,
            child: GetBuilder<ConversationController>(
              init: conversationController,
              tag: widget.dialogId,
              builder: (conversationController) {
                return Column(
                  children: [
                    _buildPhotoFields(),
                    SizedBox(height: 30.h),
                    (conversationController.isChatDetailScreenLoading) ? const CupertinoActivityIndicator() : const SizedBox.shrink(),
                    (conversationController.isChatDetailScreenLoading) ? SizedBox(height: 30.h) : const SizedBox.shrink(),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (conversationController.amIGroupAdmin)
                            GestureDetector(
                              onTap: () {
                                editTextFieldBottomModal(
                                  context,
                                  conversationController,
                                  onSubmit: (String msg) async {
                                    conversationController.updateGroupDetails();
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                Assets.assets.icons.editIcon,
                                height: 20.h,
                                width: 20.w,
                              ),
                            ),
                          SizedBox(width: 6.w),
                          Text(
                            conversationController.currentChatDialog.name ?? GayaStrings.gaya_group.tr,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      GayaStrings.group.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 30.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.r),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
                      child: ListTile(
                        onTap: _isCreatingShareLink
                            ? null
                            : () async {
                                if (_isCreatingShareLink) return;
                                setState(() {
                                  _isCreatingShareLink = true;
                                });
                                await conversationController.generateGroupChatSharableLink(context);

                                /// to avoid double tap until modal is not displayed
                                Future.delayed(const Duration(milliseconds: 700));
                                setState(() {
                                  _isCreatingShareLink = false;
                                });
                              },
                        trailing: _isCreatingShareLink ? const CupertinoActivityIndicator() : SvgIcons.shareIcon,
                        title: Text(
                          GayaStrings.generate_shareable_link_txt.tr,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.r),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {},
                          child: GroupInformationTile(
                            icon: Assets.assets.icons.gallery,
                            title: GayaStrings.media_links_docs.tr,
                            nonetxt: GayaStrings.none_txt.tr,
                          ),
                        ),
                        Divider(thickness: 1, indent: 50.w, endIndent: 0),
                        // SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () {},
                          child: GroupInformationTile(
                            icon: Assets.assets.icons.settingsIcon,
                            title: GayaStrings.settings_txt.tr,
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0).r,
                      child: Row(
                        children: [
                          Text(
                            (conversationController.chatDetailScreenOccupants.isEmpty)
                                ? GayaStrings.participants.tr
                                : '${conversationController.chatDetailScreenOccupants.length} ${GayaStrings.participants.tr}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
                      child: Column(
                        children: [
                          if (conversationController.amIGroupAdmin)
                            InkWell(
                              splashColor: greyColor2,
                              borderRadius: BorderRadius.circular(45),
                              onTap: () {
                                if (!conversationController.amIGroupAdmin) return;
                                conversationController.navigateToaddOpponentsToGroupScreen(context);
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 15.0.r, left: 25.r, bottom: 10.0.r),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(color: klightGrey, shape: BoxShape.circle),
                                      padding: EdgeInsets.all(5.r),
                                      child: Icon(
                                        Icons.add,
                                        size: 35.r,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Text(
                                      GayaStrings.add_participants.tr,
                                      style: TextStyle(color: AppColors.primary, fontSize: 18.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ///loading while participants are in async
                          if (conversationController.isChatDetailScreenLoading)
                            Padding(padding: const EdgeInsets.only(top: 12).r, child: const CupertinoActivityIndicator()),
                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 25.0.r, vertical: 5.r),
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       if (conversationController.currentChatDialog.userId == conversationController.currentUser?.id ||
                          //           conversationController.chatDetailScreenOccupants.keys
                          //               .contains(conversationController.currentUser?.id ?? 123)) {
                          //         conversationController.navigateToSearchGroupMembersScreen(context);
                          //       } else {
                          //         Fluttertoast.showToast(msg: GayaStrings.only_admin_allowed.tr);
                          //       }
                          //     },
                          //     child: Row(
                          //       children: [
                          //         Expanded(
                          //           child: AbsorbPointer(
                          //             child: CupertinoSearchTextField(
                          //               enabled: false,
                          //               placeholder: GayaStrings.search_txt.tr,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 10).r,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: (conversationController.chatDetailScreenOccupants.length < 3)
                                ? conversationController.chatDetailScreenOccupants.length
                                : 2,
                            itemBuilder: getGroupOpponentListItemTile,
                            separatorBuilder: (context, index) {
                              return Divider(thickness: 1, indent: 60.w, endIndent: 0);
                            },
                          ),
                          if (conversationController.chatDetailScreenOccupants.isNotEmpty)
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (conversationController.chatDetailScreenOccupants.isNotEmpty) {
                                        conversationController.navigateToSearchGroupMembersScreen(context);
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10).r,
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(10.r)),
                                      child: Text(
                                        GayaStrings.see_all.tr,
                                        style: TextStyle(color: AppColors.black, fontSize: 14.sp, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // (conversationController.isChatDetailScreenLoading)
                    //     ? const SizedBox.shrink()
                    //     : Column(
                    //         children: <Widget>[
                    //           _addMemberBtn(),
                    //           _removeMemberBtn(),
                    //           (conversationController.isChatDetailScreenLoading)
                    //               ? const SizedBox.shrink()
                    //               : ListView.separated(
                    //                   padding: const EdgeInsets.only(top: 8),
                    //                   scrollDirection: Axis.vertical,
                    //                   shrinkWrap: true,
                    //                   primary: false,
                    //                   itemCount: conversationController.chatDetailScreenOccupants.length,
                    //                   itemBuilder: getGroupOpponentListItemTile,
                    //                   separatorBuilder: (context, index) {
                    //                     return const Divider(thickness: 2, indent: 20, endIndent: 20);
                    //                   },
                    //                 ),
                    //           _exitGroupBtn(),
                    //         ],
                    //       ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 8),
                    //   child: Visibility(
                    //     maintainSize: false,
                    //     maintainAnimation: false,
                    //     maintainState: false,
                    //     visible: conversationController.isChatDetailScreenLoading,
                    //     child: const CircularProgressIndicator(
                    //       strokeWidth: 2,
                    //     ),
                    //   ),
                    // ),

                    SizedBox(height: 15.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showGayaAlertDialogButton(
                                    context: context,
                                    actionText: 'exit'.tr,
                                    tapOnYes: () async {
                                      Navigator.pop(context);
                                      conversationController.exitGroup(context);
                                    },
                                    tapOnNo: () => Navigator.pop(context),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
                                  child: Text(
                                    GayaStrings.exit_group.tr,
                                    style: TextStyle(color: Colors.red, fontSize: 16.sp, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),

                        /// show createdAt only if available!
                        if (_getGroupCreatedAt(conversationController.currentChatDialog.createdAt) != null) ...[
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${GayaStrings.group_created_you.tr} ${conversationController.groupCreatedBy?.fullName ?? ""}',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              if (!conversationController.groupCreatedByUser)
                                const CupertinoActivityIndicator(
                                  color: Colors.black,
                                )
                            ],
                          ),
                          Text(
                            _getGroupCreatedAt(conversationController.currentChatDialog.createdAt)!,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ],
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ],
                );
              },
            )),
      ),
    );
  }

  /// returns group createdAt string only if able to parse to `fromNow()`
  String? _getGroupCreatedAt(DateTime? createdAt) {
    if (createdAt == null) return null;
    try {
      String createdAtString = Jiffy(createdAt).fromNow();
      return '${GayaStrings.created_at.tr} $createdAtString';
    } catch (e) {
      return null;
    }
  }

  Widget _buildPhotoFields() {
    Widget avatarCircle = CircleAvatar(
      backgroundImage: conversationController.currentChatDialog.photo != null && conversationController.currentChatDialog.photo!.isNotEmpty
          ? NetworkImage(conversationController.currentChatDialog.photo!)
          : null,
      backgroundColor: greyColor2,
      radius: 50,
      child: getAvatarTextWidget(
          conversationController.currentChatDialog.photo != null && conversationController.currentChatDialog.photo!.isNotEmpty,
          conversationController.currentChatDialog.name!.substring(0, 2).toUpperCase()),
    );

    return InkWell(
      splashColor: greyColor2,
      borderRadius: BorderRadius.circular(45),
      onTap: () {
        if (!conversationController.amIGroupAdmin) return;
        conversationController.changeGroupProfile();
      },
      child: avatarCircle,
    );
  }

  Widget _buildTextFields() {
    // if (conversationController.isChatDetailScreenLoading) {
    //   return const SizedBox.shrink();
    // }
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          TextField(
            style: TextStyle(color: primaryColor, fontSize: 20.0),
            controller: conversationController.groupNameTextField,
            decoration: const InputDecoration(labelText: 'Change group name'),
          ),
        ],
      ),
    );
  }

  Widget getGroupOpponentListItemTile(BuildContext context, int index) {
    final user = conversationController.chatDetailScreenOccupants.values.elementAt(index);
    Widget getUserAvatar() {
      if (user.avatar != null && user.avatar!.isNotEmpty) {
        return CircleAvatar(
          backgroundImage: NetworkImage(user.avatar!),
          backgroundColor: greyColor2,
          radius: 25.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(55),
          ),
        );
      } else {
        return Material(
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
          clipBehavior: Clip.hardEdge,
          child: Icon(
            Icons.account_circle,
            size: 50.0,
            color: greyColor,
          ),
        );
      }
    }

    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10).r,
        horizontalTitleGap: 10.w,
        leading: getUserAvatar(),
        onTap: () {
          if (user.login.isBlank == true) return;
          Routes.viewProfile(uid: user.login);
        },
        title: Text(
          '${user.fullName}',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        // subtitle: index == 0
        //     ? const Text(
        //         'Gaya App Support account....',
        //         style: TextStyle(color: Color.fromARGB(255, 15, 13, 13)),
        //       )
        // : null,

        trailing: (index == 0 &&
                conversationController.currentChatDialog.adminsIds?.isEmpty == false &&
                conversationController.currentChatDialog.adminsIds!.contains(user.id))
            ? const Text(
                'Admin',
                style: TextStyle(color: Colors.grey),
              )
            : Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 15.r,
              ));
  }

  Widget _exitGroupBtn() {
    return Container(
      padding: EdgeInsets.only(
        bottom: 3.r, // space between underline and text
      ),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: greyColor, // Text colour here
        width: 1.0, // Underline width
      ))),
      child: InkWell(
        splashColor: greyColor2,
        borderRadius: BorderRadius.circular(45),
        onTap: () {
          conversationController.exitGroup(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const Icon(
              Icons.exit_to_app,
              size: 35.0,
              color: Colors.blue,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16).r,
              child: Text(
                GayaStrings.exit_group.tr,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20, // Text colour here
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
