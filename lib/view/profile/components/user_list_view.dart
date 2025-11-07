import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/controller/homepage.controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserListTileView extends StatelessWidget {
  const UserListTileView({Key? key, required this.userModel, this.tapOnViewProfile, this.tapOnTile}) : super(key: key);
  final UserModel userModel;
  final VoidCallback? tapOnViewProfile;
  final VoidCallback? tapOnTile;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: tapOnTile,
      contentPadding: EdgeInsets.zero,
      leading: (userModel.profilePicture == '' || userModel.profilePicture == null)
          ? const CircleAvatar(backgroundColor: kBaseGrey, backgroundImage: AssetImage('Assets/images/user.png'))
          : CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 20,
              child: ProfileImageWidget(url: userModel.profilePicture, size: const Size(50, 50))),
      title: Text(
        userModel.name.toString(),
        maxLines: 2,
        style: CustomTypography.body4StyleLowWeight,
        textDirection: context.read<HomePageController>().isRTL(userModel.name.toString()) ? TextDirection.rtl : TextDirection.ltr,
      ),
      trailing: GayaButton(
          textStyle: GayaTypography.caption2.copyWith(height: 1),
          height: 30.h,
          width: MediaQuery.sizeOf(context).width * 0.25,
          primaryColor: kBaseGrey,
          title: GayaStrings.view_profile.tr,
          borderColor: kTransparentColor,
          onPressed: tapOnViewProfile),
    );
  }
}
