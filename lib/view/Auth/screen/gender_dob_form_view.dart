import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/gaya_alert_dialogs.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/service/shared_service.dart';
import 'package:gaya/shared/view/widget/gaya_cupertino_datetime_modal_view.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/Auth/service/authentication_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../shared/view/widget/gaya_back_button.dart';
import '../../../utils/theme/app_colors.dart';

class DateAndGenderFormView extends StatefulWidget {
  const DateAndGenderFormView({Key? key, this.email}) : super(key: key);
  final String? email;
  @override
  State<DateAndGenderFormView> createState() => _DateAndGenderFormViewState();
}

class _DateAndGenderFormViewState extends State<DateAndGenderFormView> {
  late DateTime _chosenDateTime;
  final TextEditingController _dateController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  final GlobalKey<FormState> _dobGnderformKey = GlobalKey<FormState>();
  FormValidation formValidation = FormValidation();
  bool isEnteredAgeValid = true;

  @override
  void initState() {
    super.initState();
    DateTime currentDate = DateTime.now();
    _chosenDateTime = DateTime(currentDate.year - 13, currentDate.month, currentDate.day);
    _dateController.text = DateFormat('MMM d, yyyy').format(_chosenDateTime);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      gayaCupertinoDateTimeModal(context, _dateController, onDateTimeChanged: (dateTime) {
        SharedService.isEnteredAgeValid(dateTime, 13)
            ? setState(() {
                _chosenDateTime = dateTime;
                isEnteredAgeValid = true;
              })
            : setState(() {
                _chosenDateTime = dateTime;
                isEnteredAgeValid = false;
              });
        _dateController.text = DateFormat('MMM d, yyyy').format(_chosenDateTime);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    myFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: const IconThemeData(color: kBlackColor),
          shape: const Border(bottom: BorderSide(color: kBaseGrey)),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          title: Text(GayaStrings.sign_up.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0),
      body: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 50.h),
        child: Form(
          key: _dobGnderformKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(Assets.assets.images.birthdayCake),
                ),
                // dob work
                const SizedBox(height: distance_20),
                Center(
                  child: Text(
                    GayaStrings.dob.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.63.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: GayaFontTheme.primaryFont,
                    ),
                  ),
                ),
                const SizedBox(height: distance_20),
                InkWell(
                  onTap: () {
                    DateTime currentDate = DateTime.now();
                    setState(() {
                      _chosenDateTime = DateTime(currentDate.year - 13, currentDate.month, currentDate.day);
                      _dateController.text = DateFormat('MMM d, yyyy').format(_chosenDateTime);
                      isEnteredAgeValid = true;
                    });
                    gayaCupertinoDateTimeModal(context, _dateController, onDateTimeChanged: (dateTime) {
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
                          isEnabled: false,
                          focusNode: myFocusNode,
                          controller: _dateController,
                          autoFocus: true,
                          maxlines: 1,
                          borderColor: myFocusNode.hasFocus ? kprimaryColor : borderColor,
                          isPassword: false,
                          autovalidateModel: AutovalidateMode.onUserInteraction,
                          inputType: TextInputType.datetime,
                          validation: formValidation.verifyDob,
                          onChanged: (value) {},
                          hintText: DateFormat('MMM d, yyyy').format(_chosenDateTime))),
                ),
                (!isEnteredAgeValid)
                    ? Column(
                        children: [
                          const SizedBox(height: distance_3),
                          Text(GayaStrings.valid_dob.tr,
                              style: TextStyle(
                                  fontSize: 14.sp, fontFamily: GayaFontTheme.primaryFont, fontWeight: FontWeight.w400, color: Colors.red)),
                        ],
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: distance_15),
                GayaButton(
                  height: 50.h,
                  borderColor: kTransparentColor,
                  // textStyle: loginController.styleEmail,
                  textStyle: CustomTypography.body2EnableStyle,
                  title: GayaStrings.next_txt.tr,
                  onPressed: () async {
                    myFocusNode.unfocus();
                    if (isEnteredAgeValid == false) {
                      return GayaAlertDialogs.showAlertPopNotEligibleDOB(ctx: context);
                    }
                    if (isEnteredAgeValid && _dobGnderformKey.currentState!.validate() && widget.email != null) {
                      Routes.birthDayScreen(dob: _chosenDateTime, email: widget.email);
                    } else {
                      final authService = AuthenticationServices();
                      Map<String, dynamic> updatedData = {"dob": _chosenDateTime};
                      if (authService.authUser != null) {
                        await authService.updateUser(userId: authService.authUser!.uid, updatedData: updatedData);
                        Routes.switchView();
                      }
                    }
                  },
                  primaryColor: AppColors.primary,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
