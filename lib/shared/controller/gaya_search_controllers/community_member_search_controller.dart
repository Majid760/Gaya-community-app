import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/search_service/search_service.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

class CommunityMemberSearchController extends GetxController {
  AlgoliaService algoliaService = AlgoliaService();
  List<UserModel> communityUsers = [];

  // recent searches
  GetCommunityUsersStorageController getStorage = Get.find<GetCommunityUsersStorageController>();
  List<dynamic> recentSearches = [];
  bool isLoading = false;
  get state => null;

  @override
  void onInit() {
    super.onInit();
    recentSearches = getStorage.getRecentSearchedList() ?? [];
  }

  @override
  void dispose() {
    //clear all comments in case (rare case) if cache left.
    resetSearchFeedContainers();
    super.dispose();
  }

  void resetSearchFeeds() {
    resetSearchFeedContainers();
    update();
  }

  void resetSearchFeedContainers() {
    communityUsers = [];
  }

  // gaya users
  Future<List> searchCommunityMembers(String queryData) async {
    try {
      isLoading = true;
      update();
      communityUsers = await algoliaService.getCommunityMembers(queryData);
      return communityUsers;
      isLoading = false;
      update();
    } catch (e) {
      return [];
    }
  }

  // add to recent search
  void addToRecentSearch(dynamic item) {
    try {
      if (!(recentSearches.contains(item))) {
        recentSearches.insert(0, item);
        getStorage.storeRecentCommunitySearchedList(recentSearches: recentSearches);
      }
      update();
    } catch (e) {
      MyLoggerServices.to.print('error=>${e.toString()}');
    }
  }

  // add to recent search
  void removeFromRecentSearch(int index) {
    try {
      recentSearches.removeAt(index);
      update();
      getStorage.storeRecentCommunitySearchedList(recentSearches: recentSearches);
    } catch (e) {
      MyLoggerServices.to.print('error=>${e.toString()}');
    }
  }

  void removeAllFromRecentSearch() {
    try {
      recentSearches = [];
      update();
      getStorage.storeRecentCommunitySearchedList(recentSearches: recentSearches);
    } catch (e) {
      MyLoggerServices.to.print('error=>${e.toString()}');
    }
  }
}
