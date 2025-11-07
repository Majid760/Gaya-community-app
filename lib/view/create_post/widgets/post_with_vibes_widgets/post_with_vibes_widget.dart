import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PostWithVibesWidget extends StatelessWidget {
  final PostWithVibes postEmoji;
  final String postTitle;
  Post? postModel;
  Color? themeColor;

  /// Widget with TextField if [isEditable] is true
  bool isEditable;

  PostWithVibesWidget(
      {required this.postEmoji, required this.postTitle, this.postModel, this.themeColor, this.isEditable = false, Key? key})
      : super(key: key);

  Color? getColorFromHexaString() {
    Color? color = themeColor;
    if (postModel != null) {
      color = getColorFromHex(postModel?.community?.communityThemeModel?.color ?? 'FFD28AFF');
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final createPostController = Provider.of<CreatePostController>(context, listen: true);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 1.sw,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45).r,
          decoration: BoxDecoration(color: AppColors.transparrent, borderRadius: BorderRadius.circular(30).r),
          child: Text(postTitle, style: GayaTypography.titleMedium.copyWith(color: AppColors.transparrent)),
        ),
        (!isEditable)
            ? Container(
                width: 1.sw,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).r,
                decoration: BoxDecoration(color: getColorFromHexaString() ?? AppColors.warning, borderRadius: BorderRadius.circular(30).r),
                child: Text(postTitle, textAlign: TextAlign.center, style: GayaTypography.titleMedium.copyWith(color: AppColors.black)),
              )
            : Container(
                width: 1.sw,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5).r,
                decoration: BoxDecoration(color: getColorFromHexaString() ?? AppColors.warning, borderRadius: BorderRadius.circular(30).r),
                child: TextFormField(
                  autofocus: false,
                  autocorrect: false,
                  enableSuggestions: true,
                  onChanged: (String value) {
                    createPostController.onChanged(value);
                  },
                  controller: createPostController.aboutPostController,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: createPostController.aboutPostController.text.length > 120
                      ? CustomTypography.bodyStyle.copyWith(
                          fontSize: 14.sp,
                        )
                      : CustomTypography.bodyStyle.copyWith(
                          fontSize: 18.sp,
                        ),
                  decoration: InputDecoration(
                      hintStyle: CustomTypography.bodyStyle.copyWith(color: AppColors.secondary),
                      hintText: GayaStrings.talk_to.tr,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      border: InputBorder.none),
                ),
              ),
        Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(10).r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: getColorFromHexaString() ?? AppColors.warning),
              child: Text(postEmoji.emoji ?? '', style: GayaTypography.text.copyWith(fontSize: 24.sp)),
            ))
      ],
    );
  }
}
