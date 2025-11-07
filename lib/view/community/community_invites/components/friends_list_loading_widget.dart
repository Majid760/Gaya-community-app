import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

class FriendListLoadingWidget extends StatelessWidget {
  const FriendListLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
        // SvgPicture.asset(
        //   'Assets/icons/ios_loading.svg',
        //   height: 32,
        //   width: 32,
        //   color: kprimaryColor,
        // ),
        CupertinoActivityIndicator(
          radius: 18.r,
          color: kprimaryColor,
        ),
        const SizedBox(
          height: distance_16,
        ),
        Text(
          GayaStrings.getting_contacts.tr,
          style: CustomTypography.body2EnableStyle1.copyWith(color: kSecondaryColor),
        ),
      ]),
    );
  }
}
