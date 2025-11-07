import 'package:flutter/cupertino.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/search_service/search_service.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

class FeedSearchController extends GetxController {
  static FeedSearchController get to => Get.find<FeedSearchController>();
  AlgoliaService algoliaService = AlgoliaService();
  final ScrollController scrollController = ScrollController();
  List<UserModel> users = [];
  List<Community> communities = [];

  // recent searches
  GetStorageController getStorage = Get.find<GetStorageController>();
  List<dynamic> recentSearches = [];

  //
  bool isLoading = false;

  get state => null;

  @override
  void onInit() {
    // algoliaService = AlgoliaService();
    super.onInit();
    recentSearches = getStorage.getRecentSearchedList() ?? [];
  }

  @override
  void dispose() {
    //clear all comments in case (rare case) if cache left.
    resetSearchFeedContainers();
    super.dispose();
  }

  // search feeds
  Future<void> searchFeeds(String queryData) async {
    try {
      List result = [];
      isLoading = true;
      update();
      result = await algoliaService.getFeedsData(queryData);
      users = result.first;
      communities = result.last;
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
    users = [];
    communities = [];
  }

  // add to recent search
  void addToRecentSearch(dynamic item) {
    try {
      if (!(recentSearches.contains(item))) {
        // to show more recent search,inserted it 0 index
        recentSearches.insert(0, item);
        getStorage.storeRecentSearchedList(recentSearches: recentSearches);
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
      getStorage.storeRecentSearchedList(recentSearches: recentSearches);
    } catch (e) {
      MyLoggerServices.to.print('error=>${e.toString()}');
    }
  }

  void removeAllFromRecentSearch() {
    try {
      recentSearches = [];
      update();
      getStorage.storeRecentSearchedList(recentSearches: recentSearches);
    } catch (e) {
      MyLoggerServices.to.print('error=>${e.toString()}');
    }
  }
}

// binding of search screen
class SearchScreensBindings extends Bindings {
  SearchScreensBindings();

  @override
  void dependencies() {
    Get.lazyPut(() => FeedSearchController());
  }
}
