import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/controller/profile.controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/service/shared_service.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_cupertino_datetime_modal_view.dart';
import 'package:gaya/shared/view/widget/gaya_photo_picking_bottom_sheet.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
// import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/gaya_alert_dialogs.dart';
import '../../../components/gradient_text_widget.dart';

class AskNameFieldView extends StatefulWidget {
  final bool fromPhoneProvider;

  const AskNameFieldView({Key? key, this.fromPhoneProvider = false}) : super(key: key);

  @override
  State<AskNameFieldView> createState() => _AskNameFieldViewState();
}

class _AskNameFieldViewState extends State<AskNameFieldView> {
  final int emailText = 1;

  // for registration
  late DateTime subtractedDate;
  final askNameDobGender = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(text: UserModel.to.name);
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  UserModel userModel = UserModel.to;
  final validation = FormValidation();
  bool isEnteredAgeValid = true;
  String? gender;

  // for dob and gender
  DateTime? _chosenDateTime;
  FocusNode myFocusNode = FocusNode();
  FormValidation formValidation = FormValidation();
  String phoneCode = '+972';

  @override
  void initState() {
    super.initState();
    subtractedDate = DateTime.now().subtract(const Duration(days: 13 * 365));
    gender = userModel.gender ?? 'male';
    _dateController.text = DateFormat('MMM d, yyyy').format(UserModel.to.dob ?? subtractedDate);
    _chosenDateTime = userModel.dob ?? subtractedDate;
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   gayaCupertinoDateTimeModal(context, _dateController, backgroundColor: kWhiteColor, onDateTimeChanged: (dateTime) {
    //     SharedService.isEnteredAgeValid(dateTime, 13)
    //         ? setState(() {
    //             _chosenDateTime = dateTime;
    //             isEnteredAgeValid = true;
    //           })
    //         : setState(() {
    //             _chosenDateTime = dateTime;
    //             isEnteredAgeValid = false;
    //           });
    //     _dateController.text = DateFormat('MMM d, yyyy').format(dateTime);
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final validation = FormValidation();
    final profileController = Provider.of<ProfileController>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        if (FirebaseAuth.instance.currentUser?.displayName == null || FirebaseAuth.instance.currentUser?.displayName == '') {
          FirebaseAuth.instance.signOut();
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            iconTheme: const IconThemeData(color: kBlackColor),
            shape: const Border(bottom: BorderSide(color: kBaseGrey)),
            automaticallyImplyLeading: false,
            title: Text(GayaStrings.completing_account.tr, style: CustomTypography.bodyStyle),
            centerTitle: true,
            backgroundColor: kTransparentColor,
            elevation: 0),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: distance_20),
            child: Form(
              key: askNameDobGender,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: distance_20),
                  // ProfilePicWidget(),
                  Center(
                    child: Consumer<ProfileController>(
                      builder: (context, provider, __) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 90,
                              width: 120,
                              child: Stack(children: [
                                ProfileImageWidget(url: UserModel.to.profilePicture, maxDiskCacheHeight: 300, maxDiskCacheWidth: 300),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: InkWell(
                                    onTap: () async => gayaPhotoPickerBottomSheet(context,
                                        onCameraPressed: () async => [
                                              Navigator.pop(context),
                                              await profileController.pickImageFromCamera(
                                                  context: context, imageQuality: 50, isUploadAuto: true)
                                            ],
                                        onGalleryPressed: () async => [
                                              Navigator.pop(context),
                                              await profileController.pickImageFromGallery(context: context, imageQuality: 50)
                                            ]),
                                    child: const CircleAvatar(radius: 12, child: Icon(Icons.camera_alt_outlined, size: 12)),
                                  ),
                                )
                              ]),
                            ),
                            const SizedBox(height: distance_20),
                            profileController.percentage == null
                                ? const SizedBox()
                                : Center(
                                    child: SizedBox(
                                      width: 100,
                                      child: LinearProgressIndicator(value: provider.percentage, minHeight: 3.0, color: kprimaryColor),
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: distance_20),
                  Text(GayaStrings.enter_name.tr, style: CustomTypography.body1Style),
                  const SizedBox(height: distance_20),
                  Text(GayaStrings.full_name.tr, style: CustomTypography.secondaryFontStyle),
                  const SizedBox(height: distance_10),
                  textField(
                      textCapitalization: TextCapitalization.words,
                      controller: nameController,
                      maxlines: 1,
                      borderColor: borderColor,
                      isPassword: false,
                      autovalidateModel: AutovalidateMode.onUserInteraction,
                      inputType: TextInputType.name,
                      // validation: validation.fullNameValidator,
                      validation: (value) {
                        if (value == null) {
                          return GayaStrings.please_enter_name.tr;
                        } else if (value.trim().isEmpty) {
                          return GayaStrings.please_enter_valid_name.tr;
                        } else if ((value.trim().toLowerCase().contains('anonymous'))) {
                          return GayaStrings.please_enter_real_name.tr;
                        } else {
                          return null;
                        }
                      },
                      hintText: GayaStrings.enter_name_hint.tr),
                  if (FirebaseAuth.instance.currentUser?.phoneNumber == null) const SizedBox(height: distance_20),
                  if (FirebaseAuth.instance.currentUser?.phoneNumber == null)
                    Text(GayaStrings.phone_number.tr, style: CustomTypography.secondaryFontStyle),
                  if (FirebaseAuth.instance.currentUser?.phoneNumber == null) const SizedBox(height: distance_10),
                  if (FirebaseAuth.instance.currentUser?.phoneNumber == null)
                    textField(
                        prefixIcon: countryList(context, phoneNumberController),
                        autovalidateModel: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          // if (validation.phoneNumberValidator.isValid(phoneCntrlr.text)) {
                          //   setState(() {
                          //     _isPhoneValid = true;
                          //   });
                          // } else {
                          //   setState(() {
                          //     _isPhoneValid = true;
                          //   });
                          // }
                        },
                        maxlines: 1,
                        borderColor: borderColor,
                        isPassword: false,
                        inputType: TextInputType.phone,
                        // suffixIcon: logInCtrl.isPhoneNumberValid ? const SizedBox() : const Icon(Icons.error_sharp, color: kRedColor),
                        validation: validation.phoneNumberValidator,
                        //     (value) {
                        //   final isvalid = validation.phoneNumberValidator(value);
                        //   if (isvalid == null) {
                        //     logInCtrl.changePhoneValidation(true);
                        //     return null;
                        //   } else {
                        //     logInCtrl.changePhoneValidation(false);
                        //     return isvalid;
                        //   }
                        // },
                        controller: phoneNumberController,
                        hintText: AuthString.phoneHint.tr),
                  // dob and gender
                  // dob work
                  const SizedBox(height: distance_20),
                  Text(GayaStrings.dob_date.tr, style: CustomTypography.secondaryFontStyle),
                  const SizedBox(height: distance_10),
                  InkWell(
                    onTap: () {
                      gayaCupertinoDateTimeModal(context, _dateController, backgroundColor: kWhiteColor, onDateTimeChanged: (dateTime) {
                        SharedService.isEnteredAgeValid(dateTime, 13)
                            ? setState(() {
                                _chosenDateTime = dateTime;
                                isEnteredAgeValid = true;
                              })
                            : setState(() {
                                _chosenDateTime = dateTime;
                                isEnteredAgeValid = false;
                              });
                        _dateController.text = DateFormat('MMM d, yyyy').format(dateTime);
                      });
                    },
                    child: IgnorePointer(
                        child: textField(
                            focusNode: myFocusNode,
                            controller: _dateController,
                            maxlines: 1,
                            borderColor: myFocusNode.hasFocus ? kprimaryColor : borderColor,
                            isPassword: false,
                            autovalidateModel: AutovalidateMode.onUserInteraction,
                            inputType: TextInputType.datetime,
                            validation: formValidation.verifyDob,
                            // validation: (value) {
                            //   if (value == null || value.toString().trim().isEmpty) {
                            //     return AuthString.enterDOB;
                            //   }
                            // },
                            onChanged: (value) {},
                            hintText: GayaStrings.dob_hint.tr)),
                  ),
                  (!isEnteredAgeValid)
                      ? Column(
                          children: [
                            const SizedBox(height: distance_3),
                            Text(GayaStrings.valid_dob.tr,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400, fontFamily: GayaFontTheme.primaryFont, color: Colors.red)),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: distance_15),
                  Text(GayaStrings.gender.tr, style: CustomTypography.body1Style),
                  SizedBox(
                    height: 40,
                    child: RadioListTile(
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: const Text(AuthString.male,
                          style: TextStyle(fontWeight: FontWeight.w400, fontFamily: GayaFontTheme.primaryFont, fontSize: 16)),
                      contentPadding: EdgeInsets.zero,
                      groupValue: gender,
                      autofocus: true,
                      activeColor: kprimaryColor,
                      value: "male",
                      onChanged: (value) {
                        setState(() {
                          gender = value.toString();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: RadioListTile(
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: const Text(AuthString.female,
                          style: TextStyle(fontWeight: FontWeight.w400, fontFamily: GayaFontTheme.primaryFont, fontSize: 16)),
                      contentPadding: EdgeInsets.zero,
                      groupValue: gender,
                      autofocus: true,
                      activeColor: kprimaryColor,
                      value: "female",
                      onChanged: (value) {
                        setState(() {
                          gender = value.toString();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Theme(
                      data: ThemeData(splashColor: kTransparentColor),
                      child: RadioListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: const Text(AuthString.other,
                            style: TextStyle(fontWeight: FontWeight.w400, fontFamily: GayaFontTheme.primaryFont, fontSize: 16)),
                        contentPadding: EdgeInsets.zero,
                        groupValue: gender,
                        enableFeedback: false,
                        autofocus: true,
                        activeColor: kprimaryColor,
                        value: "other",
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: distance_40),
                  // end of dob and gender
                  GayaButton(
                      height: 50,
                      borderColor: kTransparentColor,
                      // textStyle: loginController.styleEmail,
                      textStyle: isEnteredAgeValid ? CustomTypography.body2EnableStyle : CustomTypography.body2DisableStyle,
                      title: GayaStrings.continue_txt.tr,
                      onPressed: () async {
                        if (isEnteredAgeValid == false) {
                          return GayaAlertDialogs.showAlertPopNotEligibleDOB(ctx: context);
                        }
                        User? user = FirebaseAuth.instance.currentUser;
                        if ((askNameDobGender.currentState!.validate()) && nameController.text.trim().isNotEmpty) {
                          Map<String, dynamic> data = {};
                          final name = nameController.text;
                          data['name'] = name.isBlank == true ? (user?.displayName ?? '') : name;
                          data['dob'] = _chosenDateTime;
                          data['gender'] = gender;
                          if (FirebaseAuth.instance.currentUser?.phoneNumber == null) {
                            data['phoneNumber'] = phoneCode + phoneNumberController.text;
                          }

                          if (widget.fromPhoneProvider) {
                            await Provider.of<LoginController>(context, listen: false).createUserEntryInFirestore(payload: data);
                          } else if (user != null) {
                            await profileController.updateUserData(userData: data, userId: user.uid);
                          }
                          Routes.splash();
                        }
                      },
                      primaryColor: isEnteredAgeValid ? AppColors.primary : AppColors.secondary),
                  const SizedBox(height: distance_20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget countryList(BuildContext context, TextEditingController controller) {
    final registerController = Provider.of<LoginController>(context, listen: true);
    return StatefulBuilder(builder: (context, update) {
      return CountryListPick(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: kTransparentColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.choose_country.tr, style: CustomTypography.bodyStyle),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          actions: [
            TextButton(
                style: GayaButtonStyles.actionRowTextButtonStyle2,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: GradientTextWidget(
                  GayaStrings.done.tr,
                  style: CustomTypography.body2EnableStyle1.copyWith(color: kprimaryColor, fontWeight: FontWeight.bold),
                  gradient: AppColors.textGradient,
                ))
          ],
        ),
        theme: CountryTheme(
            initialSelection: '+972',
            searchHintText: GayaStrings.search_hint.tr,
            isDownIcon: false,
            isShowTitle: false,
            labelColor: kBlackColor),
        initialSelection: '+972',
        onChanged: ((value) => setState(() => phoneCode = value?.dialCode ?? '+972')
            // registerController.phoneCode = value!.dialCode!;
            // update(() {});
            ),
      );
    });
  }
}
