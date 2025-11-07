import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/app.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/firebase_analytics_controller.dart';
import '../model/user.model.dart';

class HelpersFunctions extends ChangeNotifier {
  //cover picture
  File? communityCoverImage;
  double? imageUploadPercentageCover;
  String? communityPictureDownloadUrlCover;
  String communityImageFolderNameCover = 'communityCovers';

  // Create a community detail things
  File? communityImage;
  double? imageUploadPercentage;
  String? communityPictureDownloadUrl;
  String communityImageFolderName = 'CommunityPic';

  //create Post things
  File? postImage;
  var selectedImage = "";

  File? postImageCover;

  var selectedImageCover = "";

  //Pick the image from the gallery
// image service

  //FOR PROFILE PICTURE
  Future pickImage(BuildContext context, File? image) async {
    try {
      XFile? imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (imagePick != null) {
        File convertedFile = File(imagePick.path);
        image = convertedFile;
        List<File> croppedImage = await Routes.cropPhotoView(imageFile: <File>[image]);
        if (croppedImage.isNotEmpty) {
          communityImage = croppedImage.first;
        }

        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        notifyListeners();
        selectedImage = image.path.toString();
        notifyListeners();
        postImage = image;
        notifyListeners(); /**/
      } else {
        return;
      }
    } on PlatformException catch (e) {
      snackBar(context, e.toString(), kprimaryColor);
    }
  }

  //Upload the image to firebase fireStorage
  uploadImage(BuildContext context, double? percentage, File? image, String folderName) async {
    UploadTask uploadTask = FirebaseStorage.instance.ref().child(folderName).child(uuid.v1()).putFile(image!);

    StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
      percentage = (data.bytesTransferred / data.totalBytes);
      notifyListeners();
      if (data.state == TaskState.success) {
        percentage = null;

        log('Our image uploading done');
      }

      log('This is our uploading image task : ${percentage.toString()}');
    });

    TaskSnapshot taskSnapshot = await uploadTask;
    communityPictureDownloadUrl = await taskSnapshot.ref.getDownloadURL();
    listenEvent.cancel();
    log(communityPictureDownloadUrl!);
  }

  // FOR COVER PHOTO

  Future pickCoverImage(
    BuildContext context,
    File? image,
  ) async {
    try {
      XFile? imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (imagePick != null) {
        File convertedFile = File(imagePick.path);
        image = convertedFile;
        List<File> croppedImage = await Routes.cropPhotoView(imageFile: <File>[image]);
        if (croppedImage.isNotEmpty) {
          communityCoverImage = croppedImage.first;
        }

        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        notifyListeners();
        selectedImageCover = image.path.toString();
        notifyListeners();
        postImageCover = image;
        notifyListeners();
      } else {
        return;
      }
    } on PlatformException catch (e) {
      snackBar(context, e.toString(), kprimaryColor);
    }
  }

  //Upload the image to firebase fireStorage
  uploadCoverImage(BuildContext context, double? percentage, File? image, String folderName) async {
    UploadTask uploadTask = FirebaseStorage.instance.ref().child(folderName).child(uuid.v1()).putFile(image!);

    StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
      percentage = (data.bytesTransferred / data.totalBytes);
      notifyListeners();
      if (data.state == TaskState.success) {
        percentage = null;

        log('Our image uploading done');
      }

      log('This is our uploading image task : ${percentage.toString()}');
    });

    TaskSnapshot taskSnapshot = await uploadTask;
    communityPictureDownloadUrlCover = await taskSnapshot.ref.getDownloadURL();
    listenEvent.cancel();
    log(communityPictureDownloadUrlCover!);
  }
}
