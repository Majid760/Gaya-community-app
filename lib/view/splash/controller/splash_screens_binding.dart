import 'package:gaya/view/splash/controller/interest_search_controller.dart';
import 'package:get/get.dart';

class SplashScreenBindings extends Bindings {
  SplashScreenBindings();

  @override
  void dependencies() {
    Get.lazyPut(() => InterestController(), fenix: true);
  }
}
