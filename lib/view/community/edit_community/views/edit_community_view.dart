import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:get/get.dart';

import '../../../../components/community_visibility_row.dart';
import '../../../../components/profile_image_widget.dart';
import '../../../../model/user.model.dart';
import '../../../../shared/view/widget/gaya_alert_dialog.dart';
import '../../../../shared/view/widget/gaya_back_button.dart';
import '../../../../utils/assets_icons.dart';
import '../../../../utils/const.dart';
import '../../../../utils/enum.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/methods.dart';
import '../../../../utils/textstyles.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../../utils/theme/app_spaces.dart';
import '../../../../utils/vallidation.dart';
import '../../../../widgets/profile.widgets/button.widget.dart';
import '../../controllers/community_editing_controller.dart';
import '../../controllers/community_profile_controller.dart';
import '../components/community_type_popup.dart';
import '../components/edit_community_item.dart';
import '../components/edit_title_subtitle.dart';
import '../components/theme_selection_horizontal.dart';

class EditCommunityScreen extends StatefulWidget {
  final String communityId;

  const EditCommunityScreen({Key? key, required this.communityId}) : super(key: key);

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _nameController;
  late EditCommunityController editCommunityController;
  late String communitySelectedColorString;
  late String communitySelectedTypeString;

  late CommunityProfileController communityProfileController;

  @override
  void initState() {
    editCommunityController = EditCommunityController.to(tag: widget.communityId);
    communityProfileController = CommunityProfileController.to(tag: widget.communityId);
    _descriptionController = TextEditingController(text: editCommunityController.createCommunityModel?.communityDescription);
    _nameController = TextEditingController(text: editCommunityController.createCommunityModel?.communityName);
    communitySelectedColorString = communityProfileController.communityModel?.communityThemeModel?.color ?? 'FFD28AFF';
    communitySelectedTypeString = communityProfileController.communityModel?.communityType ?? 'Public';
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    editCommunityController.setIsSavedPressed(false);
    super.dispose();
  }

  Future<bool> _onPop() async {
    /// if user pressed save button then pop the screen
    if (editCommunityController.isSavedPressed) {
      Navigator.pop(context);
      return true;
    }

    /// if user data is changed then show alert dialog
    editCommunityController.isUserDataChanged(
      description: _descriptionController.text,
      name: _nameController.text,
      selectedThemeColor: communitySelectedColorString,
      communityType: communitySelectedTypeString,
    )
        ? showGayaAlertDialogButton(
            actionText: "",
            actionMsg: GayaStrings.do_you_save_changes.tr,
            context: context,
            tapOnYes: () async {
              // Invoking method to log edit community event to analytics
              _logEditCommunityToAnalytics(editCommunityController);

              await editCommunityController.updateCommunity(
                context,
                description: _descriptionController.text,
                name: _nameController.text,
                selectedThemeColor: communitySelectedColorString,
                communityType: communitySelectedTypeString,
                community: communityProfileController.communityModel!,
              );
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            tapOnNo: () {
              editCommunityController.discardChanges();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          )
        : Navigator.pop(context);
    return false;
  }

  communityType _getCommunityType(String type) {
    print(type);
    if (type.toLowerCase() == "public" || type.toLowerCase() == GayaStrings.public_txt.tr.toLowerCase()) {
      return communityType.Public;
    } else if (type.toLowerCase() == "private" || type.toLowerCase() == GayaStrings.private_txt.tr.toLowerCase()) {
      return communityType.Private;
    } else {
      return communityType.Public;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vertical16Gap = SizedBox(height: MySpaces.gap3.h);
    final vertical12Gap = SizedBox(height: 12.h);
    return WillPopScope(
      onWillPop: _onPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: GayaBackButton(onPop: _onPop),
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.edit_community.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 18).r,
                child: GetBuilder<EditCommunityController>(
                  autoRemove: false,
                  tag: widget.communityId,
                  builder: (communityEditingController) {
                    return GestureDetector(
                      onTap: () async {
                        // Invoking method to log edit community event to analytics
                        _logEditCommunityToAnalytics(communityEditingController);

                        await communityEditingController.updateCommunity(
                          context,
                          description: _descriptionController.text,
                          name: _nameController.text,
                          selectedThemeColor: communitySelectedColorString,
                          communityType: communitySelectedTypeString,
                          community: communityProfileController.communityModel!,
                        );
                      },
                      child: communityEditingController.isLoading
                          ? const CircularProgressIndicator(
                              color: kprimaryColor,
                              backgroundColor: blueColor,
                            )
                          : Text(
                              GayaStrings.save_txt.tr,
                              style: const TextStyle(
                                color: kprimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8).r,
          child: SingleChildScrollView(
            child: GetBuilder<EditCommunityController>(
              init: editCommunityController,
              autoRemove: false,
              tag: widget.communityId,
              builder: (communityEditCtrl) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditCommunityItem(
                      controller: _nameController,
                      title: GayaStrings.name_txt.tr,
                      subtitle: GayaStrings.edit_name_community.tr,
                      maxLength: 30,
                      validator: FormValidation.validateCommunityName,
                    ),
                    vertical12Gap,
                    // community description

                    EditCommunityItem(
                      controller: _descriptionController,
                      title: GayaStrings.description_txt.tr,
                      subtitle: GayaStrings.describe_community_2.tr,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      minLines: 2,
                    ),
                    vertical16Gap,
                    Text(
                      GayaStrings.change_theme.tr,
                      style: GayaTypography.titleMedium.copyWith(height: 1.18),
                    ),
                    vertical12Gap,
                    // colors list view.
                    CommunityThemeHorizontalListView(
                      selectedHexColor: communitySelectedColorString,
                      onColorSelected: (selectedColor) {
                        communitySelectedColorString = selectedColor;
                      },
                    ),
                    vertical16Gap,
                    Text(
                      GayaStrings.community_type.tr,
                      style: GayaTypography.titleMedium.copyWith(height: 1.18),
                    ),
                    vertical12Gap,

                    StatefulBuilder(
                      builder: (context, updateState) {
                        return GestureDetector(
                          onTap: () {
                            Methods.showCircularModalSheet(
                              context,
                              CommunityTypePopup(
                                onCancel: null,
                                onDone: (selectedType) {
                                  communitySelectedTypeString =
                                      selectedType == communityType.Public ? communityType.Public.name : communityType.Private.name;
                                  updateState(() {});
                                },
                                type: _getCommunityType(communitySelectedTypeString),
                              ),
                            );
                          },
                          child: Container(
                            width: 124.r,
                            padding: const EdgeInsets.all(8).r,
                            decoration: BoxDecoration(
                              color: kBaseGrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: CommunityTypeWidget(
                              iconSize: 16.7.r,
                              communityType: communitySelectedTypeString,
                              community: communityProfileController.communityModel!,
                              textStyle: GayaTypography.titleMedium,
                              trailingIcon: Container(
                                width: 18.r,
                                height: 18.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kBlackColor),
                                ),
                                child: Icon(Icons.keyboard_arrow_down_outlined, size: 16.7.r),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    vertical16Gap,
                    // community cover photo
                    TitleAndSubtitle(
                      title: GayaStrings.edit_cover_pic.tr,
                      subtitle: GayaStrings.add_cover_pic_show_people.tr,
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 120.h,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          communityEditCtrl.coverPhoto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    decoration: const BoxDecoration(shape: BoxShape.rectangle),
                                    child: Image.file(
                                      File(communityEditCtrl.coverPhoto!.path),
                                      fit: BoxFit.fill,
                                      height: double.infinity,
                                      width: double.infinity,
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(6).r,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: PostImageWidget(
                                      url: communityEditCtrl.createCommunityModel?.coverPicture,
                                      width: double.infinity,
                                      fit: BoxFit.fill,
                                      height: 120.h,
                                    ),
                                  ),
                                ),
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: ButtonWidget(
                              icon: SvgIconWidget.imageOutline(),
                              onTap: () async => await communityEditCtrl.pickImageFromGallery(
                                context: context,
                                photoType: PhotoType.cover,
                              ),
                              buttonColor: borderColor.withOpacity(0.8),
                              color: kSecondaryColor.withOpacity(0.6),
                              title: GayaStrings.edit_cover_pic.tr,
                              style: CustomTypography.secondaryFontStyleBig,
                            ),
                          )
                        ],
                      ),
                    ),
                    vertical16Gap,
                    TitleAndSubtitle(
                      title: GayaStrings.profile_pic.tr,
                      subtitle: GayaStrings.add_profile_pic_show_community.tr,
                    ),

                    vertical16Gap,
                    Center(
                      child: SizedBox(
                        height: 90.h,
                        width: 90.h,
                        child: communityEditCtrl.profilePhoto != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(120).r,
                                child: SizedBox(
                                  height: 90.h,
                                  width: 90.h,
                                  child: PostImageWidget(
                                    url: communityEditCtrl.profilePhoto!.path,
                                    isHttpsImage: false,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : ProfileImageWidget(
                                url: communityEditCtrl.createCommunityModel?.CommunityPic,
                                fit: BoxFit.fill,
                                maxDiskCacheHeight: 300,
                                maxDiskCacheWidth: 300,
                              ),
                      ),
                    ),
                    vertical16Gap,
                    SafeArea(
                      child: ButtonWidget(
                        icon: SvgIconWidget.imageOutline(),
                        onTap: () async {
                          await communityEditCtrl.pickImageFromGallery(
                            context: context,
                            photoType: PhotoType.profile,
                          );
                        },
                        buttonColor: borderColor.withOpacity(0.4),
                        color: kSecondaryColor.withOpacity(0.6),
                        height: 40.h,
                        title: GayaStrings.edit_profile_pic.tr,
                        style: CustomTypography.secondaryFontStyleBig,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Invoke to log edit community analytics event
  void _logEditCommunityToAnalytics(EditCommunityController communityEditingController) {
    bool isNameUpdated = false;
    // If community name updated
    if (editCommunityController.createCommunityModel?.communityName != _nameController.text) {
      isNameUpdated = true;
    }

    bool isBioUpdated = false;
    // If community bio updated
    if (editCommunityController.createCommunityModel?.communityDescription != _descriptionController.text) {
      isBioUpdated = true;
    }

    bool isTypeUpdated = false;
    // If community type updated
    if (editCommunityController.createCommunityModel?.type != communitySelectedTypeString) {
      isTypeUpdated = true;
    }

    bool isThemeUpdated = false;
    // If community theme updated
    if (editCommunityController.createCommunityModel?.communityThemeModel?.color != communitySelectedColorString) {
      isThemeUpdated = true;
    }

    bool isProfilePicUpdated = false;
    // If community profile pic updated
    if (communityEditingController.profilePhoto != null) {
      isProfilePicUpdated = true;
    }

    bool isCoverPhotoUpdated = false;
    // If community cover photo updated
    if (communityEditingController.coverPhoto != null) {
      isCoverPhotoUpdated = true;
    }

    // Logging edit community analytics event
    AnalyticsController.to.instance.logEditCommunity(
      communityId: widget.communityId,
      userId: UserModel.to.uId ?? '',
      isBioChanged: isBioUpdated,
      isCoverPictureChanged: isCoverPhotoUpdated,
      isNameChanged: isNameUpdated,
      isProfilePictureChanged: isProfilePicUpdated,
      isThemeChanged: isThemeUpdated,
      isTypeChanged: isTypeUpdated,
    );
  }
}
