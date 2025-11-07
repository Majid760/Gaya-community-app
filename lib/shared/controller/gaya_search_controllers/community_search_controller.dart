import 'package:gaya/model/community.model.dart';
import 'package:gaya/shared/service/search_service/search_service.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

class CommunitySearchController extends GetxController {
  AlgoliaService algoliaService = AlgoliaService();
  List<Community> communities = [];

  // recent searches
  GetCommunityStorageController getStorage = Get.find<GetCommunityStorageController>();
  List<dynamic> recentSearches = [];
  //
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

  // search communities
  Future<void> searchCommunity(String queryData) async {
    print("searching community with query:=> $queryData");
    try {
      isLoading = true;
      update();
      communities = await algoliaService.getCommunities(queryData);
      isLoading = false;
      update();
    } catch (e) {
      MyLoggerServices.to.print('error throw during search in feed error:=>${e.toString()}');
    }
  }

  void resetSearchFeeds() {
    resetSearchFeedContainers();
    update();
  }

  void resetSearchFeedContainers() {
    communities = [];
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
