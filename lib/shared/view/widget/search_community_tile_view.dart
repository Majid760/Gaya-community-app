// community tile view
import 'package:flutter/material.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

class CommunityTileView extends StatelessWidget {
  const CommunityTileView({Key? key, required this.community, this.onTap}) : super(key: key);
  final Community community;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading:
          CircleAvatar(radius: 24, backgroundColor: kBaseGrey, child: PostImageWidget(url: community.CommunityPic, shape: BoxShape.circle)),
      title: Text(community.communityName ?? '', style: CustomTypography.bodyStyle),
      subtitle: Text(community.communityMembers?.toString() ?? '0${GayaStrings.member_txt.tr}', style: CustomTypography.titleStyleBlack),
      trailing: Container(
        width: 20,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kBlackColor)),
        child: const Icon(Icons.keyboard_arrow_right_outlined, size: 16),
      ),
    );
  }
}
