import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart' show ScreenshotController;
import 'package:social_share/social_share.dart';

import '../../../controller/firebase_analytics_controller.dart';
import '../../../controller/gaya_shared_controller.dart';
import '../../../model/community.model.dart';
import '../../../model/create.post.model.dart';
import '../../../model/user.model.dart';
import '../../../shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import '../../../shared/service/dynamic_link_service/model/gaya_social_tag.dart';
import '../../../shared/service/dynamic_link_service/utils/dynamic_link_utils.dart';
import '../../../shared/view/widget/gaya_snackbar.dart';
import '../../../utils/asset_video.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/logger.dart';
import '../models/community_insta_share.dart';
import '../models/insta_share.dart';
import '../models/post_insta_share.dart';

class InstagramStoryShareController extends GetxController {
  /// static getter to get instance of InstagramStoryShareController
  static InstagramStoryShareController get instance => Get.find();

  /* -------------------------------------------------------------------------- */
  /*                               STATE VARIABLES                              */
  /* -------------------------------------------------------------------------- */

  /// instance of ScreenshotController for taking ss of widgets
  ScreenshotController screenshotController = ScreenshotController();

  /// instance of InstaShare to share to insta
  InstaShare? instaShare;

  /// invoke to share post/community to instagram story
  Future<void> sharePostOrCommunity() async {
    try {
      // loading video from assets for BG
      ByteData videoByteData = await rootBundle.load(
        VideoAssetsUtils.instaStoryBg,
      );
      // creating bg vide file from [videoByteData]
      File videoFile = await File('${(await getTemporaryDirectory()).path}/bg.mp4').writeAsBytes(
        videoByteData.buffer.asUint8List(
          videoByteData.offsetInBytes,
          videoByteData.lengthInBytes,
        ),
      );

      // getting screen shot image bytes from ssController
      Uint8List? imageBytesList = await screenshotController.capture();
      // creating ss image file
      File ssFile = File('${(await getTemporaryDirectory()).path}/ss.png');
      ssFile.writeAsBytesSync(imageBytesList!);

      // sharing post data to instagram story
      SocialShare.shareInstagramStory(
        appId: '939959917386507',
        imagePath: ssFile.path,
        attributionURL: 'https://gayaapp.page.link',
        backgroundResourcePath: videoFile.path,
      );

      // Logging share event
      AnalyticsController.to.instance.logShare(
        contentType: instaShare is CommunityInstaShare ? 'community' : 'post',
        itemId: instaShare is CommunityInstaShare
            ? (instaShare as CommunityInstaShare).community?.communityId ?? ''
            : (instaShare as PostInstaShare).post?.postid ?? '',
        userId: UserModel.to.uId ?? '',
        platform: 'instagram_story',
      );

      // Logging using special feature analytics event
      AnalyticsController.to.instance.logSpecialFeatureUsage(
        userId: UserModel.to.uId ?? '',
        featureName: 'instagram_story_share',
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                HELPER API'S                                */
  /* -------------------------------------------------------------------------- */
  /// invoke to get post or community dynamic link using [post] or [community]
  Future<String?> getPostOrCommunityDynamicLink({
    Post? post,
    Community? community,
  }) async {
    String queryParam = "";
    GayaSocialTag? tag;
    late DynamicLinkType type;

    if (post != null) {
      queryParam = post.queryParams;
      tag = DynamicLinkUtils.generateTagPost(post: post);
      type = DynamicLinkType.shareCommunityPost;
    } else if (community != null) {
      queryParam = community.queryParams;
      tag = DynamicLinkUtils.generateTagCommunity(community: community);
      type = DynamicLinkType.communityInvite;
    }
    final shareAbleLink = await GayaSharedController.to.createAShareableLink(
      queryParam: queryParam,
      tag: tag,
      type: type,
    );

    return shareAbleLink;
  }

  /// invoke to copy [url] to clipboard
  Future<void> copyLinkToClipboard(String? url) async {
    if (url == null) {
      // Todo: add translation
      GayaSnackBar.show(
        context: Get.context!,
        type: GayaSnackBarType.error,
        text: 'Something went wrong',
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    MyLoggerServices.to.print("Shareable link is $url");

    GayaSnackBar.show(
      context: Get.context!,
      type: GayaSnackBarType.link,
      text: GayaStrings.copied_to_clipboard.tr,
    );
  }
}
