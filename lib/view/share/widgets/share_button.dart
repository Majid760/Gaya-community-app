import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/button.component.dart';
import '../../../utils/const.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/textstyles.dart';
import '../controllers/instagram_story_share_controller.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      /* ------------------------------ share button ------------------------------ */
      child: buttonIcon(
        height: 40.h,
        borderColor: kTransparentColor,
        primaryColor: kBaseGrey,
        title: GayaStrings.share_txt.tr,
        iconString: "",
        icon: CupertinoIcons.arrow_turn_up_right,
        textStyle: CustomTypography.dark12,
        onPressed: () {
          InstagramStoryShareController.instance.sharePostOrCommunity();
        },
      ),
    );
  }
}
