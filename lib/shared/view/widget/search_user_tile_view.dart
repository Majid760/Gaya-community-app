// user tile view
import 'package:flutter/material.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/textstyles.dart';

import '../../../model/user.model.dart';

class UserTileView extends StatelessWidget {
  const UserTileView({Key? key, required this.user, this.onTap}) : super(key: key);
  final UserModel user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: user.profilePicture == '' || user.profilePicture == null
          ? CircleAvatar(radius: 24, backgroundColor: kBaseGrey, backgroundImage: AssetImage(Assets.assets.images.userDefault))
          : CircleAvatar(radius: 24, backgroundColor: kBaseGrey, child: PostImageWidget(url: user.profilePicture, shape: BoxShape.circle)),
      title: Text(user.name ?? '', style: CustomTypography.bodyStyle),
      trailing: Container(
        width: 20,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kBlackColor)),
        child: const Icon(Icons.keyboard_arrow_right_outlined, size: 16),
      ),
    );
  }
}
