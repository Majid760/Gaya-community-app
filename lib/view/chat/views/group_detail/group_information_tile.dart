import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class GroupInformationTile extends StatelessWidget {
  const GroupInformationTile({super.key, required this.icon, required this.title, this.nonetxt});
  final String icon;
  final String title;
  final String? nonetxt;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
      horizontalTitleGap: 0,
      leading: SvgPicture.asset(
        icon,
        color: AppColors.black,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 18.sp),
      ),
      trailing: SizedBox(
        width: 60.w,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          (nonetxt != null)
              ? Text(
                  nonetxt ?? GayaStrings.none_txt.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                )
              : const SizedBox.shrink(),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16.r,
          )
        ]),
      ),
    );
  }
}
