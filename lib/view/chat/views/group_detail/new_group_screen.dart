import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/components/progress.indicator.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/view/widget/gaya_photo_picking_bottom_sheet.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/chat/components/paginated_connectycube_users.dart';
import 'package:gaya/view/chat/components/selected_user_listTile.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

/////////////////////////////////////////////// New Group New UI ////////////////////////////////////////////////
final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
void showConnectyCubeNewChatSheets({required BuildContext ctx, required Function(UserModel?)? onUserTap}) {
  final chatController = ChatController.to();
  chatController.initializeCommunityMembersServices();
  chatController.getAllCubeUsersList(shouldClearFields: true);
  chatController.isCreatingNewChat = false;
  showModalBottomSheet(
      context: ctx,
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      shape: RoundedRectangleBorder(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)).r),
      builder: (context) {
        return GetBuilder<ChatController>(
          init: chatController,
          builder: (chatController) {
            return WillPopScope(
              onWillPop: () async {
                chatController.clearSearchValues();
                chatController.update();
                return true;
              },
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                      // top: MediaQuery.of(context).padding.top,
                      left: 20.w,
                      right: 20.w,
                    ),
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height - (kBottomNavigationBarHeight - kToolbarHeight),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 12.h),
                          Container(height: 4, width: 40, decoration: const BoxDecoration(color: kBaseGrey)),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  child: Text(
                                      (chatController.isCreateGroupEditFieldsScreenSelected == true)
                                          ? GayaStrings.back_txt.tr
                                          : GayaStrings.cancel_txt.tr,
                                      style: CustomTypography.modalSheetTitleStyle),
                                  onTap: () {
                                    if (chatController.isNewGroupChat == false) {
                                      chatController.resetAllUsersController(isDisposing: true);
                                      chatController.update();
                                      Navigator.pop(context);
                                    } else {
                                      if (chatController.isCreateGroupEditFieldsScreenSelected == true) {
                                        chatController.goBackFromCreateGroupFieldsViewAndClearFields();
                                        // editCommunityController.resetController(isDisposing: true);
                                      } else {
                                        chatController.resetAllUsersController(isDisposing: true);
                                        chatController.update();
                                        Navigator.pop(context);

                                        // chatController.clearSearchValues();
                                        //     chatController.update();
                                      }
                                      chatController.isCreatingNewChat = false;
                                    }
                                  }),
                              Text(
                                  (chatController.isNewGroupChat == false)
                                      ? GayaStrings.new_chat.tr
                                      : (chatController.isCreateGroupEditFieldsScreenSelected == true)
                                          ? GayaStrings.add_participants.tr
                                          : GayaStrings.new_group.tr,
                                  style: GayaTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                              InkWell(
                                  child: chatController.isCreatingNewChat
                                      ? const PrimaryCircularProgressIndicator.centered()
                                      : Text(
                                          (chatController.isCreateGroupEditFieldsScreenSelected == true)
                                              ? GayaStrings.create_txt.tr
                                              : GayaStrings.next_txt.tr,
                                          style: CustomTypography.modalSheetTitleStyle.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                  onTap: () {
                                    if (chatController.isNewGroupChat == false && chatController.selectedUsers.isNotEmpty) {
                                      if (chatController.searchedUsersList.isNotEmpty) {
                                        chatController.clearSearchChatUsersTextField();
                                        Navigator.pop(context);
                                        _debouncer.call(() async => chatController.isCreatingNewChat
                                            ? null
                                            : await chatController.createNewConversation(
                                                context, {chatController.selectedUsers.first}, false));
                                      } else if (chatController.allCubeUsers.isNotEmpty) {
                                        Navigator.pop(context);
                                        _debouncer.call(() async => chatController.isCreatingNewChat
                                            ? null
                                            : await chatController.createNewConversation(
                                                context, {chatController.selectedUsers.first}, false));
                                      }
                                    } else {
                                      if (chatController.isCreateGroupEditFieldsScreenSelected == false &&
                                          chatController.selectedUsers.isNotEmpty) {
                                        _debouncer.call(() async => chatController.isCreatingNewChat
                                            ? null
                                            : await chatController.createNewConversation(context, chatController.selectedUsers, true));
                                      } else if (chatController.isCreateGroupEditFieldsScreenSelected == true &&
                                          chatController.groupNameTextField.text.isNotEmpty) {
                                        _debouncer.call(() async =>
                                            chatController.isCreatingNewChat ? null : await chatController.createNewGroupChat(context));
                                      } else {
                                        MyLoggerServices.to.print('Error: No SelectedUsers available');
                                      }
                                    }
                                  }),
                            ],
                          ),
                          (chatController.isCreateGroupEditFieldsScreenSelected == false)
                              ? SizedBox(
                            height: MediaQuery.sizeOf(context).height - (kBottomNavigationBarHeight + kToolbarHeight),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      CupertinoSearchTextField(
                                          placeholder: GayaStrings.search.tr,
                                          controller: chatController.searchUsersTextField,
                                          onSuffixTap: () {
                                            chatController.clearSearchValues();
                                            chatController.update();
                                          },
                                          onSubmitted: (value) {
                                            chatController.searchUsers(value.trim());
                                          }),
                                      SizedBox(height: 16.h),
                                      (chatController.isNewGroupChat == false && GayaRemoteConfig.to.isGroupChatFeatureEnabled)
                                          ? Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4).w,
                                              child: InkWell(
                                                highlightColor: AppColors.transparrent,
                                                hoverColor: AppColors.transparrent,
                                                onTap: () {
                                                  chatController.toggleIsNewGroupChat();
                                                },
                                                child: Row(
                                                  children: [
                                                    SvgIcons.saveSolid(height: 18.h, width: 20.w),
                                                    SizedBox(width: 8.w),
                                                    Text(GayaStrings.create_new_group.tr,
                                                        style: GayaTypography.titleMedium.copyWith(fontSize: 14.sp)),
                                                  ],
                                                ),
                                              ))
                                          : SizedBox(
                                              height: (chatController.selectedCubeUsersList.isEmpty) ? 0.h : 58.h,
                                              child: (chatController.selectedCubeUsersList.isEmpty)
                                                  ? const SizedBox.shrink()
                                                  : ListView.separated(
                                                      separatorBuilder: (context, index) {
                                                        return Padding(
                                                          padding: const EdgeInsets.only(right: 24).w,
                                                        );
                                                      },
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: chatController.selectedCubeUsersList.length,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (BuildContext context, index) {
                                                        try {
                                                          return SelectedUserListTile(
                                                            user: chatController.selectedCubeUsersList[index],
                                                            onUserTap: () {
                                                              MyLoggerServices.to.print('onUserTap is: $index,');
                                                              chatController.removeSelectedUsers(
                                                                  index, chatController.selectedCubeUsersList[index]);
                                                            },
                                                          );
                                                        } catch (_) {
                                                          return const SizedBox.shrink();
                                                        }
                                                      }),
                                            ),
                                      SizedBox(height: 8.h),
                                      Expanded(
                                        child: (chatController.searchUsersTextField.text.isNotEmpty)
                                            ? const PaginatedSearchedConnectyCubeMembersToCreateNewChat()
                                            : const PaginatedAllConnectyCubeMembersToCreateNewChat(),
                                      ),
                                    ],
                                  ),
                                )
                              // ,
                              : SizedBox(
                              height: MediaQuery.sizeOf(context).height - (kBottomNavigationBarHeight + 50.h),
                                  child: Column(children: [
                                    SizedBox(height: 16.h),
                                    Row(
                                      children: [
                                        Text(GayaStrings.group_subject.tr, style: GayaTypography.subtitleRegular),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    textField(
                                      controller: chatController.groupNameTextField,
                                      maxlines: null,
                                      borderColor: borderColor,
                                      isPassword: false,
                                      textStyle: GayaTypography.subtitleRegular,
                                      autovalidateModel: AutovalidateMode.onUserInteraction,
                                      inputType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      validation: (value) {
                                        if (value.toString().trim().isEmpty) {
                                          return GayaStrings.enter_group_name.tr;
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {},
                                      hintTextStyle: GayaTypography.subtitleRegular.copyWith(color: MyColorHex().blackShade2),
                                      hintText: GayaStrings.example_best_team.tr,
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      children: [
                                        Text(GayaStrings.group_icon.tr, textAlign: TextAlign.left, style: GayaTypography.titleMedium),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Text(GayaStrings.optional_group_icon.tr,
                                            style: GayaTypography.subtitleRegular.copyWith(color: MyColorHex().blackShade2)),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    chatController.isImageUploading == true
                                        ? CircleAvatar(
                                            radius: 60.r,
                                            backgroundColor: Colors.grey.shade200,
                                            child: const PrimaryCircularProgressIndicator.centered(),
                                          )
                                        : chatController.currentChat?.photo != null &&
                                                chatController.currentChat?.photo != '' &&
                                                chatController.isImageUploading == false
                                            ? CircleAvatar(
                                                radius: 60.r,
                                                child: CachedNetworkImage(
                                                  memCacheHeight: 100,
                                                  memCacheWidth: 100,
                                                  imageUrl: chatController.currentChat?.photo ?? '',
                                                  imageBuilder: (context, imageProvider) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                                    );
                                                  },
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, url, error) => AppData.defaultGreyCircleImage,
                                                  placeholder: (context, url) => AppData.defaultGreyCircleImage,
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 60.r,
                                                child: AppData.defaultGreyCircleImage,
                                              ),
                                    SizedBox(height: 16.h),
                                    ButtonWidget(
                                      icon: SvgPicture.asset(Assets.assets.icons.galleryIcon),
                                      onTap: () async => gayaPhotoPickerBottomSheet(context,
                                          onCameraPressed: () =>
                                              [Navigator.pop(context), chatController.pickImageFromCamera(context: context)],
                                          onGalleryPressed: () =>
                                              [Navigator.pop(context), chatController.pickImageFromGallery(context: context)]),
                                      buttonColor: borderColor.withOpacity(0.4),
                                      color: kSecondaryColor.withOpacity(0.6),
                                      height: 40.h,
                                      title: GayaStrings.edit_group_pic.tr,
                                      style: CustomTypography.secondaryFontStyleBig,
                                    ),
                                  ])),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      });
}
