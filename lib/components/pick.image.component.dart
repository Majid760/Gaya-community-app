import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:image_picker/image_picker.dart';

class PickImage extends ChangeNotifier {
//Pick the image from the camera

  File? image;
  Future imagePicker() async {
    try {
      final imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (imagePick == null) {
        return;
      }
      final imageStore = File(imagePick.path);
      image = imageStore;

      // Logging pick image or video analytics event
      AnalyticsController.to.instance.logPickImageVideo(
        pickType: 'image',
        userId: UserModel.to.uId ?? '',
      );

      notifyListeners();
    } on PlatformException catch (e) {
      log(e.toString());
    }
  }
}
