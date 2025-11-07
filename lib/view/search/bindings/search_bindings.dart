import 'package:get/get.dart' show Bindings, Get, Inst;

import '../../../shared/controller/gaya_search_controllers/feed_search_controller.dart';
import '../controllers/search_controller.dart';

/// getx bindings class for injecting dependencies
class SearchBindings extends Bindings {
  @override
  void dependencies() {
    // injecting GayaSearchController
    Get.lazyPut<GayaSearchController>(() => GayaSearchController());

    /// Suggestion Builder
    Get.lazyPut<FeedSearchController>(() => FeedSearchController());
  }
}
