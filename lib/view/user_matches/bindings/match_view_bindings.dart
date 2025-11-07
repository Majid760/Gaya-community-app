import 'package:gaya/view/user_matches/controllers/match_controller.dart';
import 'package:get/get.dart' show Bindings, Get, Inst;

class MatchViewBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchViewController>(() => MatchViewController());
  }
}
