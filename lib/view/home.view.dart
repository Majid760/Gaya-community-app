import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/crowns_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/switch_view/widgets/app_badge.dart';
import 'package:gaya/view/topics.view.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import '../components/app_logo_title_widget.dart';
import '../utils/strings.dart';
import '../utils/textstyles.dart';
import 'Auth/controller/require.sigin.register.dart';
import 'feed/view/guest/guest_user_feed_view.dart';
import 'feed/view/private/feeds_View.dart';
import 'switch_view/controllers/switch_view_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late GetInterestStorageController getStorage;

  Future<void> areTopicSelected() async {
    try {
      if (getStorage.getInterestList() == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // await topicsBottomSheet(context);
          Routes.openNewSplashWelcomeScreen();
        });
      }
    } catch (e) {
      MyLoggerServices.to.print('error thrown during showing bottom_sheet${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    getStorage = Get.find<GetInterestStorageController>();
    // final topicController = Provider.of<TopicsController>(context, listen: false);
    areTopicSelected();

    // Logging user opened app event to analytics
    AnalyticsController.to.instance.logUserOpenedApp(
      userId: userModel.uId,
      userName: userModel.name,
    );
  }

  UserModel userModel = UserModel.to;
  final isShowInviteHome = false;//GayaRemoteConfig.to.isShowInviteHome;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final controller = Get.find<SwitchViewController>();
    final _commonServices = Services.to;
    return ScaffoldMessenger(
      key: Get.find<AppConfigurationController>().getScaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: kTransparentColor,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// app logo
              SizedBox(height: 30.r, width: 30.r, child: const GayaLogo(padding: EdgeInsets.zero)),
              const SizedBox(width: distance_10),
              GestureDetector(
                onTap: () => AnalyticsController.to.instance.logHomeLogoTapped(
                  userId: UserModel.to.uId ?? '',
                ),
                child: Text("Gaya", style: CustomTypography.headingStyle),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          centerTitle: false,
          actions: [
            // Invite Friends
            Visibility(
              visible: isShowInviteHome,
              child: IconButton(
                tooltip: GayaStrings.invite_friends.tr,
                splashRadius: 25.r,
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Logging home invite button tap analytics event
                  AnalyticsController.to.instance.logInviteHomeButton(
                    userId: UserModel.to.uId ?? '',
                  );
                  if (user == null) {
                    Get.to(const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                    return;
                  }
                  if (DeviceCheck.isIOS) {
                    Share.share(appStoreLink);
                    // Logging home invite button tap analytics event
                    AnalyticsController.to.instance.logInviteHomeButton(
                      isTappedOnly: false,
                      userId: UserModel.to.uId ?? '',
                    );
                  } else {
                    Share.share(playstoreLink);
                    // Logging home invite button tap analytics event
                    AnalyticsController.to.instance.logInviteHomeButton(
                      isTappedOnly: false,
                      userId: UserModel.to.uId ?? '',
                    );
                  }
                },
                icon: SvgIconWidget.userPlusOutline(),
              ),
            ),

            /// Notification button
            IconButton(
                tooltip: GayaStrings.notifications_txt.tr,
                splashRadius: 25.r,
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (user == null) {
                    Get.to(const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                    return;
                  }
                  if (controller.unreadNotificationCount > 0) {
                    _commonServices.markAllNotificationsAsRead();
                  }
                  Routes.notificationView();
                },
                icon: Obx(
                    ()=> AppBadge(count:
                  controller.unreadNotificationCount,
                  child: SvgIconWidget.selectedNotification()),
                )),

            ///home feed search button
            IconButton(
                tooltip: GayaStrings.search_txt.tr,
                splashRadius: 25.r,
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (user == null) {
                    Get.to(const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                  } else {
                    Get.toNamed(RouteHelper.landingSearchScreen);
                  }
                },
                icon: SvgIconWidget.searchLgOutline()),
            const SizedBox(width: distance_10),
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        // floatingActionButton: user == null
        //     ? const SizedBox.shrink()
        //     : GayaFloatingActionButton(
        //         onPressed: () => Routes.createPost(from: PostCreationFrom.Home, community: null),
        //         svgIconPath: IconsAssetsPathUtils.editOutline),
        body: user == null ? const GuestUserFeed() : const FeedsView(),
      ),
    );
  }

  Future<dynamic> topicsBottomSheet(BuildContext context) async {
    return await Methods.showCircularModalSheet(context, const TopicsView());
  }
}

class CrownTweenTimer extends StatelessWidget {
  final bool showSeconds;

  const CrownTweenTimer({super.key, this.showSeconds = false});

  @override
  Widget build(BuildContext context) {
    final crownRemainingTime = AppConfigurationController.to.getCrownRemainingTimeDuration();
    return GetBuilder<CrownsController>(
      init: CrownsController.to,
      builder: (crownsController) {
        return TweenAnimationBuilder<Duration>(
            tween: Tween(begin: crownRemainingTime, end: const Duration(seconds: 0)),
            duration: crownRemainingTime,
            onEnd: () => crownsController.checkUpdatedCrownsInDb(),
            builder: (BuildContext context, Duration value, Widget? child) {
              // final days = value.inDays;
              final hours = value.inHours % 24;
              final minutes = value.inMinutes % 60;
              final seconds = value.inSeconds % 60;
              return (hours == 0 && minutes == 0 && seconds == 0)
                  ? Text(
                      '${crownsController.myAppUser.userDailyCrowns ?? 0}/3 ${GayaStrings.left.tr}',
                      style: GayaTypography.titleSemiBold,
                    )
                  : Text(
                      showSeconds
                          ? '${GayaStrings.renew_in.tr} ${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}'
                          : '${GayaStrings.renew_in.tr} ${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")} ',
                      style: CustomTypography.body2StyleWeightBlack,
                    );
            });
      },
    );
  }
}
