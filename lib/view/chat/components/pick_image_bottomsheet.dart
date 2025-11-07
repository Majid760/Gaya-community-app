// import 'package:gaya/components/button.component.dart';
// import 'package:gaya/shared/constant/string_constant.dart';
// import 'package:gaya/utils/asset_images.dart';
// import 'package:gaya/utils/const.dart';
// import 'package:gaya/utils/language/translation.dart';
// import 'package:gaya/utils/methods.dart';
// import 'package:gaya/utils/theme/app_colors.dart';
// import 'package:gaya/utils/theme/app_typography.dart';
// import 'package:gaya/view/chat/controllers/chat_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get_utils/src/extensions/internacionalization.dart';
//
// // IOS SHEET TO PICK
// showIosStyleSheet(context, ChatController chatController) {
//   final mediaPickerWidget = CupertinoActionSheet(
//     title: Text(GayaStrings.choose_media_type.tr,
//         style: GayaTypography.titleMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w400)),
//     actions: [
//       CupertinoActionSheetAction(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10).r,
//           child: CupertinoListTile(
//             leadingToTitle: 8.w,
//             title: Text(GayaStrings.take_photo.tr,
//                 style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
//             // leading: SvgPicture.asset(Assets.assets.icons.picturePickerIcon, color: AppColors.cupertinoBlue),
//             leading: SizedBox(
//                 height: double.infinity,
//                 child: GayaSvgAsset('Assets/icons/camera.svg', height: 17.r, width: 21.r, color: AppColors.primary)),
//           ),
//         ),
//         onPressed: () async {
//           Navigator.pop(context);
//           chatController.pickImageFromCamera(context: context);
//         },
//       ),
//       CupertinoActionSheetAction(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10).r,
//           child: CupertinoListTile(
//             leadingToTitle: 8.w,
//             title: Text(GayaStrings.photo_media_lib.tr,
//                 style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
//             leading: SizedBox(
//                 height: double.infinity,
//                 child: GayaSvgAsset('Assets/icons/gallery_icon.svg', height: 20.r, width: 20.r, color: AppColors.primary)),
//           ),
//         ),
//         onPressed: () async {
//           Navigator.pop(context);
//           chatController.pickImageFromGallery(context: context);
//         },
//       ),
//     ],
//     cancelButton: CupertinoActionSheetAction(
//         child: Text(GayaStrings.cancel_txt.tr,
//             style: GayaTypography.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w400)),
//         onPressed: () => Navigator.pop(context)),
//   );
//
//   showCupertinoModalPopup(context: context, builder: (BuildContext context) => mediaPickerWidget);
// }
//
// // ANDROID SHEET TO PICK
// showAndroidSheet(context, ChatController chatController) {
//   final mediaPickerWidget = Material(
//     color: kWhiteColor,
//     child: SingleChildScrollView(
//       child: Column(
//         children: [
//           // image from gallery
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10).r,
//             child: ListTile(
//                 minLeadingWidth: 8.w,
//                 leading: SizedBox(
//                     height: double.infinity,
//                     child: GayaSvgAsset('Assets/icons/camera.svg', height: 17.r, width: 21.r, color: AppColors.primary)),
//                 title: Text(
//                   GayaStrings.take_photo.tr,
//                   style: GayaTypography.subtitleMedium,
//                 ),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   chatController.pickImageFromCamera(context: context);
//                 }),
//           ),
//
//           // image from gallery
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0).r,
//             child: ListTile(
//               minLeadingWidth: 8.w,
//               onTap: () async {
//                 Navigator.pop(context);
//                 chatController.pickImageFromGallery(context: context);
//               },
//               leading: SizedBox(
//                   height: double.infinity,
//                   child: GayaSvgAsset('Assets/icons/gallery_icon.svg', height: 20.r, width: 20.r, color: AppColors.primary)),
//               title: Text(GayaStrings.photo_media_lib.tr, style: GayaTypography.subtitleMedium),
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0).r,
//             child: GayaButton(
//                 height: 44.h,
//                 borderColor: kTransparentColor,
//                 textStyle: GayaTypography.titleMedium.copyWith(color: AppColors.black, fontSize: 14.sp),
//                 title: SharedString.cancel,
//                 onPressed: () {
//                   Navigator.of(context);
//                 },
//                 primaryColor: AppColors.divider),
//           ),
//           SizedBox(
//             height: 15.h,
//           )
//         ],
//       ),
//     ),
//   );
//
//   Methods.showCircularModalSheet(context, mediaPickerWidget);
// }
