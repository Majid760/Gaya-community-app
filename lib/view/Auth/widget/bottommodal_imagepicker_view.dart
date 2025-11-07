import 'package:flutter/material.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

Future showImagePicker(context, {required VoidCallback onGalleryClick, required VoidCallback onCameraClick}) async {
  await showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(leading: const Icon(Icons.photo_library), title:  Text(GayaStrings.photo_library.tr), onTap: onGalleryClick),
              ListTile(leading: const Icon(Icons.photo_camera), title:  Text(GayaStrings.camera.tr), onTap: onCameraClick)
            ],
          ),
        );
      });
}
