import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/generated/assets.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/notification/fcm_service.dart';

class NotificationController extends ChangeNotifier {
  List docId = [];

  final FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
  late ScrollController notificationsScrollController;
  bool isNotificationsLoaded = false;
  bool? _permissionStatus;

  changeNotificationsLoadedStatus() {
    if (isNotificationsLoaded) return;
    isNotificationsLoaded = true;
    notifyListeners();
  }

  void scrollToTop() {
    try {
      if (notificationsScrollController.hasClients == false) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notificationsScrollController.animateTo(
          notificationsScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.bounceIn,
        );
      });
    } catch (_) {}
  }

  Future<void> getNotifications() {
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Stream<QuerySnapshot<Object?>>? friendRequestNotificationsStream() {
    try {
      User? user = _firebaseInstance.currentUser;

      if (user == null) return null;

      return FirebaseFirestore.instance
          .collection('friendship')
          .where('Recieveruid', isEqualTo: user.uid)
          .where('isaccepted', isEqualTo: false)
          .snapshots();
    } catch (e) {
      return null;
    }
  }

  aproveFriendRequest(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('friendship').doc(docId).update({'isaccepted': true});
      notifyListeners();
    } catch (_) {}
  }

  rejectFriendrequest(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('friendship').doc(docId).delete();
      notifyListeners();
    } catch (_) {}
  }

  final GetStorageController _storage = GetStorageController.to;

  final NOTIFICATION_DIALOG_KEY = "is_notification_dialog_shown";

  Future<void> init({required BuildContext context}) async {
    /// to avoid extra calls
    if (_permissionStatus != null) return;

    /// fetch status of permission (notification)
    await checkPermissionStatus();

    /// show modal if needed
    showBottomSheetIfNeeded(context);
  }

  bool? checkPermissionStatus()  {
    try {
      final status = FirebaseMessagingService.instance.isPermissionGranted;

      // Logging notification settings changed analytics event
      _logNotificationSettingsChanged(status);

      debugPrint("Notification permission status: $status");
      _permissionStatus = status;
    } catch (_) {
      debugPrint("Notification permission status: $_permissionStatus");
    }
    return _permissionStatus;
  }

  // Invoke notification settings changed analytics event
  static void _logNotificationSettingsChanged(bool isGranted) async {
    await GetStorage.init();
    GetStorage db = GetStorage();

    // Whether we have notification permission
    bool? hasNotificationPermission = db.read('notification_permission') as bool?;

    if (hasNotificationPermission == null) {
      // Adding notification_permission to db for first time
      await db.write('notification_permission', isGranted);
      hasNotificationPermission = isGranted;
    }

    // Checking whether we have notification permission locally as well as in settings both (true)
    // OR both (false)
    if ((isGranted && hasNotificationPermission) || (!isGranted && !hasNotificationPermission)) {
      return;
    } else {
      // Logging notification settings changed analytics event
      AnalyticsController.to.instance.logNotificationsSettingsChanged(
        areNotificationsEnabled: isGranted,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      db.write('notification_permission', isGranted);
    }
  }

  void showBottomSheetIfNeeded(BuildContext context) {
    if (_checkIfNotiDialogIsShown) return;
    if (_permissionStatus != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBottomSheet(context);
      });
    }
  }

  bool get _checkIfNotiDialogIsShown {
    final status = _storage.box.read(NOTIFICATION_DIALOG_KEY);
    if (status == null) {
      _storage.box.writeIfNull(NOTIFICATION_DIALOG_KEY, true);
    }
    return status ?? false;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 12.h),
                  Container(height: 4.h, width: 40.w, decoration: const BoxDecoration(color: kBaseGrey)),
                  SizedBox(height: 50.h),
                  Column(
                    children: [
                      SizedBox(
                        height: 120.h,
                        width: 120.w,
                        child: SvgPicture.asset(Assets.bellNotification),
                      ),
                      Text(
                        GayaStrings.enable_notification.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w700, fontFamily: GayaFontTheme.primaryFont, fontSize: 28.sp),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.7,
                        child: Center(
                          child: Text(
                            GayaStrings.receive_latest_update.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.normal, fontFamily: GayaFontTheme.primaryFont, fontSize: 16.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 50.h),
                      GayaButton(
                          height: 50.h,
                          textStyle: CustomTypography.body2Style,
                          borderColor: kTransparentColor,
                          title: GayaStrings.turn_on_notifications.tr,
                          onPressed: () {
                            openAppSettings();
                          },
                          primaryColor: kpurpleColor),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          GayaStrings.skip_for_now.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.normal, fontFamily: GayaFontTheme.primaryFont, fontSize: 16.sp),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
