import 'package:flutter/services.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/user.model.dart';

class ImagePickerHelper {
  ImagePickerHelper({ImagePicker? imagePicker}) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<List<XFile>> pickImage({ImageSource imageSource = ImageSource.gallery, bool multiple = false}) async {
    try {
      if (multiple) {
        return await _imagePicker.pickMultiImage();
      }

      final singleImage = await _imagePicker.pickImage(source: imageSource, imageQuality: 50);

      // Logging pick image or video analytics event
      AnalyticsController.to.instance.logPickImageVideo(
        pickType: 'image',
        userId: UserModel.to.uId ?? '',
      );

      if (singleImage != null) {
        return [singleImage];
      } else {
        return [];
      }
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied') {
        final status = await Permission.photos.status;
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
      }
    } catch (e, s) {
      CrashlyticsController.to.instance.recordError("picker image crashes $e", stackTrace: s);
    }
    return [];
  }
}
