import 'dart:ui';

import 'package:gaya/controller/crowns_controller.dart';
import 'package:get/get.dart';

import '../components/check_for_app_update.dart';
import '../controller/cache_controller.dart';
import '../utils/local.storage.dart';
import '../view/community/community_analytics/controllers/community_analytics_controller.dart';
import '../view/community/community_analytics/services/community_analytics_firestore_service.dart';

class InitializingDependency implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GayaRemoteConfig(), fenix: true);
    Get.lazyPut(() => GetCommunityStorageController(), fenix: true);
    Get.lazyPut(() => GetCommunityUsersStorageController());
    Get.lazyPut(() => CrownsController(), fenix: true);
    Get.lazyPut(() => CacheController(), fenix: true);
    Get.lazyPut(() => GetInterestStorageController(), fenix: true);
    Get.lazyPut(() => CommunityAnalyticsController(), fenix: true);
    Get.lazyPut(() => CommunityAnalyticsFirestoreService(), fenix: true);
  }
}

class LocalizationController extends GetxController implements GetxService {
  static LocalizationController to = Get.find();
  final GetStorageController getStorage;

  LocalizationController({required this.getStorage});

  /// en, he etc.
  void setLanguage({required String languageCode}) async {
    Get.updateLocale(Locale(languageCode));
    await getStorage.box.write("language", languageCode);
  }

  ///toggle between [he/en]
  void toggleLanguage() {
    if (!isHebrew) {
      setLanguage(languageCode: "he");
    } else {
      setLanguage(languageCode: "en");
    }
  }

  bool get isHebrew => Get.locale?.languageCode == "he";

  /// Get the last selected language from the storage, if not exists, get the device language, if not exists, use hebrew
  Locale getLastSelectedLanguageCode() {
    /// If user already chose a language, we will use it instead of the device language (if exists)
    String? languageCode = getStorage.box.read("language");
    if (languageCode == null) {
      /// if the user didn't choose a language yet, we will use the device language, if it's not supported we will use hebrew
      return Get.deviceLocale ?? const Locale("he");
    }

    /// if the user chose a language, we will use it (from the storage)
    return Locale(getStorage.box.read("language") ?? "he");
  }

  /// fallback language
  Locale get fallbackLanguage => const Locale('he', 'IL');
}
