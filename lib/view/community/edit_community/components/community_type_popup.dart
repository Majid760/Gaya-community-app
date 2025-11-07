import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/modalsheet_title.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:get/get.dart';

import '../../../../utils/const.dart';
import '../../create_community/components/listtile.row.widget.dart';

class CommunityTypePopup extends StatefulWidget {
  final Function? onCancel;
  final Function(communityType) onDone;
  final communityType type;

  const CommunityTypePopup({Key? key, required this.onCancel, required this.onDone, required this.type}) : super(key: key);

  @override
  State<CommunityTypePopup> createState() => _CommunityTypePopupState();
}

class _CommunityTypePopupState extends State<CommunityTypePopup> {
  late communityType type;

  updateState(Function() fn) {
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    type = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    final gap16 = SizedBox(height: MySpaces.gap4.h);
    return Column(children: [
      // title
      ModalSheetTitle(
          title: GayaStrings.community_type.tr,
          isDoneEnabled: true,
          onDone: () {
            Navigator.pop(context);
            if (type != widget.type) widget.onDone(type);
          },
          onCancel: () {
            Navigator.pop(context);
            widget.onCancel != null ? widget.onCancel!() : null;
          }),
      // public
      ListTileRow(
        onTap: () => updateState(() => type = communityType.Public),
        borderColorcircle: type == communityType.Public ? kTransparentColor : kSecondaryColor.withOpacity(0.5),
        externalColor: type == communityType.Public ? kprimaryColor : kWhiteColor,
        icon: IconsAssetsPathUtils.lockUnlockedOutline,
        internalColor: kWhiteColor,
        subtitle: GayaStrings.all_user_create_post.tr,
        title: GayaStrings.public_txt.tr,
        iconSize: 16.r,
      ),
      gap16,
      // private
      ListTileRow(
        onTap: () => updateState(() => type = communityType.Private),
        borderColorcircle: type == communityType.Private ? kTransparentColor : kSecondaryColor.withOpacity(0.5),
        externalColor: type == communityType.Private ? kprimaryColor : kWhiteColor,
        icon: IconsAssetsPathUtils.lockOutline,
        internalColor: kWhiteColor,
        subtitle: GayaStrings.group_user_create_post.tr,
        title: GayaStrings.private_txt.tr,
        iconSize: 16.r,
      ),
      MySpaces.bottom,
    ]);
  }
}
