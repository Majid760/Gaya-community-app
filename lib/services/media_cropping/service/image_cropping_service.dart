import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../model/user.model.dart';

abstract class ImageServicesImpl {
  Future<File?> cropPhoto(File photo, BuildContext context);
}

class ImageServices implements ImageServicesImpl {
  // cropping photos/images
  @override
  Future<File> cropPhoto(
    File pickedFile,
    BuildContext context,
  ) async {
    // Logging crop image analytics event
    AnalyticsController.to.instance.cropImage(
      userId: UserModel.to.uId ?? '',
    );

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: GayaStrings.cropper.tr,
              toolbarColor: kprimaryColor,
              toolbarWidgetColor: Colors.white,
              statusBarColor: kprimaryColor,
              activeControlsWidgetColor: kprimaryColor,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(title: GayaStrings.cropper.tr),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(width: 520, height: 520),
            viewPort: const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return pickedFile;
    } catch (e) {
      debugPrint(e.toString());
      return pickedFile;
    }
  }
}
