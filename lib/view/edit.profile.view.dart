import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/show.topics.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/controller/profile.controller.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/model/topic.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/service/shared_service.dart';
import 'package:gaya/shared/view/widget/gaya_cupertino_datetime_modal_view.dart';
import 'package:gaya/shared/view/widget/gaya_photo_picking_bottom_sheet.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../shared/view/widget/gaya_back_button.dart';
import '../utils/const.dart';
import '../utils/textstyles.dart';
import '../utils/theme/button_styles.dart';
import '../widgets/topic_view_widgets/interest.widget.dart';

class EditProfileView extends StatefulWidget {
  final UserModel userModel;

  const EditProfileView({Key? key, required this.userModel}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  QuerySnapshot? data;
  UserModel? usermodel;
  late TextEditingController dateController;
  FocusNode focusNode = FocusNode();
  DateTime? _chosenDateTime;
  bool isEnteredAgeValid = true;
  FormValidation validation = FormValidation();
  String? gender;
  List<TopicsModel> userSelectedModel = [];
  List<Gender> genders = const [];

  @override
  void initState() {
    genders = SharedService.genderStringList;
    dateController = TextEditingController();
    final profileController = context.read<ProfileController>();
    profileController.nameController.text = widget.userModel.name ?? '';
    profileController.bioController.text = widget.userModel.bio ?? '';
    profileController.dobController.text = widget.userModel.dob != null ? DateFormat.yMMMd().format(widget.userModel.dob!) : '';
    gender = widget.userModel.gender;
    userSelectedModel = widget.userModel.interests ?? [];
    Provider.of<TopicsController>(context, listen: false).selectedList = userSelectedModel;
    profileController.nameController.addListener(() => isInfoChanged());
    profileController.bioController.addListener(() => isInfoChanged());
    profileController.dobController.addListener(() => isInfoChanged());
    profileController.image = null;
    profileController.percentage = null;
    profileController.isLoading = false;

    super.initState();
  }

  bool isSomethingChanged = false;

  void isInfoChanged() {
    if (!isSomethingChanged) {
      isSomethingChanged = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileController>(context, listen: true);
    final topicController = Provider.of<TopicsController>(context, listen: true);

    return Scaffold(
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
            automaticallyImplyLeading: false,
            leading: const GayaBackButton(),
            actions: [
              Consumer<ProfileController>(builder: (context, editValues, _) {
                return TextButton(
                    style: GayaButtonStyles.actionRowTextButtonStyle2,
                    onPressed: !(isSomethingChanged || isEnteredAgeValid)
                        ? null
                        : () async {
                            await editValues.updateUserDetails(context, _chosenDateTime, gender);
                            editValues.image = null;
                            editValues.dobController.clear();
                            Routes.switchView(initialIndex: 4);
                          },
                    child: editValues.isLoading
                        ? const CircularProgressIndicator.adaptive(backgroundColor: kprimaryColor)
                        : Text(
                            GayaStrings.save_txt.tr,
                            style: TextStyle(color: isSomethingChanged ? AppColors.primary : AppColors.secondary),
                          ));
              })
            ],
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(GayaStrings.edit_profile.tr, style: CustomTypography.bodyStyle),
            centerTitle: true,
            backgroundColor: kTransparentColor,
            elevation: 0),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: distance_10),
              Center(
                child: profileController.image == null
                    ? CircleAvatar(
                        backgroundColor: kBaseGrey,
                        radius: 58,
                        child: CachedNetworkImage(
                          memCacheHeight: 100,
                          memCacheWidth: 100,
                          imageUrl: widget.userModel.profilePicture ?? '',
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                          ),
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(profileController.image!),
                        onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.error),
                        radius: 58),
              ),
              profileController.percentage == null ? const SizedBox() : const SizedBox(height: distance_10),
              profileController.percentage == null
                  ? const SizedBox()
                  : Center(
                      child: SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(value: profileController.percentage, minHeight: 3.0, color: kprimaryColor)),
                    ),
              const SizedBox(height: distance_10),
              Center(
                  child: TextButton(
                      style: GayaButtonStyles.actionRowTextButtonStyle2,
                      onPressed: () async => gayaPhotoPickerBottomSheet(context,
                          onCameraPressed: () async =>
                              [Navigator.pop(context), await profileController.pickImageFromCamera(context: context, imageQuality: 50)],
                          onGalleryPressed: () async => [Navigator.pop(context), await profileController.imagePicker(context)]),
                      child: Text(GayaStrings.change_profile_photo.tr, style: CustomTypography.body4KStylePrimary))),
              const SizedBox(height: distance_15),
              Divider(color: kSecondaryColor.withOpacity(0.5)),
              const SizedBox(height: distance_15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: distance_20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // name field
                    Text(GayaStrings.name_txt.tr, style: CustomTypography.secondaryFontStyleWeight),
                    const SizedBox(height: distance_5),
                    textField(
                        key: profileController.nameGlobalKey,
                        // onChanged: (value) {
                        //   profileController.nameOnChange(value);
                        // },
                        isPassword: false,
                        inputType: TextInputType.name,
                        hintText: GayaStrings.full_name.tr,
                        controller: profileController.nameController,
                        validation: validation.firstNameValidator,
                        borderColor: borderColor),
                    const SizedBox(height: distance_10),
                    Text(GayaStrings.bio_txt.tr, style: CustomTypography.secondaryFontStyleWeight),
                    const SizedBox(height: distance_5),
                    textField(
                        maxlines: null,
                        onTap: () => Routes.openBioView(),
                        isPassword: false,
                        inputType: TextInputType.name,
                        hintText: GayaStrings.write_bio.tr,
                        controller: profileController.bioController,
                        validation: validation.firstNameValidator,
                        borderColor: borderColor),
                    const SizedBox(height: distance_10),
                    Text(GayaStrings.date_of_birth.tr, style: CustomTypography.secondaryFontStyleWeight),
                    const SizedBox(height: distance_5),
                    InkWell(
                      onTap: () {
                        gayaCupertinoDateTimeModal(context, profileController.dobController, backgroundColor: kWhiteColor,
                            onDateTimeChanged: (dateTime) {
                          SharedService.isEnteredAgeValid(dateTime, 13)
                              ? setState(() {
                                  _chosenDateTime = dateTime;
                                  isEnteredAgeValid = true;
                                  isInfoChanged();
                                })
                              : setState(() {
                                  _chosenDateTime = dateTime;
                                  isEnteredAgeValid = false;
                                });
                          profileController.dobController.text = DateFormat('MMM d, yyyy').format(dateTime);
                        });
                      },
                      child: IgnorePointer(
                          child: textField(
                              focusNode: focusNode,
                              controller: profileController.dobController,
                              // initialValue: _chosenDateTime ?? '',
                              maxlines: 1,
                              borderColor: focusNode.hasFocus ? kprimaryColor : borderColor,
                              isPassword: false,
                              autovalidateModel: AutovalidateMode.onUserInteraction,
                              inputType: TextInputType.datetime,
                              validation: (value) {
                                return null;
                              },
                              onChanged: (value) {},
                              hintText: AuthString.dobHint)),
                    ),
                    (!isEnteredAgeValid)
                        ? const Column(
                            children: [
                              SizedBox(height: distance_3),
                              Text(AuthString.validDOB, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.red)),
                            ],
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: distance_10),
                    Text(GayaStrings.gender.tr, style: CustomTypography.secondaryFontStyleWeight),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                          itemCount: genders.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              trailing: Padding(
                                padding: EdgeInsets.zero,
                                child: Radio<String>(
                                  autofocus: true,
                                  fillColor: MaterialStateColor.resolveWith((states) => kprimaryColor),
                                  value: SharedService.genderString(genders[index]),
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value.toString();
                                      isInfoChanged();
                                    });
                                  },
                                ),
                              ),
                              leading: Text((SharedService.genderString(genders[index]).tr).capitalize!,
                                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                            );
                          }),
                    ),
                    const SizedBox(height: distance_15),
                    Divider(color: kSecondaryColor.withOpacity(0.5)),
                    topicController.selectedList.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: distance_15),
                              Text(GayaStrings.interest_txt.tr, style: CustomTypography.bodyStyle),
                              const SizedBox(height: distance_10),
                              Wrap(
                                alignment: WrapAlignment.start,
                                direction: Axis.horizontal,
                                runAlignment: WrapAlignment.start,
                                runSpacing: distance_10,
                                spacing: distance_10,
                                children: List.generate(topicController.selectedList.length, (index) {
                                  return InterestWidget(
                                    color: kBaseGrey,
                                    horizontalDistance: distance_40,
                                    image: topicController.selectedList[index].image,
                                    title: topicController.selectedList[index].title,
                                    onTap: () {
                                      isInfoChanged();
                                      TopicsModel interestsModel = TopicsModel(
                                        image: topicController.selectedList[index].image,
                                        title: topicController.selectedList[index].title,
                                        isSeleted: false,
                                      );
                                      usermodel = UserModel(interests: [interestsModel]);
                                    },
                                  );
                                }),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: distance_15),
                    GestureDetector(
                      onTap: () {
                        showTopic1(context, () {
                          isInfoChanged();
                          Navigator.of(context).pop();
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: distance_15, vertical: distance_10),
                          decoration: BoxDecoration(color: kBaseGrey, borderRadius: BorderRadius.circular(borderRadius_4)),
                          child: Text(
                              topicController.selectedList.isNotEmpty ? GayaStrings.change_interests.tr : GayaStrings.add_interests.tr,
                              style: CustomTypography.secondaryFontStyleBig)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: distance_20),
            ],
          ),
        ));
  }
}
