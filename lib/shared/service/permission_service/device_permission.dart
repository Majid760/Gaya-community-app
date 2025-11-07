import 'package:flutter/material.dart';
import 'package:gaya/shared/view/widget/gaya_alertbox.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  // photo permission abstract methods
  Future<PermissionStatus> requestPhotosPermission();

  Future<bool> handlePhotosPermission(BuildContext context);

  // camera permission abstract methods
  Future<PermissionStatus> requestCameraPermission();

  Future<bool> handleCameraPermission(BuildContext context);

  // gallery permission abstract methods
  Future<PermissionStatus> requestStoragePermission();

  Future<bool> handleStoragePermission(BuildContext context);

  // audio permission abstract methods
  Future<PermissionStatus> requestAudioPermission();

  Future<bool> handleAudioPermission(BuildContext context);
}

class PermissionHandlerService implements PermissionService {
  // photo permission  methods
  @override
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  @override
  Future<PermissionStatus> requestPhotosPermission() async {
    return await Permission.photos.request();
  }

  @override
  Future<PermissionStatus> requestAudioPermission() async {
    return await Permission.microphone.request();
  }

  @override
  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  // photo permission  methods
  @override
  Future<bool> handleCameraPermission(BuildContext context) async {
    PermissionStatus status = await requestCameraPermission();
    if (status.isGranted) {
      return true;
    } else {
      debugPrint('😰 😰 😰 Permission to camera was not granted! 😰 😰 😰 ');
      bool isAllowed = false;
      await showGayaAlertDialogBox(
          context: context,
          tapOnYes: () async {
            Navigator.pop(context);
            isAllowed = await openAppSettings();
          },
          tapOnNo: () {
            isAllowed = false;
            Navigator.pop(context);
          });

      // await showGayaAlertDialogButton(
      //     context: context,
      //     actionText: '!',
      //     actionMsg: SharedString.cameraPermissionMsg,
      //     tapOnYes: () async {
      //       Navigator.pop(context);
      //       isAllowed = await openAppSettings();
      //     },
      //     tapOnNo: () {
      //       isAllowed = false;
      //       Navigator.pop(context);
      //     });
      return isAllowed;
    }
  }

  @override
  Future<bool> handlePhotosPermission(BuildContext context) async {
    PermissionStatus status = await requestPhotosPermission();
    bool isAllowed = false;
    if (status.isGranted) {
      return true;
    } else {
      debugPrint('😰 😰 😰 Permission to camera was not granted! 😰 😰 😰 ');
      await showGayaAlertDialogBox(
          context: context,
          tapOnYes: () async {
            Navigator.pop(context);
            isAllowed = await openAppSettings();
          },
          tapOnNo: () {
            isAllowed = false;
            Navigator.pop(context);
          });
      // await showGayaAlertDialogButton(
      //     context: context,
      //     actionText: '!',
      //     actionMsg: SharedString.galleryPermissionMsg,
      //     tapOnYes: () async {
      //       Navigator.pop(context);
      //       isAllowed = await openAppSettings();
      //     },
      //     tapOnNo: () {
      //       isAllowed = false;
      //       Navigator.pop(context);
      //     });
      return isAllowed;
    }
  }

  @override
  Future<bool> handleStoragePermission(BuildContext context) async {
    PermissionStatus status = await requestStoragePermission();
    bool isAllowed = false;
    if (status.isGranted) {
      return true;
    } else {
      debugPrint('😰 😰 😰 Permission to storage was not granted! 😰 😰 😰 ');
      await showGayaAlertDialogBox(
          context: context,
          tapOnYes: () async {
            Navigator.pop(context);
            isAllowed = await openAppSettings();
          },
          tapOnNo: () {
            isAllowed = false;
            Navigator.pop(context);
          });
      // await showGayaAlertDialogButton(
      //     context: context,
      //     actionText: '!',
      //     actionMsg: SharedString.galleryPermissionMsg,
      //     tapOnYes: () async {
      //       Navigator.pop(context);
      //       isAllowed = await openAppSettings();
      //     },
      //     tapOnNo: () {
      //       isAllowed = false;
      //       Get.back();
      //     });
      return isAllowed;
    }
  }

  @override
  Future<bool> handleAudioPermission(BuildContext context) async {
    PermissionStatus status = await requestAudioPermission();
    if (status != PermissionStatus.granted) {
      return false;
    } else {
      return true;
    }
  }
}

// debugPrint('😰 😰 😰 Permission to camera was not granted! 😰 😰 😰 ');
// bool isAllowed = false;
// await EOMAlertDialog(
//     context: context,
//     title: "Enable Permission!",
//     body: "Allow the Permissions to access photos,media, and files on you devices",
//     okButtonText: "Continue",
//     tapOnOk: () async {
//       Navigator.pop(context);
//       isAllowed = await openAppSettings();
//     },
//     cancleButtonText: "Cancle",
//     tapOnCancel: () {
//       isAllowed = false;
//       Navigator.pop(context);
//     });

class DevicePermissionUtils {
  static bool isDenied(String exception) {
    debugPrint('😰 😰 😰 $exception 😰 😰 😰 ');
    exception = exception.toLowerCase();
    if (exception.contains('denied') || exception.contains('denied permanently') || exception.contains('did not') ||  exception.contains('not granted') || exception.contains('not allowed') ||   exception.contains('not authorized') || exception.contains('not available') || exception.contains('not enabled') || exception.contains('not found') || exception.contains('access')) {
      return true;
    } else {
      return false;
    }
  }
}
