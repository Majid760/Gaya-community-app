import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/button.component.dart';
import '../../../model/community.model.dart';
import '../../../model/create.post.model.dart';
import '../../../utils/const.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/textstyles.dart';
import '../controllers/instagram_story_share_controller.dart';

class CopyLinkButton extends StatelessWidget {
  const CopyLinkButton({
    super.key,
    this.post,
    this.community,
  });

  final Post? post;
  final Community? community;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      /* ---------------------------- copy link button ---------------------------- */
      child: buttonIcon(
        height: 40,
        borderColor: kTransparentColor,
        primaryColor: kprimaryColor,
        title: GayaStrings.copy_txt.tr,
        iconString: "Assets/icons/outline.svg",
        icon: null,
        textStyle: CustomTypography.titleStyleWhite,
        onPressed: () async {
          InstagramStoryShareController instagramStoryShareController = InstagramStoryShareController.instance;
          await instagramStoryShareController.copyLinkToClipboard(
            await instagramStoryShareController.getPostOrCommunityDynamicLink(
              post: post,
              community: community,
            ),
          );
        },
      ),
    );
  }
}
