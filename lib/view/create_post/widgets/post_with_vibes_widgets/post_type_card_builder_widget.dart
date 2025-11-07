import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/shared/view/widget/gaya_upload_document_madalsheet.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/helper/pick.image.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/create_post/controller/new_post_creation_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../utils/assets_icons.dart';

class PostWidgetCardBuilderWidget extends StatelessWidget {
  final BuildContext postContext;
  final String postControllerText;

  PostWidgetCardBuilderWidget({required this.postContext, required this.postControllerText, Key? key}) : super(key: key);

  final List<String> titles = [
    GayaStrings.media_txt,
    GayaStrings.poll_txt,
    GayaStrings.question_txt,
    // GayaStrings.challange_txt,
    // GayaStrings.introduction_txt,
    // GayaStrings.q_a_txt,
    GayaStrings.post_with_vibes
  ];
  final List icons = [
    "Assets/icons/media.svg",
    "Assets/icons/poll.svg",
    "Assets/icons/question.svg",
    // "Assets/icons/flag.svg",
    // "Assets/icons/intro.svg",
    // "Assets/icons/qa.svg",
    "Assets/icons/vibe.svg"
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        itemCount: titles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.3),
        itemBuilder: (context, i) {
          return PostTypeCardWidget(
            postText: postControllerText,
            title: titles[i].tr,
            iconString: icons[i],
            index: i,
            postContext: postContext,
          );
        },
      ),
    );
  }
}

final ImagePickerHelper imagePickerHelper = ImagePickerHelper();

class PostTypeCardWidget extends StatelessWidget {
  final String postText;
  final String title;
  final String iconString;
  final int index;
  final BuildContext postContext;

  const PostTypeCardWidget(
      {required this.postText, required this.title, required this.iconString, required this.index, required this.postContext, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createPostController = Provider.of<CreatePostController>(context, listen: true);
    return GetBuilder<PostWithVibeController>(
        init: PostWithVibeController.to,
        autoRemove: false,
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              PostWithVibeController.to.dropSheet();
              HapticFeedback.mediumImpact();
              //image video and file post creation
              if (index == 0) {
                DeviceCheck.isIOS
                    ? showIosStyleSheet(postContext, createPostController)
                    : showAndroidSheet(postContext, createPostController);
                return;
              }
              //post with poll creation
              else if (index == 1) {
                createPostController.pollTiles.clear();
                createPostController.addTwoPollTilesInitially();
                createPostController.isPostWithVibe(false);
                createPostController.isPostWithPoll(true);
                return;
              }
              //post with question creation
              else if (index == 2) {
                createPostController.isPostWithVibe(false);
                createPostController.isPostWithPoll(false);
                createPostController.setPostVibeType({'postType': 'vibe', 'name': 'question', 'emoji': '❔'});
                return;
              }
              // else  if(index==3){
              //
              //       return;
              // }
              // else  if(index==4){
              //
              //       return;
              // }
              // else  if(index==5){
              //
              //       return;
              // }
              //post with vibes creation
              else if (index == 3) {
                createPostController.isPostWithPoll(false);
                createPostController.isPostWithVibe(true);
                return;
              } else {
                GayaSnackBar.show(context: context, type: GayaSnackBarType.error, text: GayaStrings.alert_message_about_post_text.tr);
                return;
              }
            },
            child: Container(
              width: 174.w,
              height: 116.h,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD1D2D6), width: 1.w),
                borderRadius: BorderRadius.circular(16).r,
              ),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconString,
                    width: 27.0.r,
                    height: 27.0.r,
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    title,
                    style: GayaTypography.text,
                  )
                ],
              ),
            ),
          );
        });
  }
}

// IOS SHEET TO PICK
showIosStyleSheet(BuildContext context, CreatePostController createPostController) {
  final mediaPickerWidget = CupertinoActionSheet(
    title: Text(GayaStrings.choose_media_type.tr,
        style: GayaTypography.titleMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w400)),
    actions: [
      CupertinoActionSheetAction(
        child: CupertinoListTile(
          title: Text(GayaStrings.pick_img.tr,
              style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
          leading: SvgIconWidget.imageOutline(color: AppColors.cupertinoBlue),
        ),
        onPressed: () async {
          final files = await imagePickerHelper.pickImage(multiple: true);
          createPostController.videoFile = null;

          if (files.length > 4) {
            snackBar(context, GayaStrings.select_4_items.tr, kRedColor);
          } else {
            createPostController.images.clear();
            createPostController.images.addAll(files.map((e) => File(e.path)).toList());
            createPostController.notifyListeners();
          }

          if (createPostController.images.isNotEmpty) {
            await createPostController.cropPhoto();
          }
          // createPostController.pickImage(context);
          Navigator.of(context, rootNavigator: true).pop("1");
        },
      ),
      CupertinoActionSheetAction(
        child: CupertinoListTile(
          title: Text(GayaStrings.pick_video.tr,
              style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
          // leading: SvgPicture.asset(Assets.assets.icons.videoPickerIcon, color: AppColors.cupertinoBlue),
          leading: Icon(
            Icons.video_collection_outlined,
            color: AppColors.cupertinoBlue,
            size: 24.r,
          ), //SvgPicture.asset(Assets.assets.icons.videoPickerIcon),
        ),
        onPressed: () async {
          Navigator.pop(context);
          await createPostController.getVideo(context);
        },
      ),
// pdf document from storage
      CupertinoActionSheetAction(
        child: CupertinoListTile(
          title: Text(GayaStrings.document.tr,
              style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
          leading: SvgIconWidget.fileOutline(color: AppColors.cupertinoBlue),
        ),
        onPressed: () async {
          Navigator.pop(context);
          final docFile = await createPostController.getPdfDocument(context);
          if (docFile == null) return;
          // ignore: use_build_context_synchronously
          uploadDocumentModelSheet(context, onSubmit: (String reportMsg) async {
            Navigator.pop(context);
          });
        },
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
        child: Text(GayaStrings.cancel_txt.tr,
            style: GayaTypography.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w400)),
        onPressed: () => Navigator.pop(context)),
  );

  showCupertinoModalPopup(context: context, builder: (BuildContext context) => mediaPickerWidget);
}

// ANDROID SHEET TO PICK
showAndroidSheet(BuildContext context, CreatePostController createPostController) {
  final mediaPickerWidget = Material(
    color: kWhiteColor,
    child: SingleChildScrollView(
      child: Column(
        children: [
          // image from gallery
          ListTile(
              leading: SvgIconWidget.imageOutline(color: AppColors.primary),
              title: Text(
                GayaStrings.pick_img.tr,
                style: GayaTypography.subtitleMedium,
              ),
              onTap: () async {
                final files = await imagePickerHelper.pickImage(multiple: true);
                createPostController.videoFile = null;
                if (files.length > 4) {
                  snackBar(context, GayaStrings.select_4_items.tr, kRedColor);
                } else {
                  createPostController.images.clear();
                  createPostController.images.addAll(files.map((e) => File(e.path)).toList());
                  createPostController.notifyListeners();
                }

                if (createPostController.images.isNotEmpty) {
                  await createPostController.cropPhoto();
                }
                Navigator.pop(context);
              }),

          // video from camera
          ListTile(
            onTap: () async {
              Navigator.pop(context);
              await createPostController.getVideo(context);
            },
            leading: Icon(
              Icons.video_collection_outlined,
              color: AppColors.primary,
            ), //SvgPicture.asset(Assets.assets.icons.videoPickerIcon),
            title: Text(GayaStrings.pick_video.tr, style: GayaTypography.subtitleMedium),
          ),
          // pdf document from storage
          ListTile(
            onTap: () async {
              Navigator.pop(context);
              final docFile = await createPostController.getPdfDocument(context);
              if (docFile == null) return;
              // ignore: use_build_context_synchronously
              uploadDocumentModelSheet(context, onSubmit: (String reportMsg) async {
                Navigator.pop(context);
              });
            },
            title: Text(GayaStrings.document.tr, style: GayaTypography.titleMedium.copyWith(fontWeight: FontWeight.w400)),
            leading: SvgIconWidget.fileOutline(color: AppColors.primary),
            // leading: GayaSvgAsset(
            //   'Assets/images/doc.svg',
            //   height: 20.r,
            //   width: 20.r,
            //   color: AppColors.primary,
            // )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
            child: GayaButton(
                height: 40.h,
                borderColor: kTransparentColor,
                // textStyle: loginController.styleEmail,
                textStyle: GayaTypography.titleMedium.copyWith(color: AppColors.black, fontSize: 14.sp),
                title: GayaStrings.cancel_txt.tr,
                onPressed: () {
                  Navigator.pop(context);
                  //Navigator.of(context, rootNavigator: true).pop("1");
                },
                primaryColor: AppColors.divider),
          ),
          SizedBox(
            height: 15.h,
          )
        ],
      ),
    ),
  );

  Methods.showCircularModalSheet(context, mediaPickerWidget);
}
