import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:get/get.dart';

import '../../../controller/app_config_controller.dart';
import '../../feed/controller/base/base_feed_impl.dart';

class CommunityProfileController extends BaseController {
  static CommunityProfileController to({required String? tag}) => Get.find(tag: tag);

  static bool isRegistered({required String? tag}) => Get.isRegistered<CommunityProfileController>(tag: tag);
  final String communityId;
  Community? communityModel;

  CommunityProfileController({required this.communityId, this.communityModel});

  late Services _commonService;

  UserModel userModel = UserModel.to;

  bool get isAdmin =>
      communityModel?.adminUid == FirebaseAuth.instance.currentUser?.uid && communityModel?.adminUid != null ||
      AppConfigurationController.to.isSuperAdmin;

  bool get isAdminOrModerator => isAdmin || communityModel?.moderators?.contains(FirebaseAuth.instance.currentUser?.uid) == true;

  @override
  onInit() {
    super.onInit();
    _commonService = Services();
    fetchCommunityProfile();
  }

  void fetchCommunityProfile() async {
    setLoading(true);
    final communityProfile = await _commonService.getCommunityDetailsModel(communityId);
    if (communityProfile != null) {
      communityModel = communityProfile;
    }
    setLoading(false);
  }

  Future<void> reloadCommunityProfile() async => fetchCommunityProfile();

  /// Update the community locally
  /// This is used when the community is updated from the community settings page
  void updateGroupViewCommunity({required Community? community}) {
    if (community == null) return;
    communityModel = community;
    // // update community feed with updated community
    // CommunityFeedController.to._updateAllPostsCommunityLocally(community);
    //update home feed with updated community
    FeedControllerUtils.updateAllOfTheCommunitieslocally(community);
    setLoading(false);
  }

  // get color from hex color
  Color? getColorFromHexaString() {
    Color? color;
    if (communityModel?.communityThemeModel?.color != null) {
      color = getColorFromHex(communityModel?.communityThemeModel?.color ?? 'FFD28AFF');
    }
    return color;
  }

  Community? getPosts() => communityModel;

  // A dispose method.
  void resetController() async {
    communityModel = null;
    setLoading(false, notify: false);
  }
}
