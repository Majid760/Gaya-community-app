import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/show.topics.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/community/create_community/components/listtile.row.widget.dart';
import 'package:gaya/view/community/create_community/controllers/create_community_controller.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:gaya/widgets/topic_view_widgets/interest.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../utils/methods.dart';
import '../../../../utils/theme/button_styles.dart';

class CommunityView1 extends StatelessWidget {
  const CommunityView1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topicController = Provider.of<TopicsController>(context, listen: true);

    return GetBuilder<CreateCommunityController>(builder: (communityController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            GayaStrings.community_name.tr,
            style: CustomTypography.body4Style,
          ),
          const SizedBox(
            height: distance_5,
          ),
          textField(
              isPassword: false,
              inputType: TextInputType.text,
              hintText: GayaStrings.name_txt.tr,
              maxlength: 30,
              controller: communityController.communityName,
              validation: FormValidation.validateCommunityName,
              borderColor: borderColor),
          const SizedBox(
            height: distance_15,
          ),
          Text(
            GayaStrings.community_type.tr,
            style: CustomTypography.bodyStyle,
          ),
          const SizedBox(
            height: distance_5,
          ),
          IntrinsicWidth(
            child: GestureDetector(
              onTap: () => privacySheet(context, communityController),
              child: Container(
                padding: const EdgeInsets.all(distance_10),
                decoration: BoxDecoration(border: Border.all(color: kBaseGrey), borderRadius: BorderRadius.circular(borderRadius_4)),
                child: Row(
                  children: [
                    communityController.getType == communityType.Public
                        ? SvgIconWidget.lockUnlockedOutline(height: 20.r)
                        // SvgPicture.asset(
                        //         "Assets/icons/unlock.svg",
                        //         height: 20.r,
                        //       )
                        : communityController.type == communityType.Secret
                            ? SvgIconWidget.eyeOffOutline(height: 20.r)
                            // SvgPicture.asset(
                            //             'Assets/icons/eye.svg',
                            //             height: 20.r,
                            //           )
                            : SvgIconWidget.lockOutline1(height: 20.r),
                    // SvgPicture.asset(
                    //             "Assets/icons/lock.svg",
                    //             height: 20.r,
                    //           ),
                    const SizedBox(
                      width: distance_5,
                    ),
                    Text(
                      communityController.getType == communityType.Public
                          ? GayaStrings.public_txt.tr
                          : communityController.type == communityType.Secret
                              ? GayaStrings.secret_txt.tr
                              : GayaStrings.private_txt.tr,
                      style: GayaTypography.titleMedium.copyWith(height: 1.18),
                    ),
                    const SizedBox(width: distance_10),
                    Container(
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kBlackColor),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 16.7.r,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: distance_10,
          ),
          Text(
            communityController.type == communityType.Public
                ? GayaStrings.anyone_see_post.tr
                : communityController.type == communityType.Secret
                    ? GayaStrings.community_visible_invited_users.tr
                    : GayaStrings.group_user_create_post.tr,
            style: GayaTypography.text.copyWith(color: kSecondaryColor, fontSize: 14.sp, height: 1.57),
          ),
          const SizedBox(
            height: distance_10,
          ),
          Text(
            GayaStrings.topic.tr,
            style: CustomTypography.bodyStyle,
          ),
          const SizedBox(
            height: distance_10,
          ),
          ButtonWidget(
            height: 40.h,
            icon: SvgIconWidget.plusOutline(),
            // icon: const Icon(Icons.add, color: kBlackColor),
            onTap: () => showTopic(
              context,
              () {
                topicController.addUserInterests();
                Navigator.of(context).pop();
              },
            ),
            buttonColor: kBaseGrey,
            color: kBlackColor.withOpacity(0.5),
            title: GayaStrings.add_topic.tr,
            style: CustomTypography.secondaryFontStyleBig,
          ),
          const SizedBox(
            height: distance_10,
          ),
          topicController.selectedList.isNotEmpty
              ? InterestWidget(
                  textstyle: const TextStyle(
                    color: kprimaryColor,
                    fontFamily: GayaFontTheme.primaryFont,
                  ),
                  color: kprimaryColorLight,
                  horizontalDistance: distance_40,
                  image: topicController.selectedList[0].image.toString(),
                  title: topicController.selectedList.isEmpty ? '' : topicController.selectedList[0].title.toString(),
                  onTap: () {},
                )
              : const SizedBox()
        ],
      );
    });
  }

  void privacySheet(BuildContext context, CreateCommunityController communityController) {
    Methods.showCircularModalSheet(context, SingleChildScrollView(
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return SafeArea(
          minimum: const EdgeInsets.only(bottom: distance_10).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18).r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: GayaButtonStyles.actionRowTextButtonStyle2
                          .copyWith(padding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.zero)),
                      onPressed: () => Navigator.pop(context),
                      child: Text(GayaStrings.cancel_txt.tr, style: CustomTypography.modalSheetTitleStyle),
                    ),
                    Text(GayaStrings.community_type.tr, style: GayaTypography.titleMedium),
                    TextButton(
                        style: GayaButtonStyles.actionRowTextButtonStyle2
                            .copyWith(padding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.zero)),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          GayaStrings.done.tr,
                          style: CustomTypography.modalSheetTitleStyle.copyWith(color: kprimaryColor),
                        ))
                  ],
                ),
              ),
              SizedBox(height: 16.r),
              ListTileRow(
                onTap: () => setState(
                  () => communityController.setType(communityType.Public),
                ),
                borderColorcircle:
                    communityController.getType == communityType.Public ? kTransparentColor : kSecondaryColor.withOpacity(0.5),
                externalColor: communityController.getType == communityType.Public ? kprimaryColor : kWhiteColor,
                icon: IconsAssetsPathUtils.lockUnlockedOutline,
                // icon: 'Assets/icons/unlock.svg',
                internalColor: kWhiteColor,
                subtitle: GayaStrings.all_user_create_post.tr,
                title: GayaStrings.public_txt.tr,
              ),
              SizedBox(height: distance_16.h),
              ListTileRow(
                onTap: () => setState(
                  () => communityController.setType(communityType.Private),
                ),
                borderColorcircle:
                    communityController.getType == communityType.Private ? kTransparentColor : kSecondaryColor.withOpacity(0.5),
                externalColor: communityController.getType == communityType.Private ? kprimaryColor : kWhiteColor,
                icon: IconsAssetsPathUtils.lockOutline,
                // icon: 'Assets/icons/lock.svg',
                internalColor: kWhiteColor,
                subtitle: GayaStrings.group_user_create_post.tr,
                title: GayaStrings.private_txt.tr,
              ),
              SizedBox(height: distance_16.h),
              ListTileRow(
                onTap: () => setState(
                  () => communityController.setType(communityType.Secret),
                ),
                borderColorcircle:
                    communityController.getType == communityType.Secret ? kTransparentColor : kSecondaryColor.withOpacity(0.5),
                externalColor: communityController.getType == communityType.Secret ? kprimaryColor : kWhiteColor,
                icon: IconsAssetsPathUtils.eyeOffOutline,
                // icon: 'Assets/icons/eye.svg',
                internalColor: kWhiteColor,
                subtitle: GayaStrings.community_visible_invited_users.tr,
                title: GayaStrings.secret_txt.tr,
              ),
            ],
          ),
        );
      }),
    ));
  }
}
