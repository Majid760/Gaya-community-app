import 'package:flutter/cupertino.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import 'package:gaya/shared/service/dynamic_link_service/model/gaya_social_tag.dart';
import 'package:gaya/shared/service/dynamic_link_service/services/dynamic_link_services.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

import '../shared/service/dynamic_link_service/utils/dynamic_link_utils.dart';
import '../shared/service/service/version_platform_services.dart';
import '../shared/view/widget/gaya_snackbar.dart';

class GayaSharedController extends GetxService {
  final VersionPlatformServices versionPlatform;
  GayaSharedController({required this.versionPlatform});



  static GayaSharedController get to => Get.find();
  DynamicLinkServices? _dynamicLinkServices;

  /// * Create a shareable link with query params and tag as DynamicLink
  Future<String?> createAShareableLink({required String queryParam, required GayaSocialTag? tag, required DynamicLinkType type}) async {


      return await _dynamicLinkServices?.createDynamicLink(queryParam, tag: tag,  );

  }

  Future<String?> createAShareableProfileLink({required UserModel user}) async {

    return await _dynamicLinkServices?.createDynamicLink(
      user.queryParams,
      tag: GayaSocialTag(
        title: user.name,
        description: user.bio,
        pictureURL: user.profilePicture,
      ),
    );
  }

  Future<String?> createAShareablePostLink({required Post post, required BuildContext ctx}) async {
    try {

      /// generate social tag
      GayaSocialTag? tag = DynamicLinkUtils.generateTagPost(post: post);
      return await _dynamicLinkServices?.createDynamicLink(post.queryParams, tag: tag,  );
    } catch (_) {
      GayaSnackBar.show(context: ctx, type: GayaSnackBarType.error, text: GayaStrings.cannot_share_post.tr);
    }
    return null;
  }

  Future<String?> createAShareableCommunityLink({required Community community}) async {

    GayaSocialTag? tag = DynamicLinkUtils.generateTagCommunity(community: community);
    return await _dynamicLinkServices?.createDynamicLink(community.queryParams, tag: tag );
  }

  // Private methods

  // Dependency injection for dynamic link
  Future<void> initDynamicLinks() async {
    PackageInfo? packageInfo = await versionPlatform.getPlatformInfo();
    if (packageInfo == null) return;

    _dynamicLinkServices = DynamicLinkServices.init(packageInfo: packageInfo);
    _dynamicLinkServices?.initDynamicLinks(Get.context!);
  }
}
