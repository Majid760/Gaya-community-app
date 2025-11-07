import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/shared/constant/string_constant.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// A bottom sheet to pick image from camera or gallery with a title and a subtitle and automatically handles the the android and ios platform.
/// [onCameraPressed] and [onGalleryPressed] are the callbacks to be called when the user presses the camera or gallery button.
/// [cameraText] and [galleryText] are the texts to be displayed on the camera and gallery buttons.
/// If not provided, the default texts will be used.

void gayaPhotoPickerBottomSheet(BuildContext context,
    {required VoidCallback onCameraPressed, required VoidCallback onGalleryPressed, String? cameraText, String? galleryText}) {
  if (Platform.isIOS) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => GayaIOSBottomSheet(
            onCameraPressed: onCameraPressed, onGalleryPressed: onGalleryPressed, cameraText: cameraText, galleryText: galleryText));
  } else {
    Methods.showCircularModalSheet(
        context,
        GayaAndroidBottomSheet(
            onCameraPressed: onCameraPressed, onGalleryPressed: onGalleryPressed, cameraText: cameraText, galleryText: galleryText));
  }
}

class GayaIOSBottomSheet extends StatelessWidget {
  const GayaIOSBottomSheet({super.key, required this.onCameraPressed, required this.onGalleryPressed, this.cameraText, this.galleryText});
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final String? cameraText;
  final String? galleryText;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(GayaStrings.choose_media_type.tr,
          style: GayaTypography.titleMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          onPressed: onCameraPressed ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10).r,
            child: CupertinoListTile(
              leadingToTitle: 8.w,
              title: Text(cameraText ?? GayaStrings.take_photo.tr,
                  style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
              // leading: SvgPicture.asset(Assets.assets.icons.picturePickerIcon, color: AppColors.cupertinoBlue),
              leading: SizedBox(
                  height: double.infinity,
                  child: GayaSvgAsset('Assets/icons/camera.svg', height: 17.r, width: 21.r, color: AppColors.primary)),
            ),
          ),
        ),
        CupertinoActionSheetAction(
            onPressed: onGalleryPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10).r,
              child: CupertinoListTile(
                leadingToTitle: 8.w,
                title: Text(galleryText ?? GayaStrings.photo_media_lib.tr,
                    style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
                leading: SizedBox(
                    height: double.infinity,
                    child: GayaSvgAsset('Assets/icons/gallery_icon.svg', height: 20.r, width: 20.r, color: AppColors.primary)),
              ),
            )),
      ],
      cancelButton: CupertinoActionSheetAction(
          child: Text(GayaStrings.cancel_txt.tr,
              style: GayaTypography.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w400)),
          onPressed: () => Navigator.pop(context)),
    );
  }
}

/// Android photo picker bottom sheet view
class GayaAndroidBottomSheet extends StatelessWidget {
  const GayaAndroidBottomSheet(
      {super.key, required this.onCameraPressed, required this.onGalleryPressed, this.cameraText, this.galleryText});
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final String? cameraText;
  final String? galleryText;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // image from gallery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10).r,
              child: ListTile(
                onTap: onCameraPressed,
                minLeadingWidth: 8.w,
                leading: SizedBox(
                    height: double.infinity,
                    child: GayaSvgAsset('Assets/icons/camera.svg', height: 17.r, width: 21.r, color: AppColors.primary)),
                title: Text(cameraText ?? GayaStrings.take_photo.tr, style: GayaTypography.subtitleMedium),
              ),
            ),

            // image from gallery
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0).r,
              child: ListTile(
                onTap: onGalleryPressed,
                minLeadingWidth: 8.w,
                leading: SizedBox(
                    height: double.infinity,
                    child: GayaSvgAsset('Assets/icons/gallery_icon.svg', height: 20.r, width: 20.r, color: AppColors.primary)),
                title: Text(galleryText ?? GayaStrings.photo_media_lib.tr, style: GayaTypography.subtitleMedium),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0).r,
              child: GayaButton(
                  height: 44.h,
                  borderColor: kTransparentColor,
                  textStyle: GayaTypography.titleMedium.copyWith(color: AppColors.black, fontSize: 14.sp),
                  title: SharedString.cancel,
                  onPressed: () {
                    Navigator.of(context);
                  },
                  primaryColor: AppColors.divider),
            ),
            SizedBox(height: 15.h)
          ],
        ),
      ),
    );
  }
}
