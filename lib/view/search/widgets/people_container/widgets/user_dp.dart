import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../components/profile_image_widget.dart';
import '../../../../../utils/const.dart';

class UserDp extends StatelessWidget {
  const UserDp({
    super.key,
    required this.profileImage,
  });

  final String profileImage;

  @override
  Widget build(BuildContext context) {
    /* --------------------------- user profile image --------------------------- */
    return CircleAvatar(
      radius: 28.r,
      backgroundColor: Colors.transparent,
      child: ProfileImageWidget(
        url: profileImage,
        onError: CircleAvatar(
          radius: 28.r,
          backgroundImage: const AssetImage('Assets/images/user.png'),
          backgroundColor: kBaseGrey,
        ),
      ),
    );
  }
}
