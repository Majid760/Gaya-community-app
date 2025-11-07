import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;
  @override
  void initState() {
    super.initState();
    selectedGender = 'male';
  }

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
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
        padding: EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 15.w),
        child: Column(children: [
          Expanded(
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  GayaStrings.what_gender.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.63.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: GayaFontTheme.primaryFont,
                  ),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: Row(
                    children: [
                      GenderWidget(
                        pathOfImage: Assets.assets.images.maleImg,
                        genderTxt: GayaStrings.male.tr,
                        selected: selectedGender == 'male',
                        onTap: () => selectGender('male'),
                      ),
                      GenderWidget(
                        pathOfImage: Assets.assets.images.nonBinaryImg,
                        genderTxt: GayaStrings.non_binary.tr,
                        selected: selectedGender == 'other',
                        onTap: () => selectGender('other'),
                      ),
                      GenderWidget(
                        pathOfImage: Assets.assets.images.femaleImg,
                        genderTxt: GayaStrings.female.tr,
                        selected: selectedGender == 'female',
                        onTap: () => selectGender('female'),
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),
          GayaButton(
              height: 50.h,
              borderColor: kTransparentColor,
              // textStyle: loginController.styleEmail,
              textStyle: CustomTypography.body2EnableStyle,
              title: GayaStrings.next_txt.tr,
              onPressed: () async {
                Routes.register(dob: widget.data['dob'], email: widget.data['email'], gender: selectedGender);
              },
              primaryColor: kprimaryColor)
        ]),
      ),
    );
  }
}

class GenderWidget extends StatelessWidget {
  const GenderWidget({
    Key? key,
    required this.pathOfImage,
    required this.genderTxt,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  final String pathOfImage;
  final String genderTxt;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Center(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: selected ? kprimaryColor : kBaseGrey, width: 2.0.r),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0.r, horizontal: 10.r),
                  child: SizedBox(height: 80.h, width: 60.w, child: Image.asset(pathOfImage)),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(genderTxt),
          ],
        ),
      ),
    );
  }
}
