import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/shared/service/permission_service/device_permission.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '../../../controller/firebase_analytics_controller.dart';
import '../../../model/user.model.dart';

enum AppImageSource { camera, gallery, audio, storage }

abstract class MediaServiceInterface {
  PermissionService get permissionService;

  Future<XFile?> pickImageFromCamera({required BuildContext context, int imageQuality = 50});
  Future<XFile?> pickImageFromPhotos({required BuildContext context, int imageQuality = 50});

  Future<List<XFile>?> pickImageFromGallery({required BuildContext context});

  Future<XFile?> pickVideoFromGallery({required BuildContext context});
  Future<File?> pickFile({required BuildContext context});
}

class MediaService implements MediaServiceInterface {
  final ImagePicker _picker = ImagePicker();
  @override
  PermissionHandlerService permissionService = PermissionHandlerService();

  // PermissionService get _permissionService => locator<PermissionService>();
  Future<bool> _handlePermission(BuildContext context, AppImageSource? imageSource) async {
    switch (imageSource) {
      case AppImageSource.camera:
        return await permissionService.handleCameraPermission(context);
      case AppImageSource.gallery:
        return await permissionService.handlePhotosPermission(context);
      case AppImageSource.audio:
        return await permissionService.handleAudioPermission(context);
      case AppImageSource.storage:
        return await permissionService.handleStoragePermission(context);
      default:
        return false;
    }
  }

  // pick the image from camera
  @override
  Future<XFile?> pickImageFromCamera({required BuildContext context, int imageQuality = 50}) async {
    try {
      bool canProceed = true;
      XFile? file;
      // canProceed = await _handlePermission(context, AppImageSource.camera);
      if (canProceed) {
        file = await _picker.pickImage(source: ImageSource.camera, imageQuality: imageQuality);
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );
      }
      return file;
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    } catch (e) {
      debugPrint('excepton caught during image picking from camera!$e');
      // rethrow;
    }
    return null;
  }

  // pick the image from Photos
  @override
  Future<XFile?> pickImageFromPhotos({required BuildContext context, int imageQuality = 50}) async {
    try {
      bool canProceed = true;
      XFile? file;
      if (canProceed) {
        file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: imageQuality);
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );
      }
      return file;
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    } catch (e) {
      debugPrint('excepton caught during image picking from camera!$e');
      // rethrow;
    }
    return null;
  }

  // pick the image from gallery
  @override
  Future<List<XFile>?> pickImageFromGallery({required BuildContext context, int imageQuality = 50}) async {
    try {
      bool canProceed = true;
      List<XFile>? files = [];
      // canProceed = await _handlePermission(context, Platform.isIOS ? AppImageSource.gallery : AppImageSource.storage);
      if (canProceed) {
        files = await _picker.pickMultiImage(imageQuality: imageQuality);
      }
      return files;
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    } catch (e) {
      debugPrint('excepton caught during image picking from gallery!$e');
      // rethrow;
    }
    return null;
  }

  @override
  Future<XFile?> pickVideoFromGallery({required BuildContext context}) async {
    try {
      bool canProceed = true;
      XFile? file;
      if (canProceed) {
        file = await _picker.pickVideo(source: ImageSource.gallery);
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'video',
          userId: UserModel.to.uId ?? '',
        );
      }
      return file;
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    } catch (e) {
      debugPrint('excepton caught during image picking from gallery!$e');
      // rethrow;
    }
    return null;
  }

// pick the file from storage
  @override
  Future<File?> pickFile({required BuildContext context, int imageQuality = 50}) async {
    try {
      bool canProceed = true;

      File? file;

      // canProceed = await _handlePermission(context, AppImageSource.storage);

      if (canProceed) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null) {
          List<File> files = result.paths.map((path) => File(path ?? '')).toList();
          file = files[0];
          // print('path is: ${file.path}');
        } else {
          print('path else is:');
        }
      }
      return file;
    } catch (e) {
      debugPrint('excepton caught during image picking from camera!$e');
      rethrow;
    }
  } // // save to local directory
// static Future<String> saveImageToLocalDirectory(XFile? image) async {
//   try {
//     final String path = (await getApplicationDocumentsDirectory()).path;
//     final fileName = image!.name;
//     await image.saveTo('$path/$fileName');
//     return '$path/$fileName';
//   } catch (e) {
//     debugPrint('excepton caught during image saving to local directory!');
//     throw Exception(e);
//   }
// }

// @override
// Future<FilePickerResult?> pickFileFromGallery(
//     {required BuildContext context, bool allowMultiple = true, List<String>? allowExtension}) async {
//   try {
//     bool canProceed = true;
//     if (!Helper.isWeb) {
//       canProceed = await _handlePermission(context, AppImageSource.storage);
//     }
//     if (canProceed) {
//       FilePickerResult? result = await FilePicker.platform
//           .pickFiles(allowMultiple: allowMultiple, type: FileType.custom, allowedExtensions: allowExtension ?? _supportedFileType);
//       return result;
//     }
//   } catch (e) {
//     debugPrint('excepton caught during file getteing from gallery! $e');
//     throw Exception(e);
//   }
// }
}
