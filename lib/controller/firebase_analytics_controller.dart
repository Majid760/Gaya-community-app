import 'package:flutter/cupertino.dart';
import 'package:gaya/shared/service/engagement_score_services/engagement_helpers/engagement_utils.dart';
import 'package:get/get.dart';

import '../shared/service/engagement_score_services/engagement_score_services.dart';
import '../shared/service/firebase_analytics_services.dart';
import '../shared/service/firebase_crashlytics_services.dart';
import '../shared/service/firebase_performance_services.dart';
import '../utils/logger.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// A Service class for all Firebase services + a controller for each service
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// A controller for [FirebaseAnalyticsService]
class AnalyticsController extends GetxService {
  static AnalyticsController get to => Get.find();
  final FirebaseAnalyticsService _instance = FirebaseAnalyticsService();

  FirebaseAnalyticsService get instance => _instance;
}

/// A controller for [PerformanceServices]
class PerformanceController extends GetxService {
  static PerformanceController get to => Get.find();

  final PerformanceServices _instance = PerformanceServices();

  PerformanceServices get instance => _instance;
}

/// A controller for [CrashlyticsService]
class CrashlyticsController extends GetxService {
  static CrashlyticsController get to => Get.find();

  final CrashlyticsService _instance = CrashlyticsService();

  CrashlyticsService get instance => _instance;
}

/// A controller for [EngagementScoreServices]
class EngagementScoreController extends GetxService {
  static EngagementScoreController get to => Get.find();

  ScoringValues? scoringValues;

  late EngagementScoreServices _instance;

  @override
  void onInit() {
    super.onInit();
    _instance = EngagementScoreServices(
      logger: MyLoggerServices.to,
      crashlyticsController: CrashlyticsController.to.instance,
      scoringValues: scoringValues ?? ScoringValues.defaultValues(),
    );
  }

  void setScoringValue({ScoringValues? scoringValues}) {
    _instance = EngagementScoreServices(
      logger: MyLoggerServices.to,
      crashlyticsController: CrashlyticsController.to.instance,
      scoringValues: scoringValues ?? ScoringValues.defaultValues(),
    );
  }

  EngagementScoreServices get instance => _instance;
}

/// Contains all the Bindings for firebase product related services
class FirebaseBindings {
  static void init() {
    Get.lazyPut(() => AnalyticsController(), fenix: true);
    Get.lazyPut(() => EngagementScoreController(), fenix: true);
    Get.lazyPut(() => PerformanceController(), fenix: true);
    Get.lazyPut(() => CrashlyticsController(), fenix: true);
  }
}
