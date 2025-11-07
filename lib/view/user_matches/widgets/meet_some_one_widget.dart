import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../routing/getx_route_methods.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/theme/app_typography.dart';

class MeetSomeOneWidget extends StatelessWidget {
  const MeetSomeOneWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Routes.gotoUserMatchesView();
      },
      child: Column(
        children: [
          Image.asset("Assets/images/user_match.png",width: 93.w,height: 62.h,),

          Container(
              alignment: Alignment.center,
              width: 60.w,
              height: 30.h,
              child: Text(GayaStrings.meet_someone.tr,textAlign: TextAlign.center,style: GayaTypography.caption,))

        ],
      ),
    );
  }
}
