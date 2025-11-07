import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:get/get.dart';

import '../model/community.model.dart';

class CacheController extends GetxService with UserProfilesCacheImpl {
  static CacheController get to => Get.find();
}

/// cache for user profiles
mixin UserProfilesCacheImpl {
  List<UserModel> userProfiles = [];

  void addUser(UserModel? user) {
    if (user == null || user.name == null) return;

    /// store only 100 users in cache
    if (userProfiles.length > 100) userProfiles.removeAt(0);
    userProfiles.add(user);
  }

  UserModel? getUserProfileById(String uid) {
    // return null;
    return userProfiles.firstWhereOrNull((user) => user.uId == uid && user.name != null);
  }

  void disposeProfiles() {
    userProfiles.clear();
  }

  /// currently updates only userTotalCrowns and userDailyCrowns
  void updateUser(UserModel user, {bool addIfNotExist = false}) {
    final index = userProfiles.indexWhere((element) => element.uId == user.uId);
    if (index != -1) {
      userProfiles[index] = userProfiles[index].copyWith(userTotalCrowns: user.userTotalCrowns, userDailyCrowns: user.userDailyCrowns);
    }
    if (addIfNotExist) {
      addUser(user);
    }
  }

  Community? getCommunityById(String communityId) {
    Community? community = AppConfigurationController.to.getCommunityObjectById(communityId: communityId);
    if (community != null) {
      return community;
    }
    return null;
  }
}
