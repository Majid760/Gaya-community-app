import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lazy_indexed_stack/flutter_lazy_indexed_stack.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_floating_action_button.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:get/get.dart';
import '../../../components/check_for_app_update.dart';
import '../../../components/profile_image_widget.dart';
import '../../../model/user.model.dart';
import '../../../shared/view/widget/gaya_alert_dialog.dart';
import '../../../utils/app_data.dart';
import '../../../utils/asset_images.dart';
import '../../../utils/const.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';
import '../controllers/switch_view_controller.dart';
import '../widgets/app_badge.dart';
import '../widgets/nav_bar_icon.dart';

class SwitchView extends StatefulWidget {
  const SwitchView({Key? key}) : super(key: key);

  @override
  State<SwitchView> createState() => _SwitchViewState();
}

class _SwitchViewState extends State<SwitchView> {
  @override
  void initState() {
    super.initState();
    GayaRemoteConfig.to.checkAppVersion(context: context);
    ChatController.to().subscribeToNewMsgs();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SwitchViewController>();
    final User? user = FirebaseAuth.instance.currentUser;
    return WillPopScope(
      onWillPop: !kIsWeb && Platform.isAndroid
          ? () async {
              showConfirmationToCloseApp(context);
              return false;
            }
          : null,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:
        GayaNavBArFloatingActionButton(
            onPressed: () {
              if(user == null){
                Get.toNamed(RouteHelper.requireSignRegisterView);}
              else{
                Routes.createPost(from: PostCreationFrom.Home, community: null);
              }

            },
            svgIconPath:  ImageAssetsUtils.addPostIconPath),
        body: Obx(
          () {
            return Column(
              children: [
                Flexible(
                  child: LazyIndexedStack(
                    index: controller.selectedIndex,
                    children: controller.screens,
                  ),
                ),
                BottomNavigationBar(
                  fixedColor: AppColors.transparrent,
                  enableFeedback: true,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  useLegacyColorScheme: false,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: controller.selectedIndex,
                  onTap: (selectedIndex) => controller.setIndex(selectedIndex, context),
                  elevation: 0,
                  selectedLabelStyle: GayaTypography.caption3Medium.copyWith(color: kprimaryColor),
                  unselectedLabelStyle: GayaTypography.caption3Medium.copyWith(color: kSecondaryColor),
                  items: [
                    /// Home
                    BottomNavigationBarItem(
                      tooltip: GayaStrings.home_txt.tr,
                      icon: const NavBarIcon(
                        path: ImageAssetsUtils.homeUnselectedIconPath,
                      ),
                      activeIcon: const NavBarIcon(
                        path: ImageAssetsUtils.homeSelectedIconPath,
                       // color: AppColors.primary,
                      ),
                       label: GayaStrings.home_txt.tr,
                    ),

                    /// Message
                    BottomNavigationBarItem(
                      tooltip: GayaStrings.message_txt.tr,
                      icon: AppBadge(
                        count: controller.unreadMessageCount,
                        child: const NavBarIcon(
                          path: ImageAssetsUtils.messageUnselectedIconPath,
                        ),
                      ),
                      activeIcon: AppBadge(
                        count: controller.unreadMessageCount,
                        child: const NavBarIcon(
                          path: ImageAssetsUtils.messageSelectedIconPath,
                         // color: AppColors.primary,
                        ),
                      ),
                      label: GayaStrings.message_txt.tr,
                    ),
                    ///create post=>this is only used for a same space.
                    ///floating action button is on the top of this Item.
                    BottomNavigationBarItem(

                      tooltip: GayaStrings.create_post.tr,

                      icon: const NavBarIcon(
                        path: ImageAssetsUtils.addIconPath,
                      ),
                      activeIcon: const NavBarIcon(
                        path: ImageAssetsUtils.addPostIconPath,
                        //color: AppColors.primary,
                      ),
                      label: GayaStrings.create_post.tr,
                    ),

                    /// Communities
                    BottomNavigationBarItem(
                      tooltip: GayaStrings.communities_txt.tr,
                      icon: const NavBarIcon(
                        path: ImageAssetsUtils.communityUnselectedIconPath,
                      ),
                      activeIcon: const NavBarIcon(
                        path: ImageAssetsUtils.communitySelectedIconPath,
                        //color: AppColors.primary,
                      ),
                      label: GayaStrings.communities_txt.tr,
                    ),


                    // /// Notification
                    // BottomNavigationBarItem(
                    //   tooltip: GayaStrings.notifications_txt.tr,
                    //   icon: AppBadge(
                    //     count: controller.unreadNotificationCount,
                    //     child: const NavBarIcon(
                    //       path: ImageAssetsUtils.notificationUnselectedIconPath,
                    //     ),
                    //   ),
                    //   activeIcon: AppBadge(
                    //     count: controller.unreadNotificationCount,
                    //     child: NavBarIcon(
                    //       path: ImageAssetsUtils.notificationSelectedIconPath,
                    //       color: AppColors.primary,
                    //     ),
                    //   ),
                    //   label: GayaStrings.notifications_txt.tr,
                    // ),

                    /// Profile
                    BottomNavigationBarItem(
                      tooltip: GayaStrings.profile_txt.tr,
                      icon: getProfileIcon(currentIndex: controller.selectedIndex),
                      activeIcon: getProfileIcon(currentIndex: controller.selectedIndex),
                      label: GayaStrings.profile_txt.tr,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getProfileIcon({required int currentIndex}) {
    final bool isSelected = currentIndex == 4;
    final color = isSelected ? AppColors.primary : kTransparentColor;

    return FirebaseAuth.instance.currentUser != null
        ? Container(
            alignment: Alignment.center,
            height: 25.r,
            width: 25.r,
            margin: const EdgeInsets.only(bottom: 12, top: 5).r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: CircleAvatar(
              backgroundColor: color,
              child: UserModel.to.profilePicture.toString().isBlank == true
                  ? AppData.defaultUserProfileWidget()
                  : ProfileImageWidget(size: Size(25.r, 25.r), url: UserModel.to.profilePicture),
            ),
          )
        : isSelected
            ? const NavBarIcon(
                path: ImageAssetsUtils.profileSelectedIconPath,
                //color: AppColors.primary,
              )
            : const NavBarIcon(path: ImageAssetsUtils.profileUnselectedIconPath);
  }

  void showConfirmationToCloseApp(BuildContext context) {
    showGayaAlertDialogButton(
      context: context,
      actionMsg: GayaStrings.are_you_sure_you_want.tr,
      actionText: GayaStrings.close_app.tr,
      tapOnNo: () => Navigator.pop(context),
      tapOnYes: () {
        Navigator.pop(context);
        SystemNavigator.pop();
      },
    );
  }
}
