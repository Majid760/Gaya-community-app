import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/helpers.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CommunityView2 extends StatelessWidget {
  const CommunityView2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final helperFunctionController = Provider.of<HelpersFunctions>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(GayaStrings.cover_picture.tr, style: CustomTypography.bodyStyle),
        const SizedBox(
          height: distance_10,
        ),
        Text(GayaStrings.add_cover_pic_show_people.tr,
            style: GayaTypography.text.copyWith(color: kSecondaryColor, fontSize: 14.sp, height: 1.57)),
        const SizedBox(height: distance_15),
        helperFunctionController.communityCoverImage == null
            ? const SizedBox()
            : ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius_8),
                child: Image(
                  image: FileImage(
                    helperFunctionController.communityCoverImage!,
                  ),
                  fit: BoxFit.cover,
                  height: 200.h,
                  width: double.infinity,
                ),
              ),
        const SizedBox(height: distance_15),
        ButtonWidget(
          icon: SvgIconWidget.imageOutline(height: 20.h),
          // icon: SvgPicture.asset(Assets.assets.icons.galleryIcon),
          onTap: () async {
            await helperFunctionController.pickCoverImage(
              context,
              helperFunctionController.communityCoverImage,
            );
          },
          buttonColor: kBaseGrey,
          color: kBlackColor.withOpacity(0.5),
          title: GayaStrings.add_cover_photo.tr,
          style: CustomTypography.secondaryFontStyleBig,
        ),
        const SizedBox(height: 10),
        const SizedBox(height: distance_15),
        Text(GayaStrings.profile_pic.tr, style: CustomTypography.bodyStyle),
        const SizedBox(height: distance_10),
        Text(GayaStrings.add_profile_pic_show_community.tr,
            style: GayaTypography.text.copyWith(color: kSecondaryColor, fontSize: 14.sp, height: 1.57)),
        const SizedBox(height: distance_15),
        helperFunctionController.communityImage == null
            ? const SizedBox()
            : ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius_8),
                child: Image(
                    image: FileImage(helperFunctionController.communityImage!), fit: BoxFit.cover, height: 200, width: double.infinity)),
        const SizedBox(height: distance_15),
        ButtonWidget(
            icon: SvgIconWidget.imageOutline(height: 20.h),
            // icon: SvgPicture.asset(Assets.assets.icons.galleryIcon),
            onTap: () async {
              await helperFunctionController.pickImage(context, helperFunctionController.communityImage);
            },
            buttonColor: kBaseGrey,
            color: kBlackColor.withOpacity(0.5),
            title: GayaStrings.add_profile_photo.tr,
            style: CustomTypography.secondaryFontStyleBig),
      ],
    );
  }
}
